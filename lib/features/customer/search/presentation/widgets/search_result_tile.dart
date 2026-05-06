import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../customer_home/presentation/theme/zurano_customer_colors.dart';
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

  bool get _showRating {
    final r = result.ratingAvg;
    return r != null && r > 0;
  }

  static bool _validImageUrl(String? u) {
    if (u == null || u.trim().isEmpty) return false;
    final s = u.trim().toLowerCase();
    return s.startsWith('https://') || s.startsWith('http://');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        elevation: 3,
        shadowColor: ZuranoCustomerColors.primary.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: ZuranoCustomerColors.lavenderOutline.withValues(alpha: 0.22),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Wired when salon profile route is finalized for search.
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 156,
                  width: double.infinity,
                  child: _validImageUrl(result.imageUrl)
                      ? CachedNetworkImage(
                          imageUrl: result.imageUrl!.trim(),
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 200),
                          placeholder: (_, _) => _coverPlaceholder(context),
                          errorWidget: (_, _, _) => _coverPlaceholder(context),
                        )
                      : _coverPlaceholder(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            result.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: ZuranoCustomerColors.textStrong,
                                  height: 1.2,
                                ),
                          ),
                        ),
                        if (_showRating) ...[
                          const SizedBox(width: 10),
                          _RatingBlock(
                            rating: result.ratingAvg!,
                            count: result.ratingCount,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ZuranoCustomerColors.textMuted,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(
                          label: result.isOpenNow
                              ? l10n.customerSalonOpenNowBadge
                              : l10n.customerSalonClosedBadge,
                          isPositive: result.isOpenNow,
                        ),
                        if (result.hasOffer)
                          _ZuranoMiniChip(
                            label: l10n.customerSearchPlaceOfferBadge,
                            icon: Icons.local_offer_rounded,
                            filled: true,
                          ),
                        if (result.distanceKm != null)
                          _ZuranoMiniChip(
                            label: l10n.customerMapDistanceKm(
                              result.distanceKm!.toStringAsFixed(1),
                            ),
                            icon: Icons.near_me_rounded,
                            filled: false,
                          ),
                      ],
                    ),
                    if (result.priceFrom != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.customerSearchPlacePriceFrom(
                          _formatPrice(result.priceFrom!),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ZuranoCustomerColors.textStrong,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                    if ((result.serviceCount != null && result.serviceCount! > 0) ||
                        (result.teamCount != null && result.teamCount! > 0)) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (result.serviceCount != null && result.serviceCount! > 0) ...[
                            Icon(
                              Icons.spa_rounded,
                              size: 18,
                              color: ZuranoCustomerColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.customerSearchPlaceServicesCount(result.serviceCount!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ZuranoCustomerColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                          if (result.serviceCount != null &&
                              result.serviceCount! > 0 &&
                              result.teamCount != null &&
                              result.teamCount! > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: ZuranoCustomerColors.textMuted.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          if (result.teamCount != null && result.teamCount! > 0) ...[
                            Icon(
                              Icons.groups_rounded,
                              size: 18,
                              color: ZuranoCustomerColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.customerSearchPlaceTeamCount(result.teamCount!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ZuranoCustomerColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPrice(num p) {
    if (p == p.roundToDouble()) {
      return p.round().toString();
    }
    return p.toStringAsFixed(1);
  }

  Widget _coverPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZuranoCustomerColors.lavenderSoft,
            ZuranoCustomerColors.primary.withValues(alpha: 0.12),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 52,
        color: ZuranoCustomerColors.primary.withValues(alpha: 0.55),
      ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? const Color(0xFFDCFCE7)
            : ZuranoCustomerColors.borderHairline,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isPositive ? const Color(0xFF166534) : ZuranoCustomerColors.textMuted,
            ),
      ),
    );
  }
}

class _ZuranoMiniChip extends StatelessWidget {
  const _ZuranoMiniChip({
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                colors: [
                  ZuranoCustomerColors.primary,
                  ZuranoCustomerColors.headerGradientEnd,
                ],
              )
            : null,
        color: filled ? null : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled
              ? Colors.transparent
              : ZuranoCustomerColors.lavenderOutline.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: filled ? Colors.white : ZuranoCustomerColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: filled ? Colors.white : ZuranoCustomerColors.textStrong,
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
          onTap: () {},
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
