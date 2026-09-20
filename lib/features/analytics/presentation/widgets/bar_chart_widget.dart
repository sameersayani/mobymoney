import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class BarChartWidget extends StatefulWidget {
  final List<DailySpendingModel> dailyTrend;
  final int budgetCapMinor;

  const BarChartWidget({
    super.key,
    required this.dailyTrend,
    this.budgetCapMinor = 6500000,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                'SPENDING ACTIVITY',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.slate400,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Daily',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                    'Peak',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bars container
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.dailyTrend.length, (index) {
                final item = widget.dailyTrend[index];
                final isPeak = item.ratio >= 0.9;
                final isSelected = _hoveredIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _hoveredIndex = isSelected ? null : index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value Tag
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: isSelected || item.isToday ? 1.0 : 0.6,
                        child: Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: isSelected || item.isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected || item.isToday
                                ? AppColors.neutralDark
                                : AppColors.slate400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Bar Pill
                      Container(
                        width: 28,
                        height: item.amountMinor == 0
                            ? 6.0
                            : ((item.ratio * 104.0) + 16.0).clamp(16.0, 120.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.amountMinor == 0
                                ? [
                                    const Color(0xFFE2E8F0),
                                    const Color(0xFFCBD5E1),
                                  ]
                                : (isPeak && item.ratio >= 0.8
                                    ? [
                                        const Color(0xFF10B981),
                                        const Color(0xFF059669),
                                      ]
                                    : [
                                        AppColors.primaryLight,
                                        AppColors.primary,
                                      ]),
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: (item.amountMinor > 0 && (isPeak || item.isToday))
                              ? [
                                  BoxShadow(
                                    color: (isPeak
                                            ? AppColors.tertiary
                                            : AppColors.primary)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Day Label
                      Text(
                        item.day,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: item.isToday
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: item.isToday
                              ? AppColors.primary
                              : AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          Builder(
            builder: (context) {
              if (widget.dailyTrend.isEmpty) {
                return const SizedBox.shrink();
              }
              final peakItem = widget.dailyTrend.reduce((a, b) => a.amountMinor >= b.amountMinor ? a : b);
              final totalMinor = widget.dailyTrend.fold<int>(0, (sum, item) => sum + item.amountMinor);
              final avgMinor = (totalMinor / widget.dailyTrend.length).round();
              final avgFormatted = avgMinor >= 100000 
                  ? '₹${(avgMinor / 100000).toStringAsFixed(1)}k' 
                  : '₹${(avgMinor / 100).toStringAsFixed(0)}';

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peak: ${peakItem.day} (${peakItem.label})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                    ),
                  ),
                  Text(
                    'Avg: $avgFormatted / day',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
