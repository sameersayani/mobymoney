import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/routing/app_router.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:mobymoney/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobymoney/features/expenses/presentation/providers/expense_types_provider.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';
import 'add_expense_bottom_sheet.dart';

class RecentExpenseTile extends ConsumerWidget {
  const RecentExpenseTile({
    super.key,
    required this.item,
    this.onTap,
    this.showActions = true,
  });

  final RecentExpenseItemModel item;
  final VoidCallback? onTap;
  final bool showActions;

  String _resolveExpenseTypeName(WidgetRef ref) {
    String raw = item.categoryName.trim();

    if (raw.startsWith('{') && raw.endsWith('}')) {
      final nameMatch = RegExp(r'name:\s*([^,}]+)').firstMatch(raw);
      if (nameMatch != null) {
        return nameMatch.group(1)?.trim() ?? 'General';
      }
    }

    if (raw.isNotEmpty && int.tryParse(raw) == null && !raw.startsWith('{')) {
      return raw;
    }

    final types = ref.watch(expenseTypesProvider).asData?.value ?? [];
    if (item.expenseTypeId != null) {
      final match = types.where((t) => t.id == item.expenseTypeId).firstOrNull;
      if (match != null) return match.name;
    }

    final idFromCat = int.tryParse(raw);
    if (idFromCat != null) {
      final match = types.where((t) => t.id == idFromCat).firstOrNull;
      if (match != null) return match.name;
    }

    return raw.isNotEmpty && !raw.startsWith('{') ? raw : 'General';
  }

  IconData _getCategoryIcon(String catName, String title) {
    final lower = '$catName $title'.toLowerCase().trim();
    if (lower.contains('bill') || lower.contains('receipt') || lower.contains('invoice')) {
      return PhosphorIconsRegular.receipt;
    } else if (lower.contains('book') || lower.contains('novel') || lower.contains('read')) {
      return PhosphorIconsRegular.bookOpen;
    } else if (lower.contains('cinema') || lower.contains('movie') || lower.contains('theatre') || lower.contains('film')) {
      return PhosphorIconsRegular.filmSlate;
    } else if (lower.contains('cloth') || lower.contains('wear') || lower.contains('shirt') || lower.contains('pant') || lower.contains('dress')) {
      return PhosphorIconsRegular.tShirt;
    } else if (lower.contains('doctor') || lower.contains('hospital') || lower.contains('clinic') || lower.contains('consult')) {
      return PhosphorIconsRegular.firstAid;
    } else if (lower.contains('eat') || lower.contains('party') || lower.contains('food') || lower.contains('dining') || lower.contains('restaurant') || lower.contains('snack') || lower.contains('coffee') || lower.contains('tea')) {
      return PhosphorIconsRegular.forkKnife;
    } else if (lower.contains('game') || lower.contains('entertainment') || lower.contains('play') || lower.contains('gaming')) {
      return PhosphorIconsRegular.gameController;
    } else if (lower.contains('grocery') || lower.contains('carrot') || lower.contains('vegetable') || lower.contains('fruit') || lower.contains('supermarket') || lower.contains('market')) {
      return PhosphorIconsRegular.shoppingCart;
    } else if (lower.contains('internet') || lower.contains('wifi') || lower.contains('broadband') || lower.contains('fiber')) {
      return PhosphorIconsRegular.wifiHigh;
    } else if (lower.contains('lab') || lower.contains('test') || lower.contains('blood') || lower.contains('scan')) {
      return PhosphorIconsRegular.flask;
    } else if (lower.contains('lpg') || lower.contains('gas') || lower.contains('cylinder')) {
      return PhosphorIconsRegular.fire;
    } else if (lower.contains('medicin') || lower.contains('pharma') || lower.contains('pill') || lower.contains('tablet') || lower.contains('capsule')) {
      return PhosphorIconsRegular.pill;
    } else if (lower.contains('mobile phone') || (lower.contains('mobile') && !lower.contains('recharge')) || lower.contains('smartphone')) {
      return PhosphorIconsRegular.deviceMobile;
    } else if (lower.contains('parking')) {
      return PhosphorIconsRegular.car;
    } else if (lower.contains('petrol') || lower.contains('fuel') || lower.contains('diesel')) {
      return PhosphorIconsRegular.gasPump;
    } else if (lower.contains('recharge') || lower.contains('topup') || lower.contains('dth') || lower.contains('bill pay')) {
      return PhosphorIconsRegular.lightning;
    } else if (lower.contains('repair') || lower.contains('service') || lower.contains('mechanic') || lower.contains('maintain')) {
      return PhosphorIconsRegular.wrench;
    } else if (lower.contains('saloon') || lower.contains('salon') || lower.contains('hair') || lower.contains('barber') || lower.contains('spa')) {
      return PhosphorIconsRegular.scissors;
    } else if (lower.contains('school') || lower.contains('college') || lower.contains('university') || lower.contains('admission')) {
      return PhosphorIconsRegular.graduationCap;
    } else if (lower.contains('shop') || lower.contains('mall') || lower.contains('purchase') || lower.contains('buy')) {
      return PhosphorIconsRegular.bagSimple;
    } else if (lower.contains('subscri') || lower.contains('netflix') || lower.contains('prime') || lower.contains('spotify') || lower.contains('ott')) {
      return PhosphorIconsRegular.television;
    } else if (lower.contains('travel') || lower.contains('trip') || lower.contains('tour') || lower.contains('flight') || lower.contains('train') || lower.contains('bus') || lower.contains('taxi') || lower.contains('uber') || lower.contains('ola')) {
      return PhosphorIconsRegular.airplaneTilt;
    } else if (lower.contains('tuition') || lower.contains('coaching') || lower.contains('class') || lower.contains('course')) {
      return PhosphorIconsRegular.student;
    } else if (lower.contains('unplanned') || lower.contains('emergency') || lower.contains('penalty') || lower.contains('fine')) {
      return PhosphorIconsRegular.warningCircle;
    } else if (lower.contains('watch') || lower.contains('clock')) {
      return PhosphorIconsRegular.watch;
    }
    return PhosphorIconsRegular.tag;
  }

