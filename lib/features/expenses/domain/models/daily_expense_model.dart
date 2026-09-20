import 'package:intl/intl.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class DailyExpenseItemModel {
  final String id;
  final String title;
  final String categoryName;
  final ExpenseCategory category;
  final DateTime date;
  final int amountMinor;
  final ExpenseTag tag;
  final int quantity;
  final int unitPriceMinor;
  final int? expenseTypeId;

  const DailyExpenseItemModel({
    required this.id,
    required this.title,
    required this.categoryName,
    this.category = ExpenseCategory.officeSupplies,
    required this.date,
    required this.amountMinor,
    this.tag = ExpenseTag.needed,
    this.quantity = 1,
    this.unitPriceMinor = 0,
    this.expenseTypeId,
  });

  factory DailyExpenseItemModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['price'] ?? json['total_amount'] ?? 0;
    final int amountMinor = _parseAmountToMinor(rawAmount);

    final rawUnitPrice = json['unit_price'] ?? json['price'] ?? 0;
    final int unitPriceMinor = _parseAmountToMinor(rawUnitPrice);

    final rawDate = json['date'] ?? json['created_at'] ?? json['time'] ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final isEssential = json['is_essential'] == true ||
        json['really_needed'] == true ||
        json['tag'] == 'needed' ||
        json['essential'] == true;

    // Handle when expense_type is a Map { "id": 17, "name": "Internet" } or String
    String catName = 'General';
    int? expTypeId;

    final rawType = json['expense_type'] ??
        json['expensetype'] ??
        json['category'] ??
        json['category_name'];

    if (rawType is Map<String, dynamic>) {
      catName = rawType['name']?.toString() ?? 'General';
      if (rawType['id'] is int) {
        expTypeId = rawType['id'] as int;
      } else if (rawType['id'] != null) {
        expTypeId = int.tryParse(rawType['id'].toString());
      }
    } else if (rawType != null) {
      catName = rawType.toString();
    }

    if (expTypeId == null) {
      final rawExpTypeId = json['expense_type_id'] ?? json['expensetype_id'];
      if (rawExpTypeId is int) {
        expTypeId = rawExpTypeId;
      } else if (rawExpTypeId != null) {
        expTypeId = int.tryParse(rawExpTypeId.toString());
      }
    }

    final rawQty = json['quantity_purchased'] ?? json['quantity'] ?? 1;
    final quantity = rawQty is int ? rawQty : (int.tryParse(rawQty.toString()) ?? 1);

    return DailyExpenseItemModel(
      id: (json['id'] ?? 'exp-${DateTime.now().millisecondsSinceEpoch}').toString(),
      title: json['name'] ?? json['title'] ?? json['expense_name'] ?? catName,
      categoryName: catName,
      date: parsedDate,
      amountMinor: amountMinor,
      tag: isEssential ? ExpenseTag.needed : ExpenseTag.notNeeded,
      quantity: quantity,
      unitPriceMinor: unitPriceMinor > 0 ? unitPriceMinor : (quantity > 0 ? amountMinor ~/ quantity : amountMinor),
      expenseTypeId: expTypeId,
    );
  }

  RecentExpenseItemModel toRecentExpenseItem() {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final dateStr = isToday
        ? 'Today, ${DateFormat('hh:mm a').format(date)}'
        : DateFormat('d MMM • hh:mm a').format(date);

    return RecentExpenseItemModel(
      id: id,
      title: title,
      categoryName: categoryName,
      category: category,
      timeFormatted: dateStr,
      amountMinor: amountMinor,
      tag: tag,
      expenseTypeId: expenseTypeId,
      quantity: quantity,
      unitPriceMinor: unitPriceMinor,
      rawDate: date,
    );
  }

  static int _parseAmountToMinor(dynamic val) {
    if (val == null) return 0;
    if (val is num) {
      return (val * 100).round();
    }
    if (val is String) {
      final parsed = double.tryParse(val) ?? 0.0;
      return (parsed * 100).round();
    }
    return 0;
  }
}

class DailyExpenseResponseModel {
  final String status;
  final int totalExpenditureMinor;
  final int essentialExpenditureMinor;
  final int nonEssentialExpenditureMinor;
  final List<DailyExpenseItemModel> items;

  const DailyExpenseResponseModel({
    required this.status,
    required this.totalExpenditureMinor,
    required this.essentialExpenditureMinor,
    required this.nonEssentialExpenditureMinor,
    required this.items,
  });

