import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/routing/app_router.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

/// Route observer to automatically clean up active notifications on route transitions
class AppSnackBarRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppSnackBar.dismissImmediate();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppSnackBar.dismissImmediate();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppSnackBar.dismissImmediate();
  }
}

/// A centralized, production-grade floating notification system.
/// Uses a single managed [OverlayEntry] above the UI so that:
/// - Scaffold layout is never resized.
/// - The Floating Action Button (FAB) NEVER jumps or moves upward.
/// - Rapid clicks/calls are debounced (no multiple stacking or queuing 3-5 times).
/// - Older notifications are immediately cleared before showing a new one (no overlapping).
/// - Automatically dismissed when navigating to new screens/pages.
class AppSnackBar {
  static OverlayEntry? _activeEntry;
  static String? _lastMessage;
  static DateTime? _lastShowTime;
  static final AppSnackBarRouteObserver routeObserver = AppSnackBarRouteObserver();

  static void show(
    BuildContext? context, {
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(milliseconds: 2400),
    SnackBarAction? action,
  }) {
    // 1. Debounce rapid duplicate spam (e.g. user clicking 2+ times or multiple state emits)
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShowTime != null &&
        now.difference(_lastShowTime!) < const Duration(milliseconds: 1200)) {
      return;
    }
    _lastMessage = message;
    _lastShowTime = now;

    // 2. Resolve overlay context safely
    final targetContext = context ?? rootNavigatorKey.currentContext;
    if (targetContext == null) return;

    final overlay = Overlay.maybeOf(targetContext, rootOverlay: true);
    if (overlay == null) return;

    // 3. Immediately dismiss and remove any existing active notification (prevents overlaps)
    dismissImmediate();

    // 4. Create single fresh overlay entry
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _AppSnackBarOverlay(
        key: UniqueKey(),
        message: message,
        type: type,
        duration: duration,
        action: action,
        onDismissed: () {
          if (_activeEntry == entry) {
            try {
              entry.remove();
            } catch (_) {}
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  /// Manually dismiss current notification immediately
  static void dismissImmediate() {
    if (_activeEntry != null) {
      try {
        _activeEntry!.remove();
      } catch (_) {}
      _activeEntry = null;
    }
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

class _AppSnackBarOverlay extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final Duration duration;
  final SnackBarAction? action;
  final VoidCallback onDismissed;

  const _AppSnackBarOverlay({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    this.action,
    required this.onDismissed,
  });

  @override
  State<_AppSnackBarOverlay> createState() => _AppSnackBarOverlayState();
}

class _AppSnackBarOverlayState extends State<_AppSnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _autoCloseTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuad,
    ));

    _controller.forward();

    _autoCloseTimer = Timer(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _autoCloseTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final isKeyboardOpen = bottomInset > 0;

    // Calculate dynamic bottom offset:
    // If keyboard is open -> float comfortably above keyboard (bottomInset + 16)
    // If keyboard is closed -> float cleanly above the bottom navigation bar (bottomPadding + 76)
    final double bottomOffset = isKeyboardOpen
        ? (bottomInset + 16.0)
        : (bottomPadding > 0 ? bottomPadding + 76.0 : 88.0);

    // Color configuration per SnackBarType
    Color bgColor;
    Color borderColor;
    Color accentColor;

    switch (widget.type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF0F172A); // Sleek modern slate dark
        borderColor = const Color(0xFF22C55E).withValues(alpha: 0.4);
        accentColor = const Color(0xFF22C55E); // Crisp Green
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFF1E1B1E);
        borderColor = const Color(0xFFEF4444).withValues(alpha: 0.45);
        accentColor = const Color(0xFFEF4444); // Red
        break;
      case SnackBarType.warning:
        bgColor = const Color(0xFF1C1917);
        borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.45);
        accentColor = const Color(0xFFF59E0B); // Amber
        break;
      case SnackBarType.info:
        bgColor = const Color(0xFF0F172A);
        borderColor = const Color(0xFF38BDF8).withValues(alpha: 0.4);
        accentColor = const Color(0xFF38BDF8); // Cyan Sky
        break;
    }

    return Positioned(
      bottom: bottomOffset,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: dismiss,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Logo Icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 15,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text message
                      Flexible(
                        child: Text(
                          widget.message,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.1,
                            height: 1.3,
                          ),
                        ),
                      ),

                      // Optional Action
                      if (widget.action != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            widget.action!.onPressed();
                            dismiss();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            widget.action!.label,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
