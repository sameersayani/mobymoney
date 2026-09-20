import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/domain/models/user_model.dart';

/// Clean, production-ready top app bar for Moby Money Dashboard matching page background
class DashboardHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeaderAppBar({
    super.key,
    required this.user,
    this.title = 'Moby',
    this.subtitle = 'DASHBOARD',
    this.onAvatarTap,
    this.onNotificationTap,
    this.actions,
  });

  final UserModel? user;
  final String title;
  final String subtitle;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

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
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.appBarBg,
          ),
          child: Row(
            children: [
              // Brand Logo & Title (Moby Money)
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Moby',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.brandDark,
                          ),
                        ),
                        TextSpan(
                          text: ' money',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              if (actions != null) ...[
                ...actions!,
                const SizedBox(width: 8),
              ],

              // User Profile Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryContainer,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slate400.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: user?.picture != null && user!.picture!.isNotEmpty
                        ? Image.network(
                            user!.picture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackAvatar(user),
                          )
                        : _buildFallbackAvatar(user),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(UserModel? user) {
    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
