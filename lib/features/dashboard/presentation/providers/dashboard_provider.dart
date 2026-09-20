import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/expenses/data/repositories/daily_expense_repository.dart';

final dailyExpenseRepositoryProvider = Provider<DailyExpenseRepository>((ref) {
  return DailyExpenseRepository();
});

/// Shared Selected Date Notifier for Dashboard & Expenses Screen
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) => state = newDate;
  void nextMonth() => state = DateTime(state.year, state.month + 1);
  void previousMonth() => state = DateTime(state.year, state.month - 1);
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final dashboardSummaryProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<DashboardSummaryModel>>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends Notifier<AsyncValue<DashboardSummaryModel>> {
  DateTime _currentDate = DateTime.now();

  @override
  AsyncValue<DashboardSummaryModel> build() {
    _currentDate = ref.watch(selectedDateProvider);
    loadDashboardData(date: _currentDate);
    return const AsyncValue.loading();
  }

  Future<void> loadDashboardData({DateTime? date}) async {
    final targetDate = date ?? _currentDate;
    _currentDate = targetDate;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(dailyExpenseRepositoryProvider);
      final response = await repo.getDailyExpenses(
        month: targetDate.month,
        year: targetDate.year,
      );
      final summary = response.toDashboardSummary(selectedDate: targetDate);
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
  }

  Future<void> deleteExpense(dynamic id) async {
    final repo = ref.read(dailyExpenseRepositoryProvider);
    await repo.deleteExpense(id);
    await loadDashboardData(date: _currentDate);
  }
}

