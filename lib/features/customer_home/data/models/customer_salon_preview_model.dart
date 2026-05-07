import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/salon_coordinates.dart';
import 'customer_salon_model.dart';

/// Guest-safe salon row for customer discovery lists (`publicSalons` / mirrored data).
class CustomerSalonPreviewModel {
  const CustomerSalonPreviewModel({
    required this.salonId,
    required this.salonName,
    required this.area,
    required this.city,
    required this.addressText,
    required this.coverImageUrl,
    required this.logoUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.searchKeywords,
    required this.categoryIds,
    required this.country,
    this.countryCodeIso,
    this.createdAt,
    required this.isPublished,
    required this.publicProfileEnabled,
  });

  final String salonId;
  final String salonName;
  final String area;
  final String city;
  final String addressText;
  final String coverImageUrl;
  final String logoUrl;
  final double ratingAvg;
  final int ratingCount;
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final List<String> searchKeywords;
  final List<String> categoryIds;
  final String country;
  final String? countryCodeIso;
  final Timestamp? createdAt;
  final bool isPublished;
  final bool publicProfileEnabled;

  bool get isVisibleForRecommended =>
      isPublished || publicProfileEnabled;

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

  static CustomerSalonPreviewModel fromPublicSalonDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final id = doc.id;

    final name = (data['salonName'] as String?)?.trim().isNotEmpty == true
        ? (data['salonName'] as String).trim()
        : (data['name'] as String?)?.trim() ?? '';

    final cover = (data['coverImageUrl'] as String?)?.trim().isNotEmpty == true
        ? (data['coverImageUrl'] as String).trim()
        : (data['imageUrl'] as String?)?.trim().isNotEmpty == true
        ? (data['imageUrl'] as String).trim()
        : (data['photoUrl'] as String?)?.trim() ?? '';

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

    final ratingRaw =
        data['ratingAvg'] ??
        data['averageRating'] ??
        data['ratingAverage'] ??
        data['rating'];
    final ratingAvg = (ratingRaw as num?)?.toDouble() ?? 0;

    final countRaw =
        data['ratingCount'] ?? data['reviewsCount'] ?? data['reviewCount'];
    final ratingCount = (countRaw as num?)?.toInt() ?? 0;

    final tagsRaw = List<String>.from(data['tags'] ?? const <String>[]);
    final tags = tagsRaw.isNotEmpty
        ? tagsRaw
        : (ratingAvg >= 4.5 ? <String>['Top rated'] : <String>[]);

    final pubRaw = data['isPublished'];
    final profRaw = data['publicProfileEnabled'];
    late final bool isPublished;
    late final bool publicProfileEnabled;
    if (pubRaw == null && profRaw == null) {
      isPublished = true;
      publicProfileEnabled = false;
    } else {
      isPublished = pubRaw == true;
      publicProfileEnabled = profRaw == true;
    }

    final iso = (data['countryCode'] as String?)?.trim();

    return CustomerSalonPreviewModel(
      salonId: (data['salonId'] as String?)?.trim().isNotEmpty == true
          ? (data['salonId'] as String).trim()
          : id,
      salonName: name,
      area: (data['area'] as String?)?.trim() ?? '',
      city: (data['city'] as String?)?.trim() ?? '',
      addressText: _addressLine(data),
      coverImageUrl: cover,
      logoUrl: (data['logoUrl'] as String?)?.trim() ?? '',
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      tags: tags,
      latitude: lat,
      longitude: lng,
      searchKeywords: List<String>.from(
        data['searchKeywords'] ?? const <String>[],
      ),
      categoryIds: List<String>.from(
        data['categoryIds'] ?? const <String>[],
      ),
      country:
          (data['countryName'] as String?)?.trim() ??
          (data['country'] as String?)?.trim() ??
          '',
      countryCodeIso: (iso != null && iso.isNotEmpty) ? iso : null,
      createdAt: data['createdAt'] as Timestamp?,
      isPublished: isPublished,
      publicProfileEnabled: publicProfileEnabled,
    );
  }

  factory CustomerSalonPreviewModel.fromSalonModel(
    CustomerSalonModel s, {
    Timestamp? createdAt,
  }) {
    final tags = s.tags.isNotEmpty
        ? s.tags
        : (s.ratingAverage >= 4.5 ? <String>['Top rated'] : <String>[]);
    return CustomerSalonPreviewModel(
      salonId: s.id,
      salonName: s.name,
      area: s.area,
      city: s.city,
      addressText: s.address,
      coverImageUrl: s.coverImageUrl,
      logoUrl: s.logoUrl,
      ratingAvg: s.ratingAverage,
      ratingCount: s.ratingCount,
      tags: tags,
      latitude: s.latitude,
      longitude: s.longitude,
      searchKeywords: s.searchKeywords,
      categoryIds: s.categoryIds,
      country: s.country,
      countryCodeIso: s.countryCodeIso,
      createdAt: createdAt,
      isPublished: s.isPublished,
      publicProfileEnabled: false,
    );
  }

  static String _addressLine(Map<String, dynamic> data) {
    final raw = data['address'];
    if (raw is String) {
      return raw.trim();
    }
    final at = data['addressText'];
    if (at is String && at.trim().isNotEmpty) {
      return at.trim();
    }
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final formatted =
          (m['formattedAddress'] as String?)?.trim() ??
          (m['formatted'] as String?)?.trim();
      if (formatted != null && formatted.isNotEmpty) {
        return formatted;
      }
    }
    return '';
  }
}
