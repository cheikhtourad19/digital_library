import 'package:flutter/material.dart';

/// Digital Library — App Color Palette
/// Extracted from the official Digital Library logo.
abstract class AppColors {
  // ─── Brand Core ───────────────────────────────────────────────
  /// Navy Blue — primary text, headings, book base, dark UI elements
  static const Color primary = Color(0xFF1A2B5E);

  /// Cyan / Sky Blue — interactive elements, links, "Library" wordmark
  static const Color secondary = Color(0xFF29B6D8);

  /// Amber / Golden — accents, highlights, call-to-action
  static const Color accent = Color(0xFFF5A623);

  // ─── Backgrounds ──────────────────────────────────────────────
  /// Light Ice Blue — main app/page background
  static const Color background = Color(0xFFE8F4FB);

  /// Soft Sky — gradient start (top-left)
  static const Color backgroundGradientStart = Color(0xFFC9E8F5);

  /// White — cards, panels, surfaces
  static const Color surface = Color(0xFFFFFFFF);

  // ─── Text ─────────────────────────────────────────────────────
  /// Primary text — navy
  static const Color textPrimary = Color(0xFF1A2B5E);

  /// Secondary / highlighted text — cyan
  static const Color textSecondary = Color(0xFF29B6D8);

  /// Muted / placeholder text
  static const Color textMuted = Color(0xFF7A9BB5);

  // ─── Borders & Shadows ────────────────────────────────────────
  static const Color border = Color(0x4029B6D8);   // Cyan @ 25% opacity
  static const Color shadow = Color(0x1F1A2B5E);   // Navy  @ 12% opacity

  // ─── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF29B6D8);
  static const Color warning = Color(0xFFF5A623);
  static const Color error   = Color(0xFFE05252);
  static const Color info    = Color(0xFF29B6D8);

  // ─── Gradient helpers ─────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundGradientStart, background],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFE8913A)],
  );
}
