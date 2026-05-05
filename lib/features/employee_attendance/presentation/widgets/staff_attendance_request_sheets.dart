import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../../application/employee_attendance_providers.dart';
import '../../data/employee_staff_request_models.dart';

/// First step: pick one of the three staff request types.
class EmployeeNewRequestSheet extends StatelessWidget {
  const EmployeeNewRequestSheet({super.key, required this.onSelect});

  final void Function(EmployeeRequestType type) onSelect;

  static const _bg = Color(0xFFFAF8FF);
  static const _handle = Color(0xFFD9C7FF);
  static const _title = Color(0xFF1D1233);
  static const _border = Color(0xFFE7D8FF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + bottom),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: _handle,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.employeeAttendanceTabRequestSheetTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _title,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          _RequestTile(
            icon: Icons.event_busy_rounded,
            title: l10n.employeeAttendanceStaffOptionAdjustAbsentTitle,
            subtitle: l10n.employeeAttendanceStaffOptionAdjustAbsentSubtitle,
            borderColor: _border,
            onTap: () => onSelect(EmployeeRequestType.adjustAbsentDay),
          ),
          const SizedBox(height: 10),
          _RequestTile(
            icon: Icons.access_time_filled_rounded,
            title: l10n.employeeAttendanceTabRequestOptionCorrection,
            subtitle: l10n.employeeAttendanceStaffOptionCorrectionSubtitle,
            borderColor: _border,
            onTap: () => onSelect(EmployeeRequestType.attendanceCorrection),
          ),
          const SizedBox(height: 10),
          _RequestTile(
            icon: Icons.beach_access_rounded,
            title: l10n.employeeAttendanceTabRequestOptionLeave,
            subtitle: l10n.employeeAttendanceStaffOptionLeaveSubtitle,
            borderColor: _border,
            onTap: () => onSelect(EmployeeRequestType.leaveRequest),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.borderColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            color: Colors.white.withValues(alpha: 0.7),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF8B2CFF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1D1233),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF837A98),
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openStaffAttendanceRequestDetail(
  BuildContext context,
  WidgetRef ref,
  EmployeeRequestType type,
) async {
  switch (type) {
    case EmployeeRequestType.adjustAbsentDay:
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const _AdjustAbsentDaySheet(),
      );
      break;
    case EmployeeRequestType.attendanceCorrection:
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const _AttendanceCorrectionSheet(),
      );
      break;
    case EmployeeRequestType.leaveRequest:
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const _LeaveRequestSheet(),
      );
      break;
  }
}

class _AdjustAbsentDaySheet extends ConsumerStatefulWidget {
  const _AdjustAbsentDaySheet();

  @override
  ConsumerState<_AdjustAbsentDaySheet> createState() =>
      _AdjustAbsentDaySheetState();
}

