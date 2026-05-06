import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic text styles (Inter for Latin, Cairo for Arabic).
/// Prefer [Theme.of(context).textTheme] when a Material role fits; use these for explicit semantics.
abstract final class AppTextStyles {
  static TextStyle _font({
    required Locale locale,
    required TextStyle textStyle,
  }) {
    return locale.languageCode == 'ar'
        ? GoogleFonts.cairo(textStyle: textStyle)
        : GoogleFonts.inter(textStyle: textStyle);
  }

  static TextStyle headingLarge(ColorScheme scheme, {required Locale locale}) =>
      _font(
        locale: locale,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          height: 1.2,
          letterSpacing: locale.languageCode == 'ar' ? 0 : -0.3,
          color: scheme.onSurface,
        ),
      );

  static TextStyle headingMedium(
    ColorScheme scheme, {
    required Locale locale,
  }) => _font(
    locale: locale,
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18,
      height: 1.25,
      letterSpacing: locale.languageCode == 'ar' ? 0 : -0.2,
      color: scheme.onSurface,
    ),
  );

  static TextStyle bodyLarge(ColorScheme scheme, {required Locale locale}) =>
      _font(
        locale: locale,
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: locale.languageCode == 'ar' ? 1.55 : 1.45,
          color: scheme.onSurface,
        ),
      );

  static TextStyle bodyMedium(ColorScheme scheme, {required Locale locale}) =>
      _font(
        locale: locale,
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: locale.languageCode == 'ar' ? 1.5 : 1.4,
          color: scheme.onSurfaceVariant,
        ),
      );

  static TextStyle buttonText(ColorScheme scheme, {required Locale locale}) =>
      _font(
        locale: locale,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
          letterSpacing: locale.languageCode == 'ar' ? 0 : 0.1,
          color: scheme.onPrimary,
        ),
      );

  /// Large serif-style title on discovery place cards (Latin: Playfair via Google Fonts).
  static TextStyle placeCardTitle(Color color, {required Locale locale}) {
    final base = TextStyle(
      fontSize: locale.languageCode == 'ar' ? 26 : 28,
      height: 1.05,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: locale.languageCode == 'ar' ? 0 : -0.8,
    );
    if (locale.languageCode == 'ar') {
      return GoogleFonts.cairo(textStyle: base);
    }
    return GoogleFonts.playfairDisplay(textStyle: base);
  }

  /// Places tab screen title (serif).
  static TextStyle placesScreenTitle(Color color, {required Locale locale}) {
    final base = TextStyle(
      fontSize: locale.languageCode == 'ar' ? 34 : 38,
      height: 1,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: locale.languageCode == 'ar' ? 0 : -1.2,
    );
    if (locale.languageCode == 'ar') {
      return GoogleFonts.cairo(textStyle: base);
    }
    return GoogleFonts.playfairDisplay(textStyle: base);
  }
}
