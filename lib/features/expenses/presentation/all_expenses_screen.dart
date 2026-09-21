import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/compact_month_year_picker_dialog.dart';
import 'package:mobymoney/core/widgets/shimmer_loading.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/recent_expense_tile.dart';
import 'package:mobymoney/features/expenses/domain/models/expense_filter_model.dart';
import 'package:mobymoney/features/expenses/presentation/widgets/expense_filter_bottom_sheet.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  ExpenseFilterModel _filter = const ExpenseFilterModel();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    ref.read(expensesSelectedDateProvider.notifier).previousMonth();
  }

  void _nextMonth() {
    ref.read(expensesSelectedDateProvider.notifier).nextMonth();
  }

  void _pickMonthYear() async {
    final cur = ref.read(expensesSelectedDateProvider);
    final picked = await CompactMonthYearPickerDialog.show(
      context,
      initialDate: cur,
    );

    if (picked != null && picked != cur) {
      ref.read(expensesSelectedDateProvider.notifier).updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(expensesSummaryProvider);
    final selectedDate = ref.watch(expensesSelectedDateProvider);
    final currency = ref.watch(currencyProvider);
    final monthName = DateFormat('MMMM yyyy').format(selectedDate);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
          'All Expenses',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButton.extended(
              onPressed: () => AddExpenseBottomSheet.show(context),
              backgroundColor: AppColors.primary,
              elevation: 4,
              icon: const PhosphorIcon(
                PhosphorIconsRegular.plusCircle,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Add Expense',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
      body: Column(
        children: [
          // 1. Month-Year Chooser Bar
          _buildMonthYearHeader(monthName),

          // 2. Main Content
          Expanded(
            child: dashboardAsync.when(
              loading: () => const ExpensesScreenShimmer(),
              error: (err, stack) => Center(
                child: Text(
                  err.toString(),
                  style: GoogleFonts.inter(color: AppColors.error),
                ),
              ),
              data: (summary) {
                // Apply Search & Filters
                var filtered = summary.recentExpenses.where((item) {
                  // Search query
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final matchTitle = item.title.toLowerCase().contains(q);
                    final matchCat =
                        item.categoryName.toLowerCase().contains(q);
                    if (!matchTitle && !matchCat) return false;
                  }

                  // Tag Filter
                  if (_filter.tag == ExpenseTagFilter.needed &&
                      item.tag != ExpenseTag.needed) {
                    return false;
                  }
                  if (_filter.tag == ExpenseTagFilter.notNeeded &&
                      item.tag != ExpenseTag.notNeeded) {
                    return false;
                  }

                  // Category Filter
                  if (_filter.expenseTypeId != null &&
                      item.expenseTypeId != _filter.expenseTypeId) {
                    return false;
                  }

                  return true;
                }).toList();

                // Apply Sorting
                switch (_filter.sortOrder) {
                  case ExpenseSortOrder.newest:
                    filtered.sort((a, b) => (b.rawDate ?? DateTime(2000))
                        .compareTo(a.rawDate ?? DateTime(2000)));
                    break;
                  case ExpenseSortOrder.oldest:
                    filtered.sort((a, b) => (a.rawDate ?? DateTime(2000))
                        .compareTo(b.rawDate ?? DateTime(2000)));
                    break;
                  case ExpenseSortOrder.highestAmount:
                    filtered.sort(
                        (a, b) => b.amountMinor.compareTo(a.amountMinor));
                    break;
                  case ExpenseSortOrder.lowestAmount:
                    filtered.sort(
                        (a, b) => a.amountMinor.compareTo(b.amountMinor));
                    break;
                }

                final totalSpentMinor = filtered.fold<int>(
                  0,
                  (sum, item) => sum + item.amountMinor,
                );
                final totalRupees = totalSpentMinor ~/ 100;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.read(expensesSelectedDateProvider.notifier).updateDate(DateTime.now());
                    await ref
                        .read(expensesSummaryProvider.notifier)
                        .loadExpensesData(date: DateTime.now());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                    children: [
                      // KPI Card
                      _buildSummaryCard(
                          totalRupees, filtered.length, summary, currency.symbol),

                      const SizedBox(height: 16),

                      // Search & Filter Row [Matching Image 1]
                      _buildSearchAndFilterRow(),

                      const SizedBox(height: 20),

                      // Header Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TRANSACTIONS',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.slate400,
                            ),
                          ),
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? "expense" : "expenses"}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Listings [Matching Image 2]
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map(
                          (expense) => RecentExpenseTile(
                            item: expense,
                            showActions: true,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearHeader(String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.slate200.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month
          InkWell(
            onTap: _previousMonth,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.caretLeft,
                  size: 16,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ),

          // Central Button
          GestureDetector(
            onTap: _pickMonthYear,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsRegular.calendarBlank,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const PhosphorIcon(
                    PhosphorIconsRegular.caretDown,
                    color: AppColors.slate500,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),

          // Next Month
          InkWell(
            onTap: _nextMonth,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    int totalRupees,
    int count,
    DashboardSummaryModel summary,
    String currencySymbol,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF115E59),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL SPENDING',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFFCCFBF1),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count expenses',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$currencySymbol${NumberFormat('#,##,###').format(totalRupees)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        // Rectangular Search Input (Request 2)
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.slate200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.magnifyingGlass,
                  color: AppColors.slate400,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppColors.neutralDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by merchant, note, or item...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.slate400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const PhosphorIcon(
                      PhosphorIconsRegular.xCircle,
                      color: AppColors.slate400,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Rectangular Filter Button
        GestureDetector(
          onTap: () {
            ExpenseFilterBottomSheet.show(
              context,
              currentFilter: _filter,
              onApply: (updated) {
                setState(() => _filter = updated);
              },
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _filter.isActive
                  ? AppColors.primary
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _filter.isActive
                    ? AppColors.primary
                    : const Color(0xFFA7F3D0),
                width: 1.2,
              ),
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.slidersHorizontal,
                color: _filter.isActive
                    ? Colors.white
                    : const Color(0xFF065F46),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.receipt,
                size: 26,
                color: AppColors.slate400,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Expenses Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _filter.isActive || _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'No expenses recorded for this month',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
