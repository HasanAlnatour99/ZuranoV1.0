import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../data/models/public_salon_model.dart';
import '../controllers/customer_home_providers.dart'
    show customerHomeRepositoryProvider, favoriteSalonIdsProvider;
import '../models/customer_home_ui_models.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import '../utils/customer_home_ui_mappers.dart';

class ZuranoNearbyPlaceCard extends ConsumerWidget {
  const ZuranoNearbyPlaceCard({
    super.key,
    required this.salon,
    required this.userPosition,
    required this.onBookNow,
    required this.onOpenDetail,
  });

  final PublicSalonModel salon;
  final Position? userPosition;
  final VoidCallback onBookNow;
  final VoidCallback onOpenDetail;

  static const double _imageW = 116;
  static const double _imageH = 104;
  static const double _actionColW = 116;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ui = mapPublicSalonToNearbyPlaceUi(salon, userPosition);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final favAsync = ref.watch(favoriteSalonIdsProvider);
    final isFavorite = favAsync.maybeWhen(
      data: (ids) => ids.contains(salon.salonId),
      orElse: () => false,
    );

    final cover = ui.imageUrl.trim();
    final cityCountry = _cityCountryLine(ui);
    final kmText = ui.distanceKm?.toStringAsFixed(1);

    final locationLine = kmText != null && cityCountry.isNotEmpty
        ? l10n.zuranoNearbyLocationLineKm(cityCountry, kmText)
        : (cityCountry.isNotEmpty
              ? cityCountry
              : (kmText != null ? l10n.zuranoNearbyKilometersOnly(kmText) : '—'));

    final showNumericRating = ui.reviewCount > 0 || ui.rating > 0.05;

    final tags = ui.tags.take(3).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onOpenDetail,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _imageW,
                  height: _imageH,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        cover.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: cover,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: ZuranoCustomerHomeColors.lavender,
                                ),
                                errorWidget: (_, _, _) => _fallbackThumb(),
                              )
                            : _fallbackThumb(),
                        PositionedDirectional(
                          end: 6,
                          top: 6,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: const CircleBorder(),
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
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: ZuranoCustomerHomeColors.primary,
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
                        ui.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ZuranoCustomerHomeColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: ZuranoCustomerHomeColors.mutedText,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              locationLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ZuranoCustomerHomeColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        showNumericRating
                            ? l10n.zuranoNearbyRatingLine(
                                ui.rating.toStringAsFixed(1),
                                ui.reviewCount,
                              )
                            : l10n.customerHomeNewSalonBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: showNumericRating
                              ? ZuranoCustomerHomeColors.darkText
                              : ZuranoCustomerHomeColors.primary,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tags
                              .map(
                                (t) => Container(
                                  constraints: const BoxConstraints(maxWidth: 96),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ZuranoCustomerHomeColors.lavender,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: ZuranoCustomerHomeColors.primary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: _actionColW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: onBookNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: ZuranoCustomerHomeColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(42),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          l10n.zuranoNearbyBookNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ui.isOpenNow
                                  ? ZuranoCustomerHomeColors.success
                                  : ZuranoCustomerHomeColors.mutedText,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              ui.isOpenNow
                                  ? l10n.zuranoNearbyOpenNow
                                  : l10n.zuranoNearbyClosed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ui.isOpenNow
                                    ? ZuranoCustomerHomeColors.success
                                    : ZuranoCustomerHomeColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cityCountryLine(NearbyPlaceUi ui) {
    final c = ui.city.trim();
    final co = ui.country.trim();
    if (c.isNotEmpty && co.isNotEmpty) {
      return '$c, $co';
    }
    if (c.isNotEmpty) return c;
    return co;
  }

  Widget _fallbackThumb() {
    return Container(
      color: ZuranoCustomerHomeColors.lavender,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        color: ZuranoCustomerHomeColors.primary.withValues(alpha: 0.75),
      ),
    );
  }
}
