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
    // Return sorted alphabetically or preserve server order
    return types;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchExpenseTypes());
  }
}

final expenseTypesProvider =
    AsyncNotifierProvider<ExpenseTypesNotifier, List<ExpenseTypeModel>>(
  () => ExpenseTypesNotifier(),
);