class _AdjustAbsentDaySheetState extends ConsumerState<_AdjustAbsentDaySheet> {
  final _reason = TextEditingController();
  final Set<String> _selectedIso = {};
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _messengerKey.currentState?.hideCurrentSnackBar();
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  String _iso(EtAttendanceDay d) {
    final x = d.date.toLocal();
    final y = x.year.toString().padLeft(4, '0');
    final m = x.month.toString().padLeft(2, '0');
    final day = x.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_selectedIso.isEmpty) {
      _showError(l10n.employeeAttendanceStaffSelectDaysHint);
      return;
    }
    final r = _reason.text.trim();
    if (r.length < 5) {
      _showError(l10n.employeeAttendanceTabRequestReasonTooShort);
      return;
    }
    setState(() => _submitting = true);
    try {
      final keys = _selectedIso.toList()..sort();
      await ref.read(employeeAttendanceViewRepositoryProvider).submitAdjustAbsentDayRequest(
            targetDateKeys: keys,
            reason: r,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.employeeAttendanceTabRequestSuccess)),
        );
      }
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      _showError(mapStaffRequestError(l10n, e));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final absentAsync = ref.watch(absentDaysForAdjustmentProvider);

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF8FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9C7FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      l10n.employeeAttendanceStaffAdjustAbsentTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D1233),
                          ),
                    ),
                  ),
                  Expanded(
                    child: absentAsync.when(
                      data: (days) {
                        if (days.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.employeeAttendanceStaffAdjustAbsentEmpty,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: days.length,
                          itemBuilder: (context, i) {
                            final d = days[i];
                            final iso = _iso(d);
                            final checked = _selectedIso.contains(iso);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: _submitting
                                  ? null
                                  : (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selectedIso.add(iso);
                                        } else {
                                          _selectedIso.remove(iso);
                                        }
                                      });
                                    },
                              title: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatFullDate(d.date.toLocal()),
                              ),
                              subtitle: Text(
                                l10n.employeeAttendanceStaffAbsentBadge,
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: TextField(
                      controller: _reason,
                      minLines: 2,
                      maxLines: 4,
                      enabled: !_submitting,
                      decoration: InputDecoration(
                        labelText: l10n.employeeAttendanceStaffReasonLabel,
                        hintText: l10n.employeeAttendanceTabRequestReasonHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FilledButton(
                      onPressed: _submitting ? null : () => _submit(l10n),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.employeeAttendanceTabRequestSubmit),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceCorrectionSheet extends ConsumerStatefulWidget {
  const _AttendanceCorrectionSheet();

  @override
  ConsumerState<_AttendanceCorrectionSheet> createState() =>
      _AttendanceCorrectionSheetState();
}

class _AttendanceCorrectionSheetState
    extends ConsumerState<_AttendanceCorrectionSheet> {
  AttendanceCorrectionKind _kind = AttendanceCorrectionKind.missingPunchIn;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final _reason = TextEditingController();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _messengerKey.currentState?.hideCurrentSnackBar();
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (d != null) {
      setState(() => _date = d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) {
      setState(() => _time = t);
    }
  }

  DateTime _combinedLocal() {
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final r = _reason.text.trim();
    if (r.length < 5) {
      _showError(l10n.employeeAttendanceTabRequestReasonTooShort);
      return;
    }
    final dt = _combinedLocal();
    setState(() => _submitting = true);
    try {
      await ref.read(employeeAttendanceViewRepositoryProvider).submitAttendanceCorrectionRequest(
            correctionKind: _kind,
            requestedDateTime: dt,
            reason: r,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.employeeAttendanceTabRequestSuccess)),
        );
      }
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      _showError(mapStaffRequestError(l10n, e));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final loc = MaterialLocalizations.of(context);

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9C7FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.employeeAttendanceTabRequestOptionCorrection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.employeeAttendanceStaffCorrectionKindLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<AttendanceCorrectionKind>(
                    segments: [
                      ButtonSegment(
                        value: AttendanceCorrectionKind.missingPunchIn,
                        label: Text(
                          l10n.employeeAttendanceStaffCorrectionMissingIn,
                        ),
                      ),
                      ButtonSegment(
                        value: AttendanceCorrectionKind.missingPunchOut,
                        label: Text(
                          l10n.employeeAttendanceStaffCorrectionMissingOut,
                        ),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: _submitting
                        ? null
                        : (s) {
                            if (s.isEmpty) {
                              return;
                            }
                            setState(() => _kind = s.first);
                          },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.employeeAttendanceStaffCorrectionDateLabel),
                    subtitle: Text(loc.formatFullDate(_date)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: _submitting ? null : _pickDate,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.employeeAttendanceStaffCorrectionTimeLabel),
                    subtitle: Text(_time.format(context)),
                    trailing: const Icon(Icons.schedule_rounded),
                    onTap: _submitting ? null : _pickTime,
                  ),
                  TextField(
                    controller: _reason,
                    minLines: 3,
                    maxLines: 5,
                    enabled: !_submitting,
                    decoration: InputDecoration(
                      labelText: l10n.employeeAttendanceStaffReasonLabel,
                      hintText: l10n.employeeAttendanceTabRequestReasonHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submitting ? null : () => _submit(l10n),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.employeeAttendanceTabRequestSubmit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaveRequestSheet extends ConsumerStatefulWidget {
  const _LeaveRequestSheet();

  @override
  ConsumerState<_LeaveRequestSheet> createState() => _LeaveRequestSheetState();
}

class _LeaveRequestSheetState extends ConsumerState<_LeaveRequestSheet> {
  EmployeeLeaveBalance? _balance;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);
  final _reason = TextEditingController();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _messengerKey.currentState?.hideCurrentSnackBar();
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  DateTime _combine(DateTime day, TimeOfDay t) {
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final r = _reason.text.trim();
    if (r.length < 5) {
      _showError(l10n.employeeAttendanceTabRequestReasonTooShort);
      return;
    }
    final balances = ref.read(employeeLeaveBalancesProvider).maybeWhen(
          data: (v) => v,
          orElse: () => const <EmployeeLeaveBalance>[],
        );
    if (balances.isEmpty) {
      _showError(l10n.employeeAttendanceStaffLeaveNoBalances);
      return;
    }
    final b = _balance ?? balances.first;
    final startAt = _combine(_startDate, _startTime);
    final endAt = _combine(_endDate, _endTime);
    final hours = calculateRequestedLeaveHours(start: startAt, end: endAt);
    if (hours <= 0) {
      _showError(l10n.employeeAttendanceStaffErrorLeaveHoursInvalid);
      return;
    }
    if (hours > b.remainingHours) {
      _showError(l10n.employeeAttendanceStaffErrorLeaveExceeds);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(employeeAttendanceViewRepositoryProvider).submitLeaveRequest(
            leaveTypeId: b.leaveTypeId,
            leaveTypeName: b.leaveTypeName,
            startAt: startAt,
            endAt: endAt,
            requestedHours: hours,
            remainingHoursAtRequest: b.remainingHours,
            reason: r,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.employeeAttendanceTabRequestSuccess)),
        );
      }
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      _showError(mapStaffRequestError(l10n, e));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balancesAsync = ref.watch(employeeLeaveBalancesProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final hourFmt = NumberFormat('#0.##', localeTag);

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: balancesAsync.when(
                data: (balances) {
                  if (balances.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.employeeAttendanceStaffLeaveNoBalances,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final balance = _balance ?? balances.first;

                  final startAt = _combine(_startDate, _startTime);
                  final endAt = _combine(_endDate, _endTime);
                  final requested = calculateRequestedLeaveHours(
                    start: startAt,
                    end: endAt,
                  );
                  final exceeds = requested > balance.remainingHours;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9C7FF),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.employeeAttendanceTabRequestOptionLeave,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 12),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.employeeAttendanceStaffLeaveTypeLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<EmployeeLeaveBalance>(
                            isExpanded: true,
                            value: balance,
                            items: balances
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.leaveTypeName),
                                  ),
                                )
                                .toList(),
                            onChanged: _submitting
                                ? null
                                : (v) => setState(() => _balance = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.employeeAttendanceStaffLeaveBalanceLabel}: '
                        '${l10n.employeeAttendanceStaffLeaveHoursUnit(hourFmt.format(balance.remainingHours))}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.employeeAttendanceStaffLeaveStartLabel),
                        subtitle: Text(
                          '${MaterialLocalizations.of(context).formatFullDate(_startDate)}  '
                          '${_startTime.format(context)}',
                        ),
                        onTap: _submitting
                            ? null
                            : () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(_startDate.year - 1),
                                  lastDate: DateTime(_startDate.year + 2),
                                );
                                if (d != null) {
                                  setState(() => _startDate = d);
                                }
                              },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.employeeAttendanceStaffLeaveEndLabel),
                        subtitle: Text(
                          '${MaterialLocalizations.of(context).formatFullDate(_endDate)}  '
                          '${_endTime.format(context)}',
                        ),
                        onTap: _submitting
                            ? null
                            : () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(_endDate.year - 1),
                                  lastDate: DateTime(_endDate.year + 2),
                                );
                                if (d != null) {
                                  setState(() => _endDate = d);
                                }
                              },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: _startTime,
                                      );
                                      if (t != null) {
                                        setState(() => _startTime = t);
                                      }
                                    },
                              child: Text(
                                l10n.employeeAttendanceStaffLeaveStartLabel,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _submitting
                                  ? null
                                  : () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: _endTime,
                                      );
                                      if (t != null) {
                                        setState(() => _endTime = t);
                                      }
                                    },
                              child:
                                  Text(l10n.employeeAttendanceStaffLeaveEndLabel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${l10n.employeeAttendanceStaffLeaveRequestedLabel}: '
                        '${l10n.employeeAttendanceStaffLeaveHoursUnit(hourFmt.format(requested))}',
                      ),
                      if (exceeds)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.employeeAttendanceStaffLeaveExceedsHint,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reason,
                        minLines: 3,
                        maxLines: 5,
                        enabled: !_submitting,
                        decoration: InputDecoration(
                          labelText: l10n.employeeAttendanceStaffReasonLabel,
                          hintText: l10n.employeeAttendanceTabRequestReasonHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: (_submitting || exceeds || requested <= 0)
                            ? null
                            : () => _submit(l10n),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.employeeAttendanceTabRequestSubmit),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('$e'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String mapStaffRequestError(AppLocalizations l10n, Object e) {
  final s = e.toString();
  if (s.contains('DUPLICATE_ADJUST_ABSENT')) {
    return l10n.employeeAttendanceStaffErrorDuplicateAdjustAbsent;
  }
  if (s.contains('DUPLICATE_CORRECTION') || s.contains('DUPLICATE_PENDING')) {
    return l10n.employeeAttendanceStaffErrorDuplicateCorrection;
  }
  if (s.contains('LEAVE_OVERLAP')) {
    return l10n.employeeAttendanceStaffErrorLeaveOverlap;
  }
  if (s.contains('LEAVE_EXCEEDS_BALANCE')) {
    return l10n.employeeAttendanceStaffErrorLeaveExceeds;
  }
  if (s.contains('FUTURE_CORRECTION')) {
    return l10n.employeeAttendanceStaffErrorFutureCorrection;
  }
  if (s.contains('LEAVE_HOURS_INVALID')) {
    return l10n.employeeAttendanceStaffErrorLeaveHoursInvalid;
  }
  if (s.contains('DUPLICATE')) {
    return l10n.employeeAttendanceTabRequestDuplicate;
  }
  return l10n.employeeRequestFailed;
}
