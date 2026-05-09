import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/salon_map_item.dart';
import '../map_distance_label.dart';
import '../providers/customer_map_providers.dart';

class NearbyPlacesBottomSheet extends ConsumerWidget {
  const NearbyPlacesBottomSheet({
    super.key,
    required this.onSelectSalon,
    required this.onBookSalon,
    required this.onUseMyLocation,
    required this.onExpandRadius,
  });

  final ValueChanged<SalonMapItem> onSelectSalon;
  final ValueChanged<SalonMapItem> onBookSalon;
  final VoidCallback onUseMyLocation;
  final VoidCallback onExpandRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final nearby = ref.watch(nearbyPublicSalonsProvider);
    final radiusKm = ref.watch(mapRadiusKmProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.24,
      minChildSize: 0.14,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.customerMapNearbySheetTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Text(
                      l10n.customerMapRadiusLabelKm(
                        radiusKm % 1 == 0
                            ? radiusKm.toInt().toString()
                            : radiusKm.toStringAsFixed(1),
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: nearby.isEmpty
                    ? _EmptyState(
                        l10n: l10n,
                        scheme: scheme,
                        onUseMyLocation: onUseMyLocation,
                        onExpandRadius: onExpandRadius,
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: nearby.length,
                        itemBuilder: (context, index) {
                          final salon = nearby[index];
                          return _SalonMapListTile(
                            salon: salon,
                            l10n: l10n,
                            onTap: () => onSelectSalon(salon),
                            onBook: () => onBookSalon(salon),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l10n,
    required this.scheme,
    required this.onUseMyLocation,
    required this.onExpandRadius,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final VoidCallback onUseMyLocation;
  final VoidCallback onExpandRadius;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.customerMapNoPlacesSheetTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.customerMapNoPlacesSheetBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onUseMyLocation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.customerMapUseMyLocation,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onExpandRadius,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppBrandColors.primary,
                    foregroundColor: AppBrandColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.customerMapExpandRadius,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalonMapListTile extends StatelessWidget {
  const _SalonMapListTile({
    required this.salon,
    required this.l10n,
    required this.onTap,
    required this.onBook,
  });

  final SalonMapItem salon;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final distance = customerMapDistanceLabel(l10n, salon);
    final imageUrl = salon.imageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? ColoredBox(
                            color: scheme.primaryContainer.withValues(alpha: 0.45),
                            child: Icon(Icons.storefront_rounded, color: scheme.primary),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => ColoredBox(
                              color: scheme.primaryContainer.withValues(alpha: 0.45),
                              child: Icon(Icons.storefront_rounded, color: scheme.primary),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salon.locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: scheme.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.customerMapRatingSummary(
                              salon.ratingAvg.toStringAsFixed(1),
                              salon.ratingCount.toString(),
                            ),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (distance.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(color: scheme.outline),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                distance,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppBrandColors.primary,
                    foregroundColor: AppBrandColors.onPrimary,
                    minimumSize: const Size(72, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.zuranoNearbyBookNow,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
