import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

/// Circular icon control on soft purple (no [IconButton] theme coupling).
class ShiftIconButton extends StatelessWidget {
  const ShiftIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ShiftDesignTokens.softPurple,
            shape: BoxShape.circle,
            border: Border.all(color: ShiftDesignTokens.border),
          ),
          child: Icon(icon, size: iconSize, color: ShiftDesignTokens.textDark),
        ),
      ),
    );
  }
}
