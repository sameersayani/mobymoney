import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/presentation/login_screen.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/home/presentation/home_screen.dart';
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

      final Widget nextScreen =
          isLoggedIn ? const HomeScreen() : const LoginScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
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
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF9), // Subtle minty tint at top
              Colors.white,
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // App Logo with soft shadow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name formatted with two-tone logo colors (Image 4)
              const BrandLogoTitle(
                fontSize: 30,
                spacing: 6,
              ),
              const SizedBox(height: 10),
              // Tagline: "intelligent expense management" only
              Text(
                'Intelligent Expense Management',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(flex: 3),
              // Circular mini spinner
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.8),
                  ),
                  backgroundColor: AppColors.slate200,
                ),
              ),
              const SizedBox(height: 18),
              // Linear loading indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 4,
                        backgroundColor: AppColors.slate200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Status text
              Text(
                'SECURING FINANCIAL LEDGER...',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.slate400,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
