import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../owner/settings/attendance/domain/models/attendance_settings_model.dart';
import '../../data/attendance_policy_callable_service.dart';
import '../../providers/employee_today_providers.dart';
import '../employee_today_theme.dart';
import 'attendance_policy_rule_tile.dart';
import 'attendance_policy_section.dart';
import 'employee_today_widgets.dart';

/// Scrollable attendance rules (settings-driven). Used by policy screen and sheet.
class EmployeeAttendancePolicyBody extends ConsumerWidget {
  const EmployeeAttendancePolicyBody({
    super.key,
    required this.settings,
    this.padding = const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 28),
    this.scrollController,
  });

  final AttendanceSettingsModel settings;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  String _deductionChip(AppLocalizations l10n, int percent) {
    if (percent <= 0) {
      return l10n.employeePolicyDeductionNone;
    }
    return l10n.employeePolicyDeductionPercentValue(percent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(sessionUserProvider).asData?.value;
    final canRegenerate =
        user != null &&
        (user.role == UserRoles.owner || user.role == UserRoles.admin);

    final gpsLine = settings.attendanceRequired && settings.locationRequired
        ? l10n.employeePolicyRuleGpsRequiredOneLine(
            settings.allowedRadiusMeters,
          )
        : l10n.employeePolicyRuleGpsOptionalOneLine;

    return SingleChildScrollView(
      controller: scrollController,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.employeePolicySubtitle,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: EmployeeTodayColors.mutedText,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          EtPremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.employeePolicySummaryTitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: EmployeeTodayColors.deepText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.employeePolicySummaryStatic,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: EmployeeTodayColors.mutedText,
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          EtPremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AttendancePolicySection(
                  title: l10n.employeePolicyPunchRules,
                  children: [
                    AttendancePolicyRuleTile(
                      icon: Icons.touch_app_outlined,
                      title: l10n.employeePolicyRuleWorkPunchesOneLine,
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.free_breakfast_outlined,
                      title: l10n.employeePolicyRuleMaxBreakMinutesOneLine(
                        settings.maxBreakMinutesPerDay,
                      ),
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.sync_alt_rounded,
                      title: l10n.employeePolicyRuleBreakOrderOneLine,
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.location_searching_rounded,
                      title: gpsLine,
                    ),
                  ],
                ),
                const Divider(height: 28),
                AttendancePolicySection(
                  title: l10n.employeePolicyLateEarly,
                  children: [
                    AttendancePolicyRuleTile(
                      icon: Icons.schedule_rounded,
                      title: l10n.employeePolicyRuleLateGraceOneLine(
                        settings.lateGraceMinutes,
                      ),
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.event_repeat_rounded,
                      title: l10n.employeePolicyRuleLateMonthlyOneLine(
                        settings.allowedLateCountPerMonth,
                      ),
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.logout_rounded,
                      title: l10n.employeePolicyRuleEarlyGraceOneLine(
                        settings.earlyExitGraceMinutes,
                      ),
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.event_note_rounded,
                      title: l10n.employeePolicyRuleEarlyMonthlyOneLine(
                        settings.allowedEarlyExitCountPerMonth,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                AttendancePolicySection(
                  title: l10n.employeePolicyCorrectionSection,
                  children: [
                    AttendancePolicyRuleTile(
                      icon: Icons.edit_note_outlined,
                      title: l10n.employeePolicyRuleCorrectionForgotOneLine,
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.verified_outlined,
                      title: l10n.employeePolicyRuleCorrectionApprovedOneLine,
                    ),
                  ],
                ),
                const Divider(height: 28),
                AttendancePolicySection(
                  title: l10n.employeePolicyDeductionsSection,
                  children: [
                    AttendancePolicyRuleTile(
                      icon: Icons.payments_outlined,
                      title: l10n.employeePolicyDeductionMissingCheckoutTitle,
                      subtitle:
                          l10n.employeePolicyDeductionMissingCheckoutSubtitle,
                      trailingChipLabel: _deductionChip(
                        l10n,
                        settings.missingCheckoutDeductionPercent,
                      ),
                    ),
                    AttendancePolicyRuleTile(
                      icon: Icons.event_busy_outlined,
                      title: l10n.employeePolicyDeductionAbsenceTitle,
                      subtitle: l10n.employeePolicyDeductionAbsenceSubtitle,
                      trailingChipLabel: _deductionChip(
                        l10n,
                        settings.absenceDeductionPercent,
                      ),
                    ),
                  ],
                ),
                if (canRegenerate) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      final sid = user.salonId;
                      if (sid == null || sid.isEmpty) {
                        return;
                      }
                      try {
                        await AttendancePolicyCallableService()
                            .generateAttendancePolicyReadable(sid);
                        ref.invalidate(etAttendancePolicyReadableProvider);
                        if (context.mounted) {
                          final loc = AppLocalizations.of(context)!;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.employeePolicyUpdatedSnackbar),
                            ),
                          );
                        }
                      } on Object catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    child: Text(l10n.employeePolicyRegenerateCta),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
