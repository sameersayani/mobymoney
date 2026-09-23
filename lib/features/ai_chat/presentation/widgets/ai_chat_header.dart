import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

class AiChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearChat;
  final VoidCallback? onResetDefault;

  const AiChatHeader({
    super.key,
    required this.onClearChat,
    this.onResetDefault,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.slate300.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Glowing AI Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFF0D9488),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: PhosphorIcon(
                    PhosphorIconsFill.sparkle,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Moby AI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'COPILOT',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.tertiary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Always ready to assist',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions: Reset / Clear
              PopupMenuButton<String>(
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.dotsThreeVertical,
                      size: 18,
                      color: AppColors.slate700,
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (val) {
                  if (val == 'clear') {
                    onClearChat();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const PhosphorIcon(
                          PhosphorIconsRegular.trash,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Clear Conversation',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
