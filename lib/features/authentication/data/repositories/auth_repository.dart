import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/auth_response_model.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient.instance,
        _storageService = storageService ?? SecureStorageService.instance;

  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  /// Authenticate with backend using Google ID token
  Future<AuthResponseModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleAuth,
        data: {'id_token': idToken},
      );

      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist the backend API access token & user profile in parallel (non-blocking)
      unawaited(Future.wait([
        _storageService.saveAccessToken(authResponse.accessToken),
        _storageService.saveUserData(authResponse.user.toJson()),
      ]));

      return authResponse;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to authenticate: ${e.toString()}');
    }
  }

  /// Fetch current authenticated user details from GET /api/mobile/auth/me
  Future<UserModel> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.authMe);
      final dynamic data = response.data;
      Map<String, dynamic> userMap = {};

      if (data is Map<String, dynamic>) {
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          userMap = data['user'] as Map<String, dynamic>;
        } else {
          userMap = data;
        }
      }

      final user = UserModel.fromJson(userMap);
      await _storageService.saveUserData(user.toJson());
      return user;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to load user profile: ${e.toString()}');
    }
  }

  /// Retrieve cached user data from secure storage
  Future<UserModel?> getCachedUser() async {
    final map = await _storageService.getUserData();
    if (map != null) {
      return UserModel.fromJson(map);
    }
    return null;
  }

  /// Check if user has active session
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.dio.get(ApiEndpoints.logout);
    } catch (_) {
      // If network fails during logout, still clear local storage safely
    } finally {
      await _storageService.clearAll();
    }
  }
}
