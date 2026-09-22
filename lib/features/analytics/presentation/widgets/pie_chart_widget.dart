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

          // Classic Solid Pie Chart Canvas
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                size: const Size(220, 220),
                painter: _ClassicPieChartPainter(
                  categories: widget.categories,
                  totalAmountMinor: total,
                  selectedIndex: _selectedSliceIndex,
                ),
              ),
            ),
          ),

          if (_selectedSliceIndex != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.categories[_selectedSliceIndex!].color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.categories[_selectedSliceIndex!].color.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.categories[_selectedSliceIndex!].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.categories[_selectedSliceIndex!].categoryName}: ${currency.symbol}${NumberFormat('#,##,###').format(widget.categories[_selectedSliceIndex!].amountMinor ~/ 100)} (${((widget.categories[_selectedSliceIndex!].amountMinor / (total > 0 ? total : 1)) * 100).toStringAsFixed(1)}%)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
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
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(3),
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

class _ClassicPieChartPainter extends CustomPainter {
  final List<CategorySpendingData> categories;
  final int totalAmountMinor;
  final int? selectedIndex;

  _ClassicPieChartPainter({
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

    // Outer subtle border/shadow for clean look
    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final sweepAngle = (cat.amountMinor / totalAmountMinor) * 2 * math.pi;
      final isSelected = selectedIndex == i;

      final slicePaint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      // Slice separation gap line
      final sliceSeparatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSingle ? 0.0 : 2.0;

      // Draw solid filled pie wedge
      if (isSelected) {
        // Slightly offset the selected slice outward
        final midAngle = startAngle + (sweepAngle / 2);
        final offsetDist = 6.0;
        final sliceCenter = Offset(
          center.dx + offsetDist * math.cos(midAngle),
          center.dy + offsetDist * math.sin(midAngle),
        );

        final path = Path()
          ..moveTo(sliceCenter.dx, sliceCenter.dy)
          ..arcTo(
            Rect.fromCircle(center: sliceCenter, radius: radius - 4),
            startAngle,
            sweepAngle,
            false,
          )
          ..close();

        canvas.drawPath(path, slicePaint);
        if (!isSingle) {
          canvas.drawPath(path, sliceSeparatorPaint);
        }
      } else {
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius - 4),
            startAngle,
            sweepAngle,
            false,
          )
          ..close();

        canvas.drawPath(path, slicePaint);
        if (!isSingle) {
          canvas.drawPath(path, sliceSeparatorPaint);
        }
      }

      startAngle += sweepAngle;
    }

    if (isSingle) {
      canvas.drawCircle(center, radius - 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClassicPieChartPainter oldDelegate) {
    return oldDelegate.totalAmountMinor != totalAmountMinor ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.categories != categories;
  }
}
