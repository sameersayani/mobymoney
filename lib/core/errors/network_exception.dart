import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  factory NetworkException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please check your internet and try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final data = dioException.response?.data;
        String errorMessage = 'A server error occurred. Please try again.';

        if (data is Map<String, dynamic>) {
          if (data['detail'] is String) {
            errorMessage = data['detail'];
          } else if (data['message'] is String) {
            errorMessage = data['message'];
          } else if (data['error'] is String) {
            errorMessage = data['error'];
          }
        }

        if (statusCode == 401) {
          errorMessage = 'Authentication failed. Please sign in again.';
        } else if (statusCode == 403) {
          errorMessage = 'Access denied. You do not have permission.';
        } else if (statusCode == 404) {
          errorMessage = 'Requested resource not found.';
        } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
          errorMessage = 'Server error. Our engineers are working on it.';
        }

        return NetworkException(
          message: errorMessage,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Unable to reach the server. Please check your internet connection.',
        );
      default:
        return const NetworkException(
          message: 'An unexpected network error occurred. Please try again.',
        );
    }
  }

  @override
  String toString() => message;
}
