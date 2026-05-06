import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/customer_place_model.dart';
import 'place_image_header.dart';
import 'place_meta_row.dart';
import 'place_price_footer.dart';
import 'place_status_chip.dart';

/// Visual density for [PremiumPlaceCard].
enum PlaceCardVariant {
  large,
  compact,
  mapPreview,
}

/// Premium discovery tile — reusable on home, search, map sheet, favorites, etc.
class PremiumPlaceCard extends StatelessWidget {
  const PremiumPlaceCard({
    super.key,
    required this.place,
    required this.distanceOverlayLine,
    required this.distanceMetaTitle,
    required this.showDistanceOverlay,
    required this.isFavorite,
    required this.isClosed,
    required this.onTap,
    required this.onFavoriteTap,
    this.variant = PlaceCardVariant.large,
  });

  const PremiumPlaceCard.large({
    Key? key,
    required CustomerPlaceModel place,
    required String distanceOverlayLine,
    required String distanceMetaTitle,
    required bool showDistanceOverlay,
    required bool isFavorite,
    required bool isClosed,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTap,
  }) : this(
          key: key,
          place: place,
          distanceOverlayLine: distanceOverlayLine,
          distanceMetaTitle: distanceMetaTitle,
          showDistanceOverlay: showDistanceOverlay,
          isFavorite: isFavorite,
          isClosed: isClosed,
          onTap: onTap,
          onFavoriteTap: onFavoriteTap,
          variant: PlaceCardVariant.large,
        );

  const PremiumPlaceCard.compact({
    Key? key,
    required CustomerPlaceModel place,
    required String distanceOverlayLine,
    required String distanceMetaTitle,
    required bool showDistanceOverlay,
    required bool isFavorite,
    required bool isClosed,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTap,
  }) : this(
          key: key,
          place: place,
          distanceOverlayLine: distanceOverlayLine,
          distanceMetaTitle: distanceMetaTitle,
          showDistanceOverlay: showDistanceOverlay,
          isFavorite: isFavorite,
          isClosed: isClosed,
          onTap: onTap,
          onFavoriteTap: onFavoriteTap,
          variant: PlaceCardVariant.compact,
        );

  const PremiumPlaceCard.mapPreview({
    Key? key,
    required CustomerPlaceModel place,
    required String distanceOverlayLine,
    required String distanceMetaTitle,
    required bool showDistanceOverlay,
    required bool isFavorite,
    required bool isClosed,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTap,
  }) : this(
          key: key,
          place: place,
          distanceOverlayLine: distanceOverlayLine,
          distanceMetaTitle: distanceMetaTitle,
          showDistanceOverlay: showDistanceOverlay,
          isFavorite: isFavorite,
          isClosed: isClosed,
          onTap: onTap,
          onFavoriteTap: onFavoriteTap,
          variant: PlaceCardVariant.mapPreview,
        );

  final CustomerPlaceModel place;
  final String distanceOverlayLine;
  final String distanceMetaTitle;
  final bool showDistanceOverlay;
  final bool isFavorite;
  final bool isClosed;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final PlaceCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (variant) {
      case PlaceCardVariant.compact:
      case PlaceCardVariant.mapPreview:
        return _PremiumCompactPlaceCard(
          place: place,
          distanceMetaTitle: distanceMetaTitle,
          showDistanceOverlay: showDistanceOverlay,
          distanceOverlayLine: distanceOverlayLine,
          isFavorite: isFavorite,
          isClosed: isClosed,
          onTap: onTap,
          onFavoriteTap: onFavoriteTap,
        );
      case PlaceCardVariant.large:
        return _PremiumLargePlaceCard(
          place: place,
          distanceOverlayLine: distanceOverlayLine,
          distanceMetaTitle: distanceMetaTitle,
          showDistanceOverlay: showDistanceOverlay,
          isFavorite: isFavorite,
          isClosed: isClosed,
          onTap: onTap,
          onFavoriteTap: onFavoriteTap,
          locale: locale,
        );
    }
  }
}

/// Hero / detail-style tall card (original design).
class _PremiumLargePlaceCard extends StatelessWidget {
  const _PremiumLargePlaceCard({
    required this.place,
    required this.distanceOverlayLine,
    required this.distanceMetaTitle,
    required this.showDistanceOverlay,
    required this.isFavorite,
    required this.isClosed,
    required this.onTap,
    required this.onFavoriteTap,
    required this.locale,
  });

