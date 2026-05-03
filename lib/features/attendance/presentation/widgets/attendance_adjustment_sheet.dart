import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_guard.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../employees/domain/employee_role.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../domain/models/adjustment_attendance_status.dart';
import '../attendance_adjustment_form_state.dart';
import '../attendance_adjustment_providers.dart';

/// Owner/admin attendance correction (persisted via callable `reprocessAttendanceForEmployeeDate`).
class AttendanceAdjustmentSheet extends ConsumerStatefulWidget {
  const AttendanceAdjustmentSheet({
    super.key,
    required this.params,
    this.prefillAttendancePayload,
  });

  final AttendanceAdjustmentParams params;
  final Map<String, dynamic>? prefillAttendancePayload;

  static Future<bool?> open(
    BuildContext context, {
    required AttendanceAdjustmentParams params,
    Map<String, dynamic>? prefillAttendancePayload,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AttendanceAdjustmentSheet(
        params: params,
        prefillAttendancePayload: prefillAttendancePayload,
      ),
    );
  }

  @override
  ConsumerState<AttendanceAdjustmentSheet> createState() =>
      _AttendanceAdjustmentSheetState();
}

class _AttendanceAdjustmentSheetState
    extends ConsumerState<AttendanceAdjustmentSheet> {
  AttendanceAdjustmentFormState? _form;
  TextEditingController? _noteController;

  @override
  void dispose() {
    _noteController?.dispose();
    super.dispose();
  }

  bool _punchesEnabled(AttendanceAdjustmentFormState form) =>
      form.selectedStatus != AdjustmentAttendanceStatus.absent &&
      form.selectedStatus != AdjustmentAttendanceStatus.dayOff;

  Future<void> _pickClock({
    required String help,
    required AttendanceAdjustmentFormState form,
    DateTime? current,
    required bool disabled,
    required ValueChanged<DateTime?> onResult,
  }) async {
    if (disabled) return;
    final time = await showTimePicker(
      context: context,
      helpText: help,
      initialTime: TimeOfDay.fromDateTime(
        current ?? DateTime(form.attendanceDay.year, form.attendanceDay.month, form.attendanceDay.day, 9),
      ),
    );
    if (!mounted || time == null) return;
    onResult(
      DateTime(
        form.attendanceDay.year,
        form.attendanceDay.month,
        form.attendanceDay.day,
        time.hour,
        time.minute,
      ),
    );
  }

  String _roleLabel(AppLocalizations l10n, EmployeeRole r) => switch (r) {
    EmployeeRole.owner => l10n.roleOwner,
    EmployeeRole.admin => l10n.roleAdmin,
    EmployeeRole.barber => l10n.roleBarber,
    EmployeeRole.readonly => l10n.roleBarber,
  };

  Widget _header(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TeamMemberProfileColors.primary,
                TeamMemberProfileColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.attendanceAdjustmentSheetTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: TeamMemberProfileColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.attendanceAdjustmentSheetSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TeamMemberProfileColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _employeeCard(AppLocalizations l10n, AttendanceAdjustmentFormState form) {
    final url = form.load.employee.avatarUrl?.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TeamMemberProfileColors.border),
        color: TeamMemberProfileColors.softPurple.withValues(alpha: 0.42),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              foregroundImage:
                  url != null && url.isNotEmpty ? NetworkImage(url) : null,
              child: url == null || url.isEmpty
                  ? Icon(Icons.person_rounded,
                      color: TeamMemberProfileColors.primary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.params.employeeDisplayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roleLabel(l10n, form.resolvedEmployeeRole()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TeamMemberProfileColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.place_outlined,
                          size: 17,
                          color: TeamMemberProfileColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          form.load.branchName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: TeamMemberProfileColors.textSecondary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shiftSubtitle(
    AppLocalizations l10n,
    EmployeeScheduleModel? shift,
  ) {
    if (shift == null) {
      return '-- • --';
    }
    if (shift.shiftType == 'off') {
      return l10n.attendanceAdjustmentShiftOffDay;
    }
    final name = shift.shiftName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return '${shift.startTime ?? '--'} • ${shift.endTime ?? '--'}';
  }

  Widget _dateShiftRow(AppLocalizations l10n, AttendanceAdjustmentFormState form) {
    final loc = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMEd(loc);
    final shift = form.shift;
    final shiftTitle = _shiftSubtitle(l10n, shift);

    Widget box(IconData i, String label, String subtitle) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TeamMemberProfileColors.border),
              ),
              child: Row(
                children: [
                  Icon(i, size: 20, color: TeamMemberProfileColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(
          Icons.calendar_month_rounded,
          l10n.attendanceAdjustmentDateLabel,
          dateFmt.format(form.attendanceDay.toLocal()),
        ),
        const SizedBox(width: 12),
        box(
          Icons.work_outline_rounded,
          l10n.attendanceAdjustmentShiftLabel,
          shiftTitle,
        ),
      ],
    );
  }

  Widget _statusChips(AppLocalizations l10n, AttendanceAdjustmentFormState form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attendanceAdjustmentStatusLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in AdjustmentAttendanceStatus.values)
              FilterChip(
                selected: form.selectedStatus == s,
                showCheckmark: false,
                label: Text(_statusLabel(l10n, s)),
                onSelected: (_) =>
                    setState(() => _form = _form!.withPunches(status: s)),
                selectedColor: TeamMemberProfileColors.softPurple,
                checkmarkColor: TeamMemberProfileColors.primary,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: form.selectedStatus == s
                      ? TeamMemberProfileColors.primary
                      : TeamMemberProfileColors.textPrimary,
                ),
                side: BorderSide(color: TeamMemberProfileColors.border),
              ),
          ],
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, AdjustmentAttendanceStatus s) =>
      switch (s) {
    AdjustmentAttendanceStatus.present => l10n.attendanceAdjustmentStatusPresent,
    AdjustmentAttendanceStatus.late => l10n.attendanceAdjustmentStatusLateChips,
    AdjustmentAttendanceStatus.absent => l10n.attendanceAdjustmentStatusAbsentChip,
    AdjustmentAttendanceStatus.dayOff => l10n.attendanceAdjustmentStatusDayOff,
  };

  String _messageForFunctionsFailure(
    FirebaseFunctionsException e,
    AppLocalizations l10n,
  ) {
    switch (e.code) {
      case 'unauthenticated':
        return l10n.attendanceAdjustmentSessionExpired;
      case 'permission-denied':
        return l10n.attendanceAdjustmentPermissionDeniedSave;
      case 'unavailable':
      case 'deadline-exceeded':
        return l10n.attendanceAdjustmentServerUnavailableSave;
      default:
        return l10n.attendanceAdjustmentSaveFailedMapped;
    }
  }

  String _messageForFirebaseWriteFailure(
    FirebaseException e,
    AppLocalizations l10n,
  ) {
    switch (e.code) {
      case 'permission-denied':
        return l10n.attendanceAdjustmentPermissionDeniedSave;
      case 'unavailable':
        return l10n.attendanceAdjustmentServerUnavailableSave;
      default:
        return l10n.attendanceAdjustmentSaveFailedMapped;
    }
  }

  /// Schedules [AppRoutes.login] after the sheet closes so [context] stays valid.
  void _scheduleLoginRecoveryRoute() {
    if (!mounted) return;
    final router = GoRouter.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(AppRoutes.login);
    });
  }

  Widget _timeField({
    required AppLocalizations l10n,
    required String label,
    required DateTime? value,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    final tf = DateFormat.jm(Localizations.localeOf(context).toString());
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disabled ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TeamMemberProfileColors.border),
            color: disabled
                ? TeamMemberProfileColors.softPurple.withValues(alpha: 0.15)
                : Colors.white,
          ),
          child: Row(
            children: [
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
                      value == null
                          ? l10n.attendanceAdjustmentNotSet
                          : tf.format(value.toLocal()),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: value == null
                                ? TeamMemberProfileColors.textSecondary
                                : TeamMemberProfileColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.access_time_rounded,
                color: disabled
                    ? TeamMemberProfileColors.textSecondary
                    : TeamMemberProfileColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metrics(AppLocalizations l10n, AttendanceAdjustmentFormState form) {
    final c = form.calculation;
    Widget tile(String title, String body, Color bg, Color fg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: fg,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(
          l10n.attendanceAdjustmentLateMinLabel,
          l10n.attendanceAdjustmentMinutesValue(c.lateMinutes),
          const Color(0xFFF1E8FF),
          const Color(0xFF6B21A8),
        ),
        const SizedBox(width: 8),
        tile(
          l10n.attendanceAdjustmentEarlyExitLabel,
          l10n.attendanceAdjustmentMinutesValue(c.earlyExitMinutes),
          const Color(0xFFFFE8D4),
          const Color(0xFFC2410C),
        ),
        const SizedBox(width: 8),
        tile(
          l10n.attendanceAdjustmentMissingCheckoutLabelShort,
          c.missingCheckout
              ? l10n.attendanceAdjustmentYesWithMinutes(
                  c.missingCheckoutMinutes,
                )
              : l10n.attendanceAdjustmentNoAbbr,
          const Color(0xFFE0F5FF),
          const Color(0xFF0369A1),
        ),
      ],
    );
  }

  Future<void> _save(AttendanceAdjustmentFormState form, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (form.selectedReasonCode == null || form.selectedReasonCode!.trim().isEmpty) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.attendanceAdjustmentErrorReasonRequired)),
      );
      return;
    }

    try {
      await requireFirebaseUser(ref.read(firebaseAuthProvider));
    } on AuthRequiredException catch (e, st) {
      debugPrint('attendance adjustment: requireFirebaseUser $e\n$st');
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.attendanceAdjustmentSessionExpired)),
      );
      _scheduleLoginRecoveryRoute();
      Navigator.of(context).maybePop(false);
      return;
    }

    final repo = ref.read(ownerAttendanceAdjustmentRepositoryProvider);
    try {
      setState(() => _form = form.copyWith(isSaving: true, clearError: true));

      await repo.saveViaCloudFunction(
        salonId: widget.params.salonId,
        employeeId: widget.params.employeeId,
        attendanceDate: widget.params.day,
        shiftId: form.selectedShiftId,
        statusApiValue: form.selectedStatus.apiValue,
        punchInAt: _punchesEnabled(form) ? form.punchInAt : null,
        breakOutAt: _punchesEnabled(form) ? form.breakOutAt : null,
        breakInAt: _punchesEnabled(form) ? form.breakInAt : null,
        punchOutAt: _punchesEnabled(form) ? form.punchOutAt : null,
        reason: form.selectedReasonCode!.trim(),
        managerNote: form.managerNote.trim().isEmpty ? null : form.managerNote.trim(),
      );

      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text(l10n.attendanceAdjustmentSaveSuccess)));
      Navigator.of(context).maybePop(true);
    } on AuthRequiredException catch (e, st) {
      debugPrint('attendance adjustment: auth required $e\n$st');
      if (!mounted) return;
      setState(() => _form = form.copyWith(isSaving: false));
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.attendanceAdjustmentSessionExpired)),
      );
      _scheduleLoginRecoveryRoute();
      Navigator.of(context).maybePop(false);
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint(
        'attendance adjustment: callable code=${e.code} message=${e.message}\n$st',
      );
      if (!mounted) return;
      setState(() => _form = form.copyWith(isSaving: false));
      messenger?.showSnackBar(
        SnackBar(content: Text(_messageForFunctionsFailure(e, l10n))),
      );
      if (e.code == 'unauthenticated') {
        _scheduleLoginRecoveryRoute();
        Navigator.of(context).maybePop(false);
      }
    } on FirebaseException catch (e, st) {
      debugPrint('attendance adjustment: firebase code=${e.code}\n$st');
      if (!mounted) return;
      setState(() => _form = form.copyWith(isSaving: false));
      messenger?.showSnackBar(
        SnackBar(content: Text(_messageForFirebaseWriteFailure(e, l10n))),
      );
    } catch (e, st) {
      debugPrint('attendance adjustment: unexpected $e\n$st');
      if (!mounted) return;
      setState(() => _form = form.copyWith(isSaving: false));
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.attendanceAdjustmentSaveFailedMapped)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final loadAsync = ref.watch(attendanceAdjustmentLoadProvider(widget.params));
    final authUidAsync = ref.watch(firebaseAuthUidProvider);
    final authReady = authUidAsync.maybeWhen(
      data: (uid) => uid != null && uid.isNotEmpty,
      orElse: () => false,
    );
    final authBusy = authUidAsync.isLoading;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.52,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scroll) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: loadAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) {
                debugPrint('attendance adjustment load error: $e\n$st');
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.attendanceAdjustmentLoadContextFailed),
                      TextButton(
                        onPressed: () => Navigator.maybeOf(context)?.pop(false),
                        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                      ),
                    ],
                  ),
                );
              },
              data: (load) {
                final docHint =
                    attendanceDocId(widget.params.employeeId, widget.params.day);
                if (kDebugMode) {
                  debugPrint(
                    'attendance adjustment doc id (debug only): $docHint',
                  );
                }

                _form ??= AttendanceAdjustmentFormState.fromLoad(
                  load: load,
                  attendanceDay: widget.params.day,
                  attendancePayload:
                      widget.prefillAttendancePayload ?? load.attendancePayload,
                  initialDocIdHint: docHint,
                );
                final form = _form!;
                _noteController ??= TextEditingController(text: form.managerNote);

                final canSubmit =
                    authReady && !authBusy && !form.isSaving;
                final punchEnabled = _punchesEnabled(form);
                final breakEnabled = punchEnabled && form.punchInAt != null;

                return ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: TeamMemberProfileColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    _header(l10n),
                    const SizedBox(height: 16),
                    _employeeCard(l10n, form),
                    const SizedBox(height: 16),
                    _dateShiftRow(l10n, form),
                    const SizedBox(height: 16),
                    _statusChips(l10n, form),
                    const SizedBox(height: 16),
                    Text(
                      l10n.attendanceAdjustmentTimesLabel,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 12),
                    _timeField(
                      l10n: l10n,
                      label: l10n.teamMemberAttendanceCheckInLabel,
                      value: form.punchInAt,
                      disabled: !punchEnabled,
                      onTap: () => _pickClock(
                            help: l10n.teamMemberAttendanceCheckInLabel,
                            form: form,
                            current: form.punchInAt,
                            disabled: !punchEnabled,
                            onResult: (p) => setState(
                              () => _form = _form!.withPunches(
                                punchInAt: p,
                                wipePunchIn: p == null,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _timeField(
                      l10n: l10n,
                      label: l10n.attendanceAdjustmentBreakOutLabel,
                      value: form.breakOutAt,
                      disabled: !breakEnabled,
                      onTap: () => _pickClock(
                            help: l10n.attendanceAdjustmentBreakOutLabel,
                            form: form,
                            current: form.breakOutAt,
                            disabled: !breakEnabled,
                            onResult: (p) => setState(() => _form = _form!
                                .withPunches(breakOutAt: p, wipeBreakOut: p == null)),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _timeField(
                      l10n: l10n,
                      label: l10n.attendanceAdjustmentBreakInLabel,
                      value: form.breakInAt,
                      disabled: !breakEnabled,
                      onTap: () => _pickClock(
                            help: l10n.attendanceAdjustmentBreakInLabel,
                            form: form,
                            current: form.breakInAt,
                            disabled: !breakEnabled,
                            onResult: (p) => setState(() => _form = _form!
                                .withPunches(breakInAt: p, wipeBreakIn: p == null)),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _timeField(
                      l10n: l10n,
                      label: l10n.teamMemberAttendanceCheckOutLabel,
                      value: form.punchOutAt,
                      disabled: !punchEnabled,
                      onTap: () => _pickClock(
                            help: l10n.teamMemberAttendanceCheckOutLabel,
                            form: form,
                            current: form.punchOutAt,
                            disabled: !punchEnabled,
                            onResult: (p) => setState(() => _form = _form!
                                .withPunches(punchOutAt: p, wipePunchOut: p == null)),
                          ),
                    ),
                    const SizedBox(height: 14),
                    if (form.calculation.missingCheckout)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFDEC2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: TeamMemberProfileColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.attendanceAdjustmentMissingCheckoutWarning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (form.calculation.missingCheckout)
                      const SizedBox(height: 14),
                    _metrics(l10n, form),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.attendanceAdjustmentReasonLabel} *',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(l10n.attendanceAdjustmentReasonPlaceholder),
                          value: form.selectedReasonCode,
                          items: [
                            DropdownMenuItem(
                              value: 'forgot_punch',
                              child: Text(l10n.attendanceAdjustmentReasonForgot),
                            ),
                            DropdownMenuItem(
                              value: 'gps_failure',
                              child: Text(l10n.attendanceAdjustmentReasonGps),
                            ),
                            DropdownMenuItem(
                              value: 'schedule_correction',
                              child: Text(l10n.attendanceAdjustmentReasonSchedule),
                            ),
                            DropdownMenuItem(
                              value: 'payroll_sync',
                              child: Text(l10n.attendanceAdjustmentReasonPayroll),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text(l10n.attendanceAdjustmentReasonOther),
                            ),
                          ],
                          onChanged: (v) => setState(
                            () => _form = _form!.copyWith(selectedReasonCode: v),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.attendanceAdjustmentManagerNoteLabel,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      onChanged: (t) =>
                          setState(() => _form = _form!.copyWith(managerNote: t)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            size: 17, color: TeamMemberProfileColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.attendanceAdjustmentAuditFootnote,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TeamMemberProfileColors.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: canSubmit ? () => _save(form, l10n) : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: TeamMemberProfileColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        form.isSaving
                            ? l10n.teamMemberAttendanceSave
                            : l10n.attendanceAdjustmentSaveCta,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          form.isSaving ? null : () => Navigator.maybeOf(context)?.pop(false),
                      child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 14),
                      Text(
                        '${l10n.attendanceAdjustmentFirestoreDocLabel}$docHint',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TeamMemberProfileColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
