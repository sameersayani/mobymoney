import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/expense_type_repository.dart';
import '../../domain/models/expense_type_model.dart';

final expenseTypeRepositoryProvider = Provider<ExpenseTypeRepository>((ref) {
  return ExpenseTypeRepository();
});

class ExpenseTypesNotifier extends AsyncNotifier<List<ExpenseTypeModel>> {
  @override
  Future<List<ExpenseTypeModel>> build() async {
    return _fetchExpenseTypes();
  }

  Future<List<ExpenseTypeModel>> _fetchExpenseTypes() async {
    final repository = ref.read(expenseTypeRepositoryProvider);
    final types = await repository.getExpenseTypes();
    return types;
  }

  /// Refreshes the full list from GET /expensetype
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExpenseTypes());
  }

  /// GET /expensetype/{id}
  Future<ExpenseTypeModel> getById(int id) async {
    final repository = ref.read(expenseTypeRepositoryProvider);
    return await repository.getExpenseTypeById(id);
  }

  /// POST /expensetype
  Future<void> createType(String name) async {
    final repository = ref.read(expenseTypeRepositoryProvider);
    await repository.createExpenseType(name);
    // Refresh to get server-assigned ID & sorted state
    await refresh();
  }

  /// PUT /expensetype/{id}
  Future<void> updateType(int id, String name) async {
    final repository = ref.read(expenseTypeRepositoryProvider);
    await repository.updateExpenseType(id, name);
    await refresh();
  }

  /// DELETE /expensetype/{id}
  Future<void> deleteType(int id) async {
    final repository = ref.read(expenseTypeRepositoryProvider);
    await repository.deleteExpenseType(id);
    // Optimistic removal + refresh
    final currentList = state.asData?.value ?? [];
    state = AsyncValue.data(currentList.where((item) => item.id != id).toList());
  }
}

final expenseTypesProvider =
    AsyncNotifierProvider<ExpenseTypesNotifier, List<ExpenseTypeModel>>(
  () => ExpenseTypesNotifier(),
);
