import 'package:cloud_firestore/cloud_firestore.dart';

/// Parsed WGS84 point for distance / map (no Google Maps dependency).
class SalonCoordinates {
  const SalonCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Extracts coordinates from `publicSalons` / `salons` style maps (mirrors
/// [SalonMapItem] parsing without `google_maps_flutter`).
SalonCoordinates? tryParseSalonCoordinates(Map<String, dynamic> data) {
  SalonCoordinates? fromNums(dynamic lat, dynamic lng) {
    if (lat is num && lng is num) {
      return SalonCoordinates(
        latitude: lat.toDouble(),
        longitude: lng.toDouble(),
      );
    }
    return null;
  }

  SalonCoordinates? fromMap(Map<dynamic, dynamic> raw) {
    final lat = raw['latitude'] ?? raw['lat'];
    final lng = raw['longitude'] ?? raw['lng'];
    return fromNums(lat, lng);
  }

  final location = data['location'];
  if (location is GeoPoint) {
    return SalonCoordinates(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }
  if (location is Map) {
    final p = fromMap(location);
    if (p != null) {
      return p;
    }
  }

  for (final key in <String>['geo', 'coordinates', 'position', 'coords']) {
    final v = data[key];
    if (v is Map) {
      final p = fromMap(v);
      if (p != null) {
        return p;
      }
    }
  }

  final root = fromNums(
    data['latitude'] ?? data['lat'],
    data['longitude'] ?? data['lng'],
  );
  if (root != null) {
    return root;
  }

  final address = data['address'];
  if (address is Map) {
    final m = Map<String, dynamic>.from(address);
    final innerLoc = m['location'];
    if (innerLoc is GeoPoint) {
      return SalonCoordinates(
        latitude: innerLoc.latitude,
        longitude: innerLoc.longitude,
      );
    }
    if (innerLoc is Map) {
      final p = fromMap(innerLoc);
      if (p != null) {
        return p;
      }
    }
    final inner = fromNums(m['latitude'] ?? m['lat'], m['longitude'] ?? m['lng']);
    if (inner != null) {
      return inner;
    }
  }

  return null;
}
