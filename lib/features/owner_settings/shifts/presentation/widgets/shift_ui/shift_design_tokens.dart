import 'package:flutter/material.dart';

/// Local purple design system for Shifts & Staff Schedule module only.
abstract final class ShiftDesignTokens {
  static const Color primary = Color(0xFF6D3CEB);
  static const Color deepPurple = Color(0xFF4F2BC8);
  static const Color softPurple = Color(0xFFF3EDFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E5EF);
  static const Color textDark = Color(0xFF090A1F);
  static const Color textMuted = Color(0xFF707386);
  static const Color danger = Color(0xFFE53935);
  static const Color offGray = Color(0xFFEDEDEF);

  static const double pagePadding = 20;
  static const double cardRadius = 24;
  static const double smallRadius = 16;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.055),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}
