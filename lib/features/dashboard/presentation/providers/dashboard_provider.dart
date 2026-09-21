import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobymoney/core/constants/app_currency.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/expenses/data/repositories/daily_expense_repository.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

final dailyExpenseRepositoryProvider = Provider<DailyExpenseRepository>((ref) {
  return DailyExpenseRepository();
});

/// Independent Date Notifiers for Home, Expenses, and Analytics
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) => state = newDate;
  void nextMonth() => state = DateTime(state.year, state.month + 1);
  void previousMonth() => state = DateTime(state.year, state.month - 1);
}

/// Home Screen Date
final homeSelectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Alias for backward compatibility
final selectedDateProvider = homeSelectedDateProvider;

/// Expenses Screen Date
final expensesSelectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Analytics Screen Date
final analyticsSelectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Home Dashboard Summary Notifier
final dashboardSummaryProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<DashboardSummaryModel>>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends Notifier<AsyncValue<DashboardSummaryModel>> {
  DateTime _currentDate = DateTime.now();

  @override
  AsyncValue<DashboardSummaryModel> build() {
    _currentDate = ref.watch(homeSelectedDateProvider);
    final currency = ref.watch(currencyProvider);
    loadDashboardData(date: _currentDate, currency: currency);
    return const AsyncValue.loading();
  }

  Future<void> loadDashboardData({DateTime? date, AppCurrency? currency}) async {
    final targetDate = date ?? _currentDate;
    final AppCurrency targetCurrency = currency ?? ref.read(currencyProvider);
    _currentDate = targetDate;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(dailyExpenseRepositoryProvider);
      final response = await repo.getDailyExpenses(
        month: targetDate.month,
        year: targetDate.year,
      );
      final summary = response.toDashboardSummary(
        selectedDate: targetDate,
        currency: targetCurrency,
      );
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> refresh() async {
    await loadDashboardData(date: _currentDate);
  }

  Future<void> addExpense({
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.addExpense(
      expenseTypeId: expenseTypeId,
      date: date,
      name: name,
      quantityPurchased: quantityPurchased,
      unitPrice: unitPrice,
      amount: amount,
      reallyNeeded: reallyNeeded,
    );
    await loadDashboardData(date: _currentDate);
    ref.invalidate(expensesSummaryProvider);
  }

  Future<void> updateExpense({
    required dynamic expenseId,
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.updateExpense(
      expenseId: expenseId,
      expenseTypeId: expenseTypeId,
      date: date,
      name: name,
      quantityPurchased: quantityPurchased,
      unitPrice: unitPrice,
      amount: amount,
      reallyNeeded: reallyNeeded,
    );
    await loadDashboardData(date: _currentDate);
    ref.invalidate(expensesSummaryProvider);
  }

  Future<void> deleteExpense(dynamic id) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.deleteExpense(id);
    await loadDashboardData(date: _currentDate);
    ref.invalidate(expensesSummaryProvider);
  }

  Future<void> deleteBulkExpenses({required int year, int? month}) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.deleteBulkExpenses(year: year, month: month);
    await loadDashboardData(date: _currentDate);
    ref.invalidate(expensesSummaryProvider);
  }
}

/// Expenses Screen Summary Notifier (uses expensesSelectedDateProvider)
final expensesSummaryProvider =
    NotifierProvider<ExpensesNotifier, AsyncValue<DashboardSummaryModel>>(() {
  return ExpensesNotifier();
});

class ExpensesNotifier extends Notifier<AsyncValue<DashboardSummaryModel>> {
  DateTime _currentDate = DateTime.now();

  @override
  AsyncValue<DashboardSummaryModel> build() {
    _currentDate = ref.watch(expensesSelectedDateProvider);
    final currency = ref.watch(currencyProvider);
    loadExpensesData(date: _currentDate, currency: currency);
    return const AsyncValue.loading();
  }

  Future<void> loadExpensesData({DateTime? date, AppCurrency? currency}) async {
    final targetDate = date ?? _currentDate;
    final AppCurrency targetCurrency = currency ?? ref.read(currencyProvider);
    _currentDate = targetDate;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(dailyExpenseRepositoryProvider);
      final response = await repo.getDailyExpenses(
        month: targetDate.month,
        year: targetDate.year,
      );
      final summary = response.toDashboardSummary(
        selectedDate: targetDate,
        currency: targetCurrency,
      );
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> refresh() async {
    await loadExpensesData(date: _currentDate);
  }

  Future<void> addExpense({
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.addExpense(
      expenseTypeId: expenseTypeId,
      date: date,
      name: name,
      quantityPurchased: quantityPurchased,
      unitPrice: unitPrice,
      amount: amount,
      reallyNeeded: reallyNeeded,
    );
    await loadExpensesData(date: _currentDate);
    ref.invalidate(dashboardSummaryProvider);
  }

  Future<void> updateExpense({
    required dynamic expenseId,
    required int expenseTypeId,
    required DateTime date,
    required String name,
    required int quantityPurchased,
    required double unitPrice,
    required double amount,
    required bool reallyNeeded,
  }) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.updateExpense(
      expenseId: expenseId,
      expenseTypeId: expenseTypeId,
      date: date,
      name: name,
      quantityPurchased: quantityPurchased,
      unitPrice: unitPrice,
      amount: amount,
      reallyNeeded: reallyNeeded,
    );
    await loadExpensesData(date: _currentDate);
    ref.invalidate(dashboardSummaryProvider);
  }

  Future<void> deleteExpense(dynamic id) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.deleteExpense(id);
    await loadExpensesData(date: _currentDate);
    ref.invalidate(dashboardSummaryProvider);
  }
}

/// Analytics Screen Summary Notifier (uses analyticsSelectedDateProvider)
final analyticsSummaryProvider =
    NotifierProvider<AnalyticsSummaryNotifier, AsyncValue<DashboardSummaryModel>>(() {
  return AnalyticsSummaryNotifier();
});

class AnalyticsSummaryNotifier extends Notifier<AsyncValue<DashboardSummaryModel>> {
  DateTime _currentDate = DateTime.now();

  @override
  AsyncValue<DashboardSummaryModel> build() {
    _currentDate = ref.watch(analyticsSelectedDateProvider);
    final currency = ref.watch(currencyProvider);
    loadAnalyticsData(date: _currentDate, currency: currency);
    return const AsyncValue.loading();
  }

  Future<void> loadAnalyticsData({DateTime? date, AppCurrency? currency}) async {
    final targetDate = date ?? _currentDate;
    final AppCurrency targetCurrency = currency ?? ref.read(currencyProvider);
    _currentDate = targetDate;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(dailyExpenseRepositoryProvider);
      final response = await repo.getDailyExpenses(
        month: targetDate.month,
        year: targetDate.year,
      );
      final summary = response.toDashboardSummary(
        selectedDate: targetDate,
        currency: targetCurrency,
      );
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> refresh() async {
    await loadAnalyticsData(date: _currentDate);
  }
}

