import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/employee_attendance_models.dart';
import '../employee_attendance_l10n_helpers.dart';

Future<void> showAttendanceDetailsBottomSheet(
  BuildContext context,
  EmployeeAttendanceDay day,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AttendanceDetailsSheet(day: day),
  );
}

class _AttendanceDetailsSheet extends StatelessWidget {
  const _AttendanceDetailsSheet({required this.day});

  final EmployeeAttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final df = DateFormat.yMMMMEEEEd(locale);
    final tf = DateFormat('hh:mm a', locale);

    String ts(DateTime? d) =>
        d == null ? '—' : tf.format(d.toLocal());

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFCFAFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7D8FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                l10n.employeeAttendanceTabDetailsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D1233),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                df.format(day.date.toLocal()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF837A98),
                    ),
              ),
              const SizedBox(height: 20),
              _DetailRow(
                label: l10n.employeeAttendanceTabStatusLabel,
                value: attendanceStatusLabel(l10n, day.status),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabShiftStateLabel,
                value: shiftStateLabel(l10n, day.shiftState),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabCheckInLabel,
                value: ts(day.checkedInAt),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabCheckOutLabel,
                value: ts(day.checkedOutAt),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabWorkedLabel,
                value: formatAttendanceWorkedL10n(l10n, day.totalWorkedMinutes),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabBreakMinutesLabel,
                value: formatAttendanceWorkedL10n(l10n, day.totalBreakMinutes),
              ),
              _DetailRow(
                label: l10n.employeeAttendanceTabExceededBreakLabel,
                value: l10n.employeeAttendanceTabDurationMinutes(
                  day.exceededBreakMinutes,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF837A98),
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1233),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
