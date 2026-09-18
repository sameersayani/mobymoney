import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;
  static const String _requestStartTimeKey = 'request_start_time';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra[_requestStartTimeKey] = DateTime.now().millisecondsSinceEpoch;

    // Attach Bearer token if stored
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // Pretty Print Request with single-line token, payload, and URL
    AppLogger.logNetworkRequest(
      method: options.method,
      url: options.uri.toString(),
      token: token,
      queryParameters: options.queryParameters,
      data: options.data,
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra[_requestStartTimeKey] as int?;
    final durationMs = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    AppLogger.logNetworkResponse(
      statusCode: response.statusCode,
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      durationMs: durationMs,
      responseData: response.data,
    );

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final startTime = err.requestOptions.extra[_requestStartTimeKey] as int?;
    final durationMs = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    AppLogger.logNetworkError(
      statusCode: err.response?.statusCode,
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      durationMs: durationMs,
      errorMessage: err.message ?? 'Unknown error',
      errorResponse: err.response?.data,
      rawError: err.error,
    );

    if (err.response?.statusCode == 401) {
      AppLogger.w('Session expired or unauthorized (401). Clearing credentials.', 'AUTH');
      await _secureStorage.clearAll();
    }

    return handler.next(err);
  }
}
