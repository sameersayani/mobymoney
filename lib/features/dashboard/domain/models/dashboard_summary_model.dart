import 'package:mobymoney/core/constants/app_currency.dart';

enum ExpenseCategory {
  foodDining,
  officeSupplies,
  subscription,
  transportation,
  shopping,
  utilities,
}

enum ExpenseTag {
  needed,
  notNeeded,
}

class CurrencyTotals {
  final AppCurrency currency;
  final int totalExpenditureMinor;
  final int essentialExpenditureMinor;
  final int nonEssentialExpenditureMinor;
  final int expenseCount;

  const CurrencyTotals({
    required this.currency,
    required this.totalExpenditureMinor,
    this.essentialExpenditureMinor = 0,
    this.nonEssentialExpenditureMinor = 0,
    this.expenseCount = 0,
  });

  factory CurrencyTotals.fromJson(String currencyCode, Map<String, dynamic> json, {int count = 0}) {
    final currency = AppCurrency.fromCode(currencyCode);
    final rawActual = json['actual'] ?? json['total'] ?? json['total_expenditure'] ?? json['amount'] ?? 0;
    final rawEssential = json['essential'] ?? json['essential_expenditure'] ?? 0;
    final rawNonEssential = json['non_essential'] ?? json['nonEssential'] ?? json['non_essential_expenditure'] ?? 0;

    int parseToMinor(dynamic val) {
      if (val == null) return 0;
      if (val is num) return (val * 100).round();
      if (val is String) {
        final parsed = double.tryParse(val) ?? 0.0;
        return (parsed * 100).round();
      }
      return 0;
    }

    return CurrencyTotals(
      currency: currency,
      totalExpenditureMinor: parseToMinor(rawActual),
      essentialExpenditureMinor: parseToMinor(rawEssential),
      nonEssentialExpenditureMinor: parseToMinor(rawNonEssential),
      expenseCount: count,
    );
  }
}

class DashboardSummaryModel {
  final int totalSpendingMinor;
  final int vsLastMonthPercentage;
  final int dailyAverageMinor;
  final int budgetLeftMinor;
  final int budgetCapMinor;
  final int essentialAmountMinor;
  final int essentialPercentage;
  final int discretionaryAmountMinor;
  final int discretionaryPercentage;
  final String activePeriodLabel;
  final String formattedMonth;
  final List<DailySpendingModel> weeklyTrend;
  final List<RecentExpenseItemModel> recentExpenses;
  final String aiInsightText;
  final Map<AppCurrency, CurrencyTotals> totalsByCurrency;

  const DashboardSummaryModel({
    required this.totalSpendingMinor,
    required this.vsLastMonthPercentage,
    required this.dailyAverageMinor,
    required this.budgetLeftMinor,
    required this.budgetCapMinor,
    required this.essentialAmountMinor,
    required this.essentialPercentage,
    required this.discretionaryAmountMinor,
    required this.discretionaryPercentage,
    required this.activePeriodLabel,
    required this.formattedMonth,
    required this.weeklyTrend,
    required this.recentExpenses,
    required this.aiInsightText,
    this.totalsByCurrency = const {},
  });

  DashboardSummaryModel copyWith({
    int? totalSpendingMinor,
    int? vsLastMonthPercentage,
    int? dailyAverageMinor,
    int? budgetLeftMinor,
    int? budgetCapMinor,
    int? essentialAmountMinor,
    int? essentialPercentage,
    int? discretionaryAmountMinor,
    int? discretionaryPercentage,
    String? activePeriodLabel,
    String? formattedMonth,
    List<DailySpendingModel>? weeklyTrend,
    List<RecentExpenseItemModel>? recentExpenses,
    String? aiInsightText,
    Map<AppCurrency, CurrencyTotals>? totalsByCurrency,
  }) {
    return DashboardSummaryModel(
      totalSpendingMinor: totalSpendingMinor ?? this.totalSpendingMinor,
      vsLastMonthPercentage: vsLastMonthPercentage ?? this.vsLastMonthPercentage,
      dailyAverageMinor: dailyAverageMinor ?? this.dailyAverageMinor,
      budgetLeftMinor: budgetLeftMinor ?? this.budgetLeftMinor,
      budgetCapMinor: budgetCapMinor ?? this.budgetCapMinor,
      essentialAmountMinor: essentialAmountMinor ?? this.essentialAmountMinor,
      essentialPercentage: essentialPercentage ?? this.essentialPercentage,
      discretionaryAmountMinor: discretionaryAmountMinor ?? this.discretionaryAmountMinor,
      discretionaryPercentage: discretionaryPercentage ?? this.discretionaryPercentage,
      activePeriodLabel: activePeriodLabel ?? this.activePeriodLabel,
      formattedMonth: formattedMonth ?? this.formattedMonth,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      aiInsightText: aiInsightText ?? this.aiInsightText,
      totalsByCurrency: totalsByCurrency ?? this.totalsByCurrency,
    );
  }

