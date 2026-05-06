import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../providers/firebase_providers.dart';
import '../../../customer_home/presentation/controllers/customer_home_providers.dart';
import '../../../customer_home/presentation/controllers/customer_location_providers.dart';
import '../data/customer_search_repository.dart';
import '../domain/models/customer_search_filter.dart';
import 'customer_search_view_state.dart';

final customerSearchRepositoryProvider = Provider<CustomerSearchRepository>((ref) {
  return CustomerSearchRepository(ref.watch(firestoreProvider));
});

final customerSearchControllerProvider =
    AsyncNotifierProvider<CustomerSearchController, CustomerSearchViewState>(
  CustomerSearchController.new,
);

class CustomerSearchController extends AsyncNotifier<CustomerSearchViewState> {
  CustomerSearchFilter _filter = const CustomerSearchFilter(countryCode: 'QA');

  CustomerSearchFilter get filter => _filter;

  @override
  Future<CustomerSearchViewState> build() async {
    final cc = ref.read(customerDiscoveryCountryCodeProvider);
    _filter = CustomerSearchFilter(countryCode: cc);
    return const CustomerSearchViewState();
  }

  /// Call once when opening [CustomerSearchScreen] from home chips (`quickFilter` / `sort` query).
  Future<void> applyInitialQuickFilter({
    String? quickFilter,
    String? sort,
  }) async {
    final cc = ref.read(customerDiscoveryCountryCodeProvider);
    _filter = CustomerSearchFilter(countryCode: cc);

    switch (quickFilter) {
      case 'nearby':
        _filter = _filter.copyWith(
          nearbyOnly: true,
          sort: CustomerSearchSort.nearby,
        );
        break;
      case 'openNow':
        _filter = _filter.copyWith(
          openNowOnly: true,
          sort: CustomerSearchSort.openNow,
        );
        break;
      case 'availableToday':
        _filter = _filter.copyWith(
          availableTodayOnly: true,
          sort: CustomerSearchSort.recommended,
        );
        break;
      case 'offers':
        _filter = _filter.copyWith(
          offersOnly: true,
          sort: CustomerSearchSort.offers,
        );
        break;
      default:
        break;
    }

    // Nearby must win when home sends `quickFilter=nearby` or `sort=nearby`, so we do not let
    // a stray `sort=recommended` (or other) override it after the quick-filter switch.
    if (sort == 'nearby' || quickFilter == 'nearby') {
      _filter = _filter.copyWith(
        nearbyOnly: true,
        sort: CustomerSearchSort.nearby,
      );
    } else {
      final sortOverride = _parseSortQuery(sort);
      if (sortOverride != null) {
        _filter = _filter.copyWith(sort: sortOverride);
      }
    }

    _normalizeSortFlagsWithSort();
    await search();
  }

  static CustomerSearchSort? _parseSortQuery(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    switch (raw) {
      case 'recommended':
        return CustomerSearchSort.recommended;
      case 'nearby':
        return CustomerSearchSort.nearby;
      case 'openNow':
        return CustomerSearchSort.openNow;
      case 'topRated':
        return CustomerSearchSort.topRated;
      case 'priceLow':
        return CustomerSearchSort.priceLowToHigh;
      case 'priceHigh':
        return CustomerSearchSort.priceHighToLow;
      case 'offers':
        return CustomerSearchSort.offers;
      default:
        return null;
    }
  }

  Future<void> updateQuery(String query) async {
    _filter = _filter.copyWith(query: query);
    await search();
  }

  Future<void> updateSort(CustomerSearchSort sort) async {
    _filter = _filter.copyWith(sort: sort);
    _normalizeSortFlagsWithSort();
    await search();
  }

  /// Keeps [nearbyOnly], [openNowOnly], [offersOnly] aligned with [CustomerSearchFilter.sort].
  void _normalizeSortFlagsWithSort() {
    final s = _filter.sort;
    _filter = _filter.copyWith(
      nearbyOnly: s == CustomerSearchSort.nearby,
      openNowOnly: s == CustomerSearchSort.openNow,
      offersOnly: s == CustomerSearchSort.offers,
    );
  }

  Future<void> updateAudience(String? audience) async {
    _filter = _filter.copyWith(audience: audience);
    await search();
  }

  Future<void> toggleNearbyOnly() async {
    await toggleNearby();
  }

  /// Nearby quick filter: ties `nearbyOnly` + sort together.
  Future<void> toggleNearby() async {
    if (_filter.sort == CustomerSearchSort.nearby) {
      await updateSort(CustomerSearchSort.recommended);
    } else {
      await updateSort(CustomerSearchSort.nearby);
    }
  }

  Future<void> toggleOpenNow() async {
    if (_filter.sort == CustomerSearchSort.openNow) {
      await updateSort(CustomerSearchSort.recommended);
    } else {
      await updateSort(CustomerSearchSort.openNow);
    }
  }

  Future<void> toggleOffers() async {
    if (_filter.sort == CustomerSearchSort.offers) {
      await updateSort(CustomerSearchSort.recommended);
    } else {
      await updateSort(CustomerSearchSort.offers);
    }
  }

  Future<void> toggleAvailableToday() async {
    _filter = _filter.copyWith(availableTodayOnly: !_filter.availableTodayOnly);
    await search();
  }

  Future<void> resetFiltersKeepingQuery() async {
    final cc = ref.read(customerDiscoveryCountryCodeProvider);
    _filter = CustomerSearchFilter(
      query: _filter.query,
      countryCode: cc,
    );
    await search();
  }

  Future<void> search() async {
    state = const AsyncValue.loading();
    try {
      final cc = ref.read(customerDiscoveryCountryCodeProvider);
      _filter = _filter.copyWith(countryCode: cc);

      Position? position;
      if (_filter.sort == CustomerSearchSort.nearby || _filter.nearbyOnly) {
        position = await ref.read(customerCurrentPositionProvider.future);
      }

      final effective = _filter.copyWith(
        userLatitude: position?.latitude,
        userLongitude: position?.longitude,
      );

      final repo = ref.read(customerSearchRepositoryProvider);
      final results = await repo.search(effective);

      final showLocationHint =
          (effective.sort == CustomerSearchSort.nearby || effective.nearbyOnly) &&
          (effective.userLatitude == null || effective.userLongitude == null);

      if (kDebugMode) {
        debugPrint('[CustomerSearchIndex] results=${results.length} locationHint=$showLocationHint');
      }

      state = AsyncValue.data(
        CustomerSearchViewState(
          results: results,
          indexPermissionDenied: false,
          showLocationHintForNearby: showLocationHint,
        ),
      );
    } on FirebaseException catch (e, stackTrace) {
      if (e.code == 'permission-denied') {
        debugPrint('[CustomerSearchIndex] permission denied or empty result');
        state = AsyncValue.data(
          CustomerSearchViewState(
            results: const [],
            indexPermissionDenied: true,
            showLocationHintForNearby: _filter.sort == CustomerSearchSort.nearby ||
                _filter.nearbyOnly,
          ),
        );
        return;
      }
      state = AsyncValue.error(e, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
