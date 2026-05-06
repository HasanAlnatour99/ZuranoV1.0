import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class PlaceImageHeader extends StatelessWidget {
  const PlaceImageHeader({
    super.key,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceOverlayLine,
    required this.showDistanceOverlay,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String distanceOverlayLine;
  final bool showDistanceOverlay;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: PlaceDiscoveryColors.primarySoft,
              ),
              errorWidget: (_, _, _) {
                return Container(
                  color: PlaceDiscoveryColors.primarySoft,
                  child: const Center(
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 48,
                      color: PlaceDiscoveryColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.00),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: _RatingOverlay(
              rating: rating,
              reviewCount: reviewCount,
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onTap: onFavoriteTap,
            ),
          ),

          if (showDistanceOverlay)
            Positioned(
              left: 16,
              bottom: 16,
              right: 96,
              child: _DistanceOverlay(distanceText: distanceOverlayLine),
            ),
        ],
      ),
    );
  }
}

class _RatingOverlay extends StatelessWidget {
  const _RatingOverlay({
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: PlaceDiscoveryColors.gold, size: 20),
          const SizedBox(width: 6),
          if (reviewCount > 0) ...[
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              height: 16,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white.withValues(alpha: 0.45),
            ),
            Flexible(
              child: Text(
                l10n.placeCardReviewsCount(reviewCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else
            Text(
              l10n.placeCardNewLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _DistanceOverlay extends StatelessWidget {
  const _DistanceOverlay({required this.distanceText});

  final String distanceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.43),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              distanceText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          width: 52,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: PlaceDiscoveryColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
