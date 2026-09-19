import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'add_expense_bottom_sheet.dart';

class RecentExpenseTile extends ConsumerWidget {
  const RecentExpenseTile({
    super.key,
    required this.item,
    this.onTap,
    this.showActions = false,
  });

  final RecentExpenseItemModel item;
  final VoidCallback? onTap;
  final bool showActions;

  IconData get _icon {
    switch (item.category) {
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
    switch (item.category) {
      case ExpenseCategory.foodDining:
        return const Color(0xFFFEF3C7); // Amber 100
      case ExpenseCategory.officeSupplies:
        return const Color(0xFFEEF2FF); // Indigo 50
      case ExpenseCategory.subscription:
        return const Color(0xFFFEE2E2); // Red 100
      case ExpenseCategory.transportation:
        return const Color(0xFFCCFBF1); // Teal 100
      default:
        return AppColors.slate100;
    }
  }

  Color get _iconColor {
    switch (item.category) {
      case ExpenseCategory.foodDining:
        return const Color(0xFFB45309); // Amber 700
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

  String get _amountFormatted {
    final rupees = item.amountMinor ~/ 100;
    return '-₹$rupees';
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final rupees = item.amountMinor ~/ 100;
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
              'Delete Expense?',
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
              'Are you sure you want to delete this expense? It will be removed from your spending analytics.',
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
                          item.title,
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
                          item.categoryName,
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
                        item.tag == ExpenseTag.needed ? 'Needed' : 'Discretionary',
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
                    ref.read(dashboardSummaryProvider.notifier).deleteExpense(item.id);
                    Navigator.of(ctx).pop();
                    AppSnackBar.showSuccess(context, 'Expense deleted successfully');
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
    return InkWell(
      onTap: onTap ??
          () {
            context.push(AppRoutes.expenseDetail, extra: item);
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.slate400.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
        children: [
          // Category Icon
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
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Category/Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate300,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.timeFormatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount & Tag Pill or Action Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _amountFormatted,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.tag == ExpenseTag.needed
                          ? AppColors.tertiaryContainer.withValues(alpha: 0.6)
                          : AppColors.inputFieldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.tag == ExpenseTag.needed ? 'Needed' : 'Not Needed',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.tag == ExpenseTag.needed
                            ? AppColors.tertiaryDark
                            : AppColors.slate500,
                      ),
                    ),
                  ),
                  if (showActions) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        AddExpenseDialog.show(context, existingExpense: item);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.pencilSimple,
                          size: 14,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _showDeleteConfirmation(context, ref),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsRegular.trash,
                          size: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
