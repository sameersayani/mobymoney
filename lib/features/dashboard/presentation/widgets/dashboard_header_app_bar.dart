import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/domain/models/user_model.dart';

/// Clean, production-ready top app bar for Moby Money Dashboard
class DashboardHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeaderAppBar({
    super.key,
    required this.user,
    this.title = 'Moby',
    this.subtitle = 'DASHBOARD',
    this.onMenuTap,
    this.onAvatarTap,
    this.onNotificationTap,
    this.actions,
  });

  final UserModel? user;
  final String title;
  final String subtitle;
  final VoidCallback? onMenuTap;
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: AppColors.appBarBg,
          ),
          child: Row(
            children: [
              // Left: Three-Lines Drawer Menu Trigger
              InkWell(
                onTap: onMenuTap ?? () => Scaffold.maybeOf(context)?.openDrawer(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.slate200,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: PhosphorIcon(
                      PhosphorIconsBold.list,
                      color: AppColors.neutralDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Brand Logo & Title (Moby Money)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primary,
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsBold.wallet,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Text Header
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              if (actions != null) ...[
                ...actions!,
                const SizedBox(width: 8),
              ],

              // Right: User Profile Avatar
              GestureDetector(
                onTap: onAvatarTap ?? () => Scaffold.maybeOf(context)?.openDrawer(),
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
    final initial =
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';
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
