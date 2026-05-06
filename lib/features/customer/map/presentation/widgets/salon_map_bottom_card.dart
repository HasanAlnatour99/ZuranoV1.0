import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/salon_map_item.dart';
import '../map_distance_label.dart';

class SalonMapBottomCard extends StatelessWidget {
  const SalonMapBottomCard({
    super.key,
    required this.salon,
    required this.onViewDetails,
    required this.onBookNow,
  });

  final SalonMapItem salon;
  final VoidCallback onViewDetails;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final imageUrl = salon.imageUrl;
    final distanceText = customerMapDistanceLabel(l10n, salon);

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(28),
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: 92,
                height: 112,
                child: imageUrl == null || imageUrl.isEmpty
                    ? ColoredBox(
                        color: scheme.primaryContainer.withValues(alpha: 0.5),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: scheme.primary,
                          size: 34,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) {
                          return ColoredBox(
                            color: scheme.primaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: scheme.primary,
                              size: 34,
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            salon.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        _OpenStatusPill(
                          status: salon.openStatus,
                          l10n: l10n,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            salon.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: scheme.tertiary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.customerMapRatingSummary(
                            salon.ratingAvg.toStringAsFixed(1),
                            salon.ratingCount.toString(),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (distanceText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              distanceText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onViewDetails,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.primary,
                              side: BorderSide(
                                color: scheme.primary.withValues(alpha: 0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              l10n.customerMapDetailsCta,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: onBookNow,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppBrandColors.primary,
                              foregroundColor: AppBrandColors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              l10n.zuranoNearbyBookNow,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
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
    );
  }
}

class _OpenStatusPill extends StatelessWidget {
  const _OpenStatusPill({
    required this.status,
    required this.l10n,
  });

  final String status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase().trim();

    final isOpen = normalized == 'open';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? scheme.tertiaryContainer.withValues(alpha: 0.6)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? l10n.customerMapStatusOpen : l10n.customerMapStatusSoon,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isOpen
                  ? scheme.onTertiaryContainer
                  : scheme.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
