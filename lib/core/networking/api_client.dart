import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Automatically retries a request once when a timeout occurs.
/// This handles Render free-tier cold-start latency gracefully.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int _maxRetries = 1;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    final retriesLeft =
        (err.requestOptions.extra['retries'] as int?) ?? _maxRetries;

    if (isTimeout && retriesLeft > 0) {
      err.requestOptions.extra['retries'] = retriesLeft - 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    return handler.next(err);
  }
}

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectTimeout,
        responseType: ResponseType.json,
      ),
    );

    // Auth token injection
    _authInterceptor = AuthInterceptor(
      SecureStorageService.instance,
      onUnauthorized: () => _onUnauthorizedCallback?.call(),
    );
    _dio.interceptors.add(_authInterceptor);
    // Retry once on timeout (helps with Render cold-starts)
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;
  void Function()? _onUnauthorizedCallback;

  void setOnUnauthorized(void Function() callback) {
    _onUnauthorizedCallback = callback;
  }

  Dio get dio => _dio;
}


