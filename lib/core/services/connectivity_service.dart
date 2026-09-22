import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected }

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityStatus>(() {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends Notifier<ConnectivityStatus> {
  Timer? _timer;

  @override
  ConnectivityStatus build() {
    _startMonitoring();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return ConnectivityStatus.isConnected;
  }

  void _startMonitoring() {
    checkConnection();
    _timer?.cancel();
    // 15-second gentle heartbeat interval for production efficiency without battery drain
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      checkConnection();
    });
  }

  /// Verifies actual internet connectivity via DNS lookup with timeout
  static Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      // Fallback secondary check to Cloudflare
      try {
        final result = await InternetAddress.lookup('cloudflare.com')
            .timeout(const Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        // Final fallback to Apple servers (good for iOS users)
        try {
          final result = await InternetAddress.lookup('apple.com')
              .timeout(const Duration(seconds: 3));
          return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          return false;
        }
      }
    }
  }

  Future<bool> checkConnection() async {
    final connected = await hasInternetAccess();
    if (connected) {
      if (state != ConnectivityStatus.isConnected) {
        state = ConnectivityStatus.isConnected;
      }
      return true;
    } else {
      if (state != ConnectivityStatus.isDisconnected) {
        state = ConnectivityStatus.isDisconnected;
      }
      return false;
    }
  }
}


