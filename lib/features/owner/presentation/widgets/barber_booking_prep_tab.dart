import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../features/customer/data/models/customer_booking_settings_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../owner/settings/customer_booking/application/customer_booking_salon_settings_providers.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../logic/team_management_providers.dart';

class BarberBookingPrepTab extends ConsumerWidget {
  const BarberBookingPrepTab({super.key, required this.data});

  final BarberDetailsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(
      customerBookingSettingsProvider(data.employee.salonId),
    );
    final settings =
        settingsAsync.asData?.value ??
        CustomerBookingSettingsModel.defaults(data.employee.salonId);
    final bookingLive = data.employee.isBookable && settings.customerBookingEnabled;
    final visibleCount = data.visibleServices.length;
    final assignedCount = data.assignedServices.length;
    final profileSignals = <bool>[
      data.employee.name.trim().isNotEmpty,
      (data.employee.publicBio ?? '').trim().isNotEmpty,
      data.employee.avatarUrl?.trim().isNotEmpty == true,
      data.employee.workingHoursProfileId?.trim().isNotEmpty == true ||
          data.employee.weeklyAvailability != null,
      data.employee.isBookable,
    ];
    final readinessCount = profileSignals.where((ready) => ready).length;
    final readinessProgress = profileSignals.isEmpty
        ? 0.0
        : readinessCount / profileSignals.length;
    final workingHoursValue =
        data.employee.workingHoursProfileId?.trim().isNotEmpty == true
        ? data.employee.workingHoursProfileId!
        : (data.employee.weeklyAvailability != null
              ? l10n.teamValueEnabled
              : l10n.teamValueNotAvailable);
    final profileImageValue = data.employee.avatarUrl?.trim().isNotEmpty == true
        ? l10n.teamValueEnabled
        : l10n.teamValueNotAvailable;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        _BookingPrepHeroCard(
          progress: readinessProgress,
          title: l10n.teamDetailsTabBookingPrep,
          leftLabel: l10n.teamFieldBookable,
          leftValue: bookingLive ? l10n.teamValueEnabled : l10n.teamValueDisabled,
          rightLabel: l10n.teamBookingPrepVisibleServicesTitle,
          rightValue: '$visibleCount/$assignedCount',
        ),
        const SizedBox(height: AppSpacing.medium),
        AppSurfaceCard(
          borderRadius: AppRadius.large,
          showShadow: true,
          outlineOpacity: 0.14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingPrepRow(
                label: l10n.teamFieldBookable,
                value: data.employee.isBookable
                    ? l10n.teamValueEnabled
                    : l10n.teamValueDisabled,
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepPublicDisplayName,
                value: formatTeamMemberName(data.employee.name),
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepPublicBio,
                value: (data.employee.publicBio ?? '').trim().isEmpty
                    ? l10n.teamValueNotAvailable
                    : data.employee.publicBio!,
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepWorkingHoursProfile,
                value: workingHoursValue,
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepSlotDuration,
                value: '${settings.slotDurationMinutes}',
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepDisplayOrder,
                value: '${data.employee.displayOrder}',
              ),
              _BookingPrepRow(
                label: l10n.teamBookingPrepProfileImage,
                value: profileImageValue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        AppSurfaceCard(
          borderRadius: AppRadius.large,
          showShadow: true,
          outlineOpacity: 0.14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.teamBookingPrepVisibleServicesTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.medium),
              if (data.visibleServices.isEmpty)
                Text(l10n.teamBookingPrepVisibleServicesEmpty)
              else
                for (
                  var index = 0;
                  index < data.visibleServices.length;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.small),
                  _ServicePill(label: data.visibleServices[index].serviceName),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingPrepHeroCard extends StatelessWidget {
  const _BookingPrepHeroCard({
    required this.progress,
    required this.title,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final double progress;
  final String title;
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        gradient: const LinearGradient(
          colors: [Color(0xFFF4EDFF), Color(0xFFEDE2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: TeamMemberProfileColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: TeamMemberProfileColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: TeamMemberProfileColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white,
              color: TeamMemberProfileColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: _HeroMetricTile(label: leftLabel, value: leftValue),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: _HeroMetricTile(label: rightLabel, value: rightValue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: TeamMemberProfileColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: TeamMemberProfileColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: TeamMemberProfileColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingPrepRow extends StatelessWidget {
  const _BookingPrepRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicePill extends StatelessWidget {
  const _ServicePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        color: TeamMemberProfileColors.softPurple.withValues(alpha: 0.7),
        border: Border.all(
          color: TeamMemberProfileColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: TeamMemberProfileColors.textPrimary,
        ),
      ),
    );
  }
}
