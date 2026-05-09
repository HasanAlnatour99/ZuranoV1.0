import 'geo_fire_common.dart';

/// Firestore geohash query window (`startAt` / `endAt` on `geohash`).
class CustomerMapGeoBounds {
  const CustomerMapGeoBounds({required this.start, required this.end});

  final String start;
  final String end;
}

/// Geospatial helpers for the customer map — isolated from UI / Riverpod.
class CustomerMapGeoService {
  const CustomerMapGeoService();

  /// GeoFire-style bounds covering [radiusKm] circle around [latitude]/[longitude].
  ///
  /// Typically ≤ 9 ranges; callers run one Firestore query per range.
  List<CustomerMapGeoBounds> boundsForRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    final ranges = GeoFireCommon.geohashQueryBounds(
      [latitude, longitude],
      radiusKm * 1000,
    );
    return ranges.map((r) => CustomerMapGeoBounds(start: r[0], end: r[1])).toList(growable: false);
  }

  /// Haversine distance in kilometers (matches GeoFire `distanceBetween`).
  double distanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    return GeoFireCommon.distanceBetweenKm(
      [fromLat, fromLng],
      [toLat, toLng],
    );
  }
}
