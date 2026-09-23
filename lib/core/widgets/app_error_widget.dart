import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class AppErrorWidget extends StatefulWidget {
  const AppErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback onRetry;
  final bool compact;

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget>
    with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _cleanMessage(Object err) {
    final raw = err.toString();
    return raw
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^NetworkException:\s*'), '');
  }

  bool _isNetworkError(Object err) {
    final msg = err.toString().toLowerCase();
    return msg.contains('timed out') ||
        msg.contains('internet') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('reach the server');
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(milliseconds: 150));
    widget.onRetry();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = _isNetworkError(widget.error);
    final message = _cleanMessage(widget.error);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 20 : 32,
          vertical: widget.compact ? 16 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: Container(
                width: widget.compact ? 60 : 76,
                height: widget.compact ? 60 : 76,
                decoration: BoxDecoration(
                  color: isNetwork
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(
                    isNetwork
                        ? PhosphorIconsRegular.wifiSlash
                        : PhosphorIconsRegular.warning,
                    size: widget.compact ? 28 : 34,
                    color: isNetwork
                        ? const Color(0xFFF57C00)
                        : AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isNetwork ? 'No Connection' : 'Something Went Wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: widget.compact ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: widget.compact ? 12 : 13,
                color: AppColors.slate500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: widget.compact ? 160 : double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRetrying ? null : _handleRetry,
                icon: _isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const PhosphorIcon(
                        PhosphorIconsRegular.arrowClockwise,
                        size: 16,
                        color: Colors.white,
                      ),
                label: Text(
                  _isRetrying ? 'Retrying...' : 'Try Again',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
