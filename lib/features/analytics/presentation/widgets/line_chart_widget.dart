import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';

class LineChartWidget extends StatelessWidget {
  final List<DailySpendingModel> dailyTrend;

  const LineChartWidget({
    super.key,
    required this.dailyTrend,
  });

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
                'SPENDING TRAJECTORY',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.slate400,
                ),
              ),
              Builder(
                builder: (context) {
                  if (dailyTrend.length < 2) return const SizedBox.shrink();
                  final first = dailyTrend.first.amountMinor;
                  final last = dailyTrend.last.amountMinor;
                  if (first == 0 && last == 0) return const SizedBox.shrink();
                  final percentChange = first == 0 
                      ? (last > 0 ? 100 : 0) 
                      : (((last - first) / first) * 100).round();
                  final isDown = percentChange <= 0;
                  final sign = percentChange > 0 ? '+' : '';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDown ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Trend: $sign$percentChange%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDown ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Line Canvas
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _CurvedLineChartPainter(dailyTrend: dailyTrend),
            ),
          ),

          const SizedBox(height: 12),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dailyTrend.map((d) {
              return Text(
                d.day,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: d.isToday ? FontWeight.w800 : FontWeight.w500,
                  color: d.isToday ? AppColors.primary : AppColors.slate500,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          Builder(
            builder: (context) {
              if (dailyTrend.isEmpty) {
                return const SizedBox.shrink();
              }
              final lowestItem = dailyTrend.reduce((a, b) => a.amountMinor <= b.amountMinor ? a : b);
              final highestItem = dailyTrend.reduce((a, b) => a.amountMinor >= b.amountMinor ? a : b);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lowest: ${lowestItem.day} (${lowestItem.label})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate600,
                    ),
                  ),
                  Text(
                    'Highest: ${highestItem.day} (${highestItem.label})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
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

class _CurvedLineChartPainter extends CustomPainter {
  final List<DailySpendingModel> dailyTrend;

  _CurvedLineChartPainter({required this.dailyTrend});

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyTrend.isEmpty) return;

    final points = <Offset>[];
    final stepX = size.width / (dailyTrend.length - 1);

    for (int i = 0; i < dailyTrend.length; i++) {
      final x = i * stepX;
      // Invert Y because canvas Y starts at top
      final ratio = dailyTrend[i].ratio.clamp(0.1, 1.0);
      final y = size.height - (ratio * (size.height - 24)) - 12;
      points.add(Offset(x, y));
    }

    // Path for curve
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Gradient Fill Path
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Dots on points
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isToday = dailyTrend[i].isToday;

      final dotBgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final dotPaint = Paint()
        ..color = isToday ? AppColors.tertiary : AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p, isToday ? 6 : 4.5, dotBgPaint);
      canvas.drawCircle(p, isToday ? 4.5 : 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedLineChartPainter oldDelegate) {
    return oldDelegate.dailyTrend != dailyTrend;
  }
}
