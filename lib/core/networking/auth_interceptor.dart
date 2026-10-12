import 'package:dio/dio.dart';
import '../logging/app_logger.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._secureStorage, {this.onUnauthorized});

  final SecureStorageService _secureStorage;
  final void Function()? onUnauthorized;
  static const String _requestStartTimeKey = 'request_start_time';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra[_requestStartTimeKey] = DateTime.now().millisecondsSinceEpoch;

    // Attach Bearer token if stored (only if not a raw JSON object string)
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty && !token.startsWith('{')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Attach session Cookie if stored
    final cookie = await _secureStorage.getCookie();
    if (cookie != null && cookie.isNotEmpty) {
      options.headers['Cookie'] = cookie;
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // Pretty Print Request with masked token, payload, and URL
    AppLogger.logNetworkRequest(
      method: options.method,
      url: options.uri.toString(),
      token: token != null && !token.startsWith('{') ? token : null,
      queryParameters: options.queryParameters,
      data: options.data,
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final startTime = response.requestOptions.extra[_requestStartTimeKey] as int?;
    final durationMs = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    // Capture and save Set-Cookie header if provided by server
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      final cookieString = setCookieHeaders.map((c) => c.split(';').first).join('; ');
      await _secureStorage.saveCookie(cookieString);
    }

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

    // Clear credentials only for session requests (exclude login/register/delete-account where 401 is simply wrong credentials)
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/delete-account') ||
        path.contains('/api/mobile/auth/google');

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      AppLogger.w('Session expired or unauthorized (401). Clearing credentials.', 'AUTH');
      await _secureStorage.clearAll();
      onUnauthorized?.call();
    }

    return handler.next(err);
  }
}

