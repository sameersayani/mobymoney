import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
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

  void _showAddEditDialog({ExpenseTypeModel? existingItem}) {
    showDialog(
      context: context,
      builder: (ctx) => _AddEditExpenseTypeDialog(existingItem: existingItem),
    );
  }

  void _confirmDelete(ExpenseTypeModel item) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteExpenseTypeDialog(item: item),
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
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
                                hintText:
                                    'Search expense type (e.g. Bills, Petrol)...',
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
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Edit Button (PUT /expensetype/{id})
          IconButton(
            onPressed: () => _showAddEditDialog(existingItem: item),
            icon: const PhosphorIcon(
              PhosphorIconsRegular.pencilSimple,
              size: 20,
              color: AppColors.slate600,
            ),
            tooltip: 'Edit Type',
          ),

          // Delete Button (DELETE /expensetype/{id})
          IconButton(
            onPressed: () => _confirmDelete(item),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  : 'Tap "Add Expense Type" below to create one.',
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

/// Dedicated Add/Edit Dialog with isolated lifecycle
class _AddEditExpenseTypeDialog extends ConsumerStatefulWidget {
  final ExpenseTypeModel? existingItem;

  const _AddEditExpenseTypeDialog({this.existingItem});

  @override
  ConsumerState<_AddEditExpenseTypeDialog> createState() =>
      _AddEditExpenseTypeDialogState();
}

class _AddEditExpenseTypeDialogState
    extends ConsumerState<_AddEditExpenseTypeDialog> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingItem?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _nameController.text.trim();
    if (text.isEmpty) {
      AppSnackBar.showError(context, 'Please enter a type name');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.existingItem != null) {
        // Calls PUT /expensetype/{id}
        await ref.read(expenseTypesProvider.notifier).updateType(
              widget.existingItem!.id,
              text,
            );
        if (!mounted) return;
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(context, 'Expense type updated successfully!');
      } else {
        // Calls POST /expensetype
        await ref.read(expenseTypesProvider.notifier).createType(text);
        if (!mounted) return;
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(context, 'Expense type created successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackBar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
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
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 20,
                  ),
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
              controller: _nameController,
              autofocus: true,
              enabled: !_isSaving,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDark,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Grocery, Fuel, Gym, Freelance',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.slate400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.slate100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
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
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Create Type',
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
  }
}

/// Dedicated Delete Confirmation Dialog
class _DeleteExpenseTypeDialog extends ConsumerStatefulWidget {
  final ExpenseTypeModel item;

  const _DeleteExpenseTypeDialog({required this.item});

  @override
  ConsumerState<_DeleteExpenseTypeDialog> createState() =>
      _DeleteExpenseTypeDialogState();
}

class _DeleteExpenseTypeDialogState
    extends ConsumerState<_DeleteExpenseTypeDialog> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      // Calls DELETE /expensetype/{id}
      await ref
          .read(expenseTypesProvider.notifier)
          .deleteType(widget.item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(
        context,
        'Expense type #${widget.item.id} deleted',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      AppSnackBar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Delete Expense Type',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.neutralDark,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${widget.item.name}" (ID: ${widget.item.id})? This will remove it from the server.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.slate600,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              color: AppColors.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _delete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isDeleting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}
