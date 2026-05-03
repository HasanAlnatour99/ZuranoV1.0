import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRoutes, AppRouteNames;
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../../domain/customer_geo.dart';
import '../../data/models/customer_salon_model.dart';
import '../controllers/customer_home_providers.dart'
    show
        customerDiscoveryCountryNameProvider,
        customerSearchTextProvider,
        nearbySalonsProvider;
import '../controllers/customer_location_providers.dart'
    show customerCurrentPositionProvider;
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'nearby_salon_card.dart';

const int _kNearbyDisplayLimit = 10;

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
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoNearbyTitle,
          actionLabel: l10n.zuranoNearbyViewMap,
          leading: Icons.location_on_outlined,
          onAction: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.zuranoNearbyMapSnack)));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: salonsAsync.when(
            data: (raw) {
              final filtered = filterSalonsForQuery(raw, query);
              final userPosition = positionAsync.maybeWhen(
                data: (p) => p,
                orElse: () => null,
              );
              final sorted = sortNearbySalonsByDistance(filtered, userPosition);
              final display = sorted.take(_kNearbyDisplayLimit).toList();
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
                      (s) => NearbySalonCard(
                        salon: s,
                        calculatedDistanceKm: _distanceKmForSalon(
                          s,
                          userPosition,
                        ),
                        onBookNow: () {
                          context.push(
                            '${AppRoutes.customerBook}/${s.id}/services',
                          );
                        },
                        onOpen: () {
                          context.pushNamed(
                            AppRouteNames.customerSalonProfile,
                            pathParameters: {'salonId': s.id},
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
        ),
      ],
    );
  }
}

double? _distanceKmForSalon(CustomerSalonModel salon, Position? userPosition) {
  if (userPosition == null) {
    return null;
  }
  return calculateDistanceKm(
    userLat: userPosition.latitude,
    userLng: userPosition.longitude,
    salonLat: salon.latitude,
    salonLng: salon.longitude,
  );
}
