import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../data/models/attendance_ui_status.dart';
import '../../data/models/employee_attendance_card_model.dart';
import 'attendance_action_button.dart';
import 'attendance_info_tile.dart';
import 'attendance_status_header.dart';
import 'attendance_summary_strip.dart';

/// Premium white attendance card (no shift row — shift lives in the hero header).
class PremiumAttendanceCard extends StatelessWidget {
  const PremiumAttendanceCard({
    super.key,
    required this.data,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.locale,
    required this.l10n,
    required this.breakCountdownSlot,
    required this.busyType,
    required this.onPunchIn,
    required this.onLeaveBreak,
    required this.onReturnBreak,
    required this.onPunchOut,
    required this.onViewPolicy,
  });

  final EmployeeAttendanceCardModel data;
  final String statusTitle;
  final String statusSubtitle;
  final Locale locale;
  final AppLocalizations l10n;
  final Widget? breakCountdownSlot;
  final AttendancePunchType? busyType;
  final VoidCallback onPunchIn;
  final VoidCallback onLeaveBreak;
  final VoidCallback onReturnBreak;
  final VoidCallback onPunchOut;
  final VoidCallback onViewPolicy;

  Color _glowColor() {
    switch (data.uiStatus) {
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

  @override
  Widget build(BuildContext context) {
    final glow = _glowColor();
    final gpsTitle = data.gpsLocating
        ? l10n.employeeTodayGpsLocating
        : (data.gpsVerified
              ? l10n.employeeTodayGpsVerified
              : l10n.employeePremiumAttendanceGpsOutsideTitle);
    final gpsSubtitle = data.gpsLocating
        ? l10n.employeePremiumAttendanceGpsLocatingSubtitle
        : (data.gpsVerified
              ? l10n.employeePremiumAttendanceGpsInsideSubtitle
              : l10n.employeePremiumAttendanceGpsOutsideSubtitle);
    final gpsColor = data.gpsLocating
        ? const Color(0xFF64748B)
        : (data.gpsVerified
              ? const Color(0xFF16A34A)
              : const Color(0xFFF97316));

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AttendanceStatusHeader(
                    uiStatus: data.uiStatus,
                    statusTitle: statusTitle,
                    statusSubtitle: statusSubtitle,
                    lastActionAt: data.lastActionAt,
                    locale: locale,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AttendanceInfoTile(
                          icon: Icons.location_on_rounded,
                          title: gpsTitle,
                          subtitle: gpsSubtitle,
                          color: gpsColor,
                          onTap: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AttendanceInfoTile(
                          icon: Icons.shield_rounded,
                          title: l10n.employeePremiumAttendancePolicyTileTitle,
                          subtitle:
                              l10n.employeePremiumAttendancePolicyTileSubtitle,
                          color: const Color(0xFF6D28D9),
                          titleColor: const Color(0xFF4C1D95),
                          onTap: onViewPolicy,
                        ),
                      ),
                    ],
                  ),
                  if (breakCountdownSlot != null) ...[
                    const SizedBox(height: 10),
                    breakCountdownSlot!,
                  ],
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 6.0;

                      Widget punchIn() => AttendanceActionButton(
                        icon: Icons.login_rounded,
                        title: l10n.employeeTodayPunchIn,
                        subtitle: l10n.employeeTodayPrimaryPunchInSubtitle,
                        enabled: data.canPunchIn,
                        loading: busyType == AttendancePunchType.punchIn,
                        color: const Color(0xFF16A34A),
                        availableLabel:
                            l10n.employeePremiumAttendanceActionAvailable,
                        disabledLabel:
                            l10n.employeePremiumAttendanceActionDisabled,
                        onTap: onPunchIn,
                      );

                      Widget leaveBreak() => AttendanceActionButton(
                        icon: Icons.free_breakfast_rounded,
                        title: l10n.employeeTodayBreakOut,
                        subtitle: l10n.employeeTodayPrimaryBreakOutSubtitle,
                        enabled: data.canLeaveBreak,
                        loading: busyType == AttendancePunchType.breakOut,
                        color: const Color(0xFFF97316),
                        availableLabel:
                            l10n.employeePremiumAttendanceActionAvailable,
                        disabledLabel:
                            l10n.employeePremiumAttendanceActionDisabled,
                        onTap: onLeaveBreak,
                      );

                      Widget returnBreak() => AttendanceActionButton(
                        icon: Icons.coffee_rounded,
                        title: l10n.employeeTodayBreakIn,
                        subtitle: l10n.employeeTodayPrimaryBreakInSubtitle,
                        enabled: data.canReturnBreak,
                        loading: busyType == AttendancePunchType.breakIn,
                        color: const Color(0xFF7C3AED),
                        availableLabel:
                            l10n.employeePremiumAttendanceActionAvailable,
                        disabledLabel:
                            l10n.employeePremiumAttendanceActionDisabled,
                        onTap: onReturnBreak,
                      );

                      Widget punchOut() => AttendanceActionButton(
                        icon: Icons.logout_rounded,
                        title: l10n.employeeTodayPunchOut,
                        subtitle: l10n.employeeTodayPrimaryPunchOutSubtitle,
                        enabled: data.canPunchOut,
                        loading: busyType == AttendancePunchType.punchOut,
                        color: const Color(0xFFEF4444),
                        availableLabel:
                            l10n.employeePremiumAttendanceActionAvailable,
                        disabledLabel:
                            l10n.employeePremiumAttendanceActionDisabled,
                        onTap: onPunchOut,
                      );

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: punchIn()),
                              SizedBox(width: gap),
                              Expanded(child: leaveBreak()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: returnBreak()),
                              SizedBox(width: gap),
                              Expanded(child: punchOut()),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AttendanceSummaryStrip(
                    todayHours: data.todayHours,
                    weeklyHours: data.weeklyHours,
                    weeklyDays: data.weeklyWorkingDays,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
