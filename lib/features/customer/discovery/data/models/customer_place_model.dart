import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer-facing salon row from `salons/{salonId}` for discovery cards.
class CustomerPlaceModel {
  const CustomerPlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.city,
    required this.addressText,
    required this.coverImageUrl,
    this.logoUrl,
    required this.isActive,
    required this.isPublic,
    required this.isPublished,
    required this.ratingAvg,
    required this.ratingCount,
    required this.minServicePrice,
    required this.currency,
    this.location,
    this.openingHours,
    this.genderTarget,
    this.hasOffer = false,
    this.searchKeywords = const [],
    this.isOpenNowCache,
  });

  final String id;
  final String name;
  final String type;
  final String area;
  final String city;
  final String addressText;
  final String coverImageUrl;
  final String? logoUrl;
  final bool isActive;
  final bool isPublic;
  final bool isPublished;
  final double ratingAvg;
  final int ratingCount;
  final double minServicePrice;
  final String currency;
  final GeoPoint? location;
  final Map<String, dynamic>? openingHours;

  /// Optional browse filters (may be absent on older salon docs).
  final String? genderTarget;
  final bool hasOffer;
  final List<String> searchKeywords;

  /// Denormalized cache when present (`true` = open now at last write).
  final bool? isOpenNowCache;

  factory CustomerPlaceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final keywordsRaw = data['searchKeywords'];
    final keywords = <String>[];
    if (keywordsRaw is List) {
      for (final e in keywordsRaw) {
        if (e != null) {
          keywords.add(e.toString());
        }
      }
    }

    return CustomerPlaceModel(
      id: doc.id,
      name: (data['salonName'] ?? data['name'] ?? 'Unknown place').toString(),
      type: (data['type'] ?? data['businessType'] ?? 'salon').toString(),
      area: (data['area'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      addressText: (data['addressText'] ?? '').toString(),
      coverImageUrl:
          (data['coverImageUrl'] ?? data['imageUrl'] ?? '').toString(),
      logoUrl: data['logoUrl']?.toString(),
      isActive: data['isActive'] == true,
      isPublic: data['isPublic'] == true,
      isPublished: data['isPublished'] == true,
      ratingAvg: ((data['ratingAvg'] ??
              data['ratingAverage'] ??
              data['rating'] ??
              0) as num)
          .toDouble(),
      ratingCount:
          ((data['ratingCount'] ?? data['reviewsCount'] ?? 0) as num).toInt(),
      minServicePrice: ((data['minServicePrice'] ?? 0) as num).toDouble(),
      currency: (data['currency'] ??
              data['currencyCode'] ??
              'QAR')
          .toString(),
      location: data['location'] is GeoPoint
          ? data['location'] as GeoPoint
          : null,
      openingHours: data['openingHours'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['openingHours'] as Map)
          : null,
      genderTarget: data['genderTarget']?.toString(),
      hasOffer: data['hasOffer'] == true,
      searchKeywords: keywords,
      isOpenNowCache: data['isOpenNow'] is bool
          ? data['isOpenNow'] as bool
          : null,
    );
  }

  String get displayLocation {
    if (area.isNotEmpty && city.isNotEmpty) {
      return '$area, $city';
    }
    if (addressText.isNotEmpty) {
      return addressText;
    }
    if (city.isNotEmpty) {
      return city;
    }
    return '';
  }

  /// Plain numeric amount for localized “From” rows.
  String get formattedMinPriceAmount {
    final v = minServicePrice;
    if (v % 1 == 0) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(2);
  }
}
