abstract class AppConstants {
  static const String appName = 'Moby Money';
  
  // API Config
  static const String apiBaseUrl = 'https://expensemanager-0ac3.onrender.com';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  
  // Storage Keys
  static const String keyAccessToken = 'secure_access_token';
  static const String keyUserData = 'secure_user_data';
}
