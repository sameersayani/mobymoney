import 'package:flutter/material.dart';

/// Helper to generate consistent, deterministic, and aesthetic colors for expense categories.
class CategoryColorHelper {
  // Predefined curated color palette for modern financial applications
  static const List<Color> palette = [
    Color(0xFF0F766E), // Forest Teal
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Rose Pink
    Color(0xFF3B82F6), // Sky Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF97316), // Vivid Orange
    Color(0xFF14B8A6), // Cyan / Mint
    Color(0xFFEF4444), // Crimson Red
    Color(0xFF84CC16), // Lime Green
    Color(0xFF06B6D4), // Deep Cyan
    Color(0xFFA855F7), // Violet
    Color(0xFFD97706), // Ochre
    Color(0xFF4F46E5), // Royal Blue
    Color(0xFFE11D48), // Ruby
  ];

  // Specific semantic color mappings for common category terms
  static final Map<String, Color> _semanticColorMap = {
    'internet': const Color(0xFF0F766E),
    'wifi': const Color(0xFF0F766E),
    'broadband': const Color(0xFF0F766E),
    'lab tests': const Color(0xFFF59E0B),
    'medical': const Color(0xFFF59E0B),
    'health': const Color(0xFFEF4444),
    'hospital': const Color(0xFFEF4444),
    'doctor': const Color(0xFFEF4444),
    'medicine': const Color(0xFFEF4444),
    'food': const Color(0xFF10B981),
    'dining': const Color(0xFF10B981),
    'groceries': const Color(0xFF10B981),
    'restaurant': const Color(0xFF10B981),
    'cafe': const Color(0xFF10B981),
    'shopping': const Color(0xFF8B5CF6),
    'cloth': const Color(0xFF8B5CF6),
    'fashion': const Color(0xFF8B5CF6),
    'bills': const Color(0xFF3B82F6),
    'utilities': const Color(0xFF3B82F6),
    'electricity': const Color(0xFF3B82F6),
    'water': const Color(0xFF3B82F6),
    'travel': const Color(0xFFF97316),
    'transport': const Color(0xFFF97316),
    'fuel': const Color(0xFFF97316),
    'petrol': const Color(0xFFF97316),
    'uber': const Color(0xFFF97316),
    'taxi': const Color(0xFFF97316),
    'subscription': const Color(0xFFEC4899),
    'netflix': const Color(0xFFEC4899),
    'entertainment': const Color(0xFFEC4899),
    'movies': const Color(0xFFEC4899),
    'education': const Color(0xFF6366F1),
    'books': const Color(0xFF6366F1),
    'gym': const Color(0xFF06B6D4),
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
