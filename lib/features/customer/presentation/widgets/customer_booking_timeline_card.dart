import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_booking_details_model.dart';

class CustomerBookingTimelineCard extends StatelessWidget {
  const CustomerBookingTimelineCard({
    super.key,
    required this.details,
    required this.l10n,
  });

  final CustomerBookingDetailsModel details;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final tag = locale.toString();
    final dateFmt = DateFormat.yMMMd(tag);
    final timeFmt = DateFormat.jm(tag);

    String formatDt(DateTime? d) {
      if (d == null) {
        return '—';
      }
      final local = d.toLocal();
      return '${dateFmt.format(local)} · ${timeFmt.format(local)}';
    }

    String actorLabel(String? raw) {
      final t = raw?.trim().toLowerCase() ?? '';
      return switch (t) {
        'customer' => l10n.customerTimelineActorCustomer,
        'system' => l10n.customerTimelineActorSystem,
        'owner' => l10n.customerTimelineActorOwner,
        'admin' => l10n.customerTimelineActorAdmin,
        _ => '',
      };
    }

    String withActor(String when, String actor) {
      if (actor.trim().isEmpty) return when;
      if (when.trim().isEmpty || when.trim() == '—') return actor;
      return '$when · $actor';
    }

    final status = details.status.trim();
    final now = DateTime.now();
    final isActiveVisit =
        (status == BookingStatuses.pending ||
            status == BookingStatuses.confirmed ||
            status == 'checkedIn' ||
            status == 'checked_in') &&
        details.endAt.isAfter(now);

    final step2Label = switch (status) {
      BookingStatuses.pending => l10n.customerBookingDetailsPendingConfirmation,
      BookingStatuses.confirmed ||
      'checkedIn' ||
      'checked_in' => l10n.customerBookingDetailsTimelineConfirmed,
      BookingStatuses.completed => l10n.customerBookingStatusCompleted,
      BookingStatuses.cancelled => l10n.customerBookingStatusCancelled,
      BookingStatuses.noShow || 'noShow' => l10n.customerBookingStatusNoShow,
      _ => l10n.customerBookingDetailsPendingConfirmation,
    };

    final step3Label = switch (status) {
      BookingStatuses.completed => l10n.customerBookingStatusCompleted,
      BookingStatuses.cancelled => l10n.customerBookingStatusCancelled,
      BookingStatuses.noShow || 'noShow' => l10n.customerBookingStatusNoShow,
      _ when isActiveVisit => l10n.customerBookingDetailsTimelineUpcoming,
      _ => l10n.customerBookingStatusCompleted,
    };

    final step2Time = switch (status) {
      BookingStatuses.pending => details.createdAt ?? details.startAt,
      BookingStatuses.confirmed ||
      'checkedIn' ||
      'checked_in' => details.confirmedAt ?? details.updatedAt ?? details.startAt,
      _ => details.startAt,
    };

    final step3Time = switch (status) {
      BookingStatuses.completed => formatDt(details.endAt),
      BookingStatuses.cancelled => formatDt(details.cancelledAt ?? details.updatedAt ?? details.endAt),
      BookingStatuses.noShow || 'noShow' => formatDt(details.startAt),
      _ when isActiveVisit =>
        '${timeFmt.format(details.startAt.toLocal())} – '
            '${timeFmt.format(details.endAt.toLocal())}',
      _ => formatDt(details.endAt),
    };

    final createdActor = actorLabel(details.createdActorType);
    final confirmedActor = actorLabel(details.confirmedActorType);
    final cancelledActor = actorLabel(details.cancelledActorType);
    final rescheduledActor = actorLabel(details.rescheduledActorType);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerBookingDetailsTimelineTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            _TimelineRow(
              dotColor: AppBrandColors.primary,
              title: l10n.customerBookingDetailsTimelineCreated,
              subtitle: withActor(
                formatDt(details.createdAt ?? details.startAt),
                createdActor,
              ),
              isLast: false,
            ),
            if (details.rescheduledAt != null) ...[
              _TimelineRow(
                dotColor: AppBrandColors.primary.withValues(alpha: 0.75),
                title: l10n.bookingStatusRescheduled,
                subtitle: withActor(
                  formatDt(details.rescheduledAt),
                  rescheduledActor,
                ),
                isLast: false,
              ),
            ],
            _TimelineRow(
              dotColor: AppBrandColors.primary.withValues(alpha: 0.65),
              title: step2Label,
              subtitle: withActor(
                formatDt(step2Time),
                step2Label == l10n.customerBookingDetailsTimelineConfirmed
                    ? confirmedActor
                    : '',
              ),
              isLast: false,
            ),
            _TimelineRow(
              dotColor: theme.colorScheme.outline,
              title: step3Label,
              subtitle: withActor(
                step3Time,
                step3Label == l10n.customerBookingStatusCancelled
                    ? cancelledActor
                    : '',
              ),
              extra: (step3Label == l10n.customerBookingStatusCancelled &&
                      (details.cancelReason?.trim().isNotEmpty == true))
                  ? '${l10n.customerCancelBookingReasonLabel}: ${details.cancelReason!.trim()}'
                  : null,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dotColor,
    required this.title,
    required this.subtitle,
    required this.isLast,
    this.extra,
  });

  final Color dotColor;
  final String title;
  final String subtitle;
  final bool isLast;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColorsLight.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (extra != null && extra!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      extra!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColorsLight.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