  /// Production Initial Mock Data matching the UI mockup
  factory DashboardSummaryModel.mock() {
    return const DashboardSummaryModel(
      totalSpendingMinor: 4825000,
      vsLastMonthPercentage: -12,
      dailyAverageMinor: 155600,
      budgetLeftMinor: 1675000,
      budgetCapMinor: 6500000,
      essentialAmountMinor: 3640000,
      essentialPercentage: 75,
      discretionaryAmountMinor: 1185000,
      discretionaryPercentage: 25,
      activePeriodLabel: '1 Oct – 31 Oct',
      formattedMonth: 'Oct 2024',
      weeklyTrend: [
        DailySpendingModel(day: 'Mon', amountMinor: 120000, label: '₹1.2k', ratio: 0.40),
        DailySpendingModel(day: 'Tue', amountMinor: 245000, label: '₹2.4k', ratio: 0.72),
        DailySpendingModel(day: 'Wed', amountMinor: 85000, label: '₹850', ratio: 0.28),
        DailySpendingModel(day: 'Thu', amountMinor: 310000, label: '₹3.1k', ratio: 0.90),
        DailySpendingModel(day: 'Fri', amountMinor: 342000, label: '₹3.4k', ratio: 1.0, isToday: true),
        DailySpendingModel(day: 'Sat', amountMinor: 160000, label: '₹1.6k', ratio: 0.48),
        DailySpendingModel(day: 'Sun', amountMinor: 95000, label: '₹950', ratio: 0.32),
      ],
      recentExpenses: [
        RecentExpenseItemModel(
          id: '1',
          title: 'Blue Tokai Coffee',
          categoryName: 'Food & Dining',
          category: ExpenseCategory.foodDining,
          timeFormatted: 'Today, 10:45 AM',
          amountMinor: 38000,
          tag: ExpenseTag.needed,
          currency: AppCurrency.inr,
        ),
        RecentExpenseItemModel(
          id: '2',
          title: 'Office Stationery & Notes',
          categoryName: 'Office Supplies',
          category: ExpenseCategory.officeSupplies,
          timeFormatted: 'Yesterday',
          amountMinor: 25000,
          tag: ExpenseTag.needed,
          currency: AppCurrency.inr,
        ),
        RecentExpenseItemModel(
          id: '3',
          title: 'Netflix Premium 4K',
          categoryName: 'Subscription',
          category: ExpenseCategory.subscription,
          timeFormatted: '24 Oct',
          amountMinor: 64900,
          tag: ExpenseTag.notNeeded,
          currency: AppCurrency.inr,
        ),
        RecentExpenseItemModel(
          id: '4',
          title: 'Uber Premier Airport',
          categoryName: 'Transportation',
          category: ExpenseCategory.transportation,
          timeFormatted: '22 Oct',
          amountMinor: 112000,
          tag: ExpenseTag.needed,
          currency: AppCurrency.inr,
        ),
      ],
      totalsByCurrency: {
        AppCurrency.inr: CurrencyTotals(
          currency: AppCurrency.inr,
          totalExpenditureMinor: 4825000,
          essentialExpenditureMinor: 3640000,
          nonEssentialExpenditureMinor: 1185000,
          expenseCount: 4,
        ),
      },
      aiInsightText:
          'Dining out is 18% lower than typical Fridays. You are on track to save ₹3,200 this week!',
    );
  }
}

class DailySpendingModel {
  final String day;
  final int amountMinor;
  final String label;
  final double ratio;
  final bool isToday;

  const DailySpendingModel({
    required this.day,
    required this.amountMinor,
    required this.label,
    required this.ratio,
    this.isToday = false,
  });
}

class RecentExpenseItemModel {
  final String id;
  final String title;
  final String categoryName;
  final ExpenseCategory category;
  final String timeFormatted;
  final int amountMinor;
  final ExpenseTag tag;
  final int? expenseTypeId;
  final int quantity;
  final int unitPriceMinor;
  final DateTime? rawDate;
  final AppCurrency currency;

  const RecentExpenseItemModel({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.category,
    required this.timeFormatted,
    required this.amountMinor,
    this.tag = ExpenseTag.needed,
    this.expenseTypeId,
    this.quantity = 1,
    this.unitPriceMinor = 0,
    this.rawDate,
    this.currency = AppCurrency.inr,
  });

  RecentExpenseItemModel copyWith({
    String? id,
    String? title,
    String? categoryName,
    ExpenseCategory? category,
    String? timeFormatted,
    int? amountMinor,
    ExpenseTag? tag,
    int? expenseTypeId,
    int? quantity,
    int? unitPriceMinor,
    DateTime? rawDate,
    AppCurrency? currency,
  }) {
    return RecentExpenseItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryName: categoryName ?? this.categoryName,
      category: category ?? this.category,
      timeFormatted: timeFormatted ?? this.timeFormatted,
      amountMinor: amountMinor ?? this.amountMinor,
      tag: tag ?? this.tag,
      expenseTypeId: expenseTypeId ?? this.expenseTypeId,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      rawDate: rawDate ?? this.rawDate,
      currency: currency ?? this.currency,
    );
  }
}
