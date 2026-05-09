import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/customer.dart';

class CustomerListState {
  const CustomerListState({
    required this.customers,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.hasMore,
    required this.lastDocument,
    required this.searchTerm,
    required this.selectedTag,
    required this.errorMessage,
  });

  final List<Customer> customers;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final String searchTerm;
  final String selectedTag;
  final String? errorMessage;

  factory CustomerListState.initial() => const CustomerListState(
        customers: <Customer>[],
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: false,
        lastDocument: null,
        searchTerm: '',
        selectedTag: 'All',
        errorMessage: null,
      );

  CustomerListState copyWith({
    List<Customer>? customers,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    String? searchTerm,
    String? selectedTag,
    String? errorMessage,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedTag: selectedTag ?? this.selectedTag,
      errorMessage: errorMessage,
    );
  }
}

class CustomerListController extends AsyncNotifier<CustomerListState> {
  Timer? _debounce;

  @override
  FutureOr<CustomerListState> build() {
    ref.onDispose(() => _debounce?.cancel());
    ref.watch(sessionUserProvider);
    // Keep initial state; screen triggers load explicitly.
    return CustomerListState.initial();
  }

  Future<void> loadInitial() async {
    final sid = ref.read(sessionUserProvider).asData?.value?.salonId?.trim() ?? '';
    if (sid.isEmpty) {
      state = AsyncData(CustomerListState.initial());
      return;
    }
    final current = state.asData?.value ?? CustomerListState.initial();
    if (current.isLoadingInitial) return;

    state = AsyncData(
      current.copyWith(
        isLoadingInitial: true,
        isLoadingMore: false,
        customers: <Customer>[],
        hasMore: false,
        errorMessage: null,
      ),
    );

    try {
      final afterStart = state.asData?.value ?? current;
      final page = await ref.read(customerRepositoryProvider).fetchCustomersPage(
            salonId: sid,
            searchTerm: afterStart.searchTerm,
            selectedTag: afterStart.selectedTag,
            includeInactive: includeInactiveFromTag(afterStart.selectedTag),
            startAfterDocument: null,
          );
      state = AsyncData(
        afterStart.copyWith(
          isLoadingInitial: false,
          customers: page.customers,
          hasMore: page.hasMore,
          lastDocument: page.lastDocument,
          errorMessage: null,
        ),
      );
    } catch (_) {
      final afterStart = state.asData?.value ?? current;
      state = AsyncData(
        afterStart.copyWith(isLoadingInitial: false, errorMessage: 'failed'),
      );
    }
  }

  Future<void> loadMore() async {
    final sid = ref.read(sessionUserProvider).asData?.value?.salonId?.trim() ?? '';
    if (sid.isEmpty) return;
    final current = state.asData?.value ?? CustomerListState.initial();
    if (current.isLoadingInitial || current.isLoadingMore) return;
    if (!current.hasMore) return;

    final startAfter = current.lastDocument;
    if (startAfter == null) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final page = await ref.read(customerRepositoryProvider).fetchCustomersPage(
            salonId: sid,
            searchTerm: current.searchTerm,
            selectedTag: current.selectedTag,
            includeInactive: includeInactiveFromTag(current.selectedTag),
            startAfterDocument: startAfter,
          );

      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          customers: <Customer>[...current.customers, ...page.customers],
          hasMore: page.hasMore,
          lastDocument: page.lastDocument,
          errorMessage: null,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false, errorMessage: 'failed'));
    }
  }

  void updateSearch(String value) {
    final current = state.asData?.value ?? CustomerListState.initial();
    state = AsyncData(
      current.copyWith(searchTerm: value.trim(), errorMessage: null),
    );
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(loadInitial());
    });
  }

  void updateFilter(String tag) {
    final t = tag.trim().isEmpty ? 'All' : tag.trim();
    final current = state.asData?.value ?? CustomerListState.initial();
    if (t == current.selectedTag) return;
    state = AsyncData(current.copyWith(selectedTag: t, errorMessage: null));
    unawaited(loadInitial());
  }

  Future<void> refresh() => loadInitial();
}

bool includeInactiveFromTag(String tag) =>
    tag.trim().toLowerCase() == 'inactive';

final customerListControllerProvider =
    AsyncNotifierProvider.autoDispose<CustomerListController, CustomerListState>(
  CustomerListController.new,
);

