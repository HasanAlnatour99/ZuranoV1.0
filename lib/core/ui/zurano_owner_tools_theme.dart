import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared Zurano premium styling for owner tools (Activity Center, Reports, exports).
abstract final class ZuranoOwnerToolsTheme {
  static Color get background => ZuranoPremiumUiColors.background;

  static AppBar appBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      backgroundColor: ZuranoPremiumUiColors.background,
      foregroundColor: ZuranoPremiumUiColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: ZuranoPremiumUiColors.textPrimary,
        ),
      ),
      actions: actions,
      iconTheme: const IconThemeData(color: ZuranoPremiumUiColors.primaryPurple),
      actionsIconTheme:
          const IconThemeData(color: ZuranoPremiumUiColors.primaryPurple),
    );
  }

  static BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
        color: ZuranoPremiumUiColors.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ZuranoPremiumUiColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      );

  /// Section cards (audit detail, metadata blocks).
  static Widget sectionCard({
    required String title,
    required Widget child,
    double radius = 16,
  }) {
    return Container(
      width: double.infinity,
      decoration: cardDecoration(radius: radius),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  static ThemeData chipThemeWrapper(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      chipTheme: ChipThemeData(
        backgroundColor: ZuranoPremiumUiColors.lightSurface,
        selectedColor: ZuranoPremiumUiColors.softPurple,
        disabledColor: ZuranoPremiumUiColors.lightSurface,
        labelStyle: const TextStyle(
          color: ZuranoPremiumUiColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: ZuranoPremiumUiColors.textSecondary,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ZuranoPremiumUiColors.border),
        ),
      ),
    );
  }

  static Widget loadingIndicator() => const Center(
        child: CircularProgressIndicator(
          color: ZuranoPremiumUiColors.primaryPurple,
        ),
      );

  static ButtonStyle filledPrimaryButtonStyle() => FilledButton.styleFrom(
        backgroundColor: ZuranoPremiumUiColors.primaryPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle outlinedNeutralButtonStyle() => OutlinedButton.styleFrom(
        foregroundColor: ZuranoPremiumUiColors.primaryPurple,
        side: const BorderSide(color: ZuranoPremiumUiColors.border),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  static ButtonStyle textAccentButtonStyle() => TextButton.styleFrom(
        foregroundColor: ZuranoPremiumUiColors.primaryPurple,
      );

  static InputDecoration zuranoInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: ZuranoPremiumUiColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ZuranoPremiumUiColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ZuranoPremiumUiColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ZuranoPremiumUiColors.primaryPurple,
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(color: ZuranoPremiumUiColors.textSecondary),
      floatingLabelStyle: const TextStyle(
        color: ZuranoPremiumUiColors.primaryPurple,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static BoxDecoration sheetDecoration() => const BoxDecoration(
        color: ZuranoPremiumUiColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A111827),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      );
}
