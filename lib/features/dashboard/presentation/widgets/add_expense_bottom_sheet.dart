import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';
import 'package:mobymoney/core/widgets/app_snack_bar.dart';
import 'package:mobymoney/features/expenses/domain/models/expense_type_model.dart';
import 'package:mobymoney/features/expenses/presentation/providers/expense_types_provider.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';
import '../../domain/models/dashboard_summary_model.dart';
import '../providers/dashboard_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final RecentExpenseItemModel? existingExpense;

  const AddExpenseDialog({
    super.key,
    this.existingExpense,
  });

  static Future<void> show(
    BuildContext context, {
    RecentExpenseItemModel? existingExpense,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddExpenseDialog(
        existingExpense: existingExpense,
      ),
    );
  }

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  int? _selectedExpenseTypeId;
  DateTime _selectedDate = DateTime.now();
  late final TextEditingController _nameController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _amountController;
  int _quantity = 1;
  bool _isReallyNeeded = true;
  bool _isSubmitting = false;

  // Validation Error Messages
  String? _expenseTypeError;
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      final exp = widget.existingExpense!;
      _nameController = TextEditingController(text: exp.title);
      _quantity = exp.quantity > 0 ? exp.quantity : 1;
      final unitPrice = (exp.unitPriceMinor > 0)
          ? (exp.unitPriceMinor / 100).toStringAsFixed(2)
          : (exp.amountMinor / (_quantity > 0 ? _quantity : 1) / 100).toStringAsFixed(2);
      final totalAmount = (exp.amountMinor / 100).toStringAsFixed(2);
      _unitPriceController = TextEditingController(text: unitPrice);
      _amountController = TextEditingController(text: totalAmount);
      _isReallyNeeded = exp.tag == ExpenseTag.needed;
      _selectedExpenseTypeId = exp.expenseTypeId;
      if (exp.rawDate != null) {
        _selectedDate = exp.rawDate!;
      }
    } else {
      _nameController = TextEditingController(text: '');
      _unitPriceController = TextEditingController(text: '');
      _amountController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onUnitPriceChanged(String val) {
    if (_amountError != null) setState(() => _amountError = null);
    final unitPrice = double.tryParse(val.trim()) ?? 0.0;
    final total = unitPrice * _quantity;
    _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';
  }

  void _onAmountChanged(String val) {
    if (_amountError != null) setState(() => _amountError = null);
    final total = double.tryParse(val.trim()) ?? 0.0;
    if (_quantity > 0) {
      final unitPrice = total / _quantity;
      _unitPriceController.text = unitPrice > 0 ? unitPrice.toStringAsFixed(2) : '';
    }
  }

  void _onQuantityChanged(int newQuantity) {
    if (newQuantity < 1) return;
    setState(() => _quantity = newQuantity);
    final unitPrice = double.tryParse(_unitPriceController.text.trim());
    if (unitPrice != null && unitPrice > 0) {
      final total = unitPrice * _quantity;
      _amountController.text = total.toStringAsFixed(2);
    } else {
      final total = double.tryParse(_amountController.text.trim());
      if (total != null && total > 0 && _quantity > 0) {
        _unitPriceController.text = (total / _quantity).toStringAsFixed(2);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedExpenseTypeId = null;
      _selectedDate = DateTime.now();
      _nameController.text = '';
      _unitPriceController.text = '';
      _amountController.text = '';
      _quantity = 1;
      _isReallyNeeded = true;
      _expenseTypeError = null;
      _nameError = null;
      _amountError = null;
    });
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.neutralDark,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    return isToday
        ? 'Today (${DateFormat('d MMM yyyy').format(dt)})'
        : DateFormat('d MMM yyyy').format(dt);
  }

  bool _validateForm(List<ExpenseTypeModel> availableTypes) {
    bool isValid = true;
    String? expenseTypeError;
    String? nameError;
    String? amountError;

    // 1. Expense Type validation
    if (_selectedExpenseTypeId == null && widget.existingExpense == null) {
      expenseTypeError = 'Please select an expense type';
      isValid = false;
    }

    // 2. Expense Name validation
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      nameError = 'Please enter an expense name';
      isValid = false;
    } else if (name.length < 2) {
      nameError = 'Expense name must be at least 2 characters';
      isValid = false;
    }

    // 3. Amount & Unit Price validation
    final unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (totalAmount <= 0 && unitPrice <= 0) {
      amountError = 'Please enter a valid unit price or amount';
      isValid = false;
    }

    setState(() {
      _expenseTypeError = expenseTypeError;
      _nameError = nameError;
      _amountError = amountError;
    });

    return isValid;
  }

  Future<void> _saveExpense(List<ExpenseTypeModel> availableTypes) async {
    if (_isSubmitting) return;

    if (!_validateForm(availableTypes)) {
      return;
    }

    final selectedType = availableTypes.firstWhere(
      (t) => t.id == _selectedExpenseTypeId,
      orElse: () => availableTypes.isNotEmpty
          ? availableTypes.first
          : const ExpenseTypeModel(id: 1, name: 'General Expense'),
    );

    final name = _nameController.text.trim().isEmpty
        ? selectedType.name
        : _nameController.text.trim();

    double unitPrice = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;
    double totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    // If only one was entered, deduce the other
    if (totalAmount > 0 && unitPrice == 0 && _quantity > 0) {
      unitPrice = totalAmount / _quantity;
    } else if (unitPrice > 0 && totalAmount == 0) {
      totalAmount = unitPrice * _quantity;
    }

    // Combine picked date with current automatic time
    final now = DateTime.now();
    final completeDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingExpense != null) {
        await ref.read(dashboardSummaryProvider.notifier).updateExpense(
              expenseId: widget.existingExpense!.id,
              expenseTypeId: selectedType.id,
              date: completeDateTime,
              name: name,
              quantityPurchased: _quantity,
              unitPrice: unitPrice,
              amount: totalAmount,
              reallyNeeded: _isReallyNeeded,
            );
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Expense updated successfully!');
          Navigator.of(context).pop();
        }
      } else {
        await ref.read(dashboardSummaryProvider.notifier).addExpense(
              expenseTypeId: selectedType.id,
              date: completeDateTime,
              name: name,
              quantityPurchased: _quantity,
              unitPrice: unitPrice,
              amount: totalAmount,
              reallyNeeded: _isReallyNeeded,
            );
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Expense added successfully!');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to save expense: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isEditing = widget.existingExpense != null;
    final expenseTypesAsync = ref.watch(expenseTypesProvider);
    final availableTypes = expenseTypesAsync.asData?.value ?? [];

    // Preselect existing expense category if editing and not yet set
    if (isEditing && _selectedExpenseTypeId == null && availableTypes.isNotEmpty) {
      final match = availableTypes.firstWhere(
        (t) =>
            t.name.toLowerCase() ==
            widget.existingExpense!.categoryName.toLowerCase(),
        orElse: () => availableTypes.first,
      );
      _selectedExpenseTypeId = match.id;
    }

    return Dialog(
      backgroundColor: const Color(0xFFF8FAFC),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.85,
          maxWidth: 440,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Dialog Header: Close Button | Title | Reset Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Icon Button
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.x,
                          size: 18,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    isEditing ? 'Edit Expense' : 'Add Expense',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.neutralDark,
                    ),
                  ),

                  // Reset Button
                  InkWell(
                    onTap: _resetForm,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.arrowsCounterClockwise,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.slate200),

            // Scrollable Form Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. EXPENSE TYPE (Dropdown)
                    _buildSectionLabel('EXPENSE TYPE'),
                    const SizedBox(height: 8),
                    _buildExpenseTypeDropdown(expenseTypesAsync),

                    const SizedBox(height: 16),

                    // 3. DATE
                    _buildSectionLabel('DATE'),
                    const SizedBox(height: 8),
                    _buildDateTile(),

                    const SizedBox(height: 16),

                    // 4. EXPENSE NAME
                    _buildSectionLabel('EXPENSE NAME'),
                    const SizedBox(height: 8),
                    _buildExpenseNameField(),

                    const SizedBox(height: 16),

                    // 5. QUANTITY & UNIT PRICE ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity (Left)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('QUANTITY'),
                              const SizedBox(height: 8),
                              _buildQuantityStepper(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Price (Right)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('UNIT PRICE'),
                              const SizedBox(height: 8),
                              _buildUnitPriceField(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 6. TOTAL AMOUNT
                    _buildSectionLabel('TOTAL AMOUNT'),
                    const SizedBox(height: 8),
                    _buildTotalAmountField(),

                    const SizedBox(height: 18),

                    // 7. REALLY NEEDED? BANNER CARD
                    _buildReallyNeededCard(),

                    const SizedBox(height: 22),

                    // 8. ACTION BUTTONS ROW: [Cancel] & [Add/Save Expense]
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.slate300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Save / Add Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => _saveExpense(availableTypes),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF0F766E).withValues(alpha: 0.5),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PhosphorIcon(
                                        isEditing
                                            ? PhosphorIconsRegular.check
                                            : PhosphorIconsRegular.plusCircle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isEditing ? 'Save Changes' : 'Add Expense',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.slate500,
      ),
    );
  }

  Widget _buildExpenseTypeDropdown(
      AsyncValue<List<ExpenseTypeModel>> expenseTypesAsync) {
    return expenseTypesAsync.when(
      loading: () => Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading expense types...',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFECACA),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const PhosphorIcon(
              PhosphorIconsRegular.warningCircle,
              color: AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Failed to load types',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
            InkWell(
              onTap: () => ref.read(expenseTypesProvider.notifier).refresh(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      data: (types) {
        if (types.isEmpty) {
          return Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                'No expense types found',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.slate400,
                ),
              ),
            ),
          );
        }

        final selectedId = types.any((t) => t.id == _selectedExpenseTypeId)
            ? _selectedExpenseTypeId
            : null;

        final hasError = _expenseTypeError != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
                  width: hasError ? 1.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasError
                        ? AppColors.error.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedId,
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsRegular.tag,
                            color: AppColors.slate400,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select Expense Type',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.caretDown,
                    color: AppColors.slate400,
                    size: 16,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  elevation: 4,
                  onChanged: (int? newId) {
                    if (newId != null) {
                      setState(() {
                        _selectedExpenseTypeId = newId;
                        _expenseTypeError = null;
                      });
                    }
                  },
                  items: types.map((ExpenseTypeModel item) {
                    return DropdownMenuItem<int>(
                      value: item.id,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                item.icon,
                                color: item.color,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 5),
              _buildErrorRow(_expenseTypeError!),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDateTile() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const PhosphorIcon(
              PhosphorIconsRegular.calendarBlank,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _formatDate(_selectedDate),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralDark,
                ),
              ),
            ),
            const PhosphorIcon(
              PhosphorIconsRegular.caretDown,
              color: AppColors.slate400,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseNameField() {
    final hasError = _nameError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              PhosphorIcon(
                PhosphorIconsRegular.notepad,
                color: hasError ? AppColors.error : AppColors.slate700,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  onChanged: (val) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutralDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Office Stationery & Notebooks',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.slate400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          _buildErrorRow(_nameError!),
        ],
      ],
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Minus Button
          InkWell(
            onTap: () {
              if (_quantity > 1) {
                _onQuantityChanged(_quantity - 1);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.minus,
                  size: 12,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ),

          // Quantity text
          Text(
            '$_quantity',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),

          // Plus Button
          InkWell(
            onTap: () {
              _onQuantityChanged(_quantity + 1);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: PhosphorIcon(
                  PhosphorIconsRegular.plus,
                  size: 12,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitPriceField() {
    final hasError = _amountError != null;
    final currency = ref.watch(currencyProvider);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
          width: hasError ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? AppColors.error.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            currency.symbol,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: hasError ? AppColors.error : AppColors.neutralDark,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _unitPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _onUnitPriceChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralDark,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.slate400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountField() {
    final hasError = _amountError != null;
    final currency = ref.watch(currencyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
              width: hasError ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                currency.symbol,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: hasError ? AppColors.error : AppColors.neutralDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onAmountChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.slate400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          _buildErrorRow(_amountError!),
        ],
      ],
    );
  }

  Widget _buildErrorRow(String errorText) {
    return Row(
      children: [
        const PhosphorIcon(
          PhosphorIconsRegular.warningCircle,
          size: 13,
          color: AppColors.error,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            errorText,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReallyNeededCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Leaf Icon
          const PhosphorIcon(
            PhosphorIconsFill.plant,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),

          // Text labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Really Needed?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDark,
                  ),
                ),
                Text(
                  'Essential vs discretionary ratio',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Toggle Switch
          CupertinoSwitch(
            value: _isReallyNeeded,
            activeTrackColor: const Color(0xFF0F766E),
            onChanged: (val) {
              setState(() => _isReallyNeeded = val);
            },
          ),
        ],
      ),
    );
  }
}

// Retain compatibility alias
typedef AddExpenseBottomSheet = AddExpenseDialog;
