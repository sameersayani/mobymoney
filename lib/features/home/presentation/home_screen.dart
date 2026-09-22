import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_error_widget.dart';
import 'package:mobymoney/core/widgets/compact_month_year_picker_dialog.dart';
import 'package:mobymoney/core/widgets/shimmer_loading.dart';
import 'package:mobymoney/features/ai_chat/presentation/ai_chat_screen.dart';
import 'package:mobymoney/features/analytics/presentation/analytics_screen.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/dashboard_header_app_bar.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/recent_expense_tile.dart';
import 'package:mobymoney/features/dashboard/presentation/widgets/spending_trends_widget.dart';
import 'package:mobymoney/features/expenses/presentation/expenses_screen.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';
import 'package:mobymoney/features/settings/presentation/widgets/profile_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentNavIndex = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  String _getUserDisplayName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'User';
    return fullName.trim();
  }

  void _pickDate(BuildContext context) async {
    final currentDate = ref.read(selectedDateProvider);
    final picked = await CompactMonthYearPickerDialog.show(
      context,
      initialDate: currentDate,
    );

    if (picked != null && picked != currentDate) {
      ref.read(selectedDateProvider.notifier).updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const ProfileDrawer(),
      backgroundColor: AppColors.background,
      appBar: _currentNavIndex == 0
          ? DashboardHeaderAppBar(
              user: user,
              onMenuTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              onAvatarTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (_currentNavIndex <= 2 && !isKeyboardOpen)
          ? FloatingActionButton.extended(
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
            )
          : null,
      body: _buildCurrentTabBody(dashboardAsync, user, selectedDate),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTabBody(
    AsyncValue<DashboardSummaryModel> dashboardAsync,
    dynamic user,
    DateTime selectedDate,
  ) {
    switch (_currentNavIndex) {
      case 1:
        return ExpensesScreen(
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        );
      case 2:
        return AnalyticsScreen(
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        );
      case 3:
        return AiChatScreen(
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        );
      default:
        return _buildHomeDashboard(dashboardAsync, user, selectedDate);
    }
  }

  Widget _buildHomeDashboard(
    AsyncValue<DashboardSummaryModel> dashboardAsync,
    dynamic user,
    DateTime selectedDate,
  ) {
    return dashboardAsync.when(
      loading: () => const HomeScreenShimmer(),
      error: (err, stack) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.read(homeSelectedDateProvider.notifier).updateDate(DateTime.now());
          await ref.read(dashboardSummaryProvider.notifier).loadDashboardData(date: DateTime.now());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: AppErrorWidget(
              error: err,
              onRetry: () =>
                  ref.read(dashboardSummaryProvider.notifier).refresh(),
            ),
          ),
        ),
      ),
      data: (summary) {
        final greeting = _getGreeting();
        final displayName = _getUserDisplayName(user?.name);
        final formattedSelectedMonth =
            DateFormat('MMM yyyy').format(selectedDate);
        final currency = ref.watch(currencyProvider);
        final totalRupees = summary.totalSpendingMinor ~/ 100;
        final dailyAvgRupees = summary.dailyAverageMinor ~/ 100;
        final essentialRupees = summary.essentialAmountMinor ~/ 100;
        final discretionaryRupees = summary.discretionaryAmountMinor ~/ 100;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.read(homeSelectedDateProvider.notifier).updateDate(DateTime.now());
            await ref.read(dashboardSummaryProvider.notifier).loadDashboardData(date: DateTime.now());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  // 1. Top Greeting & Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Greeting above, Name below
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  greeting,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('👋',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                displayName,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      // Interactive Premium Calendar Button
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
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
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                                formattedSelectedMonth,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
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
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 2. Hero Card: Total Spending & Dynamic Metrics
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0F766E),
                          Color(0xFF115E59),
                          Color(0xFF0F766E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const PhosphorIcon(
                                    PhosphorIconsBold.wallet,
                                    color: Color(0xFFCCFBF1),
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'TOTAL SPENDING',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFFCCFBF1),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                summary.activePeriodLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${currency.symbol} ${NumberFormat('#,##,###').format(totalRupees)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const PhosphorIcon(
                                    PhosphorIconsRegular.receipt,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${summary.recentExpenses.length} ${summary.recentExpenses.length == 1 ? "expense" : "expenses"}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Daily Avg
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const PhosphorIcon(
                                          PhosphorIconsBold.trendUp,
                                          size: 11,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'DAILY AVERAGE',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${currency.symbol}${NumberFormat('#,##,###').format(dailyAvgRupees)}',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '/day',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Essential vs Non-essential Breakdown Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const PhosphorIcon(
                                              PhosphorIconsBold.chartPieSlice,
                                              size: 11,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Essential Ratio',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${summary.essentialPercentage}%',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF6EE7B7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: summary.totalSpendingMinor > 0
                                            ? (summary.essentialPercentage / 100).clamp(0.0, 1.0)
                                            : 0.0,
                                        minHeight: 4,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF6EE7B7),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currency.symbol}${NumberFormat('#,##,###').format(essentialRupees)} Essential',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Essential vs Discretionary Ratio Cards
                  Row(
                    children: [
                      // Essential
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.slate400
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border:
                                Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.tertiaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const PhosphorIcon(
                                            PhosphorIconsBold.shieldCheck,
                                            color: AppColors.tertiaryDark,
                                            size: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Essential',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.slate600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${summary.essentialPercentage}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tertiaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${currency.symbol}${NumberFormat('#,##,###').format(essentialRupees)}',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Fixed bills, food & commute',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Discretionary
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.slate400
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border:
                                Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.discretionaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const PhosphorIcon(
                                            PhosphorIconsBold.sparkle,
                                            color: AppColors.discretionaryDark,
                                            size: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Over Spend',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.slate600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.discretionaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${summary.discretionaryPercentage}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.discretionaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${currency.symbol}${NumberFormat('#,##,###').format(discretionaryRupees)}',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Leisure, gadgets & luxury',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 4. Spending Trend Chart Section
                  SpendingTrendsWidget(weeklyTrend: summary.weeklyTrend),

                  const SizedBox(height: 24),

                  // 5. Recent Expenses Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recent Expenses',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutralDark,
                            ),
                          ),
                          // const SizedBox(width: 8),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 8, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: AppColors.inputFieldBg,
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Text(
                          //     ' Today',
                          //     style: GoogleFonts.inter(
                          //       fontSize: 11,
                          //       fontWeight: FontWeight.w600,
                          //       color: AppColors.slate500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.allExpenses);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const PhosphorIcon(
                              PhosphorIconsRegular.caretRight,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Expense List
                  ...summary.recentExpenses.map(
                    (expense) => RecentExpenseTile(item: expense),
                  ),

                  const SizedBox(height: 14),

                 
                ],
              ),
            ),
          );
        },
      );
  }

  Widget _buildBottomNav() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12,
        top: 6,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: PhosphorIconsRegular.house,
              activeIcon: PhosphorIconsFill.house,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: PhosphorIconsRegular.receipt,
              activeIcon: PhosphorIconsFill.receipt,
              label: 'Expenses',
            ),
            _buildNavItem(
              index: 2,
              icon: PhosphorIconsRegular.chartPieSlice,
              activeIcon: PhosphorIconsFill.chartPieSlice,
              label: 'Analytics',
            ),
            _buildNavItem(
              index: 3,
              icon: PhosphorIconsRegular.sparkle,
              activeIcon: PhosphorIconsFill.sparkle,
              label: 'AI Hub',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentNavIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: PhosphorIcon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.slate500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
