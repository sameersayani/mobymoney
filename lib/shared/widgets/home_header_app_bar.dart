import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/domain/models/user_model.dart';

/// Production-ready reusable header/appbar widget displaying dynamic greeting & user avatar.
class HomeHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeaderAppBar({
    super.key,
    required this.user,
    this.onAvatarTap,
    this.onNotificationTap,
    this.unreadNotificationCount = 0,
  });

  final UserModel? user;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final int unreadNotificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  /// Dynamically computes time-based greeting (Good morning / afternoon / evening)
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// Extracts firstName cleanly for modern greeting display
  String get _displayName {
    if (user == null || user!.name.trim().isEmpty) {
      return 'Member';
    }
    final name = user!.name.trim();
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Greeting & User Name
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _greeting,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '👋',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),

            // Right: User Circle Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slate400.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user?.picture != null && user!.picture!.isNotEmpty
                      ? Image.network(
                          user!.picture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackAvatar(),
                        )
                      : _buildFallbackAvatar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.primaryContainer,
      child: Center(
        child: Text(
          _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
