import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../../customer_home/presentation/controllers/customer_home_providers.dart';
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

  Future<void> updateQuery(String query) async {
    _filter = _filter.copyWith(query: query);
    await search();
  }

  Future<void> updateSort(CustomerSearchSort sort) async {
    _filter = _filter.copyWith(sort: sort);
    await search();
  }

  Future<void> updateAudience(String? audience) async {
    _filter = _filter.copyWith(audience: audience);
    await search();
  }

  Future<void> toggleNearbyOnly() async {
    _filter = _filter.copyWith(nearbyOnly: !_filter.nearbyOnly);
    await search();
  }

  Future<void> toggleOpenNow() async {
    _filter = _filter.copyWith(openNowOnly: !_filter.openNowOnly);
    await search();
  }

  Future<void> toggleOffers() async {
    _filter = _filter.copyWith(offersOnly: !_filter.offersOnly);
    await search();
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
      final repo = ref.read(customerSearchRepositoryProvider);
      final results = await repo.search(_filter);
      if (kDebugMode) {
        debugPrint('[CustomerSearchIndex] results=${results.length}');
      }
      state = AsyncValue.data(
        CustomerSearchViewState(results: results, indexPermissionDenied: false),
      );
    } on FirebaseException catch (e, stackTrace) {
      if (e.code == 'permission-denied') {
        debugPrint('[CustomerSearchIndex] permission denied or empty result');
        state = AsyncValue.data(
          const CustomerSearchViewState(
            results: [],
            indexPermissionDenied: true,
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
