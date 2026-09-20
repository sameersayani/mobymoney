abstract class ApiEndpoints {
  // Auth
  static const String googleAuth = '/api/mobile/auth/google';
  static const String authMe = '/api/mobile/auth/me';

  // Expense Types
  static const String expenseTypes = '/expensetype';
  static String expenseTypeById(int id) => '/expensetype/$id';
}


