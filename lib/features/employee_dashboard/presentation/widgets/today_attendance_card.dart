import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/zurano_error_state.dart';
import '../../../employee/attendance/data/services/employee_attendance_card_mapper.dart';
import '../../../employee/attendance/presentation/widgets/premium_attendance_card.dart';
import '../../../employee/attendance/providers/employee_attendance_card_provider.dart';
import '../../../employee_today/presentation/widgets/attendance_policy_sheet.dart';
import '../../../employee_today/presentation/widgets/employee_today_skeletons.dart';
import '../../../employee_today/providers/employee_today_providers.dart';
import '../../application/employee_punch_controller.dart';
import '../../application/employee_today_attendance_ui_provider.dart';
import '../../domain/enums/attendance_punch_type.dart';
import 'break_countdown_card.dart';

/// Premium attendance card for the employee Today tab (Firestore-backed via existing VM).
class TodayAttendanceCard extends ConsumerStatefulWidget {
  const TodayAttendanceCard({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  ConsumerState<TodayAttendanceCard> createState() => _TodayAttendanceCardState();
}

class _TodayAttendanceCardState extends ConsumerState<TodayAttendanceCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _onPunch(
    BuildContext context,
    WidgetRef ref,
    AttendancePunchType type,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final vm = ref.read(employeeTodayAttendanceProvider).asData?.value;
    if (vm == null) {
      return;
    }
    if (!vm.canPunch(type)) {
      final msg =
          vm.validationMessage(l10n) ?? l10n.employeeTodayPunchNotAllowedNow;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    await ref
        .read(employeeTodayAttendanceControllerProvider.notifier)
        .submitPunch(
          type,
          l10n,
          onMessage: (m) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(m)));
            }
          },
          onSuccess: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.employeeTodayPunchRecorded(_punchLabel(l10n, type)),
                  ),
                ),
              );
            }
          },
        );
  }

  String _punchLabel(AppLocalizations l10n, AttendancePunchType t) {
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

  void _openPolicySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttendancePolicySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final vmAsync = ref.watch(employeeTodayAttendanceProvider);
    final dayAsync = ref.watch(etTodayAttendanceDayProvider);
    final punchesAsync = ref.watch(etTodayPunchesProvider);
    final weekAsync = ref.watch(employeeWeekAttendanceRollupProvider);
    final busy = ref
        .watch(employeeTodayAttendanceControllerProvider)
        .asData
        ?.value;

    return vmAsync.when(
      loading: () => const Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: EtTodayAttendanceCardSkeleton(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: ZuranoErrorState(
          title: l10n.employeeTodayAttendanceLoadErrorTitle,
          message: error.toString(),
          onRetry: widget.onRetry,
          retryLabel: l10n.employeeTodayTryAgain,
        ),
      ),
      data: (vm) {
        if (vm.salonId.isEmpty) {
          return const SizedBox.shrink();
        }
        if (dayAsync.isLoading || punchesAsync.isLoading) {
          return const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: EtTodayAttendanceCardSkeleton(),
          );
        }
        if (dayAsync.hasError) {
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: ZuranoErrorState(
              title: l10n.employeeTodayAttendanceLoadErrorTitle,
              message: dayAsync.error.toString(),
              onRetry: widget.onRetry,
              retryLabel: l10n.employeeTodayTryAgain,
            ),
          );
        }
        if (punchesAsync.hasError) {
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: ZuranoErrorState(
              title: l10n.employeeTodayAttendanceLoadErrorTitle,
              message: punchesAsync.error.toString(),
              onRetry: widget.onRetry,
              retryLabel: l10n.employeeTodayTryAgain,
            ),
          );
        }

        final rollup = weekAsync.maybeWhen(
          data: (v) => v,
          orElse: () => (totalWorkedMinutes: 0, workingDays: 0),
        );
        final model = buildEmployeeAttendanceCardModel(
          vm: vm,
          day: dayAsync.asData?.value,
          punches: punchesAsync.asData?.value ?? const [],
          weeklyWorkedMinutes: rollup.totalWorkedMinutes,
          weeklyWorkingDays: rollup.workingDays,
          now: DateTime.now(),
        );

        Widget? breakSlot;
        if (vm.isOnBreak &&
            vm.openBreakStartedAt != null &&
            vm.openBreakAllowedMinutes != null) {
          breakSlot = BreakCountdownCard(
            breakStartedAt: vm.openBreakStartedAt!,
            remainingAllowanceMinutes: vm.openBreakAllowedMinutes!,
            shiftStart: vm.breakCountdownShiftStart,
            shiftEnd: vm.breakCountdownShiftEnd,
          );
        }

        return PremiumAttendanceCard(
            data: model,
            statusTitle: vm.primaryStatusTitle(l10n),
            statusSubtitle: vm.primaryStatusSubtitle(l10n),
            locale: locale,
            l10n: l10n,
            breakCountdownSlot: breakSlot,
            busyType: busy,
            onPunchIn: () => _onPunch(context, ref, AttendancePunchType.punchIn),
            onLeaveBreak: () =>
                _onPunch(context, ref, AttendancePunchType.breakOut),
            onReturnBreak: () =>
                _onPunch(context, ref, AttendancePunchType.breakIn),
            onPunchOut: () =>
                _onPunch(context, ref, AttendancePunchType.punchOut),
            onViewPolicy: () => _openPolicySheet(context),
          );
      },
    );
  }
}
