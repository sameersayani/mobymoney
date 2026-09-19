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
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      checkConnection();
    });
  }

  static Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
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
