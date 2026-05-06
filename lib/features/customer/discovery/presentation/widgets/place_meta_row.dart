import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class PlaceMetaRow extends StatelessWidget {
  const PlaceMetaRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.distanceMetaTitle,
    required this.typeKey,
  });

  final double rating;
  final int reviewCount;
  final String distanceMetaTitle;
  final String typeKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PlaceDiscoveryColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetaItem(
              icon: Icons.star_border_rounded,
              iconColor: PlaceDiscoveryColors.gold,
              title: rating.toStringAsFixed(1),
              subtitle: l10n.placeCardReviewsCount(reviewCount),
            ),
          ),
          const _Divider(),
          Expanded(
            child: _MetaItem(
              icon: Icons.location_on_outlined,
              iconColor: PlaceDiscoveryColors.primary,
              title: distanceMetaTitle,
              subtitle: l10n.placeCardMetaAwayLabel,
            ),
          ),
          const _Divider(),
          Expanded(
            child: _MetaItem(
              icon: Icons.local_offer_outlined,
              iconColor: PlaceDiscoveryColors.primary,
              title: _formatType(context, typeKey),
              subtitle: l10n.placeCardMetaPlaceLabel,
            ),
          ),
        ],
      ),
    );
  }

  String _formatType(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.trim().isEmpty) {
      return l10n.placeCardPremiumFallback;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PlaceDiscoveryColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: PlaceDiscoveryColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: PlaceDiscoveryColors.border,
    );
  }
}
