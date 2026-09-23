import 'package:flutter/material.dart';

/// Helper to generate consistent, deterministic, and aesthetic colors for expense categories.
class CategoryColorHelper {
  // Standard normal distinct color palette matching the pie chart in image:
  // Primary Blue, Green, Orange, Purple, Red, Cyan, Yellow, Lime, Magenta, etc.
  static const List<Color> palette = [
    Color(0xFF007BFF), // Standard Bright Blue (35%)
    Color(0xFF28A745), // Standard Green (30%)
    Color(0xFFFF9800), // Standard Orange (20%)
    Color(0xFF9C27B0), // Standard Purple (10%)
    Color(0xFFE53935), // Standard Red (4%)
    Color(0xFF00BCD4), // Standard Cyan/Teal (1%)
    Color(0xFFFFC107), // Standard Amber/Yellow
    Color(0xFF8BC34A), // Standard Light Green
    Color(0xFFE91E63), // Standard Pink
    Color(0xFF3F51B5), // Standard Indigo
    Color(0xFF795548), // Standard Brown
    Color(0xFF607D8B), // Standard Blue Grey
  ];

  // Specific semantic color mappings for common category terms
  static final Map<String, Color> _semanticColorMap = {
    'bills': const Color(0xFF007BFF), // Standard Blue
    'internet': const Color(0xFF00BCD4), // Cyan
    'wifi': const Color(0xFF00BCD4),
    'broadband': const Color(0xFF00BCD4),
    'groceries': const Color(0xFF28A745), // Standard Green
    'grocery': const Color(0xFF28A745),
    'food': const Color(0xFF28A745),
    'dining': const Color(0xFF28A745),
    'travel': const Color(0xFFFF9800), // Standard Orange
    'transport': const Color(0xFFFF9800),
    'fuel': const Color(0xFFFF9800),
    'petrol': const Color(0xFFFF9800),
    'shopping': const Color(0xFF9C27B0), // Standard Purple
    'clothes': const Color(0xFF9C27B0),
    'entertainment': const Color(0xFF9C27B0),
    'cinema': const Color(0xFF9C27B0),
    'doctor': const Color(0xFFE53935), // Standard Red
    'hospital': const Color(0xFFE53935),
    'medicines': const Color(0xFFE53935),
    'lab tests': const Color(0xFFFFC107), // Standard Amber
    'education': const Color(0xFF3F51B5), // Indigo
    'books': const Color(0xFF3F51B5),
  };

  /// Returns a consistent, deterministic color for any category name.
  /// If the category name is known, returns its dedicated semantic color.
  /// If it's a new / custom user category, calculates a deterministic hash index
  /// into the curated aesthetic palette so the color is 100% predictable every time.
  static Color getColorForCategory(String categoryName) {
    final normalized = categoryName.trim().toLowerCase();
    if (normalized.isEmpty) return palette[0];

    // 1. Direct semantic match
    if (_semanticColorMap.containsKey(normalized)) {
      return _semanticColorMap[normalized]!;
    }

    // 2. Partial keyword matching
    for (final entry in _semanticColorMap.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    // 3. Deterministic hash code calculation for any custom category
    final hash = normalized.codeUnits.fold<int>(0, (prev, curr) => (prev * 31 + curr) & 0x7FFFFFFF);
    return palette[hash % palette.length];
  }
}
