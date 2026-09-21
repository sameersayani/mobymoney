import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConstants {
  static const String appName = 'MobyMoney';

  // API Config (prioritizes compile-time --dart-define, then .env, then fallback)
  static String get apiBaseUrl {
    const definedUrl = String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) return definedUrl;

    if (dotenv.isInitialized && dotenv.env['API_BASE_URL'] != null) {
      return dotenv.env['API_BASE_URL']!;
    }
    return 'https://expensemanager-0ac3.onrender.com';
  }

  // Render free-tier cold-starts take 30-60 s; 60 s gives it a real chance.
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Storage Keys
  static const String keyAccessToken = 'secure_access_token';
  static const String keyUserData = 'secure_user_data';

  // OAuth Config (Server / Web Client ID loaded dynamically via compile define or .env)
  static String get googleServerClientId {
    const definedId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (definedId.isNotEmpty) return definedId;

    if (dotenv.isInitialized && dotenv.env['GOOGLE_SERVER_CLIENT_ID'] != null) {
      return dotenv.env['GOOGLE_SERVER_CLIENT_ID']!;
    }
    return '';
  }
}

