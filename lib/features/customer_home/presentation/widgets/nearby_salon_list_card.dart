import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../data/models/customer_salon_preview_model.dart';
import '../../domain/customer_geo.dart';
import '../controllers/customer_home_providers.dart'
    show
        customerHomeRepositoryProvider,
        favoriteSalonIdsProvider;
import '../theme/zurano_customer_colors.dart';

class NearbySalonListCard extends ConsumerWidget {
  const NearbySalonListCard({
    super.key,
    required this.salon,
    required this.onBookNow,
    required this.onOpen,
    this.userPosition,
  });

  final CustomerSalonPreviewModel salon;
  final VoidCallback onBookNow;
  final VoidCallback onOpen;
  final Position? userPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cover = salon.coverImageUrl.trim();
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final favAsync = ref.watch(favoriteSalonIdsProvider);
    final isFavorite = favAsync.maybeWhen(
      data: (ids) => ids.contains(salon.salonId),
      orElse: () => false,
    );

    final dk = calculateDistanceKm(
      userLat: userPosition?.latitude,
      userLng: userPosition?.longitude,
      salonLat: salon.latitude,
      salonLng: salon.longitude,
    );

    final locationLine = _locationLine(l10n, dk);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ZuranoCustomerColors.borderHairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 118,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: cover.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: cover,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    _fallbackThumb(),
                                placeholder: (context, url) => Container(
                                  color: ZuranoCustomerColors.lavenderSoft,
                                ),
                              )
                            : _fallbackThumb(),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Material(
                          shape: const CircleBorder(),
                          color: Colors.white.withValues(alpha: 0.94),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: uid == null || uid.isEmpty
                                ? null
                                : () async {
                                    await ref
                                        .read(customerHomeRepositoryProvider)
                                        .toggleFavorite(
                                          uid: uid,
                                          salonId: salon.salonId,
                                          currentlyFavorite: isFavorite,
                                        );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                size: 18,
                                color: ZuranoCustomerColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.salonName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: ZuranoCustomerColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationLine,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: ZuranoCustomerColors.textMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '★ ${salon.ratingAvg.toStringAsFixed(1)} (${salon.ratingCount})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ZuranoCustomerColors.textStrong,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 116,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    backgroundColor: ZuranoCustomerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onBookNow,
                  child: Text(
                    l10n.zuranoNearbyBookNow,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _locationLine(AppLocalizations l10n, double? dk) {
    final geo = salon.locationLabel;
    if (dk != null && dk <= kCustomerNearbyDistanceDisplayMaxKm) {
      final kmLabel = dk.toStringAsFixed(1);
      if (geo.isNotEmpty) {
        return l10n.zuranoNearbyLocationLineKm(geo, kmLabel);
      }
      return l10n.zuranoNearbyKilometersOnly(kmLabel);
    }
    return geo;
  }

  Widget _fallbackThumb() {
    return Container(
      color: ZuranoCustomerColors.lavenderSoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        color: ZuranoCustomerColors.primary,
      ),
    );
  }
}
