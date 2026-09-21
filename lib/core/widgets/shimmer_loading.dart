import 'package:flutter/material.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

/// A reusable, animated Shimmer effect widget.
/// Creates a sleek, modern, flowing light gradient over skeleton shapes.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer Box Skeleton Element
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer Circle Skeleton Element (Avatars, icons)
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color color;

  const ShimmerCircle({
    super.key,
    this.size = 40,
    this.color = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Full Skeleton Screen for Home Dashboard
class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Greeting & Date Chooser Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 110, height: 14, borderRadius: 6),
                    SizedBox(height: 8),
                    ShimmerBox(width: 170, height: 22, borderRadius: 6),
                  ],
                ),
                const ShimmerBox(width: 125, height: 38, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Total Spending Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerBox(width: 120, height: 14, borderRadius: 6),
                      ShimmerCircle(size: 32),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const ShimmerBox(width: 180, height: 36, borderRadius: 8),
                  const SizedBox(height: 16),
                  const ShimmerBox(width: 220, height: 14, borderRadius: 6),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Essential & Discretionary Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerCircle(size: 30),
                        SizedBox(height: 12),
                        ShimmerBox(width: 70, height: 12, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerBox(width: 90, height: 20, borderRadius: 6),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerCircle(size: 30),
                        SizedBox(height: 12),
                        ShimmerBox(width: 80, height: 12, borderRadius: 4),
                        SizedBox(height: 8),
                        ShimmerBox(width: 90, height: 20, borderRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Recent Expenses Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 140, height: 20, borderRadius: 6),
                ShimmerBox(width: 60, height: 16, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Recent Expense Tiles List
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      const ShimmerBox(width: 44, height: 44, borderRadius: 13),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                ShimmerBox(width: 120, height: 15, borderRadius: 4),
                                ShimmerBox(width: 50, height: 16, borderRadius: 4),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                ShimmerBox(width: 90, height: 11, borderRadius: 4),
                                ShimmerBox(width: 55, height: 16, borderRadius: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const ShimmerCircle(size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Skeleton Screen for Expenses List Screen
class ExpensesScreenShimmer extends StatelessWidget {
  const ExpensesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          // 1. KPI Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 90, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 130, height: 26, borderRadius: 6),
                  ],
                ),
                const ShimmerBox(width: 70, height: 28, borderRadius: 14),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Search & Filter Bar
          Row(
            children: const [
              Expanded(
                child: ShimmerBox(height: 48, borderRadius: 12),
              ),
              SizedBox(width: 10),
              ShimmerBox(width: 48, height: 48, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 90, height: 16, borderRadius: 4),
              ShimmerBox(width: 60, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Expense List Tiles
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    const ShimmerBox(width: 44, height: 44, borderRadius: 13),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              ShimmerBox(width: 110, height: 15, borderRadius: 4),
                              ShimmerBox(width: 50, height: 16, borderRadius: 4),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              ShimmerBox(width: 85, height: 11, borderRadius: 4),
                              ShimmerBox(width: 55, height: 16, borderRadius: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const ShimmerCircle(size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full Skeleton Screen for Analytics Screen
class AnalyticsScreenShimmer extends StatelessWidget {
  const AnalyticsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
        children: [
          // 1. Chart View Mode Switcher
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: const [
                Expanded(child: ShimmerBox(height: 36, borderRadius: 10)),
                SizedBox(width: 4),
                Expanded(child: ShimmerBox(height: 36, borderRadius: 10)),
                SizedBox(width: 4),
                Expanded(child: ShimmerBox(height: 36, borderRadius: 10)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Big Chart Card Skeleton
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 140, height: 18, borderRadius: 6),
                    ShimmerBox(width: 80, height: 16, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 28),
                const Center(
                  child: ShimmerCircle(size: 180),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    ShimmerBox(width: 80, height: 14, borderRadius: 4),
                    ShimmerBox(width: 80, height: 14, borderRadius: 4),
                    ShimmerBox(width: 80, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Category Breakdown List
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    const ShimmerCircle(size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 100, height: 14, borderRadius: 4),
                          SizedBox(height: 6),
                          ShimmerBox(height: 6, borderRadius: 3),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    const ShimmerBox(width: 50, height: 16, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full Skeleton Screen for Expense Types Screen
class ExpenseTypesScreenShimmer extends StatelessWidget {
  const ExpenseTypesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                const ShimmerBox(width: 44, height: 44, borderRadius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      ShimmerBox(width: 130, height: 15, borderRadius: 5),
                    ],
                  ),
                ),
                const ShimmerCircle(size: 28),
                const SizedBox(width: 10),
                const ShimmerCircle(size: 28),
              ],
            ),
          );
        },
      ),
    );
  }
}
