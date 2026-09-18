import 'package:dio/dio.dart';
import '../../../../core/errors/network_exception.dart';
import '../../../../core/networking/api_client.dart';
import '../../../../core/networking/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/auth_response_model.dart';

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

      // Persist access token & user profile securely
      await _storageService.saveAccessToken(authResponse.accessToken);
      await _storageService.saveUserData(authResponse.user.toJson());

      return authResponse;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(message: 'Failed to authenticate: ${e.toString()}');
    }
  }

  /// Check if user has active session
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
