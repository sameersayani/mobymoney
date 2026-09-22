import 'package:flutter/material.dart';

/// Helper to generate consistent, deterministic, and aesthetic colors for expense categories.
class CategoryColorHelper {
  // Predefined curated vibrant multi-color palette spanning the full spectrum
  static const List<Color> palette = [
    Color(0xFF0F766E), // Forest Teal
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Rose Pink
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Bright Violet
    Color(0xFFF97316), // Vivid Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Crimson Red
    Color(0xFF3B82F6), // Royal Sky Blue
    Color(0xFFD946EF), // Fuchsia / Magenta
    Color(0xFF84CC16), // Lime Green
    Color(0xFF14B8A6), // Mint Teal
    Color(0xFFE11D48), // Deep Ruby
    Color(0xFFA855F7), // Purple
    Color(0xFFD97706), // Golden Ochre
    Color(0xFF0284C7), // Ocean Blue
    Color(0xFF4F46E5), // Electric Indigo
    Color(0xFF059669), // Jade Green
    Color(0xFFEA580C), // Deep Coral
  ];

  // Specific semantic color mappings for common category terms
  static final Map<String, Color> _semanticColorMap = {
    'internet': const Color(0xFF0F766E), // Teal
    'wifi': const Color(0xFF0F766E),
    'broadband': const Color(0xFF0F766E),
    'lab tests': const Color(0xFFF59E0B), // Amber
    'medical': const Color(0xFFF59E0B),
    'health': const Color(0xFFEF4444), // Red
    'hospital': const Color(0xFFEF4444),
    'doctor': const Color(0xFFEF4444),
    'medicine': const Color(0xFFE11D48), // Ruby
    'food': const Color(0xFF10B981), // Emerald
    'dining': const Color(0xFF10B981),
    'groceries': const Color(0xFF84CC16), // Lime
    'restaurant': const Color(0xFF059669),
    'cafe': const Color(0xFFD97706),
    'shopping': const Color(0xFF8B5CF6), // Purple
    'cloth': const Color(0xFFD946EF), // Fuchsia
    'fashion': const Color(0xFFD946EF),
    'bills': const Color(0xFF3B82F6), // Blue
    'utilities': const Color(0xFF0284C7),
    'electricity': const Color(0xFFF59E0B),
    'water': const Color(0xFF06B6D4),
    'travel': const Color(0xFFF97316), // Orange
    'transport': const Color(0xFFF97316),
    'fuel': const Color(0xFFEA580C),
    'petrol': const Color(0xFFEA580C),
    'uber': const Color(0xFFF97316),
    'taxi': const Color(0xFFF97316),
    'subscription': const Color(0xFFEC4899), // Rose Pink
    'netflix': const Color(0xFFE11D48),
    'entertainment': const Color(0xFFEC4899),
    'movies': const Color(0xFFEC4899),
    'education': const Color(0xFF6366F1), // Indigo
    'books': const Color(0xFF6366F1),
    'gym': const Color(0xFF06B6D4), // Cyan
    'fitness': const Color(0xFF06B6D4),
    'investment': const Color(0xFF14B8A6),
    'savings': const Color(0xFF14B8A6),
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
