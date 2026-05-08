import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/public_salon_model.dart';
import '../../data/models/public_specialist_discovery_model.dart';
import '../../data/models/service_category_model.dart';
import 'customer_home_providers.dart' show customerHomeRepositoryProvider;
import 'customer_location_providers.dart' show customerCurrentPositionProvider;

/// Canonical customer home providers (production read path).
///
/// Each provider streams from exactly one customer-safe source:
///  - [nearbySalonsProvider]        ← `publicSalons`
///  - [serviceCategoriesProvider]   ← `customerDiscovery/categories/items`
///  - [availableTodayProvider]      ← `customerDiscovery/specialists/items`
///  - [recommendedSpecialistsProvider] ← same as above (no `availableToday`)
///
/// Privacy: none of these expose payroll, attendance, commission, salary, or
/// any private employee data. Customer app must only depend on these for the
/// home screen sections.

/// Raw nearby salons stream (no GPS sort applied yet).
final _nearbyPublicSalonsRawProvider =
    StreamProvider.autoDispose<List<PublicSalonModel>>((ref) {
  final repo = ref.watch(customerHomeRepositoryProvider);
  return repo.watchNearbyPublicSalons(limit: 100);
});

double _haversineKm(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  final meters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  return meters / 1000.0;
}

/// Public, GPS-aware nearby salons.
///
/// 1. Filters out rows with missing/invalid `location` (no `GeoPoint`).
/// 2. Sorts by distance to [customerCurrentPositionProvider] when available.
/// 3. Falls back to `(ratingAvg desc, updatedAt desc)` when GPS is unknown.
final nearbySalonsProvider =
    Provider.autoDispose<AsyncValue<List<PublicSalonModel>>>((ref) {
  final salonsAsync = ref.watch(_nearbyPublicSalonsRawProvider);
  final positionAsync = ref.watch(customerCurrentPositionProvider);

  return salonsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (raw) {
      final visible = raw
          .where((s) => s.isVisibleForDiscovery)
          .where((s) => s.hasValidLocation)
          .toList(growable: true);

      final position = positionAsync.maybeWhen(
        data: (p) => p,
        orElse: () => null,
      );

      if (position != null) {
        visible.sort((a, b) {
          final da = _haversineKm(
            position.latitude,
            position.longitude,
            a.location!.latitude,
            a.location!.longitude,
          );
          final db = _haversineKm(
            position.latitude,
            position.longitude,
            b.location!.latitude,
            b.location!.longitude,
          );
          return da.compareTo(db);
        });
      } else {
        visible.sort((a, b) {
          final r = b.ratingAvg.compareTo(a.ratingAvg);
          if (r != 0) return r;
          final ua = a.updatedAt;
          final ub = b.updatedAt;
          if (ua != null && ub != null) {
            return ub.compareTo(ua);
          }
          if (ub != null) return 1;
          if (ua != null) return -1;
          return 0;
        });
      }

      return AsyncValue.data(visible);
    },
  );
});

/// Public, ordered service categories for the home category scroller.
final serviceCategoriesProvider =
    StreamProvider.autoDispose<List<ServiceCategoryModel>>((ref) {
  final repo = ref.watch(customerHomeRepositoryProvider);
  return repo.watchServiceCategories(limit: 32);
});

/// Public, customer-safe specialists available today.
final availableTodayProvider =
    StreamProvider.autoDispose<List<PublicSpecialistDiscoveryModel>>((ref) {
  final repo = ref.watch(customerHomeRepositoryProvider);
  return repo.watchAvailableTodaySpecialists(limit: 20);
});

/// Public, customer-safe specialists for the "Recommended" carousel.
///
/// Re-uses the same read model. UI MUST NOT join this with private payroll,
/// attendance, commission, salary, or other private employee fields.
final recommendedSpecialistsProvider =
    StreamProvider.autoDispose<List<PublicSpecialistDiscoveryModel>>((ref) {
  final repo = ref.watch(customerHomeRepositoryProvider);
  return repo.watchRecommendedDiscoverySpecialists(limit: 10);
});
