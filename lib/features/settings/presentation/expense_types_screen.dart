import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/features/expenses/domain/models/expense_type_model.dart';
import 'package:mobymoney/features/expenses/presentation/providers/expense_types_provider.dart';

class ExpenseTypesScreen extends ConsumerStatefulWidget {
  const ExpenseTypesScreen({super.key});

  @override
  ConsumerState<ExpenseTypesScreen> createState() => _ExpenseTypesScreenState();
}

class _ExpenseTypesScreenState extends ConsumerState<ExpenseTypesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseTypesAsync = ref.watch(expenseTypesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        actions: [
          IconButton(
            onPressed: () => ref.read(expenseTypesProvider.notifier).refresh(),
            icon: const PhosphorIcon(
              PhosphorIconsRegular.arrowsClockwise,
              color: AppColors.primary,
              size: 20,
            ),
            tooltip: 'Refresh Types',
          ),
        ],
      ),
      body: expenseTypesAsync.when(
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (types) {
          final filteredTypes = _searchQuery.isEmpty
              ? types
              : types
                  .where((t) =>
                      t.name.toLowerCase().contains(_searchQuery) ||
                      t.id.toString().contains(_searchQuery))
                  .toList();

          return Column(
            children: [
              // Search & Stats Header Bar
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.magnifyingGlass,
                            size: 18,
                            color: AppColors.slate400,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutralDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search expense type (e.g. Bills, Petrol)...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.slate400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () => _searchController.clear(),
                              child: const PhosphorIcon(
                                PhosphorIconsRegular.xCircle,
                                size: 18,
                                color: AppColors.slate400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Active Count Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SERVER TYPES (${filteredTypes.length})',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.slate500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'GET /expensetype',
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // List of Expense Types
              Expanded(
                child: filteredTypes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(expenseTypesProvider.notifier).refresh(),
                        color: AppColors.primary,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                          itemCount: filteredTypes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredTypes[index];
                            return _buildTypeCard(item);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeCard(ExpenseTypeModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.slate200.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
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

          // Name and ID badge
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'API ID: ${item.id}',
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

          // Cloud sync checkmark badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${item.id}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.slate600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: 8,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.slate200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 70,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.warningCircle,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load expense types',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(expenseTypesProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const PhosphorIcon(
                PhosphorIconsRegular.arrowsClockwise,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _searchQuery.isNotEmpty
                  ? 'No matching expense types'
                  : 'No Expense Types Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with a different keyword'
                  : 'No categories available from server',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
