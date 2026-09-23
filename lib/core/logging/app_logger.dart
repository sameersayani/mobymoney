import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'talker.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    talker.debug(message, error, stackTrace);
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    talker.info(message, error, stackTrace);
    if (kDebugMode) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    talker.warning(message, error, stackTrace);
    if (kDebugMode) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    talker.error(message, error, stackTrace);
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  // Short aliases for compatibility
  static void d(String message, [String tag = 'DEBUG']) => debug('[$tag] $message');
  static void i(String message, [String tag = 'INFO']) => info('[$tag] $message');
  static void s(String message, [String tag = 'SUCCESS']) => info('✅ [$tag] $message');
  static void w(String message, [String tag = 'WARN']) => warning('[$tag] $message');
  static void e(
    String message, [
    dynamic err,
    StackTrace? stackTrace,
    String tag = 'ERROR',
  ]) =>
      error('[$tag] $message', err, stackTrace);

  static void network(
    String message, {
    String? method,
    String? url,
    Map<String, dynamic>? headers,
    dynamic data,
    int? statusCode,
    String? token,
  }) {
    final buffer = StringBuffer();
    if (method != null) buffer.write('[$method] ');
    buffer.write(message);
    if (url != null) buffer.write(' - $url');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');

    talker.info('NETWORK: ${buffer.toString()}');

    if (kDebugMode) {
      final consoleBuffer = StringBuffer();
      consoleBuffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      consoleBuffer.writeln('🌐 NETWORK: $message');
      if (method != null) consoleBuffer.writeln('Method: $method');
      if (url != null) consoleBuffer.writeln('URL: $url');
      if (statusCode != null) consoleBuffer.writeln('Status: $statusCode');
      if (token != null && token.isNotEmpty) {
        final maskedToken = token.length > 10
            ? '${token.substring(0, 6)}...${token.substring(token.length - 4)}'
            : '***';
        consoleBuffer.writeln('Token: Bearer $maskedToken');
      }
      if (headers != null) consoleBuffer.writeln('Headers: $headers');
      if (data != null) consoleBuffer.writeln('Data: ${_formatJson(data)}');
      consoleBuffer.write('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _logger.i(consoleBuffer.toString());
    }
  }

  /// 🌐 Pretty Print Network Request
  static void logNetworkRequest({
    required String method,
    required String url,
    String? token,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) {
    network(
      'Request Sent',
      method: method,
      url: url,
      token: token,
      headers: queryParameters != null ? {'params': queryParameters} : null,
      data: data,
    );
  }

  /// 📥 Pretty Print Network Response
  static void logNetworkResponse({
    required int? statusCode,
    required String method,
    required String url,
    required int durationMs,
    dynamic responseData,
  }) {
    network(
      'Response (${durationMs}ms)',
      method: method,
      url: url,
      statusCode: statusCode,
      data: responseData,
    );
  }

  /// ❌ Pretty Print Network Error
  static void logNetworkError({
    required int? statusCode,
    required String method,
    required String url,
    required int durationMs,
    required String errorMessage,
    dynamic errorResponse,
    dynamic rawError,
  }) {
    error(
      '[$statusCode] $method $url (${durationMs}ms) - $errorMessage',
      errorResponse ?? rawError,
    );
  }

  static String _formatJson(dynamic data) {
    try {
      if (data is List<int>) {
        return '<Binary Data: ${data.length} bytes>';
      }
      if (data is Map<String, dynamic> || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
