import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

class SpendingTrendsWidget extends ConsumerStatefulWidget {
  const SpendingTrendsWidget({
    super.key,
    required this.weeklyTrend,
  });

  final List<DailySpendingModel> weeklyTrend;

  @override
  ConsumerState<SpendingTrendsWidget> createState() => _SpendingTrendsWidgetState();
}

class _SpendingTrendsWidgetState extends ConsumerState<SpendingTrendsWidget> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Default select today if available, or last item
    if (widget.weeklyTrend.isNotEmpty) {
      final todayIdx = widget.weeklyTrend.indexWhere((item) => item.isToday);
      _selectedIndex = todayIdx != -1 ? todayIdx : widget.weeklyTrend.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    if (_selectedIndex >= widget.weeklyTrend.length && widget.weeklyTrend.isNotEmpty) {
      _selectedIndex = widget.weeklyTrend.length - 1;
    }

    final selectedItem = widget.weeklyTrend.isNotEmpty &&
            _selectedIndex >= 0 &&
            _selectedIndex < widget.weeklyTrend.length
        ? widget.weeklyTrend[_selectedIndex]
        : null;

    final totalMinor = widget.weeklyTrend.fold<int>(0, (sum, item) => sum + item.amountMinor);
    final count = widget.weeklyTrend.isNotEmpty ? widget.weeklyTrend.length : 1;
    final avgMinor = (totalMinor / count).round();
    final avgRupees = avgMinor ~/ 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate400.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Weekly Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Trend',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Avg ${currency.symbol}${NumberFormat('#,##,###').format(avgRupees)} / day',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              // Weekly Pill Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsBold.chartBar,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Weekly',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 7-Day Bar Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.weeklyTrend.length, (index) {
                final item = widget.weeklyTrend[index];
                final isSelected = index == _selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currency.formatMinor(item.amountMinor, compact: true),
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 20),
                          // Bar
                          Container(
                            width: 24,
                            height: item.amountMinor == 0
                                ? 4.0
                                : ((item.ratio * 58.0) + 10.0).clamp(10.0, 68.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (item.amountMinor > 0
                                      ? AppColors.primaryLight.withValues(alpha: 0.5)
                                      : const Color(0xFFE2E8F0)),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day Label
                          Text(
                            item.day,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // Selected Day Detail Pill
          if (selectedItem != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Selected: ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.slate500,
                    ),
                  ),
                  Text(
                    selectedItem.day,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    selectedItem.isToday
                        ? '${currency.formatMinor(selectedItem.amountMinor, compact: true)} (Today)'
                        : currency.formatMinor(selectedItem.amountMinor, compact: true),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
