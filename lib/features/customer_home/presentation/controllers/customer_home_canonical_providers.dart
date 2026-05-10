import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/public_salon_model.dart';
import '../../data/models/public_specialist_discovery_model.dart';
import '../../data/models/service_category_model.dart';
import 'customer_home_providers.dart'
    show customerDiscoveryCountryCodeProvider, customerHomeRepositoryProvider;
import 'customer_location_providers.dart' show customerCurrentPositionProvider;

/// Canonical customer home providers (production read path).
///
/// Specialist carousels read **`customerSearchIndex`** (same documents as search;
/// see `functions/src/customerSearchIndex.ts`). This stays in sync with search
/// even when `customerDiscovery/specialists/items` is not mirrored.
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

int _compareByRatingThenUpdated(PublicSalonModel a, PublicSalonModel b) {
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
}

/// Public, GPS-aware nearby salons.
///
/// 1. Keeps only discovery-visible rows ([PublicSalonModel.isVisibleForDiscovery]).
///    Salons without a map pin are still listed so the section is not empty
///    when mirrors omit `location`; cards hide distance until coords exist.
/// 2. When GPS is known: sorts by distance for salons with coordinates; rows
///    without coordinates sort after them, tie-broken by rating / recency.
/// 3. When GPS is unknown: sorts by `(ratingAvg desc, updatedAt desc)`.
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
          .toList(growable: true);

      final position = positionAsync.maybeWhen(
        data: (p) => p,
        orElse: () => null,
      );

      if (position != null) {
        visible.sort((a, b) {
          final aLoc = a.location;
          final bLoc = b.location;
          if (aLoc != null && bLoc != null) {
            final da = _haversineKm(
              position.latitude,
              position.longitude,
              aLoc.latitude,
              aLoc.longitude,
            );
            final db = _haversineKm(
              position.latitude,
              position.longitude,
              bLoc.latitude,
              bLoc.longitude,
            );
            final cmp = da.compareTo(db);
            if (cmp != 0) return cmp;
          } else if (aLoc != null && bLoc == null) {
            return -1;
          } else if (aLoc == null && bLoc != null) {
            return 1;
          }
          return _compareByRatingThenUpdated(a, b);
        });
      } else {
        visible.sort(_compareByRatingThenUpdated);
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

/// Raw specialist rows from `customerSearchIndex` (filtered to `type == specialist`).
final customerHomeSearchIndexSpecialistsProvider =
    StreamProvider.autoDispose<List<PublicSpecialistDiscoveryModel>>((ref) {
  final repo = ref.watch(customerHomeRepositoryProvider);
  final cc = ref.watch(customerDiscoveryCountryCodeProvider);
  return repo.watchSpecialistsFromCustomerSearchIndex(countryCode: cc);
});

/// Public, customer-safe specialists for the "Recommended" carousel.
final recommendedSpecialistsProvider =
    Provider.autoDispose<AsyncValue<List<PublicSpecialistDiscoveryModel>>>((ref) {
  final base = ref.watch(customerHomeSearchIndexSpecialistsProvider);
  return base.when(
    data: (list) => AsyncValue.data(
      list
          .where((s) => s.isReadyForCustomerHome)
          .take(12)
          .toList(growable: false),
    ),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

/// Specialists with at least one bookable slot today (`availableToday` on index).
final availableTodayProvider =
    Provider.autoDispose<AsyncValue<List<PublicSpecialistDiscoveryModel>>>((ref) {
  final base = ref.watch(customerHomeSearchIndexSpecialistsProvider);
  return base.when(
    data: (list) => AsyncValue.data(
      list
          .where((s) => s.isReadyForCustomerHome && s.availableToday)
          .take(20)
          .toList(growable: false),
    ),
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});
