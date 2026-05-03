import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../settings/presentation/widgets/zurano/settings_section_card.dart';
import '../../domain/models/attendance_settings_model.dart';
import 'attendance_settings_form_helpers.dart';

/// Section 2 — Punch rules.
class AttendanceRulesSection extends StatelessWidget {
  const AttendanceRulesSection({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final AttendanceSettingsModel draft;
  final ValueChanged<AttendanceSettingsModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsSectionCard(
      icon: Icons.fact_check_outlined,
      title: l10n.ownerAttendanceSectionPunchRules,
      subtitle: l10n.ownerSettingsHrTileSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceRulesAttendanceRequired,
            subtitle: l10n.ownerAttendanceRulesAttendanceRequiredHint,
            value: draft.attendanceRequired,
            onChanged: (v) => onChanged(draft.copyWith(attendanceRequired: v)),
          ),
          const _SoftDivider(),
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceRulesPunchInRequired,
            value: draft.punchInRequired,
            onChanged: (v) => onChanged(draft.copyWith(punchInRequired: v)),
          ),
          const _SoftDivider(),
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceRulesPunchOutRequired,
            value: draft.punchOutRequired,
            onChanged: (v) => onChanged(draft.copyWith(punchOutRequired: v)),
          ),
          const _SoftDivider(),
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceRulesBreaksEnabled,
            value: draft.breaksEnabled,
            onChanged: (v) => onChanged(
              draft.copyWith(
                breaksEnabled: v,
                maxBreaksPerDay: v && draft.maxBreaksPerDay == 0
                    ? 1
                    : draft.maxBreaksPerDay,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AttendanceStepperRow(
            label: l10n.ownerAttendanceRulesMaxBreaksLabel,
            value: draft.maxBreaksPerDay,
            min: 0,
            max: 5,
            enabled: draft.breaksEnabled,
            onChanged: (v) => onChanged(draft.copyWith(maxBreaksPerDay: v)),
          ),
        ],
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: ZuranoPremiumUiColors.border,
      ),
    );
  }
}

/// Section 3 — Grace and working time.
class AttendanceGraceSection extends StatelessWidget {
  const AttendanceGraceSection({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final AttendanceSettingsModel draft;
  final ValueChanged<AttendanceSettingsModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsSectionCard(
      icon: Icons.timer_outlined,
      title: l10n.ownerAttendanceSectionGrace,
      subtitle: l10n.ownerHrSettingsSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AttendanceNumberField(
            label: l10n.ownerAttendanceGraceLateLabel,
            value: draft.lateGraceMinutes,
            min: 0,
            max: 120,
            onChanged: (v) => onChanged(draft.copyWith(lateGraceMinutes: v)),
          ),
          const SizedBox(height: 12),
          AttendanceNumberField(
            label: l10n.ownerAttendanceGraceEarlyExitLabel,
            value: draft.earlyExitGraceMinutes,
            min: 0,
            max: 120,
            onChanged: (v) =>
                onChanged(draft.copyWith(earlyExitGraceMinutes: v)),
          ),
          const SizedBox(height: 12),
          AttendanceNumberField(
            label: l10n.ownerAttendanceGraceMinShiftLabel,
            value: draft.minimumShiftMinutes,
            min: 1,
            max: 1440,
            onChanged: (v) => onChanged(draft.copyWith(minimumShiftMinutes: v)),
          ),
          const SizedBox(height: 12),
          AttendanceNumberField(
            label: l10n.ownerAttendanceGraceMaxShiftLabel,
            value: draft.maximumShiftMinutes,
            min: 1,
            max: 1440,
            onChanged: (v) => onChanged(draft.copyWith(maximumShiftMinutes: v)),
          ),
        ],
      ),
    );
  }
}

/// Section 4 — Correction requests.
class AttendanceCorrectionSection extends StatelessWidget {
  const AttendanceCorrectionSection({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final AttendanceSettingsModel draft;
  final ValueChanged<AttendanceSettingsModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsSectionCard(
      icon: Icons.edit_calendar_outlined,
      title: l10n.ownerAttendanceSectionCorrection,
      subtitle: l10n.ownerHrSettingsSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceCorrectionEnabled,
            value: draft.correctionRequestsEnabled,
            onChanged: (v) =>
                onChanged(draft.copyWith(correctionRequestsEnabled: v)),
          ),
          const _SoftDivider(),
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceCorrectionRequireReason,
            value: draft.requireCorrectionReason,
            enabled: draft.correctionRequestsEnabled,
            onChanged: (v) =>
                onChanged(draft.copyWith(requireCorrectionReason: v)),
          ),
          const _SoftDivider(),
          AttendanceSwitchRow(
            label: l10n.ownerAttendanceCorrectionRequireApproval,
            value: draft.requireOwnerApprovalForCorrection,
            enabled: draft.correctionRequestsEnabled,
            onChanged: (v) =>
                onChanged(draft.copyWith(requireOwnerApprovalForCorrection: v)),
          ),
          const SizedBox(height: 12),
          AttendanceNumberField(
            label: l10n.ownerAttendanceCorrectionMaxPerMonth,
            value: draft.maxCorrectionRequestsPerMonth,
            min: 0,
            max: 50,
            enabled: draft.correctionRequestsEnabled,
            onChanged: (v) =>
                onChanged(draft.copyWith(maxCorrectionRequestsPerMonth: v)),
          ),
        ],
      ),
    );
  }
}
