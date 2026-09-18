import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
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
    serverClientId: AppConstants.googleServerClientId,
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
    // Initial state check
    _checkInitialSession();
    return const AsyncValue.loading();
  }

  Future<void> _checkInitialSession() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final cachedUser = await _authRepository.getCachedUser();
        state = AsyncValue.data(cachedUser);

        // Background refresh profile from /api/mobile/auth/me if available
        try {
          final refreshedUser = await _authRepository.getMe();
          state = AsyncValue.data(refreshedUser);
        } catch (_) {
          // If /api/mobile/auth/me is down or unconfigured, cached user remains valid
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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

      // 4. Optionally verify with /api/mobile/auth/me in background
      try {
        final meUser = await _authRepository.getMe();
        state = AsyncValue.data(meUser);
      } catch (e) {
        AppLogger.w('Background /api/mobile/auth/me call skipped/failed: $e', 'AUTH');
      }

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
