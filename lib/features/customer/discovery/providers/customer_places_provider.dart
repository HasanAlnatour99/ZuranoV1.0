import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../providers/firebase_providers.dart';
import '../../application/customer_salon_providers.dart';
import '../../../customer_home/presentation/controllers/customer_location_providers.dart';
import '../data/models/customer_place_model.dart';
import '../data/repositories/customer_places_repository.dart';
import '../utils/distance_utils.dart';
import '../utils/opening_hours_utils.dart';

final customerPlacesRepositoryProvider = Provider<CustomerPlacesRepository>((
  ref,
) {
  return CustomerPlacesRepository(ref.watch(firestoreProvider));
});

final customerPlacesProvider =
    StreamProvider.autoDispose<List<CustomerPlaceModel>>((ref) {
      final repo = ref.watch(customerPlacesRepositoryProvider);
      return repo.watchPublicPlaces();
    });

const double _nearbyRadiusKm = 25;

List<CustomerPlaceModel> _applyDiscoveryFilters(
  List<CustomerPlaceModel> salons,
  CustomerSalonDiscoveryFilters filters,
  Position? user,
) {
  var list = salons;
  if (filters.openNow) {
    list = list.where((p) {
      if (p.isOpenNowCache != null) {
        return p.isOpenNowCache == true;
      }
      return !OpeningHoursUtils.isClosedNow(p.openingHours);
    }).toList(growable: false);
  }
  if (filters.topRated) {
    list = list.where((p) => p.ratingAvg >= 4.0).toList(growable: false);
  }
  if (filters.offers) {
    list = list.where((p) => p.hasOffer).toList(growable: false);
  }

  if (filters.nearby && user != null) {
    list = list
        .where((p) {
          final km = DistanceUtils.distanceKm(
            salonLocation: p.location,
            user: user,
          );
          return km != null && km <= _nearbyRadiusKm;
        })
        .toList(growable: false);
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
        .where((p) {
          final g = p.genderTarget?.toLowerCase();
          if (g == null || g.isEmpty) {
            return false;
          }
          return genderKeys.any((k) => g == k);
        })
        .toList(growable: false);
  }

  if (filters.nearby && user != null) {
    final copy = [...list];
    copy.sort((a, b) {
      final da = DistanceUtils.distanceKm(salonLocation: a.location, user: user);
      final db = DistanceUtils.distanceKm(salonLocation: b.location, user: user);
      final aa = da ?? 999999;
      final bb = db ?? 999999;
      final c = aa.compareTo(bb);
      if (c != 0) {
        return c;
      }
      return b.ratingAvg.compareTo(a.ratingAvg);
    });
    return copy;
  }

  return list;
}

/// Same filters/search UX as [filteredPublicSalonsProvider], backed by `salons/*`.
final filteredCustomerPlacesProvider =
    Provider<AsyncValue<List<CustomerPlaceModel>>>((ref) {
      final salonsAsync = ref.watch(customerPlacesProvider);
      final query = ref.watch(customerSalonSearchQueryProvider);
      final filters = ref.watch(customerSalonDiscoveryFiltersProvider);
      final positionAsync = ref.watch(customerCurrentPositionProvider);

      return salonsAsync.when(
        data: (salons) {
          final searched = filterCustomerPlacesByQuery(salons, query);
          final user = positionAsync.maybeWhen(
            data: (p) => p,
            orElse: () => null,
          );
          final filtered = _applyDiscoveryFilters(searched, filters, user);
          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
      );
    });
