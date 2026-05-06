import '../domain/models/customer_search_result.dart';

class CustomerSearchViewState {
  const CustomerSearchViewState({
    this.results = const [],
    this.indexPermissionDenied = false,
    this.showLocationHintForNearby = false,
  });

  final List<CustomerSearchResult> results;
  final bool indexPermissionDenied;

  /// GPS unavailable while Nearby sort / nearby-only is active.
  final bool showLocationHintForNearby;
}
