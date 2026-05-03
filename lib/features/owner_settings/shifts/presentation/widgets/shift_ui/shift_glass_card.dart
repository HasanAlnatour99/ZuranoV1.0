import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

/// Premium white surface: border + soft shadow (no Material [Card]).
class ShiftGlassCard extends StatelessWidget {
  const ShiftGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Corner radius; defaults to [ShiftDesignTokens.cardRadius].
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? ShiftDesignTokens.cardRadius;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: ShiftDesignTokens.card,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: ShiftDesignTokens.border),
        boxShadow: ShiftDesignTokens.cardShadow,
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
