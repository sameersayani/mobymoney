import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConstants {
  static const String appName = 'MobyMoney';

  // API Config (loaded from .env with fallback)
  static String get apiBaseUrl {
    if (!dotenv.isInitialized) {
      return 'https://expensemanager-0ac3.onrender.com';
    }
    return dotenv.env['API_BASE_URL'] ?? 'https://expensemanager-0ac3.onrender.com';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Storage Keys
  static const String keyAccessToken = 'secure_access_token';
  static const String keyUserData = 'secure_user_data';

  // OAuth Config (Server / Web Client ID loaded dynamically from .env)
  static String get googleServerClientId {
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
  }
}

