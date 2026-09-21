import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

class CategorySpendingData {
  final String categoryName;
  final int amountMinor;
  final Color color;

  const CategorySpendingData({
    required this.categoryName,
    required this.amountMinor,
    required this.color,
  });
}

class PieChartWidget extends ConsumerStatefulWidget {
  final List<CategorySpendingData> categories;
  final int totalAmountMinor;

  const PieChartWidget({
    super.key,
    required this.categories,
    required this.totalAmountMinor,
  });

  @override
  ConsumerState<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends ConsumerState<PieChartWidget> {
  int? _selectedSliceIndex;

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final catTotal = widget.categories.fold<int>(0, (sum, c) => sum + c.amountMinor);
    final total = catTotal > 0 ? catTotal : widget.totalAmountMinor;

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
                'CATEGORY BREAKDOWN',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.slate400,
                ),
              ),
              Text(
                '${widget.categories.length} Categories',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pie Chart Canvas + Center Label
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _DonutChartPainter(
                      categories: widget.categories,
                      totalAmountMinor: total,
                      selectedIndex: _selectedSliceIndex,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSliceIndex != null
                            ? widget.categories[_selectedSliceIndex!].categoryName
                            : 'TOTAL SPEND',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedSliceIndex != null
                            ? '${currency.symbol}${NumberFormat('#,##,###').format(widget.categories[_selectedSliceIndex!].amountMinor ~/ 100)}'
                            : '${currency.symbol}${NumberFormat('#,##,###').format(total ~/ 100)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_selectedSliceIndex != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${((widget.categories[_selectedSliceIndex!].amountMinor / (total > 0 ? total : 1)) * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.categories[_selectedSliceIndex!].color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // Interactive Category Legend / Table
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cat = widget.categories[index];
              final percent = total > 0 ? (cat.amountMinor / total) * 100 : 0.0;
              final isSelected = _selectedSliceIndex == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    if (_selectedSliceIndex == index) {
                      _selectedSliceIndex = null;
                    } else {
                      _selectedSliceIndex = index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ),
                      Text(
                        '${currency.symbol}${NumberFormat('#,##,###').format(cat.amountMinor ~/ 100)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${percent.toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategorySpendingData> categories;
  final int totalAmountMinor;
  final int? selectedIndex;

  _DonutChartPainter({
    required this.categories,
    required this.totalAmountMinor,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalAmountMinor <= 0 || categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final isSingle = categories.length == 1;
    const strokeWidth = 24.0;
    final gapAngle = isSingle ? 0.0 : 0.04;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final sweepAngle = (cat.amountMinor / totalAmountMinor) * 2 * math.pi;
      final isSelected = selectedIndex == i;

      final paint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 6 : strokeWidth
        ..strokeCap = isSingle ? StrokeCap.butt : StrokeCap.round;

      if (isSingle) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: isSelected ? radius - 10 : radius - 12,
          ),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      } else if (sweepAngle > gapAngle) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: isSelected ? radius - 10 : radius - 12,
          ),
          startAngle + (gapAngle / 2),
          sweepAngle - gapAngle,
          false,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.totalAmountMinor != totalAmountMinor ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.categories != categories;
  }
}
