import '../constants/app_constants.dart';
import '../networking/api_endpoints.dart';

/// Central Configuration for Smart Expense Manager
/// 
/// Change API Base URLs, Endpoints, Network Timeouts, and Keys in this single file.
class AppConfig {
  AppConfig._();

  // ==========================================
  // 1. BASE URL & SERVER CONFIGURATION
  // ==========================================
  
  /// Base API URL (loaded from .env / compile define with fallback)
  static String get apiBaseUrl => AppConstants.apiBaseUrl;

  /// Google OAuth Web Client ID
  static String get googleServerClientId => AppConstants.googleServerClientId;

  /// Connection & read timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ==========================================
  // 2. AUTHENTICATION ENDPOINTS
  // ==========================================
  
  /// POST - Register new account with username, email & password
  static String get register => ApiEndpoints.register;

  /// POST - User Login with username & password
  static String get passwordLogin => ApiEndpoints.passwordLogin;

  /// GET - Verify authentication session
  static String get checkAuth => ApiEndpoints.checkAuth;

  /// DELETE - Permanently delete user account
  static String get deleteAccount => ApiEndpoints.deleteAccount;

  /// POST - Google Sign-In exchange endpoint
  static String get googleAuth => ApiEndpoints.googleAuth;

  /// GET - Current user session & profile
  static String get authMe => ApiEndpoints.authMe;

  /// POST - Session logout
  static String get logout => ApiEndpoints.logout;

  // ==========================================
  // 3. EXPENSE TYPES / CATEGORIES ENDPOINTS
  // ==========================================
  
  /// GET/POST - Expense categories list
  static String get expenseTypes => ApiEndpoints.expenseTypes;

  /// GET/PUT/DELETE - Expense category by ID
  static String expenseTypeById(int id) => ApiEndpoints.expenseTypeById(id);

  // ==========================================
  // 4. DAILY EXPENSES ENDPOINTS
  // ==========================================
  
  /// GET/POST - Daily expenses root
  static String get dailyExpense => ApiEndpoints.dailyExpense;

  /// GET - Single daily expense by ID
  static String dailyExpenseById(dynamic id) => ApiEndpoints.dailyExpenseById(id);

  /// GET - Search expense by keyword
  static String searchExpense(String name) => ApiEndpoints.searchExpense(name);

  /// POST - Add expense to category
  static String addDailyExpense(int expenseTypeId) => ApiEndpoints.addDailyExpense(expenseTypeId);

  /// PUT - Update existing expense
  static String updateDailyExpense(dynamic expenseId) => ApiEndpoints.updateDailyExpense(expenseId);

  /// DELETE - Remove single expense
  static String deleteDailyExpense(dynamic expenseId) => ApiEndpoints.deleteDailyExpense(expenseId);

  // ==========================================
  // 5. ANALYTICS & CHARTS
  // ==========================================
  
  /// GET - Aggregated multi-chart data
  static String get chartData => ApiEndpoints.chartData;

  // ==========================================
  // 6. REPORTS & BULK OPERATIONS
  // ==========================================
  
  /// GET - Download/Export report
  static String get downloadReport => ApiEndpoints.downloadReport;

  /// POST/DELETE - Bulk delete expenses
  static String get deleteExpenses => ApiEndpoints.deleteExpenses;

  // ==========================================
  // 7. AI ASSISTANT & NLP CLASSIFICATION
  // ==========================================
  
  /// POST - AI Chat interaction
  static String get aiChat => ApiEndpoints.aiChat;

  /// POST - AI Expense Deletion confirmation
  static String get aiConfirmDelete => ApiEndpoints.aiConfirmDelete;

  /// POST - AI Expense Classification & Save confirmation
  static String get aiConfirmClassification => ApiEndpoints.aiConfirmClassification;
}
