import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only log sanitized method & path (never headers, tokens, or body secrets)
    AppLogger.d('--> ${options.method} ${options.path}', 'API_REQ');

    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d(
      '<-- ${response.statusCode} ${response.requestOptions.path}',
      'API_RES',
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.e(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}',
      null,
      null,
      'API_ERR',
    );

    // Handle 401 Unauthorized centrally
    if (err.response?.statusCode == 401) {
      AppLogger.w('Received 401 Unauthorized. Clearing session.', 'AUTH');
      await _secureStorage.clearAll();
      // App can broadcast or trigger logout redirect state
    }

    return handler.next(err);
  }
}
