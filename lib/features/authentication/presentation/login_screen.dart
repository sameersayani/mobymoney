import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:mobymoney/shared/widgets/brand_logo_title.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailSignIn() {
    AppSnackBar.showInfo(
      context,
      'Please sign in with Google to access your account.',
    );
  }

  void _handleGoogleSignIn() async {
    final authState = ref.read(authStateProvider);
    if (authState.isLoading) return; // Guard duplicate taps

    final response =
        await ref.read(authStateProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    if (response != null) {
      _showSuccessFeedback('Welcome, ${response.user.name}!');
      context.go(AppRoutes.home);
    } else {
      final state = ref.read(authStateProvider);
      if (state.hasError) {
        _showErrorFeedback(state.error.toString());
      }
    }
  }

  void _showSuccessFeedback(String message) {
    AppSnackBar.showSuccess(context, message);
  }

  void _showErrorFeedback(String message) {
    AppSnackBar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isGoogleLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // App Brand Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header Title
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Sign in to manage your budgets and company expenses.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'EMAIL ID',
                  hintText: 'name@company.com',
                  prefixIcon: PhosphorIconsRegular.envelopeSimple,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'PASSWORD',
                  hintText: '••••••••••••',
                  prefixIcon: PhosphorIconsRegular.lockSimple,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: PhosphorIcon(
                      _obscurePassword
                          ? PhosphorIconsRegular.eye
                          : PhosphorIconsRegular.eyeSlash,
                      color: AppColors.slate500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: const BorderSide(
                                color: AppColors.slate400,
                                width: 1.5,
                              ),
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _rememberMe = !_rememberMe);
                              },
                              child: Text(
                                'Remember me',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slate700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign In Primary Button
                ElevatedButton(
                  onPressed: isGoogleLoading
                      ? null
                      : _handleEmailSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const PhosphorIcon(
                        PhosphorIconsRegular.arrowRight,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // "OR INSTANT ACCESS" Divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.slate200, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR INSTANT ACCESS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.slate200, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign In With Google Button
                OutlinedButton(
                  onPressed: isGoogleLoading
                      ? null
                      : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.slate200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: isGoogleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/images/google_logo.png',
                                height: 22,
                                width: 22,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const PhosphorIcon(
                                  PhosphorIconsRegular.googleLogo,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Sign in with Google',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate800,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 36),

                // Footer: "New to Moby money? Create account"
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'New to ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slate600,
                        ),
                      ),
                      const BrandLogoTitle(
                        fontSize: 15,
                        spacing: 3,
                      ),
                      Text(
                        '? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slate600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.register);
                        },
                        child: Text(
                          'Create account',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
