import 'dart:convert';
import 'package:flutter/foundation.dart';

abstract class AppLogger {
  // ANSI Colors for IDE terminals
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  static void d(String message, [String tag = 'DEBUG']) {
    if (!kDebugMode) return;
    debugPrint('$_cyan🔍 [$tag] $message$_reset');
  }

  static void i(String message, [String tag = 'INFO']) {
    if (!kDebugMode) return;
    debugPrint('$_cyan💡 [$tag] $message$_reset');
  }

  static void s(String message, [String tag = 'SUCCESS']) {
    if (!kDebugMode) return;
    debugPrint('$_green✅ [$tag] $message$_reset');
  }

  static void w(String message, [String tag = 'WARN']) {
    if (!kDebugMode) return;
    debugPrint('$_yellow⚠️ [$tag] $message$_reset');
  }

  static void e(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    String tag = 'ERROR',
  ]) {
    if (!kDebugMode) return;
    debugPrint('$_red❌ [$tag] $message$_reset');
    if (error != null) debugPrint('$_red   Error: $error$_reset');
    if (stackTrace != null) debugPrint('$_red   Stack: $stackTrace$_reset');
  }

  /// 🌐 Pretty Print Network Request
  static void logNetworkRequest({
    required String method,
    required String url,
    String? token,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) {
    if (!kDebugMode) return;
    final buffer = StringBuffer();
    buffer.writeln('$_magenta┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ 🌐 $method $url');
    if (token != null && token.isNotEmpty) {
      // Printed on one single unbroken line
      buffer.writeln('│ 🔑 Token: $token');
    }
    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('│ 📥 Params: ${_formatJson(queryParameters)}');
    }
    if (data != null) {
      buffer.writeln('│ 📦 Payload: ${_formatJson(data)}');
    }
    buffer.write('└──────────────────────────────────────────────────────────$_reset');
    debugPrint(buffer.toString());
  }

  /// 📥 Pretty Print Network Response
  static void logNetworkResponse({
    required int? statusCode,
    required String method,
    required String url,
    required int durationMs,
    dynamic responseData,
  }) {
    if (!kDebugMode) return;
    final isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;
    final color = isSuccess ? _green : _yellow;
    final icon = isSuccess ? '✅' : '⚠️';

    final buffer = StringBuffer();
    buffer.writeln('$color┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ $icon [$statusCode] $method $url');
    buffer.writeln('│ ⏱️ Response Time: ${durationMs}ms');
    if (responseData != null) {
      buffer.writeln('│ 📥 Response: ${_formatJson(responseData)}');
    }
    buffer.write('└──────────────────────────────────────────────────────────$_reset');
    debugPrint(buffer.toString());
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
    if (!kDebugMode) return;
    final buffer = StringBuffer();
    buffer.writeln('$_red┌──────────────────────────────────────────────────────────');
    buffer.writeln('│ ❌ [${statusCode ?? 'ERR'}] $method $url');
    buffer.writeln('│ ⏱️ Duration: ${durationMs}ms');
    buffer.writeln('│ 💬 Reason: $errorMessage');
    if (rawError != null) {
      buffer.writeln('│ 🔍 Raw Exception: $rawError');
    }
    if (errorResponse != null) {
      buffer.writeln('│ 📥 Error Response: ${_formatJson(errorResponse)}');
    }
    buffer.write('└──────────────────────────────────────────────────────────$_reset');
    debugPrint(buffer.toString());
  }

  static String _formatJson(dynamic data) {
    try {
      if (data is Map<String, dynamic> || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
