import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/expenses/domain/models/expense_filter_model.dart';
import 'package:mobymoney/features/expenses/presentation/providers/expense_types_provider.dart';

class ExpenseFilterBottomSheet extends ConsumerStatefulWidget {
  const ExpenseFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  final ExpenseFilterModel initialFilter;
  final ValueChanged<ExpenseFilterModel> onApply;

  static Future<void> show(
    BuildContext context, {
    required ExpenseFilterModel currentFilter,
    required ValueChanged<ExpenseFilterModel> onApply,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ExpenseFilterBottomSheet(
        initialFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  ConsumerState<ExpenseFilterBottomSheet> createState() =>
      _ExpenseFilterBottomSheetState();
}

class _ExpenseFilterBottomSheetState
    extends ConsumerState<ExpenseFilterBottomSheet> {
  late ExpenseTagFilter _tag;
  late int? _expenseTypeId;
  late ExpenseSortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    _tag = widget.initialFilter.tag;
    _expenseTypeId = widget.initialFilter.expenseTypeId;
    _sortOrder = widget.initialFilter.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(expenseTypesProvider);
    final categories = typesAsync.asData?.value ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const PhosphorIcon(
                          PhosphorIconsBold.slidersHorizontal,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Filter Expenses',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tag = ExpenseTagFilter.all;
                      _expenseTypeId = null;
                      _sortOrder = ExpenseSortOrder.newest;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset All',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
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

            const Divider(color: Color(0xFFF1F5F9), height: 22),

            // Scrollable Filters Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Tag / Necessity Filter
                    Text(
                      'EXPENSE TYPE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTagChip(ExpenseTagFilter.all, 'All'),
                        _buildTagChip(ExpenseTagFilter.needed, 'Needed (Essential)'),
                        _buildTagChip(ExpenseTagFilter.notNeeded, 'Not Needed (Over Spend)'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. Category Filter
                    Text(
                      'CATEGORY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCategoryChip(null, 'All Categories'),
                        ...categories.map(
                          (cat) => _buildCategoryChip(cat.id, cat.name),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 3. Sort Order
                    Text(
                      'SORT BY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExpenseSortOrder.values.map((order) {
                        final isSelected = _sortOrder == order;
                        return ChoiceChip(
                          label: Text(order.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _sortOrder = order);
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.inputFieldBg,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.slate600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.slate200,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.slate200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = ExpenseFilterModel(
                        tag: _tag,
                        expenseTypeId: _expenseTypeId,
                        sortOrder: _sortOrder,
                      );
                      widget.onApply(updated);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
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

  Widget _buildTagChip(ExpenseTagFilter tag, String label) {
    final isSelected = _tag == tag;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _tag = tag);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.inputFieldBg,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.slate600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.slate200,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCategoryChip(int? typeId, String label) {
    final isSelected = _expenseTypeId == typeId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _expenseTypeId = typeId);
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.inputFieldBg,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.slate600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.slate200,
        ),
      ),
      showCheckmark: false,
    );
  }
}
