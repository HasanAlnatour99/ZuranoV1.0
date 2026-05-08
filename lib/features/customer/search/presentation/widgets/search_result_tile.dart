import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../../l10n/app_localizations.dart';
import '../../../../customer_home/presentation/theme/zurano_customer_colors.dart';
import '../../../discovery/presentation/widgets/premium_place_card.dart';
import '../../domain/customer_search_result_place_mapper.dart';
import '../../domain/models/customer_search_result.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.result});

  final CustomerSearchResult result;

  @override
  Widget build(BuildContext context) {
    return switch (result.type) {
      CustomerSearchResultType.salon => _SearchSalonPlaceCard(result: result),
      _ => _SearchCompactResultCard(result: result),
    };
  }
}

class _SearchSalonPlaceCard extends StatelessWidget {
  const _SearchSalonPlaceCard({required this.result});

  final CustomerSearchResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final place = result.toCustomerPlaceModel();

    final String overlay;
    final String metaKm;
    final bool showDist;
    final dk = result.distanceKm;
    if (dk != null) {
      final rounded = dk >= 10 ? dk.toStringAsFixed(0) : dk.toStringAsFixed(1);
      overlay = l10n.placeCardDistanceKmAway(rounded);
      metaKm = l10n.placeCardDistanceKmOnly(rounded);
      showDist = true;
    } else {
      overlay = l10n.placeCardDistanceUnavailable;
      metaKm = l10n.placeCardDistanceUnavailable;
      showDist = false;
    }

    final isClosed = !result.isOpenNow;

    return PremiumPlaceCard.compact(
      place: place,
      distanceOverlayLine: overlay,
      distanceMetaTitle: metaKm,
      showDistanceOverlay: showDist,
      isFavorite: false,
      isClosed: isClosed,
      onTap: () {
        context.pushNamed(
          AppRouteNames.customerSalonProfile,
          pathParameters: {'salonId': result.salonId},
        );
      },
      onFavoriteTap: () {
        // TODO: wire customer favorites (local / sync).
      },
    );
  }
}

class _RatingBlock extends StatelessWidget {
  const _RatingBlock({required this.rating, this.count});

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final avg = rating.toStringAsFixed(1);
    final summary = (count != null && count! > 0)
        ? AppLocalizations.of(context)!.customerMapRatingSummary(
              avg,
              count.toString(),
            )
        : avg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ZuranoCustomerColors.lavenderSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 18,
            color: ZuranoCustomerColors.primary.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 4),
          Text(
            summary,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ZuranoCustomerColors.textStrong,
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchCompactResultCard extends StatelessWidget {
  const _SearchCompactResultCard({required this.result});

  final CustomerSearchResult result;

  bool get _showRating {
    final r = result.ratingAvg;
    return r != null && r > 0;
  }

  static bool _validImageUrl(String? u) {
    if (u == null || u.trim().isEmpty) return false;
    final s = u.trim().toLowerCase();
    return s.startsWith('https://') || s.startsWith('http://');
  }

  /// Service / specialist taps deep-link into the customer salon profile so
  /// users always land in the same context as a salon tap. The `targetId` is
  /// passed as a query parameter so the salon profile can preselect the
  /// service or specialist (and forward into booking when the user continues).
  void _handleTap(BuildContext context) {
    final salonId = result.salonId.trim();
    if (salonId.isEmpty) {
      return;
    }
    final extras = <String, String>{};
    switch (result.type) {
      case CustomerSearchResultType.service:
        if (result.targetId.trim().isNotEmpty) {
          extras['serviceId'] = result.targetId.trim();
        }
        break;
      case CustomerSearchResultType.specialist:
        if (result.targetId.trim().isNotEmpty) {
          extras['employeeId'] = result.targetId.trim();
        }
        break;
      case CustomerSearchResultType.salon:
        break;
    }

    context.pushNamed(
      AppRouteNames.customerSalonProfile,
      pathParameters: {'salonId': salonId},
      queryParameters: extras,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leading = _iconForType(result.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: ZuranoCustomerColors.lavenderOutline.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: _validImageUrl(result.imageUrl)
                        ? CachedNetworkImage(
                            imageUrl: result.imageUrl!.trim(),
                            fit: BoxFit.cover,
                            placeholder: (_, _) => _smallPlaceholder(leading),
                            errorWidget: (_, _, _) => _smallPlaceholder(leading),
                          )
                        : _smallPlaceholder(leading),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ZuranoCustomerColors.textStrong,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ZuranoCustomerColors.textMuted,
                            ),
                      ),
                      if (result.distanceKm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.customerMapDistanceKm(
                            result.distanceKm!.toStringAsFixed(1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: ZuranoCustomerColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_showRating)
                  _RatingBlock(
                    rating: result.ratingAvg!,
                    count: result.ratingCount,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallPlaceholder(IconData icon) {
    return Container(
      color: ZuranoCustomerColors.lavenderSoft,
      alignment: Alignment.center,
      child: Icon(icon, color: ZuranoCustomerColors.primary.withValues(alpha: 0.75)),
    );
  }

  IconData _iconForType(CustomerSearchResultType type) {
    return switch (type) {
      CustomerSearchResultType.salon => Icons.storefront_outlined,
      CustomerSearchResultType.service => Icons.content_cut_rounded,
      CustomerSearchResultType.specialist => Icons.person_outline_rounded,
    };
  }
}
