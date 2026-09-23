import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _dotController;
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 80, top: 6, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar with glow
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.slate200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shimmer label
                AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: const [
                            AppColors.slate400,
                            AppColors.primary,
                            AppColors.slate400,
                          ],
                          stops: [
                            (_shimmerAnim.value - 0.5).clamp(0.0, 1.0),
                            _shimmerAnim.value.clamp(0.0, 1.0),
                            (_shimmerAnim.value + 0.5).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Moby AI is thinking',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // masked by shader
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),

                // Animated dots
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final phase = (index / 3.0);
                        final angle = (_dotController.value - phase) * 2 * math.pi;
                        final yOffset = math.sin(angle) * 4.0;
                        final opacity =
                            (0.35 + 0.65 * ((math.sin(angle) + 1) / 2))
                                .clamp(0.3, 1.0);

                        return Transform.translate(
                          offset: Offset(0, -yOffset),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary
                                  .withValues(alpha: opacity),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
