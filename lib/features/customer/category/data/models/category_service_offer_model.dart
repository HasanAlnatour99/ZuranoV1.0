import 'package:cloud_firestore/cloud_firestore.dart';

/// A service row from **`customerSearchIndex`** (`type: service`) used for
/// category / geo discovery.
class CategoryServiceOfferModel {
  const CategoryServiceOfferModel({
    required this.salonId,
    required this.targetId,
    required this.title,
    required this.salonName,
    required this.durationMinutes,
    required this.city,
    required this.area,
    required this.countryCode,
    this.latitude,
    this.longitude,
    this.geohash,
  });

  final String salonId;
  final String targetId;
  final String title;
  final String salonName;
  final int durationMinutes;
  final String city;
  final String area;
  final String countryCode;
  final double? latitude;
  final double? longitude;
  final String? geohash;

  factory CategoryServiceOfferModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final latLng = _resolveLatLng(data);
    final gh = data['geohash'];
    final geohash = gh is String && gh.isNotEmpty ? gh : null;

    return CategoryServiceOfferModel(
      salonId: _str(data['salonId']),
      targetId: _str(data['targetId']),
      title: _str(data['title']),
      salonName: _str(data['salonName']),
      durationMinutes: _int(data['durationMinutes']),
      city: _str(data['city']),
      area: _str(data['area']),
      countryCode: _str(data['countryCode']),
      latitude: latLng?.$1,
      longitude: latLng?.$2,
      geohash: geohash,
    );
  }

  static String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    return v.toString();
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  /// Prefer explicit `latitude` / `longitude`; if those keys exist but do not
  /// form a valid pair, geo is ignored. Otherwise fall back to [GeoPoint]
  /// `location`.
  static (double, double)? _resolveLatLng(Map<String, dynamic> data) {
    final hasExplicitLat = data.containsKey('latitude');
    final hasExplicitLng = data.containsKey('longitude');

    if (hasExplicitLat && hasExplicitLng) {
      final lat = _finiteDouble(data['latitude']);
      final lng = _finiteDouble(data['longitude']);
      if (lat != null && lng != null) {
        return (lat, lng);
      }
      return null;
    }

    final loc = data['location'];
    if (loc is GeoPoint) {
      final lat = _finiteDouble(loc.latitude);
      final lng = _finiteDouble(loc.longitude);
      if (lat != null && lng != null) {
        return (lat, lng);
      }
    }

    return null;
  }

  static double? _finiteDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) {
      final d = v.toDouble();
      return d.isFinite ? d : null;
    }
    if (v is String) {
      final d = double.tryParse(v);
      return d != null && d.isFinite ? d : null;
    }
    return null;
  }
}
