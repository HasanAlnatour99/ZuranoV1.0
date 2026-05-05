import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/employee_attendance_models.dart';
import '../employee_attendance_l10n_helpers.dart';

class TodayAttendanceSummaryCard extends StatelessWidget {
  const TodayAttendanceSummaryCard({
    super.key,
    required this.today,
    this.isLoading = false,
    this.displayWorkedMinutes,
  });

  final EmployeeAttendanceDay? today;
  final bool isLoading;
  final int? displayWorkedMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final dateLine = DateFormat.yMMMMd(locale).format(now);

    if (isLoading) {
      return const TodayAttendanceSummarySkeleton();
    }

    final day = today;
    final checkIn = day?.checkedInAt;
    final checkInLabel = checkIn == null
        ? '—'
        : DateFormat('hh:mm a', locale).format(checkIn.toLocal());

    final worked = displayWorkedMinutes ?? day?.totalWorkedMinutes ?? 0;
    final workedLabel = formatAttendanceWorkedL10n(l10n, worked);
    final status = day == null ? AttendanceStatus.notStarted : day.status;
    final chipStyle = _statusChip(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8FF)),
        boxShadow: [
          BoxShadow(
            color: ZuranoTokens.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.employeeAttendanceTabTodaySummaryTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1D1233),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF837A98),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  icon: Icons.verified_outlined,
                  label: l10n.employeeAttendanceTabStatusLabel,
                  value: attendanceStatusLabel(l10n, status),
                  chipBackground: chipStyle.background,
                  chipForeground: chipStyle.foreground,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  icon: Icons.access_time_rounded,
                  label: l10n.employeeAttendanceTabCheckInLabel,
                  value: checkInLabel,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  icon: Icons.timelapse_rounded,
                  label: l10n.employeeAttendanceTabWorkedLabel,
                  value: workedLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ChipTone _statusChip(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.checkedIn:
      case AttendanceStatus.present:
        return _ChipTone(
          background: const Color(0xFFDCFCE7),
          foreground: const Color(0xFF166534),
        );
      case AttendanceStatus.onBreak:
        return _ChipTone(
          background: const Color(0xFFFFEDD5),
          foreground: const Color(0xFF9A3412),
        );
      case AttendanceStatus.absent:
        return _ChipTone(
          background: const Color(0xFFFEE2E2),
          foreground: const Color(0xFF991B1B),
        );
      case AttendanceStatus.notStarted:
        return _ChipTone(
          background: const Color(0xFFF4F4F5),
          foreground: const Color(0xFF52525B),
        );
      case AttendanceStatus.checkedOut:
        return _ChipTone(
          background: const Color(0xFFF3E8FF),
          foreground: const Color(0xFF6B21A8),
        );
      case AttendanceStatus.unknown:
        return _ChipTone(
          background: const Color(0xFFF4F4F5),
          foreground: const Color(0xFF52525B),
        );
    }
  }
}

class _ChipTone {
  const _ChipTone({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.chipBackground,
    this.chipForeground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? chipBackground;
  final Color? chipForeground;

  @override
  Widget build(BuildContext context) {
    final isChip = chipBackground != null && chipForeground != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: ZuranoTokens.primary),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF837A98),
              ),
        ),
        const SizedBox(height: 4),
        isChip
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: chipForeground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              )
            : Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF1D1233),
                      fontWeight: FontWeight.w700,
                    ),
              ),
      ],
    );
  }
}

class TodayAttendanceSummarySkeleton extends StatelessWidget {
  const TodayAttendanceSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8FF)),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
