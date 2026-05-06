import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../data/customer_search_repository.dart';
import '../domain/models/customer_search_filter.dart';
import '../domain/models/customer_search_result.dart';

final customerSearchRepositoryProvider = Provider<CustomerSearchRepository>((ref) {
  return CustomerSearchRepository(ref.watch(firestoreProvider));
});

final customerSearchControllerProvider =
    AsyncNotifierProvider<CustomerSearchController, List<CustomerSearchResult>>(
  CustomerSearchController.new,
);

class CustomerSearchController extends AsyncNotifier<List<CustomerSearchResult>> {
  CustomerSearchFilter _filter = const CustomerSearchFilter();

  CustomerSearchFilter get filter => _filter;

  @override
  Future<List<CustomerSearchResult>> build() async {
    return const <CustomerSearchResult>[];
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
    _filter = CustomerSearchFilter(query: _filter.query);
    await search();
  }

  Future<void> search() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(customerSearchRepositoryProvider);
      final results = await repo.search(_filter);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

