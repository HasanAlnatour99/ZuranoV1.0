import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Customer-flow scaffold with a plain white canvas (no tinted gradient).
class CustomerGradientScaffold extends StatelessWidget {
  const CustomerGradientScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}

/// Deep purple filled button for customer CTAs (matches brand primary).
class CustomerPrimaryButtonStyle {
  static ButtonStyle filled(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: AppBrandColors.primary,
      foregroundColor: AppBrandColors.onPrimary,
      elevation: 0,
      // App theme uses minimum width infinity for full-bleed CTAs; in a Row that
      // yields unbounded width. Use intrinsic width with a fixed min height.
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
