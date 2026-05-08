import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer-safe salon row from `publicSalons/{salonId}`.
///
/// Only fields safe to expose to guests/anonymous customers. Maintained by
/// Cloud Functions from the private `salons/{salonId}` document. The customer
/// app MUST NOT read the private salon doc; this is the canonical discovery row.
class PublicSalonModel {
  const PublicSalonModel({
    required this.salonId,
    required this.salonName,
    required this.city,
    required this.area,
    required this.country,
    required this.countryCode,
    required this.addressText,
    required this.coverImageUrl,
    required this.logoUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.tags,
    required this.categoryIds,
    required this.searchKeywords,
    required this.isActive,
    required this.isPublished,
    required this.isPublic,
    required this.isOpen,
    required this.location,
    required this.updatedAt,
    this.distanceKmText,
    this.priceLevel,
    this.discountText,
    this.startingPrice,
  });

  final String salonId;
  final String salonName;
  final String city;
  final String area;
  final String country;

  /// ISO 3166-1 alpha-2, uppercased.
  final String countryCode;
  final String addressText;
  final String coverImageUrl;
  final String logoUrl;
  final double ratingAvg;
  final int ratingCount;
  final List<String> tags;
  final List<String> categoryIds;
  final List<String> searchKeywords;
  final bool isActive;
  final bool isPublished;
  final bool isPublic;
  final bool isOpen;

  /// Typed `(lat, lng)` lifted from the canonical `location: GeoPoint` field.
  ///
  /// The customer-facing app treats `GeoPoint` as the **only** production
  /// format. Legacy map / top-level shapes are still parsed as a defensive
  /// fallback for documents written before the schema was tightened, but UIs
  /// MUST treat any `null` here as "no map pin".
  final ({double latitude, double longitude})? location;
  final Timestamp? updatedAt;

  final String? distanceKmText;
  final String? priceLevel;
  final String? discountText;
  final num? startingPrice;

  /// Only valid when [isActive] && [isPublished] && [isPublic].
  bool get isVisibleForDiscovery =>
      isActive && isPublished && isPublic;

  bool get hasValidLocation => location != null;

  String get locationLabel {
    final a = area.trim();
    final c = city.trim();
    if (a.isNotEmpty && c.isNotEmpty) {
      return '$a, $c';
    }
    if (c.isNotEmpty) {
      return c;
    }
    return a;
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static String _trimmed(dynamic v, [String fallback = '']) {
    if (v is String) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return fallback;
  }

  static double _toDouble(dynamic v, [double fallback = 0]) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.round();
    return fallback;
  }

  /// Parses the canonical `location: GeoPoint` field, with two legacy
  /// fallbacks accepted only for backwards compatibility:
  ///
  /// 1. Canonical (production):     `location` → `GeoPoint(lat, lng)`
  /// 2. Fallback (legacy map):      `location` → `{latitude, longitude}` or
  ///                                 `{lat, lng}`
  /// 3. Fallback (legacy top-level): top-level `latitude` + `longitude` nums
  ///
  /// Any value outside Earth's lat/lng range, NaN, infinite, or the `(0, 0)`
  /// sentinel is rejected and returns `null`.
  static ({double latitude, double longitude})? _parseLocation(
    Map<String, dynamic> data,
  ) {
    final raw = data['location'];

    // 1. Canonical: GeoPoint.
    if (raw is GeoPoint) {
      return _validLatLng(raw.latitude, raw.longitude);
    }

    // 2. Fallback: location as a Map.
    if (raw is Map) {
      final lat = raw['latitude'] ?? raw['lat'];
      final lng = raw['longitude'] ?? raw['lng'] ?? raw['lon'];
      if (lat is num && lng is num) {
        return _validLatLng(lat.toDouble(), lng.toDouble());
      }
    }

    // 3. Fallback: top-level latitude/longitude.
    final topLat = data['latitude'];
    final topLng = data['longitude'];
    if (topLat is num && topLng is num) {
      return _validLatLng(topLat.toDouble(), topLng.toDouble());
    }

    return null;
  }

  static ({double latitude, double longitude})? _validLatLng(
    double lat,
    double lng,
  ) {
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) {
      return null;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }
    // Reject the "null island" sentinel commonly produced by uninitialised
    // attendance / GPS records (see attendance_requests_admin_repository.dart).
    if (lat == 0 && lng == 0) {
      return null;
    }
    return (latitude: lat, longitude: lng);
  }

  factory PublicSalonModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final cc = _trimmed(data['countryCode']).toUpperCase();
    final name = _trimmed(data['salonName'])
        .isNotEmpty
        ? _trimmed(data['salonName'])
        : _trimmed(data['name']);
    final cover = _trimmed(data['coverImageUrl']).isNotEmpty
        ? _trimmed(data['coverImageUrl'])
        : _trimmed(data['imageUrl']);

    return PublicSalonModel(
      salonId: _trimmed(data['salonId'], doc.id),
      salonName: name,
      city: _trimmed(data['city']),
      area: _trimmed(data['area']),
      country: _trimmed(data['countryName']).isNotEmpty
          ? _trimmed(data['countryName'])
          : _trimmed(data['country']),
      countryCode: cc,
      addressText: _trimmed(data['addressText']).isNotEmpty
          ? _trimmed(data['addressText'])
          : _trimmed(data['address']),
      coverImageUrl: cover,
      logoUrl: _trimmed(data['logoUrl']),
      ratingAvg: _toDouble(data['ratingAvg'])
          .clamp(0.0, 5.0)
          .toDouble(),
      ratingCount: _toInt(data['ratingCount']),
      tags: _stringList(data['tags']),
      categoryIds: _stringList(data['categoryIds']),
      searchKeywords: _stringList(data['searchKeywords']),
      isActive: data['isActive'] == true,
      isPublished: data['isPublished'] == true,
      isPublic: data['isPublic'] == true,
      isOpen: data['isOpen'] == true,
      location: _parseLocation(data),
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
      distanceKmText: _trimmed(data['distanceKmText']).isEmpty
          ? null
          : _trimmed(data['distanceKmText']),
      priceLevel: _trimmed(data['priceLevel']).isEmpty
          ? null
          : _trimmed(data['priceLevel']),
      discountText: _trimmed(data['discountText']).isEmpty
          ? null
          : _trimmed(data['discountText']),
      startingPrice: data['startingPrice'] is num
          ? data['startingPrice'] as num
          : null,
    );
  }
}