  Color _getCategoryBgColor(String catName, String title) {
    final lower = '$catName $title'.toLowerCase().trim();
    if (lower.contains('bill')) {
      return const Color(0xFFE0F2FE); // Light Sky
    } else if (lower.contains('book')) {
      return const Color(0xFFFEF3C7); // Light Amber
    } else if (lower.contains('cinema')) {
      return const Color(0xFFFCE7F3); // Light Pink
    } else if (lower.contains('cloth')) {
      return const Color(0xFFEDE9FE); // Light Purple
    } else if (lower.contains('doctor')) {
      return const Color(0xFFFEE2E2); // Light Red
    } else if (lower.contains('eat') || lower.contains('party') || lower.contains('food')) {
      return const Color(0xFFFFEDD5); // Light Orange
    } else if (lower.contains('game') || lower.contains('entertainment')) {
      return const Color(0xFFF3E8FF); // Light Violet
    } else if (lower.contains('grocery') || lower.contains('carrot')) {
      return const Color(0xFFDCFCE7); // Light Mint/Green
    } else if (lower.contains('internet') || lower.contains('wifi')) {
      return const Color(0xFFEDE9FE); // Light Indigo/Purple
    } else if (lower.contains('lab') || lower.contains('test')) {
      return const Color(0xFFFEE2E2); // Light Rose
    } else if (lower.contains('lpg') || lower.contains('gas')) {
      return const Color(0xFFFFEDD5); // Light Amber/Orange
    } else if (lower.contains('medicin') || lower.contains('pharma') || lower.contains('pill')) {
      return const Color(0xFFE0E7FF); // Light Indigo
    } else if (lower.contains('mobile phone') || (lower.contains('mobile') && !lower.contains('recharge'))) {
      return const Color(0xFFDBEAFE); // Light Blue
    } else if (lower.contains('parking')) {
      return const Color(0xFFE2E8F0); // Light Slate
    } else if (lower.contains('petrol') || lower.contains('fuel')) {
      return const Color(0xFFFEF3C7); // Light Yellow
    } else if (lower.contains('recharge')) {
      return const Color(0xFFDBEAFE); // Light Sky Blue
    } else if (lower.contains('repair') || lower.contains('service')) {
      return const Color(0xFFFFEDD5); // Light Warm Orange
    } else if (lower.contains('saloon') || lower.contains('salon')) {
      return const Color(0xFFFCE7F3); // Light Rose Pink
    } else if (lower.contains('school') || lower.contains('college')) {
      return const Color(0xFFDCFCE7); // Light Emerald
    } else if (lower.contains('shop')) {
      return const Color(0xFFFEE2E2); // Light Coral
    } else if (lower.contains('subscri')) {
      return const Color(0xFFEDE9FE); // Light Purple
    } else if (lower.contains('travel')) {
      return const Color(0xFFCCFBF1); // Light Teal
    } else if (lower.contains('tuition')) {
      return const Color(0xFFE0F2FE); // Light Sky
    } else if (lower.contains('unplanned')) {
      return const Color(0xFFFFE4E6); // Light Rose Red
    } else if (lower.contains('watch')) {
      return const Color(0xFFF1F5F9); // Light Gray
    }
    return const Color(0xFFF1F5F9); // Default Light Slate
  }

