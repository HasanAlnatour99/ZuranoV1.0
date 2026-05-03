import 'package:flutter/material.dart';

import '../../data/models/weekly_schedule_assignment_model.dart';
import 'shift_ui/shift_design_tokens.dart';

/// Compact chip inside a roster cell (day / night / off).
class ShiftAssignmentChip extends StatelessWidget {
  const ShiftAssignmentChip({super.key, required this.assignment});

  final WeeklyScheduleAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    if (assignment.shiftType == 'off') {
      return _OffChip(assignment: assignment);
    }
    return _WorkingChip(assignment: assignment);
  }
}

class _WorkingChip extends StatelessWidget {
  const _WorkingChip({required this.assignment});

  final WeeklyScheduleAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final baseColor = _hexToColor(assignment.colorHex);
    final isLight = baseColor.computeLuminance() > 0.45;
    final primaryText = isLight
        ? ShiftDesignTokens.textDark
        : Colors.white.withValues(alpha: 0.96);
    final secondaryText = isLight
        ? ShiftDesignTokens.textMuted
        : Colors.white.withValues(alpha: 0.9);

    return Container(
      width: 72,
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            assignment.isOvernight
                ? Icons.nights_stay_outlined
                : Icons.wb_sunny_outlined,
            size: 16,
            color: primaryText,
          ),
          const SizedBox(height: 6),
          Text(
            assignment.shiftName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: primaryText,
              height: 1.15,
            ),
          ),
          const Spacer(),
          if (assignment.startTime != null && assignment.endTime != null)
            Text(
              '${assignment.startTime}\n${assignment.endTime}',
              maxLines: 2,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondaryText,
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }
}

class _OffChip extends StatelessWidget {
  const _OffChip({required this.assignment});

  final WeeklyScheduleAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: ShiftDesignTokens.offGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiftDesignTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 6),
          Text(
            assignment.shiftName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

Color _hexToColor(String raw) {
  final clean = raw.replaceAll('#', '').trim();
  if (clean.length == 6) {
    return Color(int.parse('FF$clean', radix: 16));
  }
  return ShiftDesignTokens.primary;
}
