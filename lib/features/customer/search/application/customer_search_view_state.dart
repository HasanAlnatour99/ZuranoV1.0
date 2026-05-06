import '../domain/models/customer_search_result.dart';

class CustomerSearchViewState {
  const CustomerSearchViewState({
    this.results = const [],
    this.indexPermissionDenied = false,
  });

  final List<CustomerSearchResult> results;
  final bool indexPermissionDenied;
}
