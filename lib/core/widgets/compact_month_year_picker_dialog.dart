import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mobymoney/core/theme/app_colors.dart';

/// Clean, high-contrast, ultra-compact month & year picker dialog with year selection list mode
class CompactMonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final int minYear;
  final int maxYear;
  final bool onlyYear;

  const CompactMonthYearPickerDialog({
    super.key,
    required this.initialDate,
    this.minYear = 2020,
    this.maxYear = 2030,
    this.onlyYear = false,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    int minYear = 2020,
    int maxYear = 2030,
    bool onlyYear = false,
  }) {
    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CompactMonthYearPickerDialog(
        initialDate: initialDate,
        minYear: minYear,
        maxYear: maxYear,
        onlyYear: onlyYear,
      ),
    );
  }

  @override
  State<CompactMonthYearPickerDialog> createState() =>
      _CompactMonthYearPickerDialogState();
}

class _CompactMonthYearPickerDialogState
    extends State<CompactMonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _isSelectingYearList = false;

  final List<String> _monthNames = const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _isSelectingYearList = widget.onlyYear;
  }

  void _prevYear() {
    if (_selectedYear > widget.minYear) {
      setState(() => _selectedYear--);
    }
  }

  void _nextYear() {
    if (_selectedYear < widget.maxYear) {
      setState(() => _selectedYear++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.slate200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header: Interactive Year Header (Tap to toggle Year list)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: !_isSelectingYearList && _selectedYear > widget.minYear
                        ? _prevYear
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: !_isSelectingYearList && _selectedYear > widget.minYear
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isSelectingYearList && _selectedYear > widget.minYear
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.caretLeft,
                          size: 15,
                          color: !_isSelectingYearList && _selectedYear > widget.minYear
                              ? AppColors.neutralDark
                              : AppColors.slate300,
                        ),
                      ),
                    ),
                  ),

                  // Year Button with caret indicator
                  InkWell(
                    onTap: () {
                      if (!widget.onlyYear) {
                        setState(() => _isSelectingYearList = !_isSelectingYearList);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.calendarBlank,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_selectedYear',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          PhosphorIcon(
                            _isSelectingYearList
                                ? PhosphorIconsRegular.caretUp
                                : PhosphorIconsRegular.caretDown,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: !_isSelectingYearList && _selectedYear < widget.maxYear
                        ? _nextYear
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: !_isSelectingYearList && _selectedYear < widget.maxYear
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isSelectingYearList && _selectedYear < widget.maxYear
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.caretRight,
                          size: 15,
                          color: !_isSelectingYearList && _selectedYear < widget.maxYear
                              ? AppColors.neutralDark
                              : AppColors.slate300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Main Content: Either Month Grid or Years Grid
            if (_isSelectingYearList || widget.onlyYear) ...[
              // Years List Grid
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      widget.maxYear - widget.minYear + 1,
                      (i) {
                        final yr = widget.minYear + i;
                        final isSelected = _selectedYear == yr;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedYear = yr;
                              if (!widget.onlyYear) {
                                _isSelectingYearList = false;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 76,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.slate100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$yr',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.neutralDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              // Months Grid (4 columns x 3 rows)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.45,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final monthNumber = index + 1;
                  final isSelected = _selectedMonth == monthNumber;
                  final monthLabel = _monthNames[index];

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedMonth = monthNumber);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.slate200,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          monthLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.slate700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      side: const BorderSide(color: AppColors.slate200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final result = DateTime(
                        _selectedYear,
                        widget.onlyYear ? 1 : _selectedMonth,
                        1,
                      );
                      Navigator.of(context).pop(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.inter(
                        fontSize: 13,
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
