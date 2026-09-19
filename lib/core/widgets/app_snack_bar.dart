import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    Color bgColor;
    Color iconColor;
    Color iconBgColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF065F46); // Rich emerald green
        iconColor = Colors.white;
        iconBgColor = Colors.white.withValues(alpha: 0.20);
        icon = PhosphorIconsFill.checkCircle;
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFF991B1B);
        iconColor = Colors.white;
        iconBgColor = Colors.white.withValues(alpha: 0.20);
        icon = PhosphorIconsFill.xCircle;
        break;
      case SnackBarType.warning:
        bgColor = const Color(0xFF92400E);
        iconColor = Colors.white;
        iconBgColor = Colors.white.withValues(alpha: 0.20);
        icon = PhosphorIconsFill.warningCircle;
        break;
      case SnackBarType.info:
        bgColor = const Color(0xFF0F766E);
        iconColor = Colors.white;
        iconBgColor = Colors.white.withValues(alpha: 0.20);
        icon = PhosphorIconsFill.info;
        break;
    }

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: EdgeInsets.zero,
        duration: duration,
        action: action,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.warning);
  }
}
