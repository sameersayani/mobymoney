import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/settings/presentation/providers/expense_categories_provider.dart';

class ExpenseTypesScreen extends ConsumerWidget {
  const ExpenseTypesScreen({super.key});

  static const List<IconData> kAvailableIcons = [
    PhosphorIconsRegular.tag,
    PhosphorIconsRegular.shoppingBag,
    PhosphorIconsRegular.forkKnife,
    PhosphorIconsRegular.car,
    PhosphorIconsRegular.briefcase,
    PhosphorIconsRegular.receipt,
    PhosphorIconsRegular.television,
    PhosphorIconsRegular.airplane,
    PhosphorIconsRegular.gameController,
    PhosphorIconsRegular.heartbeat,
    PhosphorIconsRegular.house,
    PhosphorIconsRegular.graduationCap,
    PhosphorIconsRegular.wrench,
    PhosphorIconsRegular.gift,
    PhosphorIconsRegular.coffee,
    PhosphorIconsRegular.filmSlate,
  ];

  static const List<Color> kAvailableColors = [
    Color(0xFF0F766E), // Forest Teal
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Crimson
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFF97316), // Orange
    Color(0xFF64748B), // Slate
  ];

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {ExpenseCategoryItem? existingItem}) {
    final isEditing = existingItem != null;
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    IconData selectedIcon = existingItem?.icon ?? PhosphorIconsRegular.tag;
    Color selectedColor = existingItem?.color ?? const Color(0xFF0F766E);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Expense Type' : 'Add Expense Type',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        IconButton(
                          icon: const PhosphorIcon(PhosphorIconsRegular.x, size: 20),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          color: AppColors.slate400,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name Input
                    Text(
                      'TYPE NAME',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., Groceries, Gym, Medical',
                        hintStyle: GoogleFonts.inter(color: AppColors.slate400, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.slate100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon Picker
                    Text(
                      'CHOOSE ICON',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kAvailableIcons.map((iconData) {
                        final isSelected = selectedIcon == iconData;
                        return InkWell(
                          onTap: () {
                            setModalState(() => selectedIcon = iconData);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor.withValues(alpha: 0.15) : AppColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? selectedColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                iconData,
                                size: 20,
                                color: isSelected ? selectedColor : AppColors.slate600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Color Picker
                    Text(
                      'COLOR BADGE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: kAvailableColors.map((color) {
                        final isSelected = selectedColor == color;
                        return InkWell(
                          onTap: () {
                            setModalState(() => selectedColor = color);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Center(
                                    child: PhosphorIcon(
                                      PhosphorIconsBold.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.slate200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) return;
                              if (isEditing) {
                                ref.read(expenseCategoriesProvider.notifier).updateCategory(
                                      existingItem.id,
                                      name: nameController.text,
                                      icon: selectedIcon,
                                      color: selectedColor,
                                    );
                              } else {
                                ref.read(expenseCategoriesProvider.notifier).addCategory(
                                      name: nameController.text,
                                      icon: selectedIcon,
                                      color: selectedColor,
                                    );
                              }
                              Navigator.of(dialogCtx).pop();
                              AppSnackBar.showSuccess(
                                context,
                                isEditing ? 'Expense type updated' : 'Expense type added',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              isEditing ? 'Save Changes' : 'Add Type',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ExpenseCategoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Expense Type',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.slate600,
            height: 1.4,
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
            onPressed: () {
              ref.read(expenseCategoriesProvider.notifier).deleteCategory(item.id);
              Navigator.of(ctx).pop();
              AppSnackBar.showSuccess(context, 'Expense type deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const PhosphorIcon(
            PhosphorIconsRegular.arrowLeft,
            color: AppColors.neutralDark,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Expense Types',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const PhosphorIcon(
          PhosphorIconsRegular.plus,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'Add Expense Type',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.tag,
                        size: 32,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Expense Types',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap "Add Expense Type" below to create one.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = categories[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.slate200.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Category Icon Box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            item.icon,
                            color: item.color,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Category Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.isCustom ? 'Custom Type' : 'Default Type',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit Button
                      IconButton(
                        onPressed: () => _showAddEditDialog(context, ref, existingItem: item),
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.pencilSimple,
                          size: 20,
                          color: AppColors.slate600,
                        ),
                        tooltip: 'Edit Type',
                      ),

                      // Delete Button
                      IconButton(
                        onPressed: () => _confirmDelete(context, ref, item),
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.trash,
                          size: 20,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete Type',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
