import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/logic/booking_recommendation_models.dart';
import '../../../../providers/booking_recommendation_provider.dart';

String recommendationReasonLabel(
  RecommendationReason reason,
  AppLocalizations l10n,
) {
  switch (reason) {
    case RecommendationReason.experiencedWithService:
      return l10n.recommendationReasonExperiencedWithService;
    case RecommendationReason.noServiceHistoryFallback:
      return l10n.recommendationReasonNoServiceHistoryFallback;
    case RecommendationReason.strongTrackRecord:
      return l10n.recommendationReasonStrongTrackRecord;
    case RecommendationReason.soonestTime:
      return l10n.recommendationReasonSoonestTime;
    case RecommendationReason.preferredBarber:
      return l10n.recommendationReasonPreferredBarber;
    case RecommendationReason.balancedSchedule:
      return l10n.recommendationReasonBalancedSchedule;
    case RecommendationReason.moreAvailabilityToday:
      return l10n.recommendationReasonMoreAvailabilityToday;
  }
}

class BookingRecommendationsSection extends ConsumerWidget {
  const BookingRecommendationsSection({
    super.key,
    required this.salonId,
    required this.serviceId,
    required this.selectedLocalDay,
    this.preferredBarberId,
    required this.onPick,
  });

  final String salonId;
  final String serviceId;
  final DateTime selectedLocalDay;
  final String? preferredBarberId;
  final void Function(String barberId, DateTime slotStartUtc) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localeTag = Localizations.localeOf(context).toString();
    final timeFmt = DateFormat.jm(localeTag);

    final req = BookingRecommendationRequest(
      salonId: salonId,
      serviceId: serviceId,
      selectedLocalDay: selectedLocalDay,
      preferredBarberId: preferredBarberId,
    );
    final async = ref.watch(bookingRecommendationProvider(req));

    return async.when(
      loading: () =>
          const SizedBox(height: 4, child: LinearProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerRecommendationsTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            _RecommendationTile(
              title: l10n.customerRecommendationBest,
              rec: result.bestOverall,
              timeFmt: timeFmt,
              l10n: l10n,
              scheme: scheme,
              theme: theme,
              onTap: () => onPick(
                result.bestOverall.employeeId,
                result.bestOverall.slotStartUtc,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            _RecommendationTile(
              title: l10n.customerRecommendationFastest,
              rec: result.fastestAvailable,
              timeFmt: timeFmt,
              l10n: l10n,
              scheme: scheme,
              theme: theme,
              onTap: () => onPick(
                result.fastestAvailable.employeeId,
                result.fastestAvailable.slotStartUtc,
              ),
            ),
            if (result.preferredBarber != null) ...[
              const SizedBox(height: AppSpacing.small),
              _RecommendationTile(
                title: l10n.customerRecommendationPreferred,
                rec: result.preferredBarber!,
                timeFmt: timeFmt,
                l10n: l10n,
                scheme: scheme,
                theme: theme,
                onTap: () => onPick(
                  result.preferredBarber!.employeeId,
                  result.preferredBarber!.slotStartUtc,
                ),
              ),
            ],
            if (result.alternatives.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Text(
                l10n.customerRecommendationAlternatives,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              ...result.alternatives.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: _RecommendationTile(
                    title: formatTeamMemberName(a.barberName),
                    rec: a,
                    timeFmt: timeFmt,
                    l10n: l10n,
                    scheme: scheme,
                    theme: theme,
                    dense: true,
                    onTap: () => onPick(a.employeeId, a.slotStartUtc),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.large),
          ],
        );
      },
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({
    required this.title,
    required this.rec,
    required this.timeFmt,
    required this.l10n,
    required this.scheme,
    required this.theme,
    required this.onTap,
    this.dense = false,
  });

  final String title;
  final BookingRecommendation rec;
  final DateFormat timeFmt;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final local = rec.slotStartUtc.toLocal();
    final reasons = rec.reasons.toSet().toList();
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(dense ? AppSpacing.small : AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.customerRecommendationUseSlot(
                  timeFmt.format(local),
                  formatTeamMemberName(rec.barberName),
                ),
                style: theme.textTheme.bodyMedium,
              ),
              if (reasons.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: reasons
                      .map(
                        (r) => Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          label: Text(
                            recommendationReasonLabel(r, l10n),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
