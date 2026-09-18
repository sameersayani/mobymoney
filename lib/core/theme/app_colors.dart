import 'package:flutter/material.dart';

/// Centralized color palette based on product design specifications.
abstract class AppColors {
  // Primary (Forest Teal)
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  // Secondary (Indigo/Blue Iris)
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color secondaryContainer = Color(0xFFEEF2FF);

  // Tertiary (Emerald / Success)
  static const Color tertiary = Color(0xFF10B981);
  static const Color tertiaryLight = Color(0xFF34D399);
  static const Color tertiaryDark = Color(0xFF059669);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);

  // Neutral & Dark Spectrum
  static const Color neutralDark = Color(0xFF0F172A); // Slate 900
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Logo Brand Two-Tone (Moby Money logo colors)
  static const Color brandDark = Color(0xFF1E293B); // "moby" dark tone
  static const Color brandTeal = Color(0xFF0D9488); // "money" teal tone

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F4F9);

  // Input & Field specific
  static const Color inputFieldBg = Color(0xFFEEF2F9);
  static const Color inputFieldBorder = Color(0xFFE2E8F0);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
