import 'package:flutter/material.dart';

import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';

/// One glass card with two stat columns and a vertical hairline.
class ShiftStatsPanel extends StatelessWidget {
  const ShiftStatsPanel({
    super.key,
    required this.totalShifts,
    required this.assignedStaffCount,
    required this.totalShiftsLabel,
    required this.assignedStaffLabel,
    required this.templatesLabel,
    required this.employeesLabel,
  });

  final int totalShifts;
  final int assignedStaffCount;
  final String totalShiftsLabel;
  final String assignedStaffLabel;
  final String templatesLabel;
  final String employeesLabel;

  @override
  Widget build(BuildContext context) {
    return ShiftGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _ShiftStatItem(
              label: totalShiftsLabel,
              value: '$totalShifts',
              sublabel: templatesLabel,
            ),
          ),
          const _VerticalHairline(),
          Expanded(
            child: _ShiftStatItem(
              label: assignedStaffLabel,
              value: '$assignedStaffCount',
              sublabel: employeesLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalHairline extends StatelessWidget {
  const _VerticalHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 96,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: ShiftDesignTokens.border,
    );
  }
}

class _ShiftStatItem extends StatelessWidget {
  const _ShiftStatItem({
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: ShiftDesignTokens.softPurple,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.insights_outlined,
            color: ShiftDesignTokens.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ShiftDesignTokens.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: ShiftDesignTokens.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sublabel,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: ShiftDesignTokens.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
