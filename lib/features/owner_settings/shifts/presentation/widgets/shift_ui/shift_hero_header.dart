import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';
import 'shift_icon_button.dart';

class ShiftHeroHeader extends StatelessWidget {
  const ShiftHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.leading,
    this.trailingActions,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? trailingActions;

  @override
  Widget build(BuildContext context) {
    final topRowChildren = <Widget>[
      leading ??
          ShiftIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
            iconSize: 18,
          ),
      const Spacer(),
      ...?trailingActions,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: topRowChildren),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: ShiftDesignTokens.textDark,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: ShiftDesignTokens.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
