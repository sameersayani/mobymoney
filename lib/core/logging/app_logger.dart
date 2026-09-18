import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

abstract class AppLogger {
  static void d(String message, [String tag = 'DEBUG']) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  static void i(String message, [String tag = 'INFO']) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  static void w(String message, [String tag = 'WARN']) {
    if (kDebugMode) {
      developer.log(message, name: tag);
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace, String tag = 'ERROR']) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
