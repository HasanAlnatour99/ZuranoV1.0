import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/violation_types.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../salon/data/models/penalty_settings.dart';
import '../../../salon/data/models/salon.dart';
import '../../../violations/data/models/violation.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

String _metricCaptionCase(BuildContext context, String value) {
  final lang = Localizations.localeOf(context).languageCode;
  if (lang == 'ar') {
    return value;
  }
  return value.toUpperCase();
}

/// Violation queue + penalty settings (embedded in owner workspace).
class OwnerViolationsModule extends ConsumerWidget {
  const OwnerViolationsModule({super.key, required this.salonId});

  final String salonId;

  Future<void> _review(
    BuildContext context,
    WidgetRef ref, {
    required String violationId,
    required bool approve,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(violationRepositoryProvider)
          .reviewViolation(
            salonId: salonId,
            violationId: violationId,
            approve: approve,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ownerViolationReviewSaved)));
      }
    } on Object catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  Future<void> _savePenaltySettings(
    BuildContext context,
    WidgetRef ref,
    Salon salon,
    PenaltySettings next,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(salonRepositoryProvider)
          .updateSalon(salon.copyWith(penaltySettings: next));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ownerPenaltySettingsSaved)));
      }
    } on Object catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  int _activeRulesCount(PenaltySettings? p) {
    if (p == null) {
      return 0;
    }
    return (p.barberLateEnabled ? 1 : 0) + (p.barberNoShowEnabled ? 1 : 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final violationsAsync = ref.watch(violationsStreamProvider);
    final salonAsync = ref.watch(sessionSalonStreamProvider);

    if (salonId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ownerViolationsTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.ownerViolationsSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        violationsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(l10n.genericError),
          data: (all) {
            final pending = all
                .where((v) => v.status == ViolationStatuses.pending)
                .take(24)
                .toList(growable: false);
            final pendingCount = pending.length;
            return salonAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _KpiCardPlaceholder(),
                  const SizedBox(height: AppSpacing.medium),
                  if (pending.isEmpty)
                    Text(
                      l10n.ownerViolationsEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...pending.map(
                      (v) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.medium,
                        ),
                        child: _ViolationQueueCard(
                          violation: v,
                          l10n: l10n,
                          onApprove: () => _review(
                            context,
                            ref,
                            violationId: v.id,
                            approve: true,
                          ),
                          onReject: () => _review(
                            context,
                            ref,
                            violationId: v.id,
                            approve: false,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              error: (_, _) => Text(l10n.genericError),
              data: (salon) {
                final rulesOn = _activeRulesCount(salon?.penaltySettings);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ViolationsRulesKpiCard(
                      pendingCount: pendingCount,
                      activeRulesCount: rulesOn,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    if (pending.isEmpty)
                      Text(
                        l10n.ownerViolationsEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ...pending.map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.medium,
                          ),
                          child: _ViolationQueueCard(
                            violation: v,
                            l10n: l10n,
                            onApprove: () => _review(
                              context,
                              ref,
                              violationId: v.id,
                              approve: true,
                            ),
                            onReject: () => _review(
                              context,
                              ref,
                              violationId: v.id,
                              approve: false,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.ownerPenaltySettingsTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        salonAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Text(l10n.genericError),
          data: (salon) {
            if (salon == null) {
              return const SizedBox.shrink();
            }
            final p = salon.penaltySettings;
            return _PenaltySettingsForm(
              initial: p,
              onSave: (next) => _savePenaltySettings(context, ref, salon, next),
            );
          },
        ),
      ],
    );
  }
}

class _KpiCardPlaceholder extends StatelessWidget {
  const _KpiCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: SizedBox(
        height: 112,
        child: ColoredBox(
          color: AppBrandColors.tipsBackground,
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppBrandColors.onTipsBackground.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViolationsRulesKpiCard extends StatelessWidget {
  const _ViolationsRulesKpiCard({
    required this.pendingCount,
    required this.activeRulesCount,
  });

  final int pendingCount;
  final int activeRulesCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = NumberFormat.decimalPattern(locale);
    final onCard = AppBrandColors.onTipsBackground;
    final base = AppBrandColors.tipsBackground;
    final lifted = Color.lerp(base, Colors.white, 0.14)!;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: onCard.withValues(alpha: 0.82),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      height: 1.2,
    );
    final valueStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: onCard,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: ColoredBox(
        color: base,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ColoredBox(
            color: lifted,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricCaptionCase(
                              context,
                              l10n.ownerViolationsMetricPending,
                            ),
                            style: labelStyle,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Row(
                            children: [
                              Icon(
                                AppIcons.fact_check_outlined,
                                size: 22,
                                color: AppBrandColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Text(fmt.format(pendingCount), style: valueStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 4,
                    endIndent: 4,
                    color: onCard.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricCaptionCase(
                              context,
                              l10n.ownerViolationsMetricRulesOn,
                            ),
                            style: labelStyle,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Row(
                            children: [
                              Icon(
                                AppIcons.tune,
                                size: 22,
                                color: AppBrandColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Text(
                                fmt.format(activeRulesCount),
                                style: valueStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _ViolationQueueCard extends StatelessWidget {
  const _ViolationQueueCard({
    required this.violation,
    required this.l10n,
    required this.onApprove,
    required this.onReject,
  });

  final Violation violation;
  final AppLocalizations l10n;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = violation;
    final onCard = AppBrandColors.onTipsBackground;
    final base = AppBrandColors.tipsBackground;
    final lifted = Color.lerp(base, Colors.white, 0.12)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: lifted,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                children: [
                  Icon(
                    AppIcons.report_gmailerrorred_outlined,
                    color: AppBrandColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      '${(v.employeeName?.trim().isNotEmpty == true) ? formatTeamMemberName(v.employeeName) : v.employeeId} · ${v.violationType}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppBrandColors.onTipsBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ColoredBox(
            color: base,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.ownerViolationBooking}: ${v.bookingId ?? '—'} · ${l10n.ownerViolationAmount}: ${v.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onCard.withValues(alpha: 0.88),
                    ),
                  ),
                  if (v.notes != null && v.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      v.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onCard.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.small),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Theme(
                      data: theme.copyWith(
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppBrandColors.primary,
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: onApprove,
                            child: Text(l10n.ownerViolationApprove),
                          ),
                          TextButton(
                            onPressed: onReject,
                            child: Text(l10n.ownerViolationReject),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltyRuleInsightCard extends StatelessWidget {
  const _PenaltyRuleInsightCard({
    required this.leftLabel,
    required this.leftValue,
    required this.leftIcon,
    required this.rightLabel,
    required this.rightValue,
    required this.rightIcon,
    required this.whenCaption,
    required this.whenTitle,
    required this.enabled,
    required this.onEnabledChanged,
  });

  final String leftLabel;
  final String leftValue;
  final IconData leftIcon;
  final String rightLabel;
  final String rightValue;
  final IconData rightIcon;
  final String whenCaption;
  final String whenTitle;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = AppBrandColors.onTipsBackground;
    final base = AppBrandColors.tipsBackground;
    final lifted = Color.lerp(base, Colors.white, 0.14)!;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: onCard.withValues(alpha: 0.82),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.55,
      height: 1.2,
    );
    final valueStyle = theme.textTheme.headlineSmall?.copyWith(
      color: onCard,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: lifted,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricCaptionCase(context, leftLabel),
                            style: labelStyle,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Row(
                            children: [
                              Icon(
                                leftIcon,
                                size: 22,
                                color: AppBrandColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Expanded(
                                child: Text(
                                  leftValue,
                                  style: valueStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 4,
                    endIndent: 4,
                    color: onCard.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricCaptionCase(context, rightLabel),
                            style: labelStyle,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Row(
                            children: [
                              Icon(
                                rightIcon,
                                size: 22,
                                color: AppBrandColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Expanded(
                                child: Text(
                                  rightValue,
                                  style: valueStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ColoredBox(
            color: base,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _metricCaptionCase(context, whenCaption),
                          style: labelStyle,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          whenTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: onCard,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        AppIcons.notifications_none_rounded,
                        color: onCard.withValues(alpha: 0.92),
                        size: 22,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      SwitchTheme(
                        data: SwitchThemeData(
                          trackOutlineColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppBrandColors.primary;
                            }
                            return onCard;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return onCard.withValues(alpha: 0.9);
                            }
                            return onCard.withValues(alpha: 0.28);
                          }),
                        ),
                        child: Switch.adaptive(
                          value: enabled,
                          onChanged: onEnabledChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltySettingsForm extends StatefulWidget {
  const _PenaltySettingsForm({required this.initial, required this.onSave});

  final PenaltySettings initial;
  final void Function(PenaltySettings) onSave;

  @override
  State<_PenaltySettingsForm> createState() => _PenaltySettingsFormState();
}

class _PenaltySettingsFormState extends State<_PenaltySettingsForm> {
  late bool _lateEn;
  late bool _nsEn;
  late String _lateType;
  late String _nsType;
  late final TextEditingController _grace;
  late final TextEditingController _lateVal;
  late final TextEditingController _nsVal;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _lateEn = p.barberLateEnabled;
    _nsEn = p.barberNoShowEnabled;
    _lateType = p.barberLateCalculationType;
    _nsType = p.barberNoShowCalculationType;
    _grace = TextEditingController(text: '${p.barberLateGraceMinutes}');
    _lateVal = TextEditingController(text: '${p.barberLateValue}');
    _nsVal = TextEditingController(text: '${p.barberNoShowValue}');
    _grace.addListener(_refresh);
    _lateVal.addListener(_refresh);
    _nsVal.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _grace.removeListener(_refresh);
    _lateVal.removeListener(_refresh);
    _nsVal.removeListener(_refresh);
    _grace.dispose();
    _lateVal.dispose();
    _nsVal.dispose();
    super.dispose();
  }

  String _formatLateValue(AppLocalizations l10n) {
    final raw = double.tryParse(_lateVal.text.trim());
    final n = raw ?? 0;
    if (_lateType == PenaltyCalculationTypes.percent) {
      return '${n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1)}%';
    }
    return n.toStringAsFixed(2);
  }

  String _formatNoShowValue() {
    final raw = double.tryParse(_nsVal.text.trim());
    final n = raw ?? 0;
    if (_nsType == PenaltyCalculationTypes.percent) {
      return '${n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1)}%';
    }
    return n.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PenaltyRuleInsightCard(
          leftLabel: l10n.ownerPenaltyGraceMinutes,
          leftValue: _grace.text.trim().isEmpty ? '—' : _grace.text.trim(),
          leftIcon: AppIcons.timer_outlined,
          rightLabel: l10n.ownerPenaltyLateValue,
          rightValue: _formatLateValue(l10n),
          rightIcon: AppIcons.bolt_outlined,
          whenCaption: l10n.ownerPenaltyAppliesWhenLabel,
          whenTitle: l10n.ownerPenaltyLateWhenBody,
          enabled: _lateEn,
          onEnabledChanged: (v) => setState(() => _lateEn = v),
        ),
        if (_lateEn) ...[
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            label: l10n.ownerPenaltyGraceMinutes,
            controller: _grace,
            keyboardType: TextInputType.number,
          ),
          AppSelectField<String>(
            key: ValueKey<String>('late_calc_$_lateType'),
            label: l10n.ownerPenaltyMetricCalculation,
            value: _lateType,
            options: [
              AppSelectOption(
                value: PenaltyCalculationTypes.flat,
                label: l10n.ownerPenaltyCalcFlat,
              ),
              AppSelectOption(
                value: PenaltyCalculationTypes.percent,
                label: l10n.ownerPenaltyCalcPercent,
              ),
              AppSelectOption(
                value: PenaltyCalculationTypes.perMinute,
                label: l10n.ownerPenaltyCalcPerMinute,
              ),
            ],
            onChanged: (v) => setState(() => _lateType = v ?? _lateType),
          ),
          AppTextField(
            label: l10n.ownerPenaltyLateValue,
            controller: _lateVal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        _PenaltyRuleInsightCard(
          leftLabel: l10n.ownerPenaltyMetricCalculation,
          leftValue: _nsType == PenaltyCalculationTypes.flat
              ? l10n.ownerPenaltyCalcFlat
              : l10n.ownerPenaltyCalcPercent,
          leftIcon: AppIcons.calculate_outlined,
          rightLabel: l10n.ownerPenaltyNoShowValue,
          rightValue: _formatNoShowValue(),
          rightIcon: AppIcons.event_busy_outlined,
          whenCaption: l10n.ownerPenaltyAppliesWhenLabel,
          whenTitle: l10n.ownerPenaltyNoShowWhenBody,
          enabled: _nsEn,
          onEnabledChanged: (v) => setState(() => _nsEn = v),
        ),
        if (_nsEn) ...[
          const SizedBox(height: AppSpacing.medium),
          AppSelectField<String>(
            key: ValueKey<String>('noshow_calc_$_nsType'),
            label: l10n.ownerPenaltyMetricCalculation,
            value: _nsType,
            options: [
              AppSelectOption(
                value: PenaltyCalculationTypes.flat,
                label: l10n.ownerPenaltyCalcFlat,
              ),
              AppSelectOption(
                value: PenaltyCalculationTypes.percent,
                label: l10n.ownerPenaltyCalcPercent,
              ),
            ],
            onChanged: (v) => setState(() => _nsType = v ?? _nsType),
          ),
          AppTextField(
            label: l10n.ownerPenaltyNoShowValue,
            controller: _nsVal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        const SizedBox(height: AppSpacing.medium),
        AppPrimaryButton(
          label: l10n.ownerSave,
          onPressed: () {
            widget.onSave(
              PenaltySettings(
                barberLateEnabled: _lateEn,
                barberLateGraceMinutes: int.tryParse(_grace.text.trim()) ?? 5,
                barberLateCalculationType: _lateType,
                barberLateValue: double.tryParse(_lateVal.text.trim()) ?? 0,
                barberNoShowEnabled: _nsEn,
                barberNoShowCalculationType: _nsType,
                barberNoShowValue: double.tryParse(_nsVal.text.trim()) ?? 0,
              ),
            );
          },
        ),
      ],
    );
  }
}
