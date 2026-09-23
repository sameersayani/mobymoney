import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

class AiWelcomeView extends StatefulWidget {
  final Function(String query) onSelectPrompt;

  const AiWelcomeView({
    super.key,
    required this.onSelectPrompt,
  });

  @override
  State<AiWelcomeView> createState() => _AiWelcomeViewState();
}

class _AiWelcomeViewState extends State<AiWelcomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
        'gradient': [AppColors.primary, const Color(0xFF14B8A6)],
      },
      {
        'icon': PhosphorIconsFill.piggyBank,
        'title': 'Find Savings Opportunities',
        'subtitle': 'Discover subscriptions and habits to trim',
        'query': 'How can I save ₹5,000 this month?',
        'color': AppColors.secondary,
        'bgColor': AppColors.secondaryContainer,
        'gradient': [AppColors.secondary, AppColors.secondaryLight],
      },
      {
        'icon': PhosphorIconsFill.forkKnife,
        'title': 'Dining & Delivery Audit',
        'subtitle': 'Review Swiggy, Zomato & restaurant costs',
        'query': 'Break down my dining and food delivery expenses',
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      },
      {
        'icon': PhosphorIconsFill.target,
        'title': 'Smart Budget Setup',
        'subtitle': 'Allocate 50/30/20 budget limits with alerts',
        'query': 'Help me set up a monthly budget rule',
        'color': AppColors.tertiary,
        'bgColor': AppColors.tertiaryContainer,
        'gradient': [AppColors.tertiary, AppColors.tertiaryLight],
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          // ─── Hero Section ────────────────────────────────────────────────────
          _buildHero(),
          const SizedBox(height: 32),

          // ─── Capability Pills ────────────────────────────────────────────────
          _buildCapabilityPills(),
          const SizedBox(height: 32),

          // ─── Section Label ───────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'QUICK START',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Prompt Cards ────────────────────────────────────────────────────
          ...samplePrompts.asMap().entries.map((entry) {
            return _PromptCard(
              prompt: entry.value,
              delay: entry.key * 60,
              onTap: () => widget.onSelectPrompt(
                  entry.value['query'] as String),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // Pulsing glow icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF0D9488),
                  Color(0xFF14B8A6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.sparkle,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        Text(
          'Meet Moby Copilot',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.neutralDark,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Your 24/7 intelligent finance assistant.\nAsk anything to optimize your financial life.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: AppColors.slate500,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildCapabilityPills() {
    final capabilities = [
      (PhosphorIconsFill.chartLine, 'Spend Analysis'),
      (PhosphorIconsFill.lock, 'Secure'),
      (PhosphorIconsFill.lightningA, 'Instant Insights'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: capabilities.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(c.$1, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                c.$2,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PromptCard extends StatefulWidget {
  final Map<String, dynamic> prompt;
  final int delay;
  final VoidCallback onTap;

  const _PromptCard({
    required this.prompt,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_PromptCard> createState() => _PromptCardState();
}

class _PromptCardState extends State<_PromptCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.prompt['color'] as Color;
    final bgColor = widget.prompt['bgColor'] as Color;
    final icon = widget.prompt['icon'] as IconData;
    final title = widget.prompt['title'] as String;
    final subtitle = widget.prompt['subtitle'] as String;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) {
          _hoverController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _hoverController.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slate200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: PhosphorIcon(icon, color: color, size: 23),
                ),
              ),
              const SizedBox(width: 14),

              // Text
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.slate500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Arrow
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsRegular.arrowRight,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
