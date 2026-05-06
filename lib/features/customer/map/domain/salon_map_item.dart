import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Salon snapshot for the customer map.
///
/// Parsed from **`publicSalons/{salonId}`** (customer-facing discovery). Supports
/// several coordinate and field shapes so mirrored / legacy docs still pin.
class SalonMapItem {
  const SalonMapItem({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    required this.country,
    required this.addressText,
    required this.position,
    this.imageUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.openStatus,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String area;
  final String city;
  final String country;
  final String addressText;
  final LatLng position;
  final String? imageUrl;
  final double ratingAvg;
  final int ratingCount;
  final String openStatus;
  final double? distanceMeters;

  /// Returns `null` if the document has no usable coordinates for a map pin.
  static SalonMapItem? maybeFromDiscoveryDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final latLng = _parsePosition(data);
    if (latLng == null) return null;

    final nameRaw = data['salonName'] ?? data['name'];

    return SalonMapItem(
      id: doc.id,
      name: _stringOrDefault(nameRaw, 'Salon'),
      area: _stringOrDefault(data['area'] ?? data['district'], ''),
      city: _stringOrDefault(data['city'], ''),
      country: _stringOrDefault(
        data['countryName'] ?? data['country'],
        'Qatar',
      ),
      addressText: _addressText(data),
      position: latLng,
      imageUrl: _imageUrl(data),
      ratingAvg: _ratingAvg(data),
      ratingCount: _ratingCount(data),
      openStatus: _openStatus(data),
    );
  }

  /// Extra client-side gate on top of the Firestore query (`publicSalons`).
  ///
  /// Query already enforces `isPublic` + `isActive`. This rejects rows that look
  /// explicitly suspended or hidden using alternate field names.
  static bool passesCustomerMapFilters(Map<String, dynamic> data) {
    final inactive =
        data['isActive'] == false ||
        data['status'] == 'inactive' ||
        data['accountStatus'] == 'suspended';

    if (inactive) return false;

    final visible =
        data['isPublished'] == true ||
        data['published'] == true ||
        data['isVisible'] == true ||
        data['publicProfileEnabled'] == true ||
        data['isPublic'] == true;

    return visible;
  }

  SalonMapItem copyWith({
    double? distanceMeters,
  }) {
    return SalonMapItem(
      id: id,
      name: name,
      area: area,
      city: city,
      country: country,
      addressText: addressText,
      position: position,
      imageUrl: imageUrl,
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      openStatus: openStatus,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  String get locationLabel {
    final parts = [area, city].where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return country;
    return parts.join(', ');
  }

  static LatLng? _parsePosition(Map<String, dynamic> data) {
    LatLng? fromNums(dynamic lat, dynamic lng) {
      if (lat is num && lng is num) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
      return null;
    }

    LatLng? fromMap(Map<dynamic, dynamic> raw) {
      final lat = raw['latitude'] ?? raw['lat'];
      final lng = raw['longitude'] ?? raw['lng'];
      return fromNums(lat, lng);
    }

    final location = data['location'];
    if (location is GeoPoint) {
      return LatLng(location.latitude, location.longitude);
    }
    if (location is Map) {
      final p = fromMap(location);
      if (p != null) return p;
    }

    for (final key in <String>['geo', 'coordinates', 'position', 'coords']) {
      final v = data[key];
      if (v is Map) {
        final p = fromMap(v);
        if (p != null) return p;
      }
    }

    final root = fromNums(
      data['latitude'] ?? data['lat'],
      data['longitude'] ?? data['lng'],
    );
    if (root != null) return root;

    final address = data['address'];
    if (address is Map) {
      final m = Map<String, dynamic>.from(address);
      final innerLoc = m['location'];
      if (innerLoc is GeoPoint) {
        return LatLng(innerLoc.latitude, innerLoc.longitude);
      }
      if (innerLoc is Map) {
        final p = fromMap(innerLoc);
        if (p != null) return p;
      }
      final inner = fromNums(m['latitude'] ?? m['lat'], m['longitude'] ?? m['lng']);
      if (inner != null) return inner;
    }

    return null;
  }

  static String? _trimmedString(dynamic value) {
    if (value is! String) return null;
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  static String _addressText(Map<String, dynamic> data) {
    for (final k in ['addressText', 'locationText']) {
      final s = _trimmedString(data[k]);
      if (s != null) return s;
    }
    final addr = data['address'];
    if (addr is String && addr.trim().isNotEmpty) return addr.trim();
    if (addr is Map) {
      final m = Map<String, dynamic>.from(addr);
      final formatted = _trimmedString(m['formatted']);
      if (formatted != null) return formatted;
      final line = _trimmedString(m['line1']);
      final city = _trimmedString(m['city']);
      if (line != null && city != null) return '$line, $city';
      if (line != null) return line;
      if (city != null) return city;
    }
    return '';
  }

  static String? _imageUrl(Map<String, dynamic> data) {
    for (final k in [
      'coverImageUrl',
      'imageUrl',
      'photoUrl',
      'mainImageUrl',
      'logoUrl',
    ]) {
      final s = _trimmedString(data[k]);
      if (s != null) return s;
    }
    return null;
  }

  static double _ratingAvg(Map<String, dynamic> data) {
    for (final k in [
      'ratingAvg',
      'averageRating',
      'ratingAverage',
      'rating',
    ]) {
      final v = data[k];
      if (v is num) return v.toDouble();
    }
    return 0.0;
  }

  static int _ratingCount(Map<String, dynamic> data) {
    for (final k in ['ratingCount', 'reviewsCount', 'reviewCount']) {
      final v = data[k];
      if (v is num) return v.toInt();
    }
    return 0;
  }

  static String _openStatus(Map<String, dynamic> data) {
    final raw = data['openStatus'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    if (data['isOpen'] == true) return 'open';
    if (data['isOpen'] == false) return 'closed';
    return 'unknown';
  }

  static String _stringOrDefault(dynamic value, String fallback) {
    if (value is! String) return fallback;
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
