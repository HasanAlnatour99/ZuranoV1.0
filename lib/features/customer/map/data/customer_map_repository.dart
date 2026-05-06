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

  /// Customer discovery mirror **`publicSalons`** — readable under Firestore rules.
  ///
  /// Listing raw **`salons`** is denied for customers (`permission-denied`). Coordinates
  /// must exist on the public doc (or nested shapes parsed by [SalonMapItem]).
  Stream<List<SalonMapItem>> watchMapSalons() {
    const limit = 100;
    return _firestore
        .collection(FirestorePaths.publicSalons)
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final salons = <SalonMapItem>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (kDebugMode) {
          debugPrint('MAP DEBUG salon=${doc.id} data=$data');
        }

        if (!SalonMapItem.passesCustomerMapFilters(data)) {
          if (kDebugMode) {
            debugPrint('MAP DEBUG skip ${doc.id}: failed visibility filters');
          }
          continue;
        }

        final item = SalonMapItem.maybeFromDiscoveryDoc(doc);
        if (item == null) {
          if (kDebugMode) {
            debugPrint(
              'MAP DEBUG skip ${doc.id}: no coordinates (GeoPoint/lat/lng/geo/etc.)',
            );
          }
          continue;
        }

        salons.add(item);
      }

      if (kDebugMode) {
        debugPrint('MAP DEBUG valid salons count=${salons.length}');
      }

      return salons;
    });
  }

  List<SalonMapItem> withDistance({
    required List<SalonMapItem> salons,
    required double userLat,
    required double userLng,
  }) {
    final result = salons.map((salon) {
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
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
