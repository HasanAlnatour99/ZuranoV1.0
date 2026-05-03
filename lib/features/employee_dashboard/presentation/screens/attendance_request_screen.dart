import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../application/employee_dashboard_providers.dart';
import '../../data/repositories/attendance_request_repository.dart';
import '../../data/repositories/employee_attendance_repository.dart';
import '../../domain/enums/attendance_punch_type.dart';

class AttendanceRequestScreen extends ConsumerStatefulWidget {
  const AttendanceRequestScreen({super.key});

  @override
  ConsumerState<AttendanceRequestScreen> createState() =>
      _AttendanceRequestScreenState();
}

class _AttendanceRequestScreenState
    extends ConsumerState<AttendanceRequestScreen> {
  final _reason = TextEditingController();
  AttendancePunchType _type = AttendancePunchType.punchOut;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final scope = ref.read(employeeWorkspaceScopeProvider);
    if (scope == null) {
      return;
    }
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employeeAttendanceRequestAddReason)),
      );
      return;
    }
    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    if (dt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employeeAttendanceRequestFutureTime)),
      );
      return;
    }
    final dateKey = AttendanceRequestRepository.compactDateKey(_date);
    final attendanceId = EmployeeAttendanceRepository.attendanceDocumentId(
      scope.employeeId,
      dateKey,
    );

    setState(() => _submitting = true);
    try {
      final dup = await ref
          .read(attendanceRequestRepositoryProvider)
          .hasPendingDuplicate(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            dateKey: dateKey,
            requestedPunchType: _type,
          );
      if (dup) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.employeeAttendanceRequestDuplicatePending),
          ),
        );
        return;
      }
      await ref
          .read(attendanceRequestRepositoryProvider)
          .submitRequest(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            employeeUid: scope.uid,
            employeeName: formatTeamMemberName(scope.displayName),
            attendanceId: attendanceId,
            dateKey: dateKey,
            requestedPunchType: _type,
            requestedDateTime: dt,
            reason: reason,
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(employeePendingAttendanceRequestsCountProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employeeAttendanceRequestSubmitted)),
      );
      context.pop();
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.employeeRequestFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.employeeAttendanceRequestScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<AttendancePunchType>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: l10n.employeeAttendanceRequestPunchLabel,
            ),
            items: [
              DropdownMenuItem(
                value: AttendancePunchType.punchIn,
                child: Text(l10n.employeeTodayPunchIn),
              ),
              DropdownMenuItem(
                value: AttendancePunchType.punchOut,
                child: Text(l10n.employeeTodayPunchOut),
              ),
              DropdownMenuItem(
                value: AttendancePunchType.breakOut,
                child: Text(l10n.employeeTodayBreakOut),
              ),
              DropdownMenuItem(
                value: AttendancePunchType.breakIn,
                child: Text(l10n.employeeTodayBreakIn),
              ),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(l10n.customerSelectDate),
            subtitle: Text(_date.toLocal().toString().split(' ').first),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _date = picked);
              }
            },
          ),
          ListTile(
            title: Text(l10n.customerSelectTime),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) {
                setState(() => _time = picked);
              }
            },
          ),
          TextField(
            controller: _reason,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.employeeAttendanceReasonLabel,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: ZuranoPremiumUiColors.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.employeeAttendanceRequestSubmitCta),
          ),
        ],
      ),
    );
  }
}
