import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../data/models/attendance_ui_status.dart';

class AttendanceStatusHeader extends StatelessWidget {
  const AttendanceStatusHeader({
    super.key,
    required this.uiStatus,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.lastActionAt,
    required this.locale,
    required this.l10n,
  });

  final AttendanceUiStatus uiStatus;
  final String statusTitle;
  final String statusSubtitle;
  final DateTime? lastActionAt;
  final Locale locale;
  final AppLocalizations l10n;

  Color _statusColor() {
    switch (uiStatus) {
      case AttendanceUiStatus.notStarted:
        return const Color(0xFF64748B);
      case AttendanceUiStatus.working:
        return const Color(0xFF16A34A);
      case AttendanceUiStatus.onBreak:
        return const Color(0xFFF97316);
      case AttendanceUiStatus.checkedOut:
        return const Color(0xFF16A34A);
      case AttendanceUiStatus.needsAttention:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon() {
    switch (uiStatus) {
      case AttendanceUiStatus.checkedOut:
        return Icons.check_rounded;
      case AttendanceUiStatus.onBreak:
        return Icons.free_breakfast_rounded;
      case AttendanceUiStatus.working:
        return Icons.work_rounded;
      case AttendanceUiStatus.needsAttention:
        return Icons.warning_amber_rounded;
      case AttendanceUiStatus.notStarted:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final last = lastActionAt;
    final timeText = last != null
        ? DateFormat.jm(locale.toString()).format(last)
        : '—';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusCircle(color: color, icon: _statusIcon()),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                statusSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _LastActionBox(
          timeText: timeText,
          caption: l10n.employeePremiumAttendanceLastAction,
        ),
      ],
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.85), color],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _LastActionBox extends StatelessWidget {
  const _LastActionBox({required this.timeText, required this.caption});

  final String timeText;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9D5FF)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.schedule_rounded,
              color: Color(0xFF6D28D9),
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              caption,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
