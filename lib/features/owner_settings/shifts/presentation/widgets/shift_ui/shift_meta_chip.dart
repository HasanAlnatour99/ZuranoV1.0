import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

class ShiftMetaChip extends StatelessWidget {
  const ShiftMetaChip({
    super.key,
    required this.label,
    this.foreground,
    this.background,
  });

  final String label;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? ShiftDesignTokens.softPurple,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ShiftDesignTokens.border.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground ?? ShiftDesignTokens.primary,
        ),
      ),
    );
  }
}
