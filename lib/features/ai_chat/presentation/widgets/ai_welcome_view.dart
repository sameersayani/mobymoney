import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

class AiWelcomeView extends StatelessWidget {
  final Function(String query) onSelectPrompt;

  const AiWelcomeView({
    super.key,
    required this.onSelectPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final samplePrompts = [
      {
        'icon': PhosphorIconsFill.chartPieSlice,
        'title': 'Analyze My Spending',
        'subtitle': 'Detailed breakdown of where your money went this month',
        'query': 'Analyze my spending breakdown for this month',
        'color': AppColors.primary,
        'bgColor': AppColors.primaryContainer,
      },
      {
        'icon': PhosphorIconsFill.piggyBank,
        'title': 'Find Savings Opportunities',
        'subtitle': 'Discover subscriptions and habits to trim',
        'query': 'How can I save ₹5,000 this month?',
        'color': AppColors.secondary,
        'bgColor': AppColors.secondaryContainer,
      },
      {
        'icon': PhosphorIconsFill.forkKnife,
        'title': 'Dining & Delivery Audit',
        'subtitle': 'Review Swiggy, Zomato & restaurant costs',
        'query': 'Break down my dining and food delivery expenses',
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
      },
      {
        'icon': PhosphorIconsFill.target,
        'title': 'Smart Budget Setup',
        'subtitle': 'Allocate 50/30/20 budget limits with alerts',
        'query': 'Help me set up a monthly budget rule',
        'color': AppColors.tertiary,
        'bgColor': AppColors.tertiaryContainer,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Hero Glowing Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF0D9488),
                  Color(0xFF14B8A6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hero Headline
          Text(
            'Meet Moby Copilot',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Your 24/7 intelligent personal finance assistant. Ask anything to optimize your financial life.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: AppColors.slate500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Starter Prompt Cards
          Row(
            children: [
              Text(
                'POPULAR QUESTIONS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...samplePrompts.map((p) {
            final color = p['color'] as Color;
            final bgColor = p['bgColor'] as Color;
            final icon = p['icon'] as IconData;
            final title = p['title'] as String;
            final subtitle = p['subtitle'] as String;
            final query = p['query'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelectPrompt(query),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.slate200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            icon,
                            color: color,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PhosphorIcon(
                        PhosphorIconsRegular.arrowRight,
                        size: 16,
                        color: AppColors.slate400,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
