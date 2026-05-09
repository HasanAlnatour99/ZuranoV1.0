import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../data/customer_map_repository.dart';
import '../../domain/customer_map_discovery_engine.dart';
import '../../domain/salon_map_item.dart';

export '../../domain/customer_map_discovery_engine.dart'
    show CustomerMapDiscoveryEngine, CustomerMapFilterState, MapBusinessTypeChip;

/// Map queries use this center for radius/distance (committed search area).
const LatLng kCustomerMapDohaFallback = LatLng(25.2854, 51.5310);

/// Discoverable radius around [mapCommittedSearchCenterProvider], in kilometers.
final mapRadiusKmProvider = StateProvider<double>((ref) => 5);

final mapFilterStateProvider =
    StateProvider<CustomerMapFilterState>((ref) => const CustomerMapFilterState());

/// Latest camera target while dragging / after idle (used for "Search this area").
final mapCameraTargetProvider = StateProvider<LatLng?>((ref) => null);

/// Center used for nearby list and radius filtering (updates on search-this-area + initial GPS).
final mapCommittedSearchCenterProvider =
    StateProvider<LatLng>((ref) => kCustomerMapDohaFallback);

/// Show floating "Search this area" when the camera rests away from committed center.
final mapSearchThisAreaVisibleProvider = StateProvider<bool>((ref) => false);

final selectedMapSalonProvider = StateProvider<SalonMapItem?>((ref) => null);

/// Geo-hash bounded `publicSalons` near the committed center (exact distance applied in repo).
final customerMapSalonsProvider =
    StreamProvider.autoDispose<List<SalonMapItem>>((ref) {
  final center = ref.watch(mapCommittedSearchCenterProvider);
  final radiusKm = ref.watch(mapRadiusKmProvider);
  return ref.watch(customerMapRepositoryProvider).watchNearbyMapSalons(
        center: center,
        radiusKm: radiusKm,
      );
});

/// Places after chip filters + discovery sort (radius already enforced upstream).
final nearbyPublicSalonsProvider = Provider<List<SalonMapItem>>((ref) {
  final salonsAsync = ref.watch(customerMapSalonsProvider);
  final center = ref.watch(mapCommittedSearchCenterProvider);
  final radiusKm = ref.watch(mapRadiusKmProvider);
  final filters = ref.watch(mapFilterStateProvider);

  return salonsAsync.maybeWhen(
    data: (salons) {
      final filtered = CustomerMapDiscoveryEngine.filterAndSort(
        salons: salons,
        center: center,
        radiusKm: radiusKm,
        filters: filters,
        applyRadiusFilter: false,
      );

      if (kDebugMode) {
        debugPrint(
          '[CustomerMap] discovery '
          'radiusKm=${radiusKm.toStringAsFixed(1)} '
          'businessType=${filters.businessType.name} '
          'openNowOnly=${filters.openNowOnly} '
          'topRatedOnly=${filters.topRatedOnly} '
          'inputCount=${salons.length} '
          'visibleAfterFilters=${filtered.length}',
        );
        if (filtered.length >
            CustomerMapDiscoveryEngine.kMarkerClusterThreshold) {
          debugPrint(
            '[CustomerMap] clustering threshold exceeded '
            '(${filtered.length} markers)',
          );
        }
      }

      return filtered;
    },
    orElse: () => const <SalonMapItem>[],
  );
});
