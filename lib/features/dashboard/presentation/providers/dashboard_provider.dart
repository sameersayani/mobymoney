import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

final dashboardSummaryProvider =
    NotifierProvider<DashboardNotifier, AsyncValue<DashboardSummaryModel>>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends Notifier<AsyncValue<DashboardSummaryModel>> {
  @override
  AsyncValue<DashboardSummaryModel> build() {
    loadDashboardData();
    return const AsyncValue.loading();
  }

  Future<void> loadDashboardData() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      state = AsyncValue.data(DashboardSummaryModel.mock());
    } catch (e, st) {
      state = AsyncValue.error('Failed to load dashboard data', st);
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }

  void addExpense(RecentExpenseItemModel expense) {
    state.whenData((current) {
      final updatedExpenses = [expense, ...current.recentExpenses];
      final newTotal = current.totalSpendingMinor + expense.amountMinor;
      final newBudgetLeft = (current.budgetLeftMinor - expense.amountMinor).clamp(0, double.infinity).toInt();

      state = AsyncValue.data(
        current.copyWith(
          recentExpenses: updatedExpenses,
          totalSpendingMinor: newTotal,
          budgetLeftMinor: newBudgetLeft,
        ),
      );
    });
  }

  void updateExpense(RecentExpenseItemModel updatedExpense) {
    state.whenData((current) {
      final oldExpense = current.recentExpenses.firstWhere(
        (e) => e.id == updatedExpense.id,
        orElse: () => updatedExpense,
      );
      final diff = updatedExpense.amountMinor - oldExpense.amountMinor;
      final updatedExpenses = current.recentExpenses.map((e) {
        return e.id == updatedExpense.id ? updatedExpense : e;
      }).toList();

      final newTotal = current.totalSpendingMinor + diff;
      final newBudgetLeft = (current.budgetLeftMinor - diff).clamp(0, double.infinity).toInt();

      state = AsyncValue.data(
        current.copyWith(
          recentExpenses: updatedExpenses,
          totalSpendingMinor: newTotal,
          budgetLeftMinor: newBudgetLeft,
        ),
      );
    });
  }

  void deleteExpense(String id) {
    state.whenData((current) {
      final target = current.recentExpenses.firstWhere(
        (e) => e.id == id,
        orElse: () => const RecentExpenseItemModel(
          id: '',
          title: '',
          categoryName: '',
          category: ExpenseCategory.officeSupplies,
          timeFormatted: '',
          amountMinor: 0,
        ),
      );
      final updatedExpenses = current.recentExpenses.where((e) => e.id != id).toList();
      final newTotal = current.totalSpendingMinor - target.amountMinor;
      final newBudgetLeft = current.budgetLeftMinor + target.amountMinor;

      state = AsyncValue.data(
        current.copyWith(
          recentExpenses: updatedExpenses,
          totalSpendingMinor: newTotal,
          budgetLeftMinor: newBudgetLeft,
        ),
      );
    });
  }
}
