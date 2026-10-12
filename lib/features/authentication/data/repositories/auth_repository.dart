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

      // Persist the backend JWT access token & user profile in SecureStorage
      await Future.wait([
        _storageService.saveAccessToken(authResponse.accessToken),
        _storageService.saveUserData(authResponse.user.toJson()),
      ]);

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

  /// Register new user account with username, email, and password
  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final dynamic data = response.data;
      String message = 'Registered successfully';
      String token = '';
      UserModel? user;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] is String) {
          message = data['message'] as String;
        }

        if (data.containsKey('access_token')) {
          token = data['access_token']?.toString() ?? '';
        } else if (data.containsKey('token')) {
          token = data['token']?.toString() ?? '';
        }

        if (token.isNotEmpty) {
          await _storageService.saveAccessToken(token);
        }

        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          await _storageService.saveUserData(user.toJson());
        }
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }

      return {
        'message': message,
        'hasToken': token.isNotEmpty,
        'user': user,
      };
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to register: ${e.toString()}');
    }
  }

  /// Authenticate with username and password
  /// POST /api/auth/login
  Future<UserModel> loginWithPassword({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.passwordLogin,
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final dynamic data = response.data;
      String token = '';
      Map<String, dynamic> userMap = {};

      if (data is Map<String, dynamic>) {
        if (data.containsKey('access_token')) {
          token = data['access_token']?.toString() ?? '';
        } else if (data.containsKey('token')) {
          token = data['token']?.toString() ?? '';
        }

        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          userMap = data['user'] as Map<String, dynamic>;
        } else {
          userMap = data;
        }
      } else if (data is String && data.isNotEmpty && !data.startsWith('{')) {
        token = data;
      }

      if (token.isNotEmpty) {
        await _storageService.saveAccessToken(token);
      }

      UserModel user;
      if (userMap.isNotEmpty && (userMap.containsKey('email') || userMap.containsKey('name'))) {
        user = UserModel.fromJson(userMap);
      } else {
        user = UserModel(id: 1, email: username, name: username);
      }

      await _storageService.saveUserData(user.toJson());
      return user;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Login failed: ${e.toString()}');
    }
  }

  /// Verify authenticated session with backend
  /// GET /auth
  Future<String> checkAuth() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.checkAuth);
      return response.data?.toString() ?? 'Authenticated';
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Authentication check failed: ${e.toString()}');
    }
  }

  /// Permanently delete account
  /// DELETE /api/auth/delete-account
  Future<String> deleteAccount({required String password}) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiEndpoints.deleteAccount,
        data: {
          'password': password,
        },
      );
      final dynamic data = response.data;
      String message = 'Account permanently deleted';
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message']?.toString() ?? 'Account permanently deleted';
      } else if (data is String && data.isNotEmpty && !data.startsWith('{')) {
        message = data;
      }
      return message;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  /// Check if user has active session (via JWT token or session cookie)
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      return true;
    }
    final cookie = await _storageService.getCookie();
    final user = await _storageService.getUserData();
    return cookie != null && cookie.isNotEmpty && user != null;
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
