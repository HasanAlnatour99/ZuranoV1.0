import 'package:flutter/material.dart';

import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';
import 'shift_ui/shift_icon_button.dart';

class WeekRangeNavigator extends StatelessWidget {
  const WeekRangeNavigator({
    super.key,
    required this.rangeLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String rangeLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ShiftGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      radius: 22,
      child: Row(
        children: [
          ShiftIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPrev,
            iconSize: 26,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: ShiftDesignTokens.primary,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    rangeLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ShiftDesignTokens.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ShiftIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onNext,
            iconSize: 26,
          ),
        ],
      ),
    );
  }
}
