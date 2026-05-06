import 'package:flutter/material.dart';

/// Purple / lavender Zurano discovery shell (standalone from app-wide teal branding).
abstract final class ZuranoCustomerColors {
  static const Color background = Color(0xFFFCFAFF);
  /// Search / discovery list shell (slightly warmer lavender).
  static const Color searchBackground = Color(0xFFFAF7FF);
  static const Color primary = Color(0xFF7C3AED);
  static const Color headerGradientMid = Color(0xFF9B51E0);
  static const Color headerGradientEnd = Color(0xFFC084FC);
  static const Color lavenderSoft = Color(0xFFF2E9FF);
  static const Color lavenderOutline = Color(0xFF8B5CF6);
  static const Color textStrong = Color(0xFF11162E);
  static const Color textMuted = Color(0xFF6B6478);
  static const Color borderHairline = Color(0xFFEDE7F6);
  static const Color discountGreen = Color(0xFF16A34A);

  /// Discovery search + chips (customer search screen, filter sheet opened from it).
  static ThemeData discoveryShellTheme(ThemeData base) {
    final cs = base.colorScheme.copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: searchBackground,
      onSurface: textStrong,
      onSurfaceVariant: textMuted,
      surfaceContainerHigh: lavenderSoft,
      surfaceContainerHighest: lavenderSoft,
      outline: borderHairline,
      primaryContainer: lavenderSoft,
      onPrimaryContainer: textStrong,
    );
    return base.copyWith(
      scaffoldBackgroundColor: searchBackground,
      colorScheme: cs,
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        side: const BorderSide(color: borderHairline),
        backgroundColor: Colors.white,
        selectedColor: primary,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(
          color: textStrong,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      iconTheme: const IconThemeData(color: textStrong),
      textTheme: base.textTheme.apply(
        bodyColor: textStrong,
        displayColor: textStrong,
      ),
    );
  }
}
