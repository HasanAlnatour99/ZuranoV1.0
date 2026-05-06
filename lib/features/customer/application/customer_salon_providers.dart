import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../customer_home/presentation/controllers/customer_home_providers.dart';
import '../data/models/salon_public_model.dart';
import '../data/repositories/customer_salon_repository.dart';

final customerSalonRepositoryProvider = Provider<CustomerSalonRepository>((
  ref,
) {
  return FirestoreCustomerSalonRepository(ref.watch(firestoreProvider));
});

final publicSalonsProvider = StreamProvider<List<SalonPublicModel>>((ref) {
  final code = ref.watch(customerDiscoveryCountryCodeProvider);
  return ref
      .watch(customerSalonRepositoryProvider)
      .watchPublicSalons(countryCode: code);
});

class CustomerSalonSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

final customerSalonSearchQueryProvider =
    NotifierProvider<CustomerSalonSearchQueryNotifier, String>(
      CustomerSalonSearchQueryNotifier.new,
    );

@immutable
class CustomerSalonDiscoveryFilters {
  const CustomerSalonDiscoveryFilters({
    this.nearby = false,
    this.openNow = false,
    this.availableToday = false,
    this.topRated = false,
    this.offers = false,
    this.ladies = false,
    this.men = false,
    this.unisex = false,
  });

  final bool nearby;
  final bool openNow;
  final bool availableToday;
  final bool topRated;
  final bool offers;
  final bool ladies;
  final bool men;
  final bool unisex;

  CustomerSalonDiscoveryFilters copyWith({
    bool? nearby,
    bool? openNow,
    bool? availableToday,
    bool? topRated,
    bool? offers,
    bool? ladies,
    bool? men,
    bool? unisex,
  }) {
    return CustomerSalonDiscoveryFilters(
      nearby: nearby ?? this.nearby,
      openNow: openNow ?? this.openNow,
      availableToday: availableToday ?? this.availableToday,
      topRated: topRated ?? this.topRated,
      offers: offers ?? this.offers,
      ladies: ladies ?? this.ladies,
      men: men ?? this.men,
      unisex: unisex ?? this.unisex,
    );
  }
}

class CustomerSalonDiscoveryFiltersNotifier
    extends Notifier<CustomerSalonDiscoveryFilters> {
  @override
  CustomerSalonDiscoveryFilters build() =>
      const CustomerSalonDiscoveryFilters();

  void setFilters(CustomerSalonDiscoveryFilters value) {
    state = value;
  }
}

final customerSalonDiscoveryFiltersProvider =
    NotifierProvider<
      CustomerSalonDiscoveryFiltersNotifier,
      CustomerSalonDiscoveryFilters
    >(CustomerSalonDiscoveryFiltersNotifier.new);

List<SalonPublicModel> _applyDiscoveryFilters(
  List<SalonPublicModel> salons,
  CustomerSalonDiscoveryFilters filters,
) {
  var list = salons;
  if (filters.openNow) {
    list = list.where((s) => s.isOpen).toList(growable: false);
  }
  if (filters.availableToday) {
    list = list
        .where((s) => s.meetsAvailableTodayFilter)
        .toList(growable: false);
  }
  if (filters.topRated) {
    list = list.where((s) => s.ratingAverage >= 4.0).toList(growable: false);
  }
  final genderKeys = <String>[];
  if (filters.ladies) {
    genderKeys.addAll(['ladies', 'women', 'female']);
  }
  if (filters.men) {
    genderKeys.addAll(['men', 'male', 'gentlemen']);
  }
  if (filters.unisex) {
    genderKeys.add('unisex');
  }
  if (genderKeys.isNotEmpty) {
    list = list
        .where((s) {
          final g = s.genderTarget?.toLowerCase();
          if (g == null || g.isEmpty) {
            return false;
          }
          return genderKeys.any((k) => g == k);
        })
        .toList(growable: false);
  }
  return list;
}

final filteredPublicSalonsProvider =
    Provider<AsyncValue<List<SalonPublicModel>>>((ref) {
      final salonsAsync = ref.watch(publicSalonsProvider);
      final query = ref.watch(customerSalonSearchQueryProvider);
      final filters = ref.watch(customerSalonDiscoveryFiltersProvider);

      return salonsAsync.when(
        data: (salons) {
          final searched = filterPublicSalonsByQuery(salons, query);
          return AsyncValue.data(_applyDiscoveryFilters(searched, filters));
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    });
