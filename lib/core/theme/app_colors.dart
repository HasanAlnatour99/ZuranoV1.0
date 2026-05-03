import 'package:flutter/material.dart';

/// Zurano brand — single purple accent + calm neutrals (2026).
abstract final class AppBrandColors {
  /// Primary actions, links, selected navigation.
  static const primary = Color(0xFF7B2FF7);

  /// Text and icons on top of [primary] (CTA labels).
  static const onPrimary = Color(0xFFFFFFFF);

  /// Secondary chips / soft fills (light).
  static const secondary = Color(0xFFF5F3FF);

  /// Text on [secondary].
  static const onSecondary = Color(0xFF1E1B4B);

  /// Hint / tip callouts.
  static const tipsBackground = Color(0xFF7C3AED);

  /// Text and icons on [tipsBackground].
  static const onTipsBackground = Color(0xFFFFFFFF);
}

/// Dark mode brand — brighter purple primary on deep UI.
abstract final class AppBrandColorsDark {
  static const primary = Color(0xFF8B5CF6);

  /// Text on top of [primary] in dark mode.
  static const onPrimary = Color(0xFFFFFFFF);

  /// Deep purple-tinted secondary surface.
  static const secondary = Color(0xFF2E1065);

  static const onSecondary = Color(0xFFDDD6FE);
}

/// Light palette — lavender background, white cards, purple primary.
abstract final class AppColorsLight {
  static const background = Color(0xFFF8FAFC); // Neutral Slate 50
  static const cardBackground = Color(0xFFFFFFFF);
  static const inputBackground = Color(0xFFF1F5F9); // Slate 100
  static const surfaceContainerHigh = Color(0xFFE2E8F0); // Slate 200
  static const surfaceContainerHighest = Color(0xFFCBD5E1); // Slate 300
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const border = Color(0x260F172A);
  static const outlineVariant = Color(0x140F172A);
  static const disabled = Color(0xFF94A3B8); // Slate 400
  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF410E0B);
  static const primaryContainer = Color(0xFFEDE9FE); // Violet 100
  static const onPrimaryContainer = Color(0xFF1E1B4B); // Indigo 950
  static const secondaryContainer = Color(0xFFF1F5F9);
  static const onSecondaryContainer = Color(0xFF0F172A);

  static const statIconMuted = Color(0xFF64748B); // Slate 500
  static const verifiedBadge = Color(0xFF7C3AED); // Purple 600
  static const pillButtonSurface = Color(0xFFF1F5F9);

  /// Payroll run badge — approved (light mint; not blue secondary).
  static const payrollApprovedBadgeBackground = Color(0xFFE8F5E9);
  static const onPayrollApprovedBadge = Color(0xFF1B5E20);
}

/// Dark palette — deep slate background, dark surfaces, purple primary.
abstract final class AppColorsDark {
  static const background = Color(0xFF020617); // Slate 950
  static const cardBackground = Color(0xFF0F172A); // Slate 900
  static const inputBackground = Color(0xFF1E293B); // Slate 800
  static const surfaceContainerHigh = Color(0xFF1E293B);
  static const surfaceContainerHighest = Color(0xFF334155); // Slate 700
  static const textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const textSecondary = Color(0xFF94A3B8); // Slate 400
  static const border = Color(0xFF334155);
  static const outlineVariant = Color(0x33334155);
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);
  static const primaryContainer = Color(0xFF2E1065); // Violet 950
  static const onPrimaryContainer = Color(0xFFDDD6FE); // Violet 200
  static const secondaryContainer = Color(0xFF0F172A);
  static const onSecondaryContainer = Color(0xFFF8FAFC);

  static const statIconMuted = Color(0xFF94A3B8);
  static const verifiedBadge = Color(0xFF8B5CF6); // Violet 500
  static const pillButtonSurface = Color(0xFF1E293B);

  static const payrollApprovedBadgeBackground = Color(0xFF1B3D24);
  static const onPayrollApprovedBadge = Color(0xFFC8E6C9);
}

/// Premium brand — luxury purple for auth & onboarding.
abstract final class AppBrandColorsPremium {
  /// Primary premium purple.
  static const primary = Color(0xFF7B2FF7);

  /// Gradient end / secondary accent.
  static const primaryLight = Color(0xFF9B51E0);

  /// Text and icons on top of [primary].
  static const onPrimary = Color(0xFFFFFFFF);

  /// Secondary purple (supporting fills / hovers).
  static const secondary = Color(0xFF9B51E0);
}

/// Marketing / auth accents — shared gradient (purple-based).
abstract final class AppPremiumGradients {
  static const accent = LinearGradient(
    colors: [Color(0xFF7B2FF7), Color(0xFF9B51E0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Premium Zurano surfaces for **Settings** and **HR & violations** (purple accent).
/// Use for dedicated salon-owner flows; keep the rest of the app on [ThemeData.colorScheme].
abstract final class ZuranoPremiumUiColors {
  static const primaryPurple = Color(0xFF7C3AED);
  static const deepPurple = Color(0xFF5B21B6);
  static const softPurple = Color(0xFFF3ECFF);
  static const background = Color(0xFFFAFAFC);
  static const cardBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF6F7FB);
  static const border = Color(0xFFE7E8EF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const danger = Color(0xFFE11D48);
  static const dangerSoft = Color(0xFFFFEEF3);
}

/// Owner Money / Finance dashboard (premium SaaS surface — use with Finance tab UI).
abstract final class FinanceDashboardColors {
  static const primaryPurple = Color(0xFF6D35F2);
  static const deepPurple = Color(0xFF5527D9);
  static const lightPurple = Color(0xFFF4EEFF);
  static const textPrimary = Color(0xFF101426);
  static const textSecondary = Color(0xFF667085);
  static const border = Color(0xFFE8E4F0);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFBFAFF);
  static const expensePink = Color(0xFFFF2D7A);
  static const expensePinkSoft = Color(0xFFFFEEF6);
  static const greenProfit = Color(0xFF16A34A);
  static const greenProfitSoft = Color(0xFFEFFBF4);
  static const bluePayroll = Color(0xFF3B82F6);
  static const bluePayrollSoft = Color(0xFFEFF6FF);
  static const headerGradientStart = Color(0xFF5B2BE0);
  static const headerGradientMid = Color(0xFF6D35F2);
  static const headerGradientEnd = Color(0xFF8B5CF6);
}
