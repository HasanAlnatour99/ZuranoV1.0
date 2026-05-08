import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../domain/salon_map_item.dart';

final customerMapRepositoryProvider = Provider<CustomerMapRepository>((ref) {
  return CustomerMapRepository(FirebaseFirestore.instance);
});

final customerMapSalonsProvider = StreamProvider<List<SalonMapItem>>((ref) {
  return ref.watch(customerMapRepositoryProvider).watchMapSalons();
});

class CustomerMapRepository {
  CustomerMapRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Hard upper bound on how many `publicSalons` we materialize per snapshot.
  ///
  /// TODO(scale): replace this global `limit(200)` with a geohash-bounded query
  /// (e.g. `geoflutterfire`-style range queries on `geohash` + bounding box from
  /// the camera viewport) once `publicSalons` carries geohash on every doc. The
  /// current design ships fine for MVP scale; rebalance before national rollout.
  static const int kCustomerMapDocLimit = 200;

  /// Customer discovery mirror **`publicSalons`** — readable under Firestore rules.
  ///
  /// Listing raw **`salons`** is denied for customers (`permission-denied`). The
  /// query MUST match `firestore.rules` (`publicSalons/{salonId}`):
  /// `isActive == true && isPublished == true && isPublic == true`.
  ///
  /// Further safety nets ([SalonMapItem.passesCustomerMapFilters],
  /// `bookingEnabled`, missing coordinates) run client-side.
  Stream<List<SalonMapItem>> watchMapSalons() {
    return _firestore
        .collection(FirestorePaths.publicSalons)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(kCustomerMapDocLimit)
        .snapshots()
        .map(_parseSnapshot);
  }

  List<SalonMapItem> _parseSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final salons = <SalonMapItem>[];
    int skippedHidden = 0;
    int skippedMissingLocation = 0;
    int skippedBookingDisabled = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (!SalonMapItem.passesCustomerMapFilters(data)) {
        skippedHidden += 1;
        continue;
      }

      if (data['bookingEnabled'] == false) {
        skippedBookingDisabled += 1;
        continue;
      }

      final item = SalonMapItem.maybeFromDiscoveryDoc(doc);
      if (item == null) {
        skippedMissingLocation += 1;
        continue;
      }

      salons.add(item);
    }

    if (kDebugMode) {
      debugPrint(
        '[CustomerMap] publicSalons received=${snapshot.docs.length} '
        'visibleAfterFilters=${salons.length} '
        'skippedHidden=$skippedHidden '
        'skippedBookingDisabled=$skippedBookingDisabled '
        'skippedMissingLocation=$skippedMissingLocation '
        'limit=$kCustomerMapDocLimit',
      );
    }

    return salons;
  }

  List<SalonMapItem> withDistanceFrom({
    required List<SalonMapItem> salons,
    required double centerLat,
    required double centerLng,
  }) {
    final result = salons.map((salon) {
      final distance = Geolocator.distanceBetween(
        centerLat,
        centerLng,
        salon.position.latitude,
        salon.position.longitude,
      );

      return salon.copyWith(distanceMeters: distance);
    }).toList();

    result.sort((a, b) {
      final aDistance = a.distanceMeters ?? double.maxFinite;
      final bDistance = b.distanceMeters ?? double.maxFinite;
      return aDistance.compareTo(bDistance);
    });

    return result;
  }
}
