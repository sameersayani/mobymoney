import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/compact_month_year_picker_dialog.dart';
import 'package:mobymoney/core/widgets/shimmer_loading.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/dashboard_header_app_bar.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/recent_expense_tile.dart';
import 'package:mobymoney/features/expenses/domain/models/expense_filter_model.dart';
import 'package:mobymoney/features/expenses/presentation/widgets/expense_filter_bottom_sheet.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

import 'package:mobymoney/features/settings/presentation/widgets/profile_drawer.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenDrawer;
  const ExpensesScreen({super.key, this.onOpenDrawer});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void _openFilterSheet() {
    ExpenseFilterBottomSheet.show(
      context,
      currentFilter: _filter,
      onApply: (newFilter) {
        setState(() {
          _filter = newFilter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final dashboardAsync = ref.watch(expensesSummaryProvider);
    final selectedDate = ref.watch(expensesSelectedDateProvider);
    final monthName = DateFormat('MMMM yyyy').format(selectedDate);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.onOpenDrawer == null ? const ProfileDrawer() : null,
      backgroundColor: AppColors.background,
      appBar: DashboardHeaderAppBar(
        user: user,
        subtitle: 'EXPENSES',
        onMenuTap: widget.onOpenDrawer ?? () => _scaffoldKey.currentState?.openDrawer(),
        onAvatarTap: widget.onOpenDrawer ?? () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: Column(
        children: [
          // 1. Date Chooser Header (Below the AppBar)
          _buildMonthYearHeader(monthName),

          // Main Content Area
          Expanded(
            child: dashboardAsync.when(
              loading: () => const ExpensesScreenShimmer(),
              error: (err, stack) => _ExpensesErrorWidget(
                error: err,
                onRetry: () =>
                    ref.read(expensesSummaryProvider.notifier).refresh(),
              ),
              data: (summary) {
                // Filter expenses based on search and selected filters
                final filtered = summary.recentExpenses.where((item) {
                  // Search query
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final matchTitle = item.title.toLowerCase().contains(q);
                    final matchCat = item.categoryName.toLowerCase().contains(q);
                    if (!matchTitle && !matchCat) return false;
                  }

                  // Tag filter
                  if (_filter.tag == ExpenseTagFilter.needed &&
                      item.tag != ExpenseTag.needed) {
                    return false;
                  }
                  if (_filter.tag == ExpenseTagFilter.notNeeded &&
                      item.tag != ExpenseTag.notNeeded) {
                    return false;
                  }

                  // Category filter
                  if (_filter.expenseTypeId != null &&
                      item.expenseTypeId != _filter.expenseTypeId) {
                    return false;
                  }

                  // Min amount filter
                  if (_filter.minAmount != null &&
                      (item.amountMinor / 100) < _filter.minAmount!) {
                    return false;
                  }

                  // Max amount filter
                  if (_filter.maxAmount != null &&
                      (item.amountMinor / 100) > _filter.maxAmount!) {
                    return false;
                  }

                  return true;
                }).toList();

                // Apply Sorting
                switch (_filter.sortOrder) {
                  case ExpenseSortOrder.newest:
                    if (filtered.isNotEmpty && filtered.first.rawDate != null) {
                      filtered.sort((a, b) =>
                          (b.rawDate ?? DateTime(2000)).compareTo(a.rawDate ?? DateTime(2000)));
                    }
                    break;
                  case ExpenseSortOrder.oldest:
                    if (filtered.isNotEmpty && filtered.first.rawDate != null) {
                      filtered.sort((a, b) =>
                          (a.rawDate ?? DateTime(2000)).compareTo(b.rawDate ?? DateTime(2000)));
                    }
                    break;
                  case ExpenseSortOrder.highestAmount:
                    filtered.sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
                    break;
                  case ExpenseSortOrder.lowestAmount:
                    filtered.sort((a, b) => a.amountMinor.compareTo(b.amountMinor));
                    break;
                }

                // Calculate summary totals
                final totalSpentMinor = filtered.fold<int>(
                  0,
                  (sum, item) => sum + item.amountMinor,
                );
                final totalAmount = totalSpentMinor ~/ 100;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.read(expensesSelectedDateProvider.notifier).updateDate(DateTime.now());
                    await ref.read(expensesSummaryProvider.notifier).loadExpensesData(date: DateTime.now());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    children: [
                      // 2. Spending Summary Card
                      _buildSummaryKpiCard(totalAmount, filtered.length, summary, currency.symbol),

                      const SizedBox(height: 16),

                      // 3. Search Bar + Filter Button (Image 1 Layout)
                      _buildSearchBar(),

                      const SizedBox(height: 20),

                      // 4. Listings Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expenses',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.slate400,
                            ),
                          ),
                          Text(
                            '${filtered.length} items',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 5. Expense Listings with Edit and Delete
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
          // Previous Month Arrow
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

          // Central Month & Year Selector Button (Matching Home Screen)
          GestureDetector(
            onTap: _pickMonthYear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

          // Next Month Arrow
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

  Widget _buildSummaryKpiCard(
    int totalAmount,
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
              Flexible(
                child: Text(
                  'Total Spend for this period',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$currencySymbol${NumberFormat('#,##,###').format(totalAmount)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Split Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: summary.essentialPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: summary.discretionaryPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.discretionary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Essential: ${summary.essentialPercentage}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF87171),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Over Spend: ${summary.discretionaryPercentage}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final hasActiveFilter = _filter.isActive;

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
                color: AppColors.slate200.withValues(alpha: 0.8),
                width: 1.2,
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
                  size: 20,
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

        // Rectangular Filter Button (Image 1 Layout)
        InkWell(
          onTap: _openFilterSheet,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasActiveFilter
                  ? AppColors.primary
                  : const Color(0xFFD1FAE5), // Soft mint green from Image 1
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasActiveFilter
                    ? AppColors.primary
                    : const Color(0xFFA7F3D0),
                width: 1.2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsRegular.slidersHorizontal,
                  color: hasActiveFilter ? Colors.white : const Color(0xFF065F46),
                  size: 22,
                ),
                if (hasActiveFilter)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.receipt,
                size: 28,
                color: AppColors.slate400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Expenses Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Production-grade error state for the Expenses screen
// ─────────────────────────────────────────────────────────────────────────────

class _ExpensesErrorWidget extends StatefulWidget {
  const _ExpensesErrorWidget({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  State<_ExpensesErrorWidget> createState() => _ExpensesErrorWidgetState();
}

class _ExpensesErrorWidgetState extends State<_ExpensesErrorWidget>
    with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _cleanMessage(Object err) {
    final raw = err.toString();
    // Strip the "Exception: " / "NetworkException: " prefix added by Dart
    return raw
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^NetworkException:\s*'), '');
  }

  bool _isNetworkError(Object err) {
    final msg = err.toString().toLowerCase();
    return msg.contains('timed out') ||
        msg.contains('internet') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('reach the server');
  }

  Future<void> _handleRetry() async {
    // Brief visual feedback before delegating to the notifier
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(milliseconds: 150));
    widget.onRetry();
    // Keep the loading indicator for a tick so it feels responsive
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = _isNetworkError(widget.error);
    final message = _cleanMessage(widget.error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon circle ────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isNetwork
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    isNetwork
                        ? PhosphorIconsRegular.wifiSlash
                        : PhosphorIconsRegular.warning,
                    size: 36,
                    color: isNetwork
                        ? const Color(0xFFF57C00)
                        : AppColors.error,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ───────────────────────────────────────────────────────
            Text(
              isNetwork ? 'No Connection' : 'Something Went Wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // ── Message ─────────────────────────────────────────────────────
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slate500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // ── Retry button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRetrying ? null : _handleRetry,
                icon: _isRetrying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const PhosphorIcon(
                        PhosphorIconsRegular.arrowClockwise,
                        size: 18,
                        color: Colors.white,
                      ),
                label: Text(
                  _isRetrying ? 'Retrying...' : 'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Pull-to-refresh hint ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.arrowDown,
                  size: 12,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Or pull down to refresh',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.slate400,
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
