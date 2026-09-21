import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/authentication/domain/models/user_model.dart';
import 'package:mobymoney/features/authentication/presentation/providers/auth_provider.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/expenses/presentation/providers/expense_types_provider.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';
import 'package:mobymoney/features/settings/presentation/widgets/clear_expenses_dialog.dart';
import 'package:mobymoney/features/settings/presentation/widgets/currency_selector_dialog.dart';
import 'package:mobymoney/features/settings/presentation/widgets/export_expense_dialog.dart';
import 'package:mobymoney/features/settings/presentation/widgets/privacy_policy_dialog.dart';

/// Production-ready slide-out Profile Drawer for MobyMoney
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  Widget _buildAvatar(UserModel? user) {
    if (user?.picture != null && user!.picture!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          user.picture!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackAvatar(user),
        ),
      );
    }
    return _buildFallbackAvatar(user);
  }

  Widget _buildFallbackAvatar(UserModel? user) {
    final initial =
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A';
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF0D9488),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your MobyMoney account? You can log back in anytime.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.slate600,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.slate500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                Navigator.of(context).pop(); // Close drawer
              }
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final typesAsync = ref.watch(expenseTypesProvider);
    final categoriesCount = typesAsync.asData?.value.length ?? 0;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final expenseCount =
        dashboardAsync.asData?.value.recentExpenses.length ?? 0;
    final currency = ref.watch(currencyProvider);

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Drawer Header (Profile Section)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAvatar(user),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user?.name.isNotEmpty == true
                                        ? user!.name
                                        : 'Alex Morgan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.neutralDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PRO',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email.isNotEmpty == true
                                  ? user!.email
                                  : 'alex.morgan@mobymoney.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.slate500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Sync Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Mini Stats Strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Expenses', '$expenseCount'),
                        _buildVerticalDivider(),
                        _buildStatItem('Categories', '$categoriesCount'),
                        _buildVerticalDivider(),
                        _buildStatItem('Currency', currency.shortDisplay),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFFF1F5F9), height: 1),

            // 2. Scrollable Menu Options
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  _buildSectionHeader('EXPENSE MANAGEMENT'),
                  const SizedBox(height: 6),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.tag,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryContainer,
                    title: 'Expense Types & Categories',
                    subtitle: 'Manage custom categories',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.expenseTypes);
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.fileXls,
                    iconColor: const Color(0xFF0284C7),
                    iconBg: const Color(0xFFE0F2FE),
                    title: 'Export Expense Data',
                    subtitle: 'Download Excel sheets (XLSX)',
                    onTap: () {
                      Navigator.of(context).pop();
                      ExportExpenseDialog.show(context);
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.trash,
                    iconColor: AppColors.error,
                    iconBg: AppColors.errorContainer,
                    title: 'Clear Expense History',
                    subtitle: 'Bulk delete records safely',
                    onTap: () {
                      Navigator.of(context).pop();
                      ClearExpensesDialog.show(context);
                    },
                  ),

                  const SizedBox(height: 14),
                  _buildSectionHeader('PREFERENCES & SECURITY'),
                  const SizedBox(height: 6),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.currencyDollar,
                    iconColor: AppColors.secondary,
                    iconBg: AppColors.secondaryContainer,
                    title: 'Default Currency',
                    subtitle: currency.displayName,
                    onTap: () {
                      CurrencySelectorDialog.show(context);
                    },
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.shieldCheck,
                    iconColor: const Color(0xFF10B981),
                    iconBg: const Color(0xFFD1FAE5),
                    title: 'Privacy Policy',
                    subtitle: 'View terms & data protection policy',
                    onTap: () {
                      PrivacyPolicyDialog.show(context);
                    },
                  ),

                  const SizedBox(height: 14),
                  _buildSectionHeader('ACCOUNT'),
                  const SizedBox(height: 6),
                  _buildDrawerTile(
                    context: context,
                    icon: PhosphorIconsRegular.signOut,
                    iconColor: AppColors.error,
                    iconBg: AppColors.errorContainer,
                    title: 'Logout',
                    subtitle: 'Sign out from this device',
                    titleColor: AppColors.error,
                    showChevron: false,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
            ),

            // 3. Footer with Version
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'MobyMoney v1.0.0 • AI-Powered Finance',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppColors.slate200,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 4, top: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.slate400,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: PhosphorIcon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppColors.neutralDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron)
                const PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  color: AppColors.slate300,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
