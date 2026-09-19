import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/add_expense_bottom_sheet.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  final RecentExpenseItemModel expense;

  IconData get _icon {
    switch (expense.category) {
      case ExpenseCategory.foodDining:
        return PhosphorIconsRegular.coffee;
      case ExpenseCategory.officeSupplies:
        return PhosphorIconsRegular.bagSimple;
      case ExpenseCategory.subscription:
        return PhosphorIconsRegular.filmSlate;
      case ExpenseCategory.transportation:
        return PhosphorIconsRegular.taxi;
      default:
        return PhosphorIconsRegular.receipt;
    }
  }

  Color get _iconBgColor {
    switch (expense.category) {
      case ExpenseCategory.foodDining:
        return const Color(0xFFFEF3C7);
      case ExpenseCategory.officeSupplies:
        return const Color(0xFFEEF2FF);
      case ExpenseCategory.subscription:
        return const Color(0xFFFEE2E2);
      case ExpenseCategory.transportation:
        return const Color(0xFFCCFBF1);
      default:
        return AppColors.slate100;
    }
  }

  Color get _iconColor {
    switch (expense.category) {
      case ExpenseCategory.foodDining:
        return const Color(0xFFB45309);
      case ExpenseCategory.officeSupplies:
        return AppColors.secondary;
      case ExpenseCategory.subscription:
        return AppColors.error;
      case ExpenseCategory.transportation:
        return AppColors.primary;
      default:
        return AppColors.slate600;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final rupees = expense.amountMinor ~/ 100;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.trash,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Transaction?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete this expense? Your monthly spending totals will be recalculated.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Expense Details Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputFieldBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        _icon,
                        color: _iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          expense.categoryName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$rupees',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expense.tag == ExpenseTag.needed ? 'Needed' : 'Discretionary',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.slate200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(dashboardSummaryProvider.notifier).deleteExpense(expense.id);
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                    AppSnackBar.showSuccess(context, 'Expense removed successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current state to see if updated
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final currentItem = dashboardAsync.asData?.value.recentExpenses.firstWhere(
          (e) => e.id == expense.id,
          orElse: () => expense,
        ) ??
        expense;

    final rupees = currentItem.amountMinor ~/ 100;
    final isNeeded = currentItem.tag == ExpenseTag.needed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsRegular.arrowLeft,
            color: AppColors.neutralDark,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transaction Details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsRegular.pencilSimple,
              color: AppColors.slate700,
              size: 20,
            ),
            onPressed: () {
              AddExpenseDialog.show(context, existingExpense: currentItem);
            },
          ),
          IconButton(
            icon: const PhosphorIcon(
              PhosphorIconsRegular.trash,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          children: [
            // Receipt Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.slate200.withValues(alpha: 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: _iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        _icon,
                        color: _iconColor,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    currentItem.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Category subtitle
                  Text(
                    currentItem.categoryName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Big Amount Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹${NumberFormat('#,##,###').format(rupees)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dashed separator
                  Row(
                    children: List.generate(
                      24,
                      (index) => Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: AppColors.slate200,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Rows
                  _buildDetailRow(
                    icon: PhosphorIconsRegular.calendarBlank,
                    label: 'Date & Time',
                    value: currentItem.timeFormatted,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: PhosphorIconsRegular.tag,
                    label: 'Expense Type',
                    value: currentItem.categoryName,
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: PhosphorIconsRegular.sparkle,
                    label: 'Priority Tag',
                    widgetValue: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isNeeded
                            ? AppColors.tertiaryContainer.withValues(alpha: 0.6)
                            : AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isNeeded ? 'Needed (Essential)' : 'Not Needed (Discretionary)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isNeeded ? AppColors.tertiaryDark : AppColors.slate600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: PhosphorIconsRegular.hash,
                    label: 'Transaction ID',
                    value: 'TXN-#${currentItem.id.padLeft(6, '0')}',
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    icon: PhosphorIconsRegular.checkCircle,
                    label: 'Payment Status',
                    widgetValue: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Paid / Cleared',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AddExpenseDialog.show(context, existingExpense: currentItem);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.white,
                    ),
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.pencilSimple,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Edit Expense',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorContainer.withValues(alpha: 0.8),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const PhosphorIcon(
                      PhosphorIconsRegular.trash,
                      color: AppColors.error,
                      size: 18,
                    ),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? widgetValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              icon,
              size: 16,
              color: AppColors.slate400,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        if (value != null)
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
          )
        else if (widgetValue != null)
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: widgetValue,
            ),
          ),
      ],
    );
  }
}
