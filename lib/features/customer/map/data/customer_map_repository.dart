import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../domain/salon_map_item.dart';
import 'customer_map_nearby_merge.dart';
import 'services/customer_map_geo_service.dart';

final customerMapGeoServiceProvider = Provider<CustomerMapGeoService>((ref) {
  return const CustomerMapGeoService();
});

final customerMapRepositoryProvider = Provider<CustomerMapRepository>((ref) {
  return CustomerMapRepository(
    FirebaseFirestore.instance,
    geo: ref.watch(customerMapGeoServiceProvider),
  );
});

class CustomerMapRepository {
  CustomerMapRepository(
    this._firestore, {
    CustomerMapGeoService geo = const CustomerMapGeoService(),
  }) : _geo = geo;

  final FirebaseFirestore _firestore;
  final CustomerMapGeoService _geo;

  /// Hard cap per geohash slice — GeoFire can fan out to multiple queries (≤ 9).
  static const int kCustomerMapGeoBoundLimit = 120;

  /// Legacy global scan — **not** used by the customer UI anymore.
  ///
  /// TODO(scale): delete once geo-index coverage is verified in production.
  static const int kCustomerMapGlobalLegacyLimit = 200;

  /// Streams salons near [center] within [radiusKm] using GeoFire hash slices +
  /// exact distance filtering (drops geohash false positives).
  ///
  /// Firestore query matches rules on `publicSalons/{salonId}`:
  /// `isActive && isPublished && isPublic`, ordered by `geohash`.
  Stream<List<SalonMapItem>> watchNearbyMapSalons({
    required LatLng center,
    required double radiusKm,
  }) {
    List<CustomerMapGeoBounds> bounds;
    try {
      bounds = _geo.boundsForRadius(
        latitude: center.latitude,
        longitude: center.longitude,
        radiusKm: radiusKm,
      );
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('[CustomerMap][geo] bounds generation failed: $e $st');
      }
      bounds = const [];
    }

    if (bounds.isEmpty) {
      return Stream<List<SalonMapItem>>.value(const []);
    }

    final queries = bounds.map((b) {
      return _firestore
          .collection(FirestorePaths.publicSalons)
          .where('isActive', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('geohash')
          .startAt([b.start])
          .endAt([b.end])
          .limit(kCustomerMapGeoBoundLimit);
    }).toList(growable: false);

    return Stream<List<SalonMapItem>>.multi((listener) {
      final snapshots = List<QuerySnapshot<Map<String, dynamic>>?>.filled(
        queries.length,
        null,
      );
      final subscriptions = <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

      void emit() {
        if (listener.isClosed) {
          return;
        }
        final merged = _mergeGeoSlices(
          snapshots: snapshots,
          center: center,
          radiusKm: radiusKm,
          boundsCount: bounds.length,
        );
        listener.add(merged);
      }

      for (var i = 0; i < queries.length; i++) {
        final idx = i;
        subscriptions.add(
          queries[idx].snapshots().listen(
            (snap) {
              snapshots[idx] = snap;
              emit();
            },
            onError: listener.addError,
          ),
        );
      }

      listener.onCancel = () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
      };
    });
  }

  List<SalonMapItem> _mergeGeoSlices({
    required List<QuerySnapshot<Map<String, dynamic>>?> snapshots,
    required LatLng center,
    required double radiusKm,
    required int boundsCount,
  }) {
    var totalRawDocs = 0;
    final docBuckets = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final snap in snapshots) {
      if (snap == null) {
        continue;
      }
      totalRawDocs += snap.docs.length;
      for (final doc in snap.docs) {
        docBuckets[doc.id] = doc;
      }
    }

    final uniqueIds = docBuckets.length;
    final duplicatesRemoved = totalRawDocs - uniqueIds;

    final parsed = <SalonMapItem>[];
    var skippedHidden = 0;
    var skippedBookingDisabled = 0;
    var skippedMissingLocation = 0;
    var skippedMissingGeohash = 0;

    for (final doc in docBuckets.values) {
      final data = doc.data();

      if (!SalonMapItem.passesCustomerMapFilters(data)) {
        skippedHidden += 1;
        continue;
      }

      final gh = data['geohash'];
      if (gh is! String || gh.trim().isEmpty) {
        skippedMissingGeohash += 1;
        continue;
      }

      final item = SalonMapItem.maybeFromDiscoveryDoc(doc);
      if (item == null) {
        skippedMissingLocation += 1;
        continue;
      }

      if (!item.bookingEnabled) {
        skippedBookingDisabled += 1;
        continue;
      }

      parsed.add(item);
    }

    final beforeDistance = parsed.length;
    final exact = CustomerMapNearbyMerge.dedupeAndExactDistance(
      items: parsed,
      center: center,
      radiusKm: radiusKm,
    );
    final falsePositivesRemoved = beforeDistance - exact.length;

    if (kDebugMode) {
      debugPrint(
        '[CustomerMap][geo] bounds=$boundsCount rawDocs=$totalRawDocs '
        'uniqueIds=$uniqueIds dupRemoved=$duplicatesRemoved '
        'skipHidden=$skippedHidden skipNoGeohash=$skippedMissingGeohash '
        'skipNoLoc=$skippedMissingLocation skipBookingOff=$skippedBookingDisabled '
        'preExactDist=$beforeDistance falsePositivesRemoved=$falsePositivesRemoved '
        'finalBeforeChips=${exact.length}',
      );
    }

    return exact;
  }

  /// Global fallback (legacy MVP). Prefer [watchNearbyMapSalons].
  Stream<List<SalonMapItem>> watchPublicSalonsGlobalLegacyDebug() {
    return _firestore
        .collection(FirestorePaths.publicSalons)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(kCustomerMapGlobalLegacyLimit)
        .snapshots()
        .map((snapshot) {
      final salons = <SalonMapItem>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!SalonMapItem.passesCustomerMapFilters(data)) {
          continue;
        }
        final item = SalonMapItem.maybeFromDiscoveryDoc(doc);
        if (item == null || !item.bookingEnabled) {
          continue;
        }
        salons.add(item);
      }
      if (kDebugMode) {
        debugPrint(
          '[CustomerMap][legacy] global docs=${snapshot.docs.length} parsed=${salons.length}',
        );
      }
      return salons;
    });
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
