import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/zurano_error_state.dart';
import '../../../employee_today/presentation/widgets/attendance_policy_sheet.dart';
import '../../../employee_today/presentation/widgets/employee_today_skeletons.dart';
import '../../application/employee_punch_controller.dart';
import '../../application/employee_today_attendance_ui_provider.dart';
import '../../application/employee_today_attendance_vm.dart';
import '../../domain/enums/attendance_punch_type.dart';
import 'attendance_four_action_panel.dart';
import 'break_countdown_card.dart';

/// White attendance card with a single primary punch CTA.
class TodayAttendanceCard extends ConsumerWidget {
  const TodayAttendanceCard({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(employeeTodayAttendanceProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return attendanceAsync.when(
      loading: () => const Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: EtTodayAttendanceCardSkeleton(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: ZuranoErrorState(
          title: l10n.employeeTodayAttendanceLoadErrorTitle,
          message: error.toString(),
          onRetry: onRetry,
          retryLabel: l10n.employeeTodayTryAgain,
        ),
      ),
      data: (vm) {
        if (vm.salonId.isEmpty) {
          return const SizedBox.shrink();
        }
        return _TodayAttendanceCardBody(vm: vm, locale: locale);
      },
    );
  }
}

class _TodayAttendanceCardBody extends ConsumerWidget {
  const _TodayAttendanceCardBody({required this.vm, required this.locale});

  final EmployeeTodayAttendanceVm vm;
  final Locale locale;

  Color _statusColor() {
    switch (vm.dayStatusKey) {
      case 'missingPunch':
      case 'invalidSequence':
        return const Color(0xFFF59E0B);
      case 'onBreak':
        return const Color(0xFF0EA5E9);
      case 'checkedOut':
        return const Color(0xFFDC2626);
      case 'checkedIn':
      case 'backFromBreak':
      default:
        return const Color(0xFF16A34A);
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

  Future<void> _onPunch(
    BuildContext context,
    WidgetRef ref,
    AttendancePunchType type,
  ) async {
    final l10n = AppLocalizations.of(context)!;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final busy = ref
        .watch(employeeTodayAttendanceControllerProvider)
        .asData
        ?.value;

    final lastPunchAt = vm.lastPunchAt;
    final lastTime = lastPunchAt != null
        ? DateFormat.jm(locale.toString()).format(lastPunchAt)
        : '—';
    final topStatusColor = _statusColor();

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEF0F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: topStatusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.primaryStatusTitle(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '•',
                style: TextStyle(
                  color: const Color(0xFF9CA3AF).withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                lastTime,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!vm.locationResolved)
                      _statusChip(
                        icon: Icons.gps_not_fixed_rounded,
                        label: l10n.employeeTodayGpsLocating,
                        color: const Color(0xFF6B7280),
                      )
                    else if (vm.isGpsVerified)
                      _statusChip(
                        icon: Icons.verified_rounded,
                        label: l10n.employeeTodayGpsVerified,
                        color: const Color(0xFF16A34A),
                      )
                    else
                      _statusChip(
                        icon: Icons.location_off_outlined,
                        label: l10n.employeeTodayZoneOutside,
                        color: const Color(0xFFF59E0B),
                      ),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openPolicySheet(context),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 14, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: const Color(0xFF374151),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.employeeTodayViewPolicy,
                          style: TextStyle(
                            color: const Color(0xFF374151),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  vm.shiftLabel(l10n, locale),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (vm.isOnBreak &&
              vm.openBreakStartedAt != null &&
              vm.openBreakAllowedMinutes != null) ...[
            BreakCountdownCard(
              breakStartedAt: vm.openBreakStartedAt!,
              remainingAllowanceMinutes: vm.openBreakAllowedMinutes!,
              shiftStart: vm.breakCountdownShiftStart,
              shiftEnd: vm.breakCountdownShiftEnd,
            ),
            const SizedBox(height: 14),
          ],
          AttendanceFourActionPanel(
            vm: vm,
            busyType: busy,
            onPunch: (type) => _onPunch(context, ref, type),
          ),
          if (vm.showMissingPunchChip || vm.showOutsideZoneChip) ...[
            const SizedBox(height: 10),
            Text(
              vm.validationMessage(l10n) ?? vm.primaryStatusSubtitle(l10n),
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
