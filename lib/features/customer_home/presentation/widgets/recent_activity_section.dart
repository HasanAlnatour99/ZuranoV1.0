import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes, AppRouteNames;
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/last_booked_model.dart';
import '../../data/models/recently_viewed_salon_model.dart';
import '../controllers/customer_home_providers.dart';
import 'customer_section_header.dart';

class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lastBookedAsync = ref.watch(lastBookedProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedSalonsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoRecentActivityTitle,
          actionLabel: l10n.zuranoDiscoverSeeAll,
          leading: Icons.history_rounded,
          onAction: () {},
        ),
        const SizedBox(height: 14),
        lastBookedAsync.when(
          data: (last) => last == null
              ? const SizedBox.shrink()
              : _LastBookedCard(
                  model: last,
                  onView: () {
                    final bookingId = last.bookingId?.trim();
                    if (bookingId != null && bookingId.isNotEmpty) {
                      context.pushNamed(
                        AppRouteNames.customerBookingDetails,
                        pathParameters: {
                          'salonId': last.salonId,
                          'bookingId': bookingId,
                        },
                      );
                    } else {
                      context.go(AppRoutes.customerMyBooking);
                    }
                  },
                  viewLabel: l10n.zuranoLastBookedViewBooking,
                  codeLabel: l10n.zuranoLastBookedCodeLabel,
                ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        recentlyViewedAsync.when(
          data: (list) {
            if (list.isEmpty) {
              final hasLast = lastBookedAsync.maybeWhen(
                data: (v) => v != null,
                orElse: () => false,
              );
              if (hasLast) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  l10n.zuranoRecentActivityEmpty,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final salon = list[index];
                  return _RecentlyViewedCard(
                    model: salon,
                    onTap: () {
                      context.pushNamed(
                        AppRouteNames.customerSalonProfile,
                        pathParameters: {'salonId': salon.salonId},
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 118),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _LastBookedCard extends StatelessWidget {
  const _LastBookedCard({
    required this.model,
    required this.onView,
    required this.viewLabel,
    required this.codeLabel,
  });

  final LastBookedModel model;
  final VoidCallback onView;
  final String viewLabel;
  final String codeLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final subtitleParts = <String>[
      if (model.serviceName?.trim().isNotEmpty == true) model.serviceName!.trim(),
      if (model.bookingDateText.trim().isNotEmpty) model.bookingDateText.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          onTap: onView,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: scheme.primary),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.isEmpty ? '—' : subtitleParts.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$codeLabel: ${model.bookingCode}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                TextButton(
                  onPressed: onView,
                  child: Text(viewLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentlyViewedCard extends StatelessWidget {
  const _RecentlyViewedCard({required this.model, required this.onTap});

  final RecentlyViewedSalonModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cover = model.coverImageUrl?.trim();
    final hasCover = cover != null && cover.isNotEmpty;

    return SizedBox(
      width: 220,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 86,
                height: double.infinity,
                child: hasCover
                    ? AppNetworkImage(imageUrl: cover, fit: BoxFit.cover)
                    : ColoredBox(color: scheme.surfaceContainerHighest),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        model.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.area?.trim().isNotEmpty == true ? model.area!.trim() : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

