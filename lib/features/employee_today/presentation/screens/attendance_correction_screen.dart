import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../data/attendance_exception.dart';
import '../../data/models/et_attendance_settings.dart';
import '../../data/repositories/employee_today_attendance_repository.dart';
import '../../providers/employee_today_providers.dart';
import '../employee_today_theme.dart';
import '../widgets/employee_today_widgets.dart';

class AttendanceCorrectionScreen extends ConsumerStatefulWidget {
  const AttendanceCorrectionScreen({super.key});

  @override
  ConsumerState<AttendanceCorrectionScreen> createState() =>
      _AttendanceCorrectionScreenState();
}

class _AttendanceCorrectionScreenState
    extends ConsumerState<AttendanceCorrectionScreen> {
  AttendancePunchType? _type;
  DateTime? _date;
  TimeOfDay? _time;
  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (d != null) {
      setState(() => _date = d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (t != null) {
      setState(() => _time = t);
    }
  }

  String? _validate(EtAttendanceSettings settings, AppLocalizations l10n) {
    if (_type == null) {
      return l10n.employeeCorrectionSelectPunchType;
    }
    if (_date == null) {
      return l10n.employeeCorrectionSelectValidDate;
    }
    if (_time == null) {
      return l10n.employeeCorrectionSelectValidTime;
    }
    final now = DateTime.now();
    final at = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    if (at.isAfter(now)) {
      return l10n.employeeCorrectionFutureNotAllowed;
    }
    final minDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: settings.correctionRequestMaxDaysBack));
    if (at.isBefore(minDay)) {
      return l10n.employeeCorrectionTooOld;
    }
    final reason = _reason.text.trim();
    if (settings.requireReasonForCorrection && reason.isEmpty) {
      return l10n.employeeCorrectionReasonRequired;
    }
    if (reason.isNotEmpty && reason.length < 10) {
      return l10n.employeeCorrectionReasonMinLength;
    }
    if (reason.length > 250) {
      return l10n.employeeCorrectionReasonMaxLength;
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = await ref.read(etAttendanceSettingsProvider.future);
    final err = _validate(settings, l10n);
    if (err != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
      return;
    }

    final scope = ref.read(employeeWorkspaceScopeProvider);
    final emp = await ref.read(workspaceEmployeeProvider.future);
    if (scope == null || emp == null) {
      return;
    }

    final at = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final dk = EmployeeTodayAttendanceRepository.compactDateKey(at);
    final dayId = EmployeeTodayAttendanceRepository.attendanceDayId(
      scope.employeeId,
      dk,
    );

    final repo = ref.read(employeeTodayAttendanceRepositoryProvider);
    final pastDay = await repo.getAttendanceDay(
      salonId: scope.salonId,
      dayId: dayId,
    );
    final seq = pastDay?.punchSequence ?? const <String>[];

    setState(() => _submitting = true);
    try {
      await ref
          .read(employeeTodayAttendanceRepositoryProvider)
          .createCorrectionRequest(
            uid: scope.uid,
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            employeeName: formatTeamMemberName(emp.name),
            attendanceDayId: dayId,
            dateKey: dk,
            requestedType: _type!,
            requestedPunchTime: at,
            reason: _reason.text.trim(),
            settings: settings,
            existingSequence: seq,
          );
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.employeeCorrectionSubmittedSnackbar)),
        );
        context.pop();
      }
    } on AttendanceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _label(AppLocalizations l10n, AttendancePunchType t) {
    switch (t) {
      case AttendancePunchType.punchIn:
        return l10n.employeeTodayPunchIn;
      case AttendancePunchType.punchOut:
        return l10n.employeeTodayPunchOut;
      case AttendancePunchType.breakOut:
        return l10n.employeeTodayBreakOut;
      case AttendancePunchType.breakIn:
        return l10n.employeeTodayBreakIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recentAsync = ref.watch(etEmployeeCorrectionRequestsProvider);

    return Scaffold(
      backgroundColor: EmployeeTodayColors.backgroundSoft,
      appBar: AppBar(
        title: Text(l10n.employeeAttendanceCorrectionFlowTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.employeeAttendanceCorrectionSubtitle,
            style: const TextStyle(color: EmployeeTodayColors.mutedText),
          ),
          const SizedBox(height: 16),
          EtPremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.employeeCorrectionDetailsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.employeeCorrectionRequestedPunchLabel),
                const SizedBox(height: 8),
                SegmentedButton<AttendancePunchType>(
                  segments: AttendancePunchType.values
                      .map(
                        (t) => ButtonSegment(
                          value: t,
                          label: Text(_label(l10n, t)),
                        ),
                      )
                      .toList(),
                  selected: _type != null ? {_type!} : const {},
                  emptySelectionAllowed: true,
                  onSelectionChanged: (s) {
                    setState(() {
                      _type = s.isEmpty ? null : s.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(l10n.customerSelectDate),
                  subtitle: Text(
                    _date == null
                        ? l10n.employeeCorrectionSelectPlaceholder
                        : _date!.toIso8601String().split('T').first,
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                ListTile(
                  title: Text(l10n.customerSelectTime),
                  subtitle: Text(
                    _time == null
                        ? l10n.employeeCorrectionSelectPlaceholder
                        : _time!.format(context),
                  ),
                  trailing: const Icon(Icons.schedule),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reason,
                  maxLines: 4,
                  maxLength: 250,
                  decoration: InputDecoration(
                    labelText: l10n.employeeAttendanceReasonLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          EtPremiumCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: EmployeeTodayColors.primaryPurple,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.employeeCorrectionAdminReviewNote,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          EtPrimaryGradientButton(
            label: l10n.employeeCorrectionSubmitCta,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.employeeCorrectionRecentTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          recentAsync.when(
            data: (list) => Column(
              children: list
                  .map(
                    (r) => ListTile(
                      title: Text(r.requestedPunchType),
                      subtitle: Text('${r.status} · ${r.dateKey}'),
                    ),
                  )
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}
