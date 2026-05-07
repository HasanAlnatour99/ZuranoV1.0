import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';

/// Customer-flow scaffold with Zurano off-white canvas.
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
      backgroundColor: ZuranoTokens.background,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}

/// Filled purple CTA for customer flows (Zurano).
class CustomerPrimaryButtonStyle {
  static ButtonStyle filled(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: ZuranoTokens.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(0, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
      ),
    );
  }
}
