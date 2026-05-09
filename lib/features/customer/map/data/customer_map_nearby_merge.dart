import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain/salon_map_item.dart';

/// Pure merge helpers for geo queries (testable without Firestore).
class CustomerMapNearbyMerge {
  /// Dedupe by document id (last write wins), then drop rows outside [radiusKm].
  ///
  /// Always refreshes [distanceMeters] from [center] so callers display consistent radii.
  static List<SalonMapItem> dedupeAndExactDistance({
    required Iterable<SalonMapItem> items,
    required LatLng center,
    required double radiusKm,
  }) {
    final byId = <String, SalonMapItem>{};
    for (final item in items) {
      byId[item.id] = item;
    }

    final radiusM = radiusKm * 1000;
    final out = <SalonMapItem>[];

    for (final item in byId.values) {
      final d = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        item.position.latitude,
        item.position.longitude,
      );
      if (d <= radiusM) {
        out.add(item.copyWith(distanceMeters: d));
      }
    }
    return out;
  }
}
