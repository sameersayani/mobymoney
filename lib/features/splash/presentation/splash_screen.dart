import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/storage/secure_storage_service.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/shared/widgets/brand_logo_title.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;

      final authRepository = ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepository.isAuthenticated();

      if (!mounted) return;

      if (isLoggedIn) {
        context.go(AppRoutes.home);
      } else {
        final hasOnboarded =
            await SecureStorageService.instance.isOnboardingCompleted();
        if (!mounted) return;

        if (hasOnboarded) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFB), // Soft ultra-clean mint-tinted white
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Organic Concentric Mint Circular Waves at Bottom-Left (Matching Reference Mockup)
          Positioned(
            left: -140,
            bottom: -140,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.16),
                    const Color(0xFF6EE7B7).withValues(alpha: 0.08),
                    const Color(0xFFFAFDFB).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: -80,
            bottom: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.10),
                  width: 32,
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.14),
                  width: 22,
                ),
              ),
            ),
          ),

          // 2. Main Centered Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Elevated Rhombus Brand Logo (Direct emblem image with soft glow)
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                              blurRadius: 36,
                              offset: const Offset(0, 14),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFF00A86B).withValues(alpha: 0.22),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/images/smart_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Brand Name in exact 3 stacked lines + yesitech.com subtext
                      const BrandLogoTitle(
                        fontSize: 34,
                        showSubtitle: true,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      const SizedBox(height: 56),

                      // Minimalist sleek progress bar
                      SizedBox(
                        width: 140,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                minHeight: 3.5,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00A86B),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
