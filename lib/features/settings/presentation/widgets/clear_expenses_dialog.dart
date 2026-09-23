import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';

class ClearExpensesDialog extends ConsumerStatefulWidget {
  const ClearExpensesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const ClearExpensesDialog(),
    );
  }

  @override
  ConsumerState<ClearExpensesDialog> createState() => _ClearExpensesDialogState();
}

class _ClearExpensesDialogState extends ConsumerState<ClearExpensesDialog> {
  bool _isMonthly = true;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isDeleting = false;

  late final List<int> _years;
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final curYear = DateTime.now().year;
    _years = [curYear - 2, curYear - 1, curYear, curYear + 1];
  }

  Future<void> _handleDelete() async {
    final periodName = _isMonthly
        ? '${_months[_selectedMonth - 1]} $_selectedYear'
        : 'Full Year $_selectedYear';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Final Confirmation',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you absolutely sure you want to permanently delete all expenses for $periodName? This cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: AppColors.slate600,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.slate600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              'Yes, Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(dashboardSummaryProvider.notifier).deleteBulkExpenses(
            year: _selectedYear,
            month: _isMonthly ? _selectedMonth : null,
          );

      // Also refresh chart data
      ref.read(chartDataProvider.notifier).refresh();

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(
          context,
          'All expenses for $periodName were deleted successfully.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to delete expenses: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodName = _isMonthly
        ? '${_months[_selectedMonth - 1]} $_selectedYear'
        : 'the entire year $_selectedYear';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const PhosphorIcon(
                    PhosphorIconsRegular.trash,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clear Expense History',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bulk delete expense records',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 18,
                    color: AppColors.slate400,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Mode Selector: Monthly vs Yearly
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isMonthly = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isMonthly ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _isMonthly
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            'Monthly Records',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: _isMonthly ? FontWeight.w700 : FontWeight.w500,
                              color: _isMonthly ? AppColors.neutralDark : AppColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isMonthly = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isMonthly ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: !_isMonthly
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            'Full Year Records',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: !_isMonthly ? FontWeight.w700 : FontWeight.w500,
                              color: !_isMonthly ? AppColors.neutralDark : AppColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Dropdowns
            Row(
              children: [
                // Year selection
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFieldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            icon: const PhosphorIcon(PhosphorIconsRegular.caretDown, size: 14),
                            items: _years.map((y) {
                              return DropdownMenuItem(
                                value: y,
                                child: Text(
                                  '$y',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedYear = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isMonthly) ...[
                  const SizedBox(width: 12),
                  // Month selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Month',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.inputFieldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedMonth,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              icon: const PhosphorIcon(PhosphorIconsRegular.caretDown, size: 14),
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(
                                    _months[index],
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neutralDark,
                                    ),
                                  ),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedMonth = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),

            // 4. Warning Alert Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.warning,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Warning: All expenses recorded in $periodName will be deleted permanently. This action cannot be reversed.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF991B1B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 5. Action Buttons Row: [Cancel] & [Delete Records]
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.slate300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _handleDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const PhosphorIcon(PhosphorIconsRegular.trash, size: 18),
                    label: Text(
                      _isDeleting ? 'Deleting...' : 'Clear Records',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
}
