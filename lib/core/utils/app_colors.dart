import 'package:flutter/material.dart';

/// Digital Library — App Color Palette
/// Flat modern palette (no gradients).
abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF1F2937); // Charcoal
  static const Color secondary = Color(0xFF0F766E); // Deep teal
  static const Color accent = Color(0xFFE76F51); // Burnt coral

  // Surfaces
  static const Color background = Color(0xFFF7F5F2); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);

  // Typography
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF0F766E);
  static const Color textMuted = Color(0xFF6B7280);

  // Borders / shadows
  static const Color border = Color(0x26374151);
  static const Color shadow = Color(0x1A111827);

  // Semantics
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);
}
