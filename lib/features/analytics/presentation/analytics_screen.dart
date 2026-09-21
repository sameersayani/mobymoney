import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/compact_month_year_picker_dialog.dart';
import 'package:mobymoney/core/widgets/shimmer_loading.dart';
import 'package:mobymoney/features/analytics/domain/models/chart_data_model.dart';
import 'package:mobymoney/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/dashboard_header_app_bar.dart';
import 'package:mobymoney/features/settings/presentation/widgets/profile_drawer.dart';
import 'widgets/bar_chart_widget.dart';
import 'widgets/line_chart_widget.dart';
import 'widgets/pie_chart_widget.dart';

enum ChartType { pie, bar, line }

class AnalyticsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenDrawer;
  const AnalyticsScreen({super.key, this.onOpenDrawer});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ChartType _selectedChartType = ChartType.pie;

  void _previousMonth() {
    ref.read(analyticsSelectedDateProvider.notifier).previousMonth();
  }

  void _nextMonth() {
    ref.read(analyticsSelectedDateProvider.notifier).nextMonth();
  }

  void _pickMonthYear() async {
    final cur = ref.read(analyticsSelectedDateProvider);
    final picked = await CompactMonthYearPickerDialog.show(
      context,
      initialDate: cur,
    );

    if (picked != null && picked != cur) {
      ref.read(analyticsSelectedDateProvider.notifier).updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final dashboardAsync = ref.watch(analyticsSummaryProvider);
    final chartDataAsync = ref.watch(chartDataProvider);
    final selectedDate = ref.watch(analyticsSelectedDateProvider);
    final monthName = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.onOpenDrawer == null ? const ProfileDrawer() : null,
      backgroundColor: AppColors.background,
      appBar: DashboardHeaderAppBar(
        user: user,
        subtitle: 'ANALYTICS',
        onMenuTap: widget.onOpenDrawer ?? () => _scaffoldKey.currentState?.openDrawer(),
        onAvatarTap: widget.onOpenDrawer ?? () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: Column(
        children: [
          // 1. Month & Year Chooser Header (Matching Expense Page)
          _buildHeader(monthName),

          // Main Scrollable Analytics Body
          Expanded(
            child: dashboardAsync.when(
              loading: () => const AnalyticsScreenShimmer(),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.warningCircle,
                        color: AppColors.error,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.error),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(analyticsSummaryProvider.notifier).refresh();
                          ref.read(chartDataProvider.notifier).refresh();
                        },
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.arrowClockwise,
                          size: 16,
                        ),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (summary) {
                final chartData =
                    chartDataAsync.asData?.value ?? ChartDataModel.empty();
                final categoryData = chartData.categories;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.read(analyticsSelectedDateProvider.notifier).updateDate(DateTime.now());
                    await Future.wait([
                      ref.read(analyticsSummaryProvider.notifier).loadAnalyticsData(date: DateTime.now()),
                      ref.read(chartDataProvider.notifier).refresh(date: DateTime.now()),
                    ]);
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
                      _buildActiveChart(
                        summary,
                        categoryData,
                        chartDataAsync.isLoading,
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

          // Central Month & Year Selector Button (Matching Expenses Screen)
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
    bool isLoadingChart,
  ) {
    if (isLoadingChart) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.slate200),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    switch (_selectedChartType) {
      case ChartType.pie:
        if (categoryData.isEmpty) {
          return Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PhosphorIcon(
                  PhosphorIconsRegular.chartPieSlice,
                  size: 40,
                  color: AppColors.slate300,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Category Spending Data',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log expenses for this month to see category breakdown.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          );
        }
        final catTotal = categoryData.fold<int>(0, (s, c) => s + c.amountMinor);
        return PieChartWidget(
          categories: categoryData,
          totalAmountMinor: summary.totalSpendingMinor > 0
              ? summary.totalSpendingMinor
              : catTotal,
        );
      case ChartType.bar:
        return BarChartWidget(
          dailyTrend: summary.weeklyTrend,
          budgetCapMinor: summary.budgetCapMinor,
        );
      case ChartType.line:
        return LineChartWidget(dailyTrend: summary.weeklyTrend);
    }
  }
}
