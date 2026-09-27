import 'package:intl/intl.dart';
import 'package:mobymoney/core/constants/app_currency.dart';
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
  final AppCurrency currency;

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
    this.currency = AppCurrency.inr,
  });

  factory DailyExpenseItemModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['price'] ?? json['total_amount'] ?? 0;
    final int amountMinor = _parseAmountToMinor(rawAmount);

    final rawUnitPrice = json['unit_price'] ?? json['price'] ?? 0;
    final int unitPriceMinor = _parseAmountToMinor(rawUnitPrice);

    final rawCurrency = json['currency'] ?? json['currency_code'] ?? json['currencyCode'];
    final AppCurrency currency = AppCurrency.fromCode(rawCurrency?.toString());

    // Prioritize user's business date (date, expense_date) over database insertion timestamps (createdon, created_at)
    final rawDate = json['date'] ??
        json['expense_date'] ??
        json['expensedate'] ??
        json['createdon'] ??
        json['created_on'] ??
        json['created_at'] ??
        json['createdAt'] ??
        json['timestamp'] ??
        json['time'] ??
        '';
    DateTime parsedDate;
    try {
      final str = rawDate.toString().trim();
      if (str.isNotEmpty) {
        final parsed = DateTime.tryParse(str) ?? DateTime.now();
        // Convert UTC server timestamps (ending in Z or with timezone offset) to device local time
        parsedDate = parsed.isUtc ? parsed.toLocal() : parsed;
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final dynamic rawEssential = json['really_needed'] ??
        json['reallyNeeded'] ??
        json['is_essential'] ??
        json['isEssential'] ??
        json['tag'] ??
        json['essential'] ??
        json['needed'] ??
        json['is_needed'];

    final bool isEssential = rawEssential == true ||
        rawEssential == 1 ||
        rawEssential == '1' ||
        rawEssential == 'true' ||
        rawEssential == 'needed' ||
        rawEssential == 'essential' ||
        rawEssential == 'yes';

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

    final rawId = json['id'] ??
        json['_id'] ??
        json['expense_id'] ??
        json['dailyexpense_id'];

    return DailyExpenseItemModel(
      id: (rawId != null ? rawId.toString() : 'exp-${parsedDate.millisecondsSinceEpoch}'),
      title: json['name'] ?? json['title'] ?? json['expense_name'] ?? catName,
      categoryName: catName,
      date: parsedDate,
      amountMinor: amountMinor,
      tag: isEssential ? ExpenseTag.needed : ExpenseTag.notNeeded,
      quantity: quantity,
      unitPriceMinor: unitPriceMinor > 0 ? unitPriceMinor : (quantity > 0 ? amountMinor ~/ quantity : amountMinor),
      expenseTypeId: expTypeId,
      currency: currency,
    );
  }

  RecentExpenseItemModel toRecentExpenseItem() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final expenseMidnight = DateTime(date.year, date.month, date.day);
    final dayDiff = todayMidnight.difference(expenseMidnight).inDays;

    final String dateStr;
    if (dayDiff == 0) {
      dateStr = 'Today, ${DateFormat('hh:mm a').format(date)}';
    } else if (dayDiff == 1) {
      dateStr = 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    } else if (date.year == now.year) {
      dateStr = DateFormat('d MMM • hh:mm a').format(date);
    } else {
      dateStr = DateFormat('d MMM yyyy • hh:mm a').format(date);
    }

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
      currency: currency,
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
  final Map<String, dynamic>? rawTotalsByCurrency;

  const DailyExpenseResponseModel({
    required this.status,
    required this.totalExpenditureMinor,
    required this.essentialExpenditureMinor,
    required this.nonEssentialExpenditureMinor,
    required this.items,
    this.rawTotalsByCurrency,
  });

  factory DailyExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    int totalMinor = _parseAmountToMinor(
      json['actual_total_expenditure'] ??
          json['total_expenditure'] ??
          json['total_spending'] ??
          json['total_amount'] ??
          json['totalAmount'],
    );
    int essentialMinor = _parseAmountToMinor(
      json['essential_expenditure'] ??
          json['essential_spending'] ??
          json['essential_amount'] ??
          json['essentialAmount'],
    );
    int nonEssentialMinor = _parseAmountToMinor(
      json['non_essential_expenditure'] ??
          json['non_essential_spending'] ??
          json['discretionary_amount'] ??
          json['discretionaryAmount'],
    );

    final rawTotals = json['totals_by_currency'] is Map<String, dynamic>
        ? json['totals_by_currency'] as Map<String, dynamic>
        : (json['totals_by_currency'] is Map
            ? Map<String, dynamic>.from(json['totals_by_currency'])
            : null);

    final rawData = json['data'] ?? json['expenses'] ?? json['items'];
    List<DailyExpenseItemModel> itemsList = [];
    if (rawData is List) {
      itemsList = rawData
          .whereType<Map<String, dynamic>>()
          .map(DailyExpenseItemModel.fromJson)
          .toList();
    }

    // Compute fallback sums if server returns 0 or missing in root aggregation
    if (itemsList.isNotEmpty) {
      final computedSum = itemsList.fold<int>(0, (sum, it) => sum + it.amountMinor);
      if (totalMinor <= 0 && computedSum > 0) {
        totalMinor = computedSum;
      }

      final computedEssential = itemsList
          .where((it) => it.tag == ExpenseTag.needed)
          .fold<int>(0, (sum, it) => sum + it.amountMinor);

      final computedNonEssential = itemsList
          .where((it) => it.tag == ExpenseTag.notNeeded)
          .fold<int>(0, (sum, it) => sum + it.amountMinor);

      if (essentialMinor <= 0 && nonEssentialMinor <= 0) {
        essentialMinor = computedEssential;
        nonEssentialMinor = computedNonEssential;
      } else if (essentialMinor <= 0 && computedEssential > 0) {
        essentialMinor = computedEssential;
      } else if (nonEssentialMinor <= 0 && computedNonEssential > 0) {
        nonEssentialMinor = computedNonEssential;
      }
    }

    return DailyExpenseResponseModel(
      status: json['status'] as String? ?? 'OK',
      totalExpenditureMinor: totalMinor,
      essentialExpenditureMinor: essentialMinor,
      nonEssentialExpenditureMinor: nonEssentialMinor,
      items: itemsList,
      rawTotalsByCurrency: rawTotals,
    );
  }

  factory DailyExpenseResponseModel.empty() {
    return const DailyExpenseResponseModel(
      status: 'OK',
      totalExpenditureMinor: 0,
      essentialExpenditureMinor: 0,
      nonEssentialExpenditureMinor: 0,
      items: [],
      rawTotalsByCurrency: null,
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
    AppCurrency currency = AppCurrency.inr,
  }) {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final activePeriod =
        '1 ${DateFormat('MMM').format(selectedDate)} – $daysInMonth ${DateFormat('MMM yyyy').format(selectedDate)}';
    final monthLabel = DateFormat('MMM yyyy').format(selectedDate);

    // Build recent expense list - sorted with newest/last added expense first
    final recentList = items.map((e) => e.toRecentExpenseItem()).toList();
    recentList.sort((a, b) {
      if (a.rawDate != null && b.rawDate != null) {
        final cmp = b.rawDate!.compareTo(a.rawDate!);
        if (cmp != 0) return cmp;
      }
      final numA = num.tryParse(a.id);
      final numB = num.tryParse(b.id);
      if (numA != null && numB != null) {
        final numCmp = numB.compareTo(numA);
        if (numCmp != 0) return numCmp;
      }
      return b.id.compareTo(a.id);
    });

    // Compute separate totals for EACH currency independently
    final Map<AppCurrency, CurrencyTotals> computedTotalsByCurrency = {};

    if (rawTotalsByCurrency != null && rawTotalsByCurrency!.isNotEmpty) {
      rawTotalsByCurrency!.forEach((code, data) {
        if (data is Map<String, dynamic>) {
          final curr = AppCurrency.fromCode(code);
          final count = items.where((it) => it.currency == curr).length;
          computedTotalsByCurrency[curr] = CurrencyTotals.fromJson(code, data, count: count);
        } else if (data is Map) {
          final curr = AppCurrency.fromCode(code);
          final count = items.where((it) => it.currency == curr).length;
          computedTotalsByCurrency[curr] =
              CurrencyTotals.fromJson(code, Map<String, dynamic>.from(data), count: count);
        }
      });
    }

    // Always ensure every currency present in items is represented with clean calculated totals
    for (final curr in AppCurrency.values) {
      final currencyItems = items.where((it) => it.currency == curr).toList();
      if (currencyItems.isNotEmpty) {
        final total = currencyItems.fold<int>(0, (sum, it) => sum + it.amountMinor);
        final essential = currencyItems
            .where((it) => it.tag == ExpenseTag.needed)
            .fold<int>(0, (sum, it) => sum + it.amountMinor);
        final nonEssential = currencyItems
            .where((it) => it.tag == ExpenseTag.notNeeded)
            .fold<int>(0, (sum, it) => sum + it.amountMinor);

        // If not already provided by backend or if backend total is 0 while items exist
        final existing = computedTotalsByCurrency[curr];
        if (existing == null || existing.totalExpenditureMinor <= 0) {
          computedTotalsByCurrency[curr] = CurrencyTotals(
            currency: curr,
            totalExpenditureMinor: total,
            essentialExpenditureMinor: essential,
            nonEssentialExpenditureMinor: nonEssential,
            expenseCount: currencyItems.length,
          );
        }
      }
    }

    // Determine primary display totals (for active or majority currency)
    // If only 1 currency present in items, use that currency's totals
    // If multiple present, use selected default currency if present, or first available
    final AppCurrency primaryCurrency = computedTotalsByCurrency.containsKey(currency)
        ? currency
        : (computedTotalsByCurrency.keys.isNotEmpty
            ? computedTotalsByCurrency.keys.first
            : currency);

    final CurrencyTotals? primaryTotals = computedTotalsByCurrency[primaryCurrency];

    final int effectiveTotal = primaryTotals?.totalExpenditureMinor ??
        (items.isEmpty ? 0 : totalExpenditureMinor);
    final int effectiveEssential = primaryTotals?.essentialExpenditureMinor ??
        (items.isEmpty ? 0 : essentialExpenditureMinor);
    final int effectiveNonEssential = primaryTotals?.nonEssentialExpenditureMinor ??
        (items.isEmpty ? 0 : nonEssentialExpenditureMinor);

    final int effectiveEssentialPct = effectiveTotal > 0
        ? ((effectiveEssential / effectiveTotal) * 100).round().clamp(0, 100)
        : 0;
    final int effectiveNonEssentialPct = effectiveTotal > 0
        ? ((effectiveNonEssential / effectiveTotal) * 100).round().clamp(0, 100)
        : 0;
    final int effectiveDailyAvg = daysInMonth > 0 ? (effectiveTotal / daysInMonth).round() : 0;

    // Group items for primary currency weekly spending trend
    final now = DateTime.now();
    final bool isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;
    final DateTime referenceDate = isCurrentMonth
        ? now
        : DateTime(selectedDate.year, selectedDate.month + 1, 0);

    // Build trend for 7 days ending at referenceDate for primaryCurrency
    final List<DateTime> sevenDays = [];
    for (int i = 6; i >= 0; i--) {
      sevenDays.add(referenceDate.subtract(Duration(days: i)));
    }

    final Map<int, int> dayAmounts = {};
    for (int i = 0; i < sevenDays.length; i++) {
      final targetDate = sevenDays[i];
      int sumMinor = 0;
      for (final item in items) {
        if (item.currency == primaryCurrency) {
          final sameDate = item.date.year == targetDate.year &&
              item.date.month == targetDate.month &&
              item.date.day == targetDate.day;
          final sameDayInMonth = (selectedDate.month == targetDate.month) && (item.date.day == targetDate.day);
          if (sameDate || sameDayInMonth) {
            sumMinor += item.amountMinor;
          }
        }
      }
      dayAmounts[i] = sumMinor;
    }

    int maxSpending = 0;
    for (final amt in dayAmounts.values) {
      if (amt > maxSpending) maxSpending = amt;
    }
    if (maxSpending <= 0) maxSpending = 1;

    final List<DailySpendingModel> trendList = [];
    for (int i = 0; i < sevenDays.length; i++) {
      final dayDate = sevenDays[i];
      final dayName = DateFormat('E').format(dayDate);
      final amount = dayAmounts[i] ?? 0;
      final double ratio = amount > 0 ? (amount / maxSpending).clamp(0.0, 1.0) : 0.0;
      final label = amount > 0
          ? primaryCurrency.formatMinor(amount, compact: true)
          : '${primaryCurrency.symbol}0';

      final isToday = isCurrentMonth &&
          dayDate.year == now.year &&
          dayDate.month == now.month &&
          dayDate.day == now.day;

      trendList.add(
        DailySpendingModel(
          day: dayName,
          amountMinor: amount,
          label: label,
          ratio: ratio,
          isToday: isToday,
        ),
      );
    }

    return DashboardSummaryModel(
      totalSpendingMinor: effectiveTotal,
      vsLastMonthPercentage: 0,
      dailyAverageMinor: effectiveDailyAvg,
      budgetLeftMinor: 0,
      budgetCapMinor: effectiveTotal,
      essentialAmountMinor: effectiveEssential,
      essentialPercentage: effectiveEssentialPct,
      discretionaryAmountMinor: effectiveNonEssential,
      discretionaryPercentage: effectiveNonEssentialPct,
      activePeriodLabel: activePeriod,
      formattedMonth: monthLabel,
      weeklyTrend: trendList,
      recentExpenses: recentList,
      totalsByCurrency: computedTotalsByCurrency,
      aiInsightText: effectiveTotal > 0
          ? 'Essential spending accounts for $effectiveEssentialPct% of total this month.'
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
