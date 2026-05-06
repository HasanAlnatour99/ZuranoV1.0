import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/currency_for_country.dart';
import '../../domain/salon_coordinates.dart';

class CustomerSalonModel {
  const CustomerSalonModel({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.country,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isPublished,
    required this.isOpen,
    required this.isPromoted,
    required this.ratingAverage,
    required this.ratingCount,
    required this.distanceKmText,
    required this.priceLevel,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.tags,
    required this.categoryIds,
    required this.searchKeywords,
    this.countryCodeIso,
    this.currencyCode = 'USD',
    this.discountText,
  });

  final String id;
  final String name;
  final String city;
  final String area;
  final String country;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isPublished;
  final bool isOpen;
  final bool isPromoted;
  final double ratingAverage;
  final int ratingCount;
  final String distanceKmText;
  final String priceLevel;
  final String logoUrl;
  final String coverImageUrl;
  final List<String> tags;
  final List<String> categoryIds;
  final List<String> searchKeywords;

  /// ISO 3166-1 alpha-2 when present on the salon document.
  final String? countryCodeIso;

  /// ISO 4217 — from salon doc or derived from [countryCodeIso].
  final String currencyCode;
  final String? discountText;

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

  /// Safe for `publicSalons` / salon docs where `address` may be a string or map.
  static String discoveryAddressLine(Map<String, dynamic> data) {
    return _addressLine(data);
  }

  static String _addressLine(Map<String, dynamic> data) {
    final raw = data['address'];
    if (raw is String) {
      return raw.trim();
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final formatted =
          (m['formattedAddress'] as String?)?.trim() ??
          (m['formatted'] as String?)?.trim();
      if (formatted != null && formatted.isNotEmpty) {
        return formatted;
      }
      final parts = <String>[
        if (m['line1'] is String) (m['line1'] as String).trim(),
        if (m['city'] is String) (m['city'] as String).trim(),
      ].where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }
    return '';
  }

  factory CustomerSalonModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final iso = (data['countryCode'] as String?)?.trim();
    final currencyRaw = (data['currencyCode'] as String?)?.trim();
    final currency = resolvedSalonMoneyCurrency(
      salonCurrencyCode: currencyRaw,
      salonCountryIso: (iso != null && iso.isNotEmpty) ? iso : null,
    );

    final countryDirect = (data['country'] as String?)?.trim();
    final countryName = (data['countryName'] as String?)?.trim();
    final countryResolved =
        (countryDirect != null && countryDirect.isNotEmpty)
        ? countryDirect
        : (countryName ?? '');

    double? lat = (data['latitude'] as num?)?.toDouble();
    double? lng = (data['longitude'] as num?)?.toDouble();
    final loc = data['location'];
    if (loc is GeoPoint) {
      lat ??= loc.latitude;
      lng ??= loc.longitude;
    }
    final parsedGeo = tryParseSalonCoordinates(data);
    lat ??= parsedGeo?.latitude;
    lng ??= parsedGeo?.longitude;

    return CustomerSalonModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      city: data['city'] as String? ?? '',
      area: data['area'] as String? ?? '',
      country: countryResolved,
      address: _addressLine(data),
      latitude: lat,
      longitude: lng,
      isPublished: data['isPublished'] as bool? ?? false,
      isOpen: data['isOpen'] as bool? ?? false,
      isPromoted: data['isPromoted'] as bool? ?? false,
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      distanceKmText: data['distanceKmText'] as String? ?? '',
      priceLevel: data['priceLevel'] as String? ?? '',
      logoUrl: data['logoUrl'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      tags: List<String>.from(data['tags'] ?? const []),
      categoryIds: List<String>.from(data['categoryIds'] ?? const []),
      searchKeywords: List<String>.from(data['searchKeywords'] ?? const []),
      countryCodeIso: (iso != null && iso.isNotEmpty) ? iso : null,
      currencyCode: currency,
      discountText: data['discountText'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'nameLower': name.toLowerCase(),
      'city': city,
      'area': area,
      'country': country,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isPublished': isPublished,
      'isOpen': isOpen,
      'isPromoted': isPromoted,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'distanceKmText': distanceKmText,
      'priceLevel': priceLevel,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'tags': tags,
      'categoryIds': categoryIds,
      'searchKeywords': searchKeywords,
      if (countryCodeIso != null) 'countryCode': countryCodeIso,
      'currencyCode': currencyCode,
      if (discountText != null) 'discountText': discountText,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
