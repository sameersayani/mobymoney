import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/logging/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// GoogleSignIn Instance Provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
  );
});

// Riverpod Notifier for Auth State
final authStateProvider =
    NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    return const AsyncValue.data(null);
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  GoogleSignIn get _googleSignIn => ref.read(googleSignInProvider);

  /// Perform full Google Sign-In -> Backend verification pipeline
  Future<AuthResponseModel?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // 1. Trigger Google native sign-in dialog
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled flow
        state = const AsyncValue.data(null);
        return null;
      }

      // 2. Obtain Google Auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const NetworkException(
          message: 'Unable to retrieve Google ID Token. Please try again.',
        );
      }

      AppLogger.i('Obtained Google ID Token, authenticating with backend...', 'AUTH');

      // 3. Authenticate with backend: POST /api/mobile/auth/google
      final authResponse = await _authRepository.loginWithGoogle(idToken);

      state = AsyncValue.data(authResponse.user);
      return authResponse;
    } on NetworkException catch (e, st) {
      AppLogger.e('Google Sign-In backend verification failed', e, st, 'AUTH');
      state = AsyncValue.error(e.message, st);
      return null;
    } catch (e, st) {
      AppLogger.e('Unexpected Google Sign-In failure', e, st, 'AUTH');
      state = AsyncValue.error('Sign-in failed. Please try again.', st);
      return null;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _googleSignIn.signOut();
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error('Failed to log out.', st);
    }
  }
}