  final CustomerPlaceModel place;
  final String distanceOverlayLine;
  final String distanceMetaTitle;
  final bool showDistanceOverlay;
  final bool isFavorite;
  final bool isClosed;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: PlaceDiscoveryColors.card,
            borderRadius: BorderRadius.circular(AppRadius.placeXxl),
            boxShadow: AppShadows.premiumPlaceCard,
            border: Border.all(color: PlaceDiscoveryColors.border),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.placeXxl),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.placeXxl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.placeXxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlaceImageHeader(
                      imageUrl: place.coverImageUrl,
                      rating: place.ratingAvg,
                      reviewCount: place.ratingCount,
                      distanceOverlayLine: distanceOverlayLine,
                      showDistanceOverlay: showDistanceOverlay,
                      isFavorite: isFavorite,
                      onFavoriteTap: onFavoriteTap,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _TitleAndLocation(
                                  place: place,
                                  locale: locale,
                                  compactTitle: narrow,
                                ),
                              ),
                              const SizedBox(width: 12),
                              PlaceStatusChip(isClosed: isClosed),
                            ],
                          ),
                          const SizedBox(height: 22),
                          PlaceMetaRow(
                            rating: place.ratingAvg,
                            reviewCount: place.ratingCount,
                            distanceMetaTitle: distanceMetaTitle,
                            typeKey: place.type,
                          ),
                        ],
                      ),
                    ),
                    PlacePriceFooter(
                      currencyCode: place.currency,
                      amountText: place.formattedMinPriceAmount,
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

const double _kCompactThumbSize = 96;

/// Dense list row (~100–112px): fits ~5 cards per typical phone viewport when scrolling.
class _PremiumCompactPlaceCard extends StatelessWidget {
  const _PremiumCompactPlaceCard({
    required this.place,
    required this.distanceMetaTitle,
    required this.showDistanceOverlay,
    required this.distanceOverlayLine,
    required this.isFavorite,
    required this.isClosed,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final CustomerPlaceModel place;
  final String distanceMetaTitle;
  final bool showDistanceOverlay;
  final String distanceOverlayLine;
  final bool isFavorite;
  final bool isClosed;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locRaw = place.displayLocation.trim();
    final loc =
        locRaw.isEmpty ? l10n.placeCardLocationUnavailable : locRaw;
    final typeLabel = _formatTypeLabel(context, place.type);

    final hasDistance = _hasUsableDistance(l10n, distanceMetaTitle);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: PlaceDiscoveryColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PlaceDiscoveryColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: PlaceDiscoveryColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CompactThumbnail(
                  imageUrl: place.coverImageUrl,
                  distanceLabel:
                      showDistanceOverlay ? distanceOverlayLine : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: PlaceDiscoveryColors.textPrimary,
                                letterSpacing: -0.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          PlaceStatusChip(
                            isClosed: isClosed,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: PlaceDiscoveryColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: PlaceDiscoveryColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            place.ratingAvg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: PlaceDiscoveryColors.gold,
                            ),
                          ),
                          if (place.ratingCount > 0) ...[
                            const Text(
                              ' · ',
                              style: TextStyle(
                                fontSize: 12,
                                color: PlaceDiscoveryColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                l10n.placeCardReviewsCount(place.ratingCount),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PlaceDiscoveryColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 12,
                              color: PlaceDiscoveryColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _distanceTypeLine(
                                l10n: l10n,
                                distanceMetaTitle: distanceMetaTitle,
                                typeLabel: typeLabel,
                                hasDistance: hasDistance,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: hasDistance
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: hasDistance
                                    ? PlaceDiscoveryColors.textPrimary
                                    : PlaceDiscoveryColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.placePriceFromLabel} ${place.currency} ${place.formattedMinPriceAmount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: PlaceDiscoveryColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: PlaceDiscoveryColors.primarySoft,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteTap,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: PlaceDiscoveryColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: onTap,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: PlaceDiscoveryColors.primaryDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTypeLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.trim().isEmpty) {
      return l10n.placeCardPremiumFallback;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  bool _hasUsableDistance(
    AppLocalizations l10n,
    String distanceMetaTitle,
  ) {
    final t = distanceMetaTitle.trim();
    if (t.isEmpty) {
      return false;
    }
    if (t == l10n.placeCardDistanceUnavailable) {
      return false;
    }
    return true;
  }

  /// Distance (km) when available, else em dash; always shows venue [type] after a separator.
  String _distanceTypeLine({
    required AppLocalizations l10n,
    required String distanceMetaTitle,
    required String typeLabel,
    required bool hasDistance,
  }) {
    final dist = hasDistance
        ? distanceMetaTitle
        : l10n.placeCardDistanceUnavailable;
    return '$dist · $typeLabel';
  }
}

class _CompactThumbnail extends StatelessWidget {
  const _CompactThumbnail({
    required this.imageUrl,
    this.distanceLabel,
  });

  final String imageUrl;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: _kCompactThumbSize.toDouble(),
        height: _kCompactThumbSize.toDouble(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.trim().isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl.trim(),
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: PlaceDiscoveryColors.primarySoft,
                ),
                errorWidget: (_, _, _) => Container(
                  color: PlaceDiscoveryColors.primarySoft,
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: PlaceDiscoveryColors.primary,
                    size: 36,
                  ),
                ),
              )
            else
              Container(
                color: PlaceDiscoveryColors.primarySoft,
                child: const Icon(
                  Icons.storefront_rounded,
                  color: PlaceDiscoveryColors.primary,
                  size: 36,
                ),
              ),
            if (distanceLabel != null && distanceLabel!.trim().isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.58),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            distanceLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TitleAndLocation extends StatelessWidget {
  const _TitleAndLocation({
    required this.place,
    required this.locale,
    required this.compactTitle,
  });

  final CustomerPlaceModel place;
  final Locale locale;
  final bool compactTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = AppTextStyles.placeCardTitle(
      PlaceDiscoveryColors.textPrimary,
      locale: locale,
    ).copyWith(fontSize: compactTitle ? 24 : null);

    final locRaw = place.displayLocation.trim();
    final loc =
        locRaw.isEmpty ? l10n.placeCardLocationUnavailable : locRaw;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: PlaceDiscoveryColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                loc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: PlaceDiscoveryColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
