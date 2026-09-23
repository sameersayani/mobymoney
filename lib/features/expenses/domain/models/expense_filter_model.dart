enum ExpenseTagFilter { all, needed, notNeeded }

enum ExpenseSortOrder {
  newest('Newest First'),
  oldest('Oldest First'),
  highestAmount('Highest Amount'),
  lowestAmount('Lowest Amount');

  const ExpenseSortOrder(this.label);
  final String label;
}

class ExpenseFilterModel {
  const ExpenseFilterModel({
    this.tag = ExpenseTagFilter.all,
    this.expenseTypeId,
    this.sortOrder = ExpenseSortOrder.newest,
    this.minAmount,
    this.maxAmount,
  });

  final ExpenseTagFilter tag;
  final int? expenseTypeId; // null means all categories
  final ExpenseSortOrder sortOrder;
  final double? minAmount;
  final double? maxAmount;

  bool get isActive =>
      tag != ExpenseTagFilter.all ||
      expenseTypeId != null ||
      sortOrder != ExpenseSortOrder.newest ||
      minAmount != null ||
      maxAmount != null;

  ExpenseFilterModel copyWith({
    ExpenseTagFilter? tag,
    int? Function()? expenseTypeId,
    ExpenseSortOrder? sortOrder,
    double? Function()? minAmount,
    double? Function()? maxAmount,
  }) {
    return ExpenseFilterModel(
      tag: tag ?? this.tag,
      expenseTypeId:
          expenseTypeId != null ? expenseTypeId() : this.expenseTypeId,
      sortOrder: sortOrder ?? this.sortOrder,
      minAmount: minAmount != null ? minAmount() : this.minAmount,
      maxAmount: maxAmount != null ? maxAmount() : this.maxAmount,
    );
  }
}
