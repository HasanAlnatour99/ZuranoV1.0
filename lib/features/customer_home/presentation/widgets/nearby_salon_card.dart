import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_salon_model.dart';
import '../../domain/customer_geo.dart';
import '../theme/zurano_customer_colors.dart';

class NearbySalonCard extends StatefulWidget {
  const NearbySalonCard({
    super.key,
    required this.salon,
    required this.onBookNow,
    required this.onOpen,
    this.calculatedDistanceKm,
    this.onToggleFavorite,
  });

  final CustomerSalonModel salon;

  /// When set (e.g. device GPS + salon coordinates), shown instead of static [CustomerSalonModel.distanceKmText].
  final double? calculatedDistanceKm;
  final VoidCallback onBookNow;
  final VoidCallback onOpen;
  final VoidCallback? onToggleFavorite;

  @override
  State<NearbySalonCard> createState() => _NearbySalonCardState();
}

class _NearbySalonCardState extends State<NearbySalonCard> {
  bool _favorite = false;

  String _cityCountryLine(AppLocalizations l10n, CustomerSalonModel s) {
    final city = s.city.trim();
    final country = s.country.trim();
    if (city.isNotEmpty && country.isNotEmpty) {
      return l10n.zuranoHomeLocationCityCountry(city, country);
    }
    if (city.isNotEmpty) {
      return city;
    }
    if (country.isNotEmpty) {
      return country;
    }
    return '';
  }

  String _locationDistanceLine(AppLocalizations l10n) {
    final s = widget.salon;
    final geo = _cityCountryLine(l10n, s);
    final geoOrLegacy = geo.isNotEmpty ? geo : s.locationLabel;

    final dk = widget.calculatedDistanceKm;
    if (dk != null && dk <= kCustomerNearbyDistanceDisplayMaxKm) {
      final kmLabel = dk.toStringAsFixed(1);
      if (geoOrLegacy.isNotEmpty) {
        return l10n.zuranoNearbyLocationLineKm(geoOrLegacy, kmLabel);
      }
      return l10n.zuranoNearbyKilometersOnly(kmLabel);
    }

    final legacy = s.distanceKmText.trim();
    if (legacy.isNotEmpty && legacy != '—') {
      return geoOrLegacy.isNotEmpty
          ? l10n.zuranoNearbyLocationTwoParts(geoOrLegacy, legacy)
          : legacy;
    }
    return geoOrLegacy;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.salon;
    final cover = s.coverImageUrl.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: widget.onOpen,
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
                            onTap:
                                widget.onToggleFavorite ??
                                () => setState(() => _favorite = !_favorite),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _favorite
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
                      s.name,
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
                        Text(
                          _locationDistanceLine(l10n),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ZuranoCustomerColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '★ ${s.ratingAverage.toStringAsFixed(1)} (${s.ratingCount})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ZuranoCustomerColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: s.tags.take(4).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ZuranoCustomerColors.lavenderSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (s.discountText != null &&
                      s.discountText!.trim().isNotEmpty)
                    Text(
                      s.discountText!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ZuranoCustomerColors.discountGreen,
                      ),
                    ),
                  ElevatedButton(
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
                    onPressed: widget.onBookNow,
                    child: Text(l10n.zuranoNearbyBookNow),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
