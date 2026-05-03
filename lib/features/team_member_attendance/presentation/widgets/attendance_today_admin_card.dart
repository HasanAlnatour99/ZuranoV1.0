import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/attendance_adjustment_form_state.dart';
import '../../../attendance/presentation/widgets/attendance_adjustment_sheet.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../application/team_member_attendance_providers.dart';
import '../../data/models/attendance_record_model.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';

class AttendanceTodayAdminCard extends ConsumerWidget {
  const AttendanceTodayAdminCard({
    super.key,
    required this.employeeName,
    required this.record,
    required this.assignedSchedule,
    required this.canManageAttendance,
    required this.salonId,
    required this.employeeId,
    required this.args,
  });

  final String employeeName;
  final AttendanceRecordModel? record;
  final EmployeeScheduleModel? assignedSchedule;
  final bool canManageAttendance;
  final String salonId;
  final String employeeId;
  final TeamMemberAttendanceArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.jm(localeTag);

    final hasRecord = record != null;
    final isOpen = record?.checkInAt != null && record?.checkOutAt == null;

    final title = !hasRecord
        ? l10n.teamMemberAttendanceAdminNoRecordTitle
        : isOpen
        ? l10n.teamMemberAttendanceAdminCheckedInTitle
        : l10n.teamMemberAttendanceAdminCompletedTitle;

    final subtitle = !hasRecord
        ? l10n.teamMemberAttendanceAdminNoRecordSubtitle(employeeName)
        : isOpen
        ? l10n.teamMemberAttendanceAdminCheckedInSubtitle
        : l10n.teamMemberAttendanceAdminCompletedSubtitle;

    final statusColor = !hasRecord
        ? TeamMemberProfileColors.textSecondary
        : isOpen
        ? const Color(0xFF16A34A)
        : TeamMemberProfileColors.primary;
    final hasSchedule =
        assignedSchedule != null &&
        (assignedSchedule!.shiftName.isNotEmpty ||
            (assignedSchedule!.startTime?.isNotEmpty ?? false) ||
            (assignedSchedule!.endTime?.isNotEmpty ?? false));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TeamMemberProfileColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: TeamMemberProfileColors.softPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  hasRecord
                      ? Icons.fact_check_rounded
                      : Icons.event_busy_rounded,
                  color: TeamMemberProfileColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: TeamMemberProfileColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: TeamMemberProfileColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasRecord
                      ? _statusLabel(context, record!.status)
                      : l10n.teamMemberAttendanceStatusNone,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: l10n.teamMemberAttendanceCheckInLabel,
                  value: record?.checkInAt == null
                      ? '--:--'
                      : timeFormat.format(record!.checkInAt!.toLocal()),
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeBox(
                  label: l10n.teamMemberAttendanceCheckOutLabel,
                  value: record?.checkOutAt == null
                      ? '--:--'
                      : timeFormat.format(record!.checkOutAt!.toLocal()),
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
          if (hasSchedule) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: TeamMemberProfileColors.softPurple.withValues(
                  alpha: 0.34,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TeamMemberProfileColors.border),
              ),
              child: _ScheduleDetails(
                schedule: assignedSchedule!,
                localeTag: localeTag,
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.pushNamed(AppRouteNames.ownerWeeklyShifts),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: TeamMemberProfileColors.softPurple.withValues(
                      alpha: 0.28,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TeamMemberProfileColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: TeamMemberProfileColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.teamMemberAttendanceNoShiftAssigned,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: TeamMemberProfileColors.textPrimary,
                              ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: TeamMemberProfileColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (canManageAttendance) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: TeamMemberProfileColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  final today = DateTime.now();
                  final day = DateTime(today.year, today.month, today.day);
                  final ok = await AttendanceAdjustmentSheet.open(
                    context,
                    params: AttendanceAdjustmentParams(
                      salonId: salonId,
                      employeeId: employeeId,
                      attendanceDate: day,
                      employeeDisplayName: employeeName,
                    ),
                    prefillAttendancePayload: record?.toAttendanceAdjustmentPrefillPayload(),
                  );
                  if (ok != true || !context.mounted) return;
                  ref.invalidate(todayAttendanceProvider(args));
                  ref.invalidate(recentAttendanceProvider(args));
                  ref.invalidate(attendanceSummaryProvider(args));
                },
                icon: Icon(hasRecord ? Icons.edit_rounded : Icons.add_rounded),
                label: Text(
                  hasRecord
                      ? l10n.teamMemberAttendanceEditManual
                      : l10n.teamMemberAttendanceAddManual,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      'present' => l10n.teamMemberAttendanceRecordStatusPresent,
      'late' => l10n.teamMemberAttendanceRecordStatusLate,
      'incomplete' => l10n.teamMemberAttendanceRecordStatusIncomplete,
      'manual' => l10n.teamMemberAttendanceRecordStatusManual,
      'absent' => l10n.teamMemberAttendanceRecordStatusAbsent,
      'onBreak' => l10n.teamMemberAttendanceRecordStatusOnBreak,
      'dayOff' => status,
      _ => status,
    };
  }
}

class _ScheduleDetails extends StatelessWidget {
  const _ScheduleDetails({required this.schedule, required this.localeTag});

  final EmployeeScheduleModel schedule;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shiftLabel = l10n.employeeTodayShiftLabel;
    final shiftName = schedule.shiftName.trim().isNotEmpty
        ? schedule.shiftName.trim()
        : '--';
    final shiftTimeText = _scheduleTimeText(schedule, localeTag);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 18,
              color: TeamMemberProfileColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              shiftLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: TeamMemberProfileColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          shiftName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: TeamMemberProfileColors.textPrimary,
          ),
        ),
        if (shiftTimeText != null) ...[
          const SizedBox(height: 2),
          Text(
            shiftTimeText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: TeamMemberProfileColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  String? _scheduleTimeText(EmployeeScheduleModel schedule, String localeTag) {
    if (schedule.shiftType == 'off') {
      return null;
    }
    final start = _parseTimeOnToday(schedule.startTime);
    final end = _parseTimeOnToday(schedule.endTime);
    if (start == null || end == null) {
      return null;
    }
    final fmt = DateFormat.jm(localeTag);
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  DateTime? _parseTimeOnToday(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) {
      return null;
    }
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      return null;
    }
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) {
      return null;
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.softPurple.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TeamMemberProfileColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: TeamMemberProfileColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TeamMemberProfileColors.textPrimary,
                    fontWeight: FontWeight.w900,
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
