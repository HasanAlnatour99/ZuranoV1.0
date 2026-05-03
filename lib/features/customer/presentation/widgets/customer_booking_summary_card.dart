import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employees/data/models/employee.dart';
import '../../../services/data/models/service.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class CustomerBookingSummaryCard extends StatelessWidget {
  const CustomerBookingSummaryCard({
    super.key,
    required this.l10n,
    required this.service,
    required this.barber,
    required this.slotStartUtc,
    required this.localeTag,
  });

  final AppLocalizations l10n;
  final SalonService service;
  final Employee barber;
  final DateTime slotStartUtc;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final timeFmt = DateFormat.jm(localeTag);
    final dateFmt = DateFormat.yMMMd(localeTag);
    final localStart = slotStartUtc.toLocal();
    final localEnd = localStart.add(Duration(minutes: service.durationMinutes));

    return AppSurfaceCard(
      borderRadius: AppRadius.large,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerBookingSummaryTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          _SummaryLine(
            icon: AppIcons.spa_outlined,
            label: l10n.bookingService,
            value: service.serviceName,
            scheme: scheme,
            theme: theme,
          ),
          _SummaryLine(
            icon: AppIcons.face_outlined,
            label: l10n.bookingBarber,
            value: formatTeamMemberName(barber.name),
            scheme: scheme,
            theme: theme,
          ),
          _SummaryLine(
            icon: AppIcons.event_outlined,
            label: l10n.bookingWhen,
            value:
                '${dateFmt.format(localStart)} · '
                '${timeFmt.format(localStart)}–${timeFmt.format(localEnd)}',
            scheme: scheme,
            theme: theme,
          ),
          _SummaryLine(
            icon: AppIcons.timelapse_outlined,
            label: l10n.bookingDuration,
            value: l10n.bookingDurationMinutes(service.durationMinutes),
            scheme: scheme,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
