abstract class ApiEndpoints {
  // Auth
  static const String googleAuth = '/api/mobile/auth/google';
  static const String authMe = '/api/mobile/auth/me';

  // Expense Types
  static const String expenseTypes = '/expensetype';
  static String expenseTypeById(int id) => '/expensetype/$id';

  // Daily Expenses
  static const String dailyExpense = '/dailyexpense';
  static String dailyExpenseById(dynamic id) => '/dailyexpense/$id';
  static String searchExpense(String name) => '/search-expense/$name';
  static String addDailyExpense(int expenseTypeId) => '/dailyexpense/$expenseTypeId';
  static String updateDailyExpense(dynamic expenseId) => '/dailyexpense/$expenseId';
  static String deleteDailyExpense(dynamic expenseId) => '/dailyexpense/$expenseId';

  // Analytics & Charts
  static const String chartData = '/chart-data';

  // Reports & Bulk Operations
  static const String downloadReport = '/download-report';
  static const String deleteExpenses = '/delete-expenses';
}