  factory DailyExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    final totalMinor = _parseAmountToMinor(json['actual_total_expenditure']);
    final essentialMinor = _parseAmountToMinor(json['essential_expenditure']);
    final nonEssentialMinor =
        _parseAmountToMinor(json['non_essential_expenditure']);

    final rawData = json['data'];
    List<DailyExpenseItemModel> itemsList = [];
    if (rawData is List) {
      itemsList = rawData
          .whereType<Map<String, dynamic>>()
          .map(DailyExpenseItemModel.fromJson)
          .toList();
    }

    return DailyExpenseResponseModel(
      status: json['status'] as String? ?? 'OK',
      totalExpenditureMinor: totalMinor,
      essentialExpenditureMinor: essentialMinor,
      nonEssentialExpenditureMinor: nonEssentialMinor,
      items: itemsList,
    );
  }

  factory DailyExpenseResponseModel.empty() {
    return const DailyExpenseResponseModel(
      status: 'OK',
      totalExpenditureMinor: 0,
      essentialExpenditureMinor: 0,
      nonEssentialExpenditureMinor: 0,
      items: [],
    );
  }

  int get essentialPercentage {
    if (totalExpenditureMinor <= 0) return 0;
    return ((essentialExpenditureMinor / totalExpenditureMinor) * 100)
        .round()
        .clamp(0, 100);
  }

  int get nonEssentialPercentage {
    if (totalExpenditureMinor <= 0) return 0;
    return ((nonEssentialExpenditureMinor / totalExpenditureMinor) * 100)
        .round()
        .clamp(0, 100);
  }

  int get dailyAverageMinor {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (daysInMonth <= 0) return 0;
    return (totalExpenditureMinor / daysInMonth).round();
  }

  DashboardSummaryModel toDashboardSummary({
    required DateTime selectedDate,
  }) {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final activePeriod =
        '1 ${DateFormat('MMM').format(selectedDate)} – $daysInMonth ${DateFormat('MMM yyyy').format(selectedDate)}';
    final monthLabel = DateFormat('MMM yyyy').format(selectedDate);

    // Build recent expense list
    final recentList = items.map((e) => e.toRecentExpenseItem()).toList();

    // Group items into days for weekly/monthly spending trend
    final Map<int, int> dayTotals = {};
    for (final item in items) {
      final day = item.date.day;
      dayTotals[day] = (dayTotals[day] ?? 0) + item.amountMinor;
    }

    final int maxSpending = dayTotals.values.isEmpty
        ? 1
        : dayTotals.values.reduce((a, b) => a > b ? a : b);

    // Build trend
    final List<DailySpendingModel> trendList = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final dayDate = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(dayDate);
      final amount = dayTotals[dayDate.day] ?? 0;
      final ratio = maxSpending > 0 ? (amount / maxSpending).clamp(0.1, 1.0) : 0.2;
      final label = amount > 0
          ? '₹${(amount / 100).toStringAsFixed(0)}'
          : '₹0';

      trendList.add(
        DailySpendingModel(
          day: dayName,
          amountMinor: amount,
          label: label,
          ratio: ratio,
          isToday: i == 0,
        ),
      );
    }

    return DashboardSummaryModel(
      totalSpendingMinor: totalExpenditureMinor,
      vsLastMonthPercentage: 0,
      dailyAverageMinor: dailyAverageMinor,
      budgetLeftMinor: 0,
      budgetCapMinor: totalExpenditureMinor,
      essentialAmountMinor: essentialExpenditureMinor,
      essentialPercentage: essentialPercentage,
      discretionaryAmountMinor: nonEssentialExpenditureMinor,
      discretionaryPercentage: nonEssentialPercentage,
      activePeriodLabel: activePeriod,
      formattedMonth: monthLabel,
      weeklyTrend: trendList,
      recentExpenses: recentList,
      aiInsightText: totalExpenditureMinor > 0
          ? 'Essential spending accounts for $essentialPercentage% of total this month.'
          : 'No expenses logged for this month yet. Tap + to add your first expense!',
    );
  }

  static int _parseAmountToMinor(dynamic val) {
    if (val == null) return 0;
    if (val is num) {
      return (val * 100).round();
    }
    if (val is String) {
      final parsed = double.tryParse(val) ?? 0.0;
      return (parsed * 100).round();
    }
    return 0;
  }
}
