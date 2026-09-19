import 'package:intl/intl.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class ExpenseExportService {
  /// Generates a structured CSV formatted string representing an Excel spreadsheet report.
  /// If [month] is provided (1-12), generates a monthly report.
  /// If [month] is null, generates a full yearly report.
  static String generateReport({
    required List<RecentExpenseItemModel> expenses,
    required int year,
    int? month,
  }) {
    final buffer = StringBuffer();

    // Report Header
    final periodName = month != null
        ? '${DateFormat('MMMM').format(DateTime(year, month))} $year'
        : 'Full Year $year';

    buffer.writeln('MobyMoney - Expense Report');
    buffer.writeln('Report Period: $periodName');
    buffer.writeln('Generated On: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('Currency: INR (₹)');
    buffer.writeln(''); // Empty line

    // Column Headers
    buffer.writeln('ID,Date / Time,Expense Title,Category,Priority Tag,Amount (INR)');

    int totalMinor = 0;
    int neededMinor = 0;
    int discretionaryMinor = 0;

    for (final item in expenses) {
      final rupees = item.amountMinor / 100.0;
      totalMinor += item.amountMinor;

      if (item.tag == ExpenseTag.needed) {
        neededMinor += item.amountMinor;
      } else {
        discretionaryMinor += item.amountMinor;
      }

      final cleanTitle = '"${item.title.replaceAll('"', '""')}"';
      final cleanCategory = '"${item.categoryName.replaceAll('"', '""')}"';
      final tagStr = item.tag == ExpenseTag.needed ? 'Essential' : 'Discretionary';

      buffer.writeln('${item.id},"${item.timeFormatted}",$cleanTitle,$cleanCategory,$tagStr,${rupees.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('Total Expenses Count,${expenses.length}');
    buffer.writeln('Total Essential Spending (₹),${(neededMinor / 100.0).toStringAsFixed(2)}');
    buffer.writeln('Total Discretionary Spending (₹),${(discretionaryMinor / 100.0).toStringAsFixed(2)}');
    buffer.writeln('Grand Total Spending (₹),${(totalMinor / 100.0).toStringAsFixed(2)}');

    return buffer.toString();
  }
}
