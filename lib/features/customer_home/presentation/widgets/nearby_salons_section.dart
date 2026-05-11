import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRoutes, AppRouteNames;
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../../data/models/public_salon_model.dart';
import '../controllers/customer_home_canonical_providers.dart';
import '../controllers/customer_home_providers.dart'
    show
        customerDiscoveryCountryNameProvider,
        customerSearchTextProvider;
import '../controllers/customer_location_providers.dart'
    show customerCurrentPositionProvider;
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'public_salon_list_card.dart';

const int _kNearbyDisplayLimit = 5;

/// Customer home "Nearby salons" section.
///
/// Reads from the canonical [nearbySalonsProvider] (`publicSalons`, discovery-
/// visible rows). Salons may omit `location` on the mirror; list cards hide
/// distance until coordinates exist. The "View map" action is guarded — if no
/// salon has a valid `GeoPoint`, we surface a SnackBar instead
/// of pushing the map route with empty markers (avoids iOS Google Maps crash
/// when bounds collapse to a single null point).
class NearbySalonsSection extends ConsumerWidget {
  const NearbySalonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(nearbySalonsProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final query = ref.watch(customerSearchTextProvider);
    final skelH = ZuranoResponsive.v(context, 160);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoNearbyTitle,
          actionLabel: l10n.zuranoNearbyViewMap,
          leading: Icons.location_on_rounded,
          onAction: () => _onViewMapTap(context, ref, salonsAsync, l10n),
        ),
        const SizedBox(height: 14),
        salonsAsync.when(
          data: (raw) {
            final filtered = filterPublicSalonsForQuery(raw, query);
            final userPosition = positionAsync.maybeWhen(
              data: (p) => p,
              orElse: () => null,
            );
            final display = filtered.take(_kNearbyDisplayLimit).toList();
            if (display.isEmpty) {
              final countryName = ref.watch(
                customerDiscoveryCountryNameProvider,
              );
              return CustomerCompactEmptyState(
                icon: Icons.map_outlined,
                message: l10n.zuranoDiscoverNearbyEmptyInCountry(countryName),
              );
            }
            return Column(
              children: display
                  .map(
                    (s) => PublicSalonListCard(
                      salon: s,
                      userPosition: userPosition,
                      onBookNow: () {
                        context.push(
                          '${AppRoutes.customerBook}/${s.salonId}/services',
                        );
                      },
                      onOpen: () {
                        context.pushNamed(
                          AppRouteNames.customerSalonProfile,
                          pathParameters: {'salonId': s.salonId},
                        );
                      },
                    ),
                  )
                  .toList(growable: false),
            );
          },
          loading: () => SizedBox(
            height: skelH,
            child: const CustomerNearbyListSkeleton(),
          ),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return SizedBox(
                height: skelH,
                child: const CustomerNearbyListSkeleton(),
              );
            }
            return CustomerDiscoverError(
              message: l10n.zuranoDiscoverSectionLoadFailed,
            );
          },
        ),
      ],
    );
  }

  /// Validates [PublicSalonModel.hasValidLocation] before navigating to the
  /// map. If no row carries a valid `GeoPoint`, show a SnackBar — never push
  /// the map route with null/invalid markers (would crash iOS GoogleMap when
  /// computing `LatLngBounds`).
  void _onViewMapTap(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PublicSalonModel>> salonsAsync,
    AppLocalizations l10n,
  ) {
    final list = salonsAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const <PublicSalonModel>[],
    );
    final hasValid = list.any((s) => s.hasValidLocation);
    if (!hasValid) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.customerHomeMapNoValidLocations),
          ),
        );
      return;
    }
    context.push(AppRoutes.customerNearbyMap);
  }
}
