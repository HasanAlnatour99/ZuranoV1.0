import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

class ShiftIconTile extends StatelessWidget {
  const ShiftIconTile({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize = 26,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  /// Compact tile for inline rows.
  const ShiftIconTile.small({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 22,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? ShiftDesignTokens.smallRadius;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? ShiftDesignTokens.softPurple,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: ShiftDesignTokens.border.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? ShiftDesignTokens.primary,
      ),
    );
  }
}
