import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_location_providers.dart';

class CustomerLocationPill extends ConsumerWidget {
  const CustomerLocationPill({super.key, this.onTap});

  final VoidCallback? onTap;

  static String? _cityLine(AppLocalizations l10n, Placemark pm) {
    String? pick(Iterable<String?> candidates) {
      for (final raw in candidates) {
        final t = raw?.trim();
        if (t != null && t.isNotEmpty) {
          return t;
        }
      }
      return null;
    }

    final city = pick([
      pm.locality,
      pm.subAdministrativeArea,
      pm.administrativeArea,
    ]);
    final country = pm.country?.trim();
    if (city != null && country != null && country.isNotEmpty) {
      return l10n.zuranoHomeLocationCityCountry(city, country);
    }
    if (city != null && city.isNotEmpty) {
      return city;
    }
    if (country != null && country.isNotEmpty) {
      return country;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final placeAsync = ref.watch(customerHomeResolvedPlaceProvider);

    final String label = positionAsync.when(
      loading: () => l10n.zuranoHomeLocationLoading,
      error: (_, _) => l10n.zuranoHomeLocationUnavailable,
      data: (pos) {
        if (pos == null) {
          return l10n.zuranoHomeLocationUnavailable;
        }
        return placeAsync.when(
          loading: () => l10n.zuranoHomeLocationLoading,
          error: (_, _) => l10n.zuranoHomeLocationNearYou,
          data: (pm) {
            if (pm == null) {
              return l10n.zuranoHomeLocationNearYou;
            }
            return _cityLine(l10n, pm) ?? l10n.zuranoHomeLocationNearYou;
          },
        );
      },
    );

    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

