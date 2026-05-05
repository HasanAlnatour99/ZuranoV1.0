import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import 'attendance_blob_glow.dart';

class AttendanceSummaryStrip extends StatelessWidget {
  const AttendanceSummaryStrip({
    super.key,
    required this.todayHours,
    required this.weeklyHours,
    required this.weeklyDays,
    required this.l10n,
  });

  final double todayHours;
  final double weeklyHours;
  final int weeklyDays;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E0B4B), Color(0xFF4C1D95), Color(0xFF6D28D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -24,
              bottom: -32,
              child: AttendanceBlobGlow(
                color: Colors.white.withValues(alpha: 0.10),
                size: 108,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.schedule_rounded,
                    label: l10n.employeePremiumAttendanceSummaryTodayLabel,
                    value: '${todayHours.toStringAsFixed(1)} h',
                    subtitle: l10n.employeePremiumAttendanceSummaryTodayHint,
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withValues(alpha: 0.24),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.calendar_month_rounded,
                    label: l10n.employeePremiumAttendanceSummaryWeekLabel,
                    value: '${weeklyHours.toStringAsFixed(1)} h',
                    subtitle: l10n.employeePremiumAttendanceSummaryWeekDays(
                      weeklyDays,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
