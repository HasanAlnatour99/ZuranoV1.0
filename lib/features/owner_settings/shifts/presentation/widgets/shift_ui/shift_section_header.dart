import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

class ShiftSectionHeader extends StatelessWidget {
  const ShiftSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: ShiftDesignTokens.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