  Color _getCategoryIconColor(String catName, String title) {
    final lower = '$catName $title'.toLowerCase().trim();
    if (lower.contains('bill')) {
      return const Color(0xFF0284C7);
    } else if (lower.contains('book')) {
      return const Color(0xFFD97706);
    } else if (lower.contains('cinema')) {
      return const Color(0xFFDB2777);
    } else if (lower.contains('cloth')) {
      return const Color(0xFF7C3AED);
    } else if (lower.contains('doctor')) {
      return const Color(0xFFDC2626);
    } else if (lower.contains('eat') || lower.contains('party') || lower.contains('food')) {
      return const Color(0xFFEA580C);
    } else if (lower.contains('game') || lower.contains('entertainment')) {
      return const Color(0xFF9333EA);
    } else if (lower.contains('grocery') || lower.contains('carrot')) {
      return const Color(0xFF16A34A);
    } else if (lower.contains('internet') || lower.contains('wifi')) {
      return const Color(0xFF6366F1);
    } else if (lower.contains('lab') || lower.contains('test')) {
      return const Color(0xFFE11D48);
    } else if (lower.contains('lpg') || lower.contains('gas')) {
      return const Color(0xFFEA580C);
    } else if (lower.contains('medicin') || lower.contains('pharma') || lower.contains('pill')) {
      return const Color(0xFF4F46E5);
    } else if (lower.contains('mobile phone') || (lower.contains('mobile') && !lower.contains('recharge'))) {
      return const Color(0xFF2563EB);
    } else if (lower.contains('parking')) {
      return const Color(0xFF475569);
    } else if (lower.contains('petrol') || lower.contains('fuel')) {
      return const Color(0xFFCA8A04);
    } else if (lower.contains('recharge')) {
      return const Color(0xFF0284C7);
    } else if (lower.contains('repair') || lower.contains('service')) {
      return const Color(0xFFD97706);
    } else if (lower.contains('saloon') || lower.contains('salon')) {
      return const Color(0xFFBE185D);
    } else if (lower.contains('school') || lower.contains('college')) {
      return const Color(0xFF059669);
    } else if (lower.contains('shop')) {
      return const Color(0xFFE11D48);
    } else if (lower.contains('subscri')) {
      return const Color(0xFF7C3AED);
    } else if (lower.contains('travel')) {
      return const Color(0xFF0D9488);
    } else if (lower.contains('tuition')) {
      return const Color(0xFF0369A1);
    } else if (lower.contains('unplanned')) {
      return const Color(0xFFE11D48);
    } else if (lower.contains('watch')) {
      return const Color(0xFF334155);
    }
    return const Color(0xFF0F766E);
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final currency = ref.read(currencyProvider);
    final rupees = item.amountMinor ~/ 100;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.trash,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Expense?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this expense? It will be removed from your spending analytics.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputFieldBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _getCategoryBgColor(item.categoryName, item.title),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        _getCategoryIcon(item.categoryName, item.title),
                        color: _getCategoryIconColor(
                            item.categoryName, item.title),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _resolveExpenseTypeName(ref),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currency.symbol}$rupees',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.tag == ExpenseTag.needed
                            ? 'Needed'
                            : 'Not Needed',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.slate200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ref
                          .read(dashboardSummaryProvider.notifier)
                          .deleteExpense(item.id);
                      if (context.mounted) {
                        AppSnackBar.showSuccess(
                            context, 'Expense deleted successfully');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppSnackBar.showError(
                          context,
                          'Failed to delete expense: ${e.toString().replaceAll('Exception: ', '')}',
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final displayCategory = _resolveExpenseTypeName(ref);
    final rupees = item.amountMinor ~/ 100;
    final iconBg = _getCategoryBgColor(item.categoryName, item.title);
    final iconColor = _getCategoryIconColor(item.categoryName, item.title);
    final iconData = _getCategoryIcon(item.categoryName, item.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap ??
              () {
                context.push(AppRoutes.expenseDetail, extra: item);
              },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                // 1. Category Icon inside Pastel Rounded Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      iconData,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Center Content: 2-Line Layout preventing truncation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top Row: Title + Amount
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutralDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currency.symbol}$rupees',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Bottom Row: Subtitle + Tag Pill
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.timeFormatted.isNotEmpty
                                  ? '$displayCategory  •  ${item.timeFormatted}'
                                  : displayCategory,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.slate400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: item.tag == ExpenseTag.needed
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.tag == ExpenseTag.needed ? 'Needed' : 'Not Needed',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.tag == ExpenseTag.needed
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Prominent 3-Dots Menu Button (Far Right, zero dead space)
                if (showActions) ...[
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 28,
                    height: 38,
                    child: PopupMenuButton<String>(
                      icon: const PhosphorIcon(
                        PhosphorIconsBold.dotsThreeVertical,
                        color: AppColors.slate500,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (action) {
                        if (action == 'edit') {
                          AddExpenseDialog.show(context, existingExpense: item);
                        } else if (action == 'delete') {
                          _showDeleteConfirmation(context, ref);
                        } else if (action == 'details') {
                          context.push(AppRoutes.expenseDetail, extra: item);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsRegular.pencilSimple,
                                size: 16,
                                color: AppColors.slate700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsRegular.eye,
                                size: 16,
                                color: AppColors.slate700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'View Details',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsRegular.trash,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}




