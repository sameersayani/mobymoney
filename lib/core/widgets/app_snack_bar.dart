import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    switch (type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF065F46); // Rich emerald green
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFF991B1B);
        break;
      case SnackBarType.warning:
        bgColor = const Color(0xFF92400E);
        break;
      case SnackBarType.info:
        bgColor = const Color(0xFF0F766E);
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              // App Icon at the start
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Message Text
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.25,
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
