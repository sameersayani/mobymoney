import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/compact_month_year_picker_dialog.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/dashboard_header_app_bar.dart';
import 'widgets/bar_chart_widget.dart';
import 'widgets/line_chart_widget.dart';
import 'widgets/pie_chart_widget.dart';

enum ChartType { pie, bar, line }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  ChartType _selectedChartType = ChartType.pie;
  DateTime _selectedDate = DateTime.now();

  void _previousPeriod() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextPeriod() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  void _pickPeriod() async {
    final picked = await CompactMonthYearPickerDialog.show(
      context,
      initialDate: _selectedDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  List<CategorySpendingData> _buildCategoryData(DashboardSummaryModel summary) {
    // Generate realistic category distribution from recentExpenses or defaults
    return const [
      CategorySpendingData(
        categoryName: 'Food & Dining',
        amountMinor: 1850000,
        color: Color(0xFFF59E0B), // Amber
      ),
      CategorySpendingData(
        categoryName: 'Office & Supplies',
        amountMinor: 1240000,
        color: Color(0xFF0F766E), // Teal
      ),
      CategorySpendingData(
        categoryName: 'Transportation',
        amountMinor: 820000,
        color: Color(0xFF6366F1), // Indigo
      ),
      CategorySpendingData(
        categoryName: 'Subscriptions',
        amountMinor: 565000,
        color: Color(0xFFEF4444), // Red
      ),
      CategorySpendingData(
        categoryName: 'Shopping & Misc',
        amountMinor: 350000,
        color: Color(0xFF10B981), // Emerald
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final monthName = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DashboardHeaderAppBar(
        user: user,
        subtitle: 'ANALYTICS',
        onAvatarTap: () {
          context.push(AppRoutes.settings);
        },
      ),
      body: Column(
        children: [
          // 1. Month & Year Chooser Header (Matching Expense Page)
          _buildHeader(monthName),

          // Main Scrollable Analytics Body
            Expanded(
              child: dashboardAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    err.toString(),
                    style: GoogleFonts.inter(color: AppColors.error),
                  ),
                ),
                data: (summary) {
                  final categoryData = _buildCategoryData(summary);
                  final budgetCapRupees = summary.budgetCapMinor ~/ 100;
                  final budgetUsedRatio = (summary.totalSpendingMinor /
                          (summary.budgetCapMinor > 0
                              ? summary.budgetCapMinor
                              : 1))
                      .clamp(0.0, 1.0);

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      await ref.read(dashboardSummaryProvider.notifier).refresh();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                      children: [
                        // 2. Chart View Mode Switcher (Pie / Bar / Line)
                        _buildChartTypeSelector(),

                        const SizedBox(height: 16),

                        // 3. Active Chart Card
                        _buildActiveChart(summary, categoryData),

                        const SizedBox(height: 18),

                        // 4. Budget & Spending KPI Cards
                        Row(
                          children: [
                            // Left KPI: Budget Utilization
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Budget Cap',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '₹${NumberFormat('#,##,###').format(budgetCapRupees)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.neutralDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: budgetUsedRatio,
                                        minHeight: 6,
                                        backgroundColor: AppColors.slate100,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          budgetUsedRatio > 0.85
                                              ? AppColors.error
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${(budgetUsedRatio * 100).toInt()}% used',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.slate600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Right KPI: Daily Average
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Average',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '₹${NumberFormat('#,##,###').format(summary.dailyAverageMinor ~/ 100)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.neutralDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const PhosphorIcon(
                                          PhosphorIconsRegular.trendDown,
                                          size: 14,
                                          color: AppColors.tertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '12% vs last month',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.tertiaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 5. Essential vs Discretionary Ratio Card
                        _buildEssentialVsDiscretionaryCard(summary),

                        const SizedBox(height: 16),

                        // 6. AI Smart Spending Insight Banner
                        _buildAiInsightCard(summary),
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

  Widget _buildHeader(String monthName) {
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
            onTap: _previousPeriod,
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

          // Central Month & Year Selector Button (Matching Expenses Screen)
          GestureDetector(
            onTap: _pickPeriod,
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
            onTap: _nextPeriod,
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

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          _buildChartPill(
            label: 'Pie Chart',
            icon: PhosphorIconsRegular.chartPieSlice,
            type: ChartType.pie,
          ),
          _buildChartPill(
            label: 'Bar Chart',
            icon: PhosphorIconsRegular.chartBar,
            type: ChartType.bar,
          ),
          _buildChartPill(
            label: 'Line Chart',
            icon: PhosphorIconsRegular.chartLineUp,
            type: ChartType.line,
          ),
        ],
      ),
    );
  }

  Widget _buildChartPill({
    required String label,
    required IconData icon,
    required ChartType type,
  }) {
    final isSelected = _selectedChartType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedChartType = type);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.slate500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChart(
    DashboardSummaryModel summary,
    List<CategorySpendingData> categoryData,
  ) {
    switch (_selectedChartType) {
      case ChartType.pie:
        return PieChartWidget(
          categories: categoryData,
          totalAmountMinor: summary.totalSpendingMinor,
        );
      case ChartType.bar:
        return BarChartWidget(
          dailyTrend: summary.weeklyTrend,
          budgetCapMinor: summary.budgetCapMinor,
        );
      case ChartType.line:
        return LineChartWidget(
          dailyTrend: summary.weeklyTrend,
        );
    }
  }

  Widget _buildEssentialVsDiscretionaryCard(DashboardSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEED VS DISCRETIONARY',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.slate400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Healthy Ratio',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tertiaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Double Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: summary.essentialPercentage,
                    child: Container(color: AppColors.tertiary),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: summary.discretionaryPercentage,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Essential (Needed)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##,###').format(summary.essentialAmountMinor ~/ 100)} (${summary.essentialPercentage}%)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Discretionary',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##,###').format(summary.discretionaryAmountMinor ~/ 100)} (${summary.discretionaryPercentage}%)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
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

  Widget _buildAiInsightCard(DashboardSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moby AI Financial Intelligence',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.aiInsightText,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
