import 'package:intl/intl.dart';
import 'package:mobymoney/core/constants/app_currency.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class ExpenseExportService {
  /// Generates a structured CSV formatted string representing an Excel spreadsheet report.
  /// If [month] is provided (1-12), generates a monthly report.
  /// If [month] is null, generates a full yearly report.
  static String generateReport({
    required List<RecentExpenseItemModel> expenses,
    required int year,
    int? month,
    AppCurrency currency = AppCurrency.inr,
  }) {
    final buffer = StringBuffer();

    // Report Header
    final periodName = month != null
        ? '${DateFormat('MMMM').format(DateTime(year, month))} $year'
        : 'Full Year $year';

    buffer.writeln('MobyMoney - Expense Report');
    buffer.writeln('Report Period: $periodName');
    buffer.writeln('Generated On: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('Currency: ${currency.name} (${currency.symbol})');
    buffer.writeln(''); // Empty line

    // Column Headers
    buffer.writeln('ID,Date / Time,Expense Title,Category,Currency,Priority Tag,Amount');

    final Map<AppCurrency, int> currencyTotals = {};
    final Map<AppCurrency, int> currencyNeeded = {};
    final Map<AppCurrency, int> currencyDiscretionary = {};

    for (final item in expenses) {
      final amt = item.amountMinor / 100.0;
      currencyTotals[item.currency] = (currencyTotals[item.currency] ?? 0) + item.amountMinor;

      if (item.tag == ExpenseTag.needed) {
        currencyNeeded[item.currency] = (currencyNeeded[item.currency] ?? 0) + item.amountMinor;
      } else {
        currencyDiscretionary[item.currency] = (currencyDiscretionary[item.currency] ?? 0) + item.amountMinor;
      }

      final cleanTitle = '"${item.title.replaceAll('"', '""')}"';
      final cleanCategory = '"${item.categoryName.replaceAll('"', '""')}"';
      final tagStr = item.tag == ExpenseTag.needed ? 'Essential' : 'Discretionary';

      buffer.writeln('${item.id},"${item.timeFormatted}",$cleanTitle,$cleanCategory,${item.currency.code},$tagStr,${item.currency.symbol}${amt.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('SUMMARY (SEPARATE TOTALS BY CURRENCY)');
    buffer.writeln('Total Expenses Count,${expenses.length}');
    for (final curr in currencyTotals.keys) {
      final total = (currencyTotals[curr] ?? 0) / 100.0;
      final essential = (currencyNeeded[curr] ?? 0) / 100.0;
      final discretionary = (currencyDiscretionary[curr] ?? 0) / 100.0;
      buffer.writeln('${curr.code} Total Spending (${curr.symbol}),${total.toStringAsFixed(2)}');
      buffer.writeln('${curr.code} Essential Spending (${curr.symbol}),${essential.toStringAsFixed(2)}');
      buffer.writeln('${curr.code} Discretionary Spending (${curr.symbol}),${discretionary.toStringAsFixed(2)}');
    }

    return buffer.toString();
  }
}
