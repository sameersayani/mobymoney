import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class ExpenseCategoryItem {
  final String id;
  final String name;
  final ExpenseCategory category;
  final IconData icon;
  final Color color;
  final bool isCustom;

  const ExpenseCategoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  ExpenseCategoryItem copyWith({
    String? id,
    String? name,
    ExpenseCategory? category,
    IconData? icon,
    Color? color,
    bool? isCustom,
  }) {
    return ExpenseCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

const List<ExpenseCategoryItem> kDefaultExpenseCategories = [
  ExpenseCategoryItem(
    id: 'supplies',
    name: 'Office Supplies',
    category: ExpenseCategory.officeSupplies,
    icon: PhosphorIconsRegular.briefcase,
    color: Color(0xFF6366F1), // Indigo
  ),
  ExpenseCategoryItem(
    id: 'food',
    name: 'Food & Dining',
    category: ExpenseCategory.foodDining,
    icon: PhosphorIconsRegular.forkKnife,
    color: Color(0xFFF59E0B), // Amber
  ),
  ExpenseCategoryItem(
    id: 'travel',
    name: 'Travel & Transport',
    category: ExpenseCategory.transportation,
    icon: PhosphorIconsRegular.car,
    color: Color(0xFF0F766E), // Teal
  ),
  ExpenseCategoryItem(
    id: 'utilities',
    name: 'Bills & Utilities',
    category: ExpenseCategory.utilities,
    icon: PhosphorIconsRegular.receipt,
    color: Color(0xFF0284C7), // Sky Blue
  ),
  ExpenseCategoryItem(
    id: 'subscription',
    name: 'Subscription',
    category: ExpenseCategory.subscription,
    icon: PhosphorIconsRegular.television,
    color: Color(0xFFEF4444), // Rose
  ),
  ExpenseCategoryItem(
    id: 'shopping',
    name: 'Shopping',
    category: ExpenseCategory.shopping,
    icon: PhosphorIconsRegular.shoppingBag,
    color: Color(0xFF8B5CF6), // Purple
  ),
];

class ExpenseCategoriesNotifier extends Notifier<List<ExpenseCategoryItem>> {
  @override
  List<ExpenseCategoryItem> build() {
    return List.from(kDefaultExpenseCategories);
  }

  void addCategory({
    required String name,
    required IconData icon,
    required Color color,
    ExpenseCategory category = ExpenseCategory.officeSupplies,
  }) {
    final newItem = ExpenseCategoryItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      icon: icon,
      color: color,
      isCustom: true,
    );
    state = [...state, newItem];
  }

  void updateCategory(String id, {required String name, required IconData icon, required Color color}) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(name: name.trim(), icon: icon, color: color);
      }
      return item;
    }).toList();
  }

  void deleteCategory(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final expenseCategoriesProvider =
    NotifierProvider<ExpenseCategoriesNotifier, List<ExpenseCategoryItem>>(() {
  return ExpenseCategoriesNotifier();
});
