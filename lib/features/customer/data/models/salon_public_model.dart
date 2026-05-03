import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/currency_for_country.dart';

/// Denormalized public salon row under `publicSalons/{salonId}` for guest browse.
class SalonPublicModel {
  const SalonPublicModel({
    required this.id,
    required this.salonName,
    required this.area,
    required this.currencyCode,
    this.phone,
    this.whatsapp,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    required this.isPublic,
    required this.isActive,
    required this.isOpen,
    required this.ratingAverage,
    required this.ratingCount,
    required this.startingPrice,
    this.genderTarget,
    this.searchKeywords = const [],
    this.areaKeywords = const [],
    this.serviceKeywords = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonName;
  final String area;

  /// ISO 4217 — from public row or derived from `countryCode` when missing.
  final String currencyCode;
  final String? phone;
  final String? whatsapp;
  final String? coverImageUrl;
  final double? latitude;
  final double? longitude;
  final bool isPublic;
  final bool isActive;
  final bool isOpen;
  final double ratingAverage;
  final int ratingCount;
  final double startingPrice;
  final String? genderTarget;

  /// Lowercase tokens for local discovery search (salon + services + area).
  final List<String> searchKeywords;

  /// Area-only tokens (from Cloud Function denormalization).
  final List<String> areaKeywords;

  /// Keywords from visible public services.
  final List<String> serviceKeywords;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  static DateTime? _ts(Timestamp? t) => t?.toDate();

  static double? _nullableDouble(dynamic v) {
    if (v is num) {
      return v.toDouble();
    }
    return null;
  }

  static double _double(dynamic v, double fallback) {
    if (v is num) {
      return v.toDouble();
    }
    return fallback;
  }

  static int _int(dynamic v, int fallback) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.round();
    }
    return fallback;
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory SalonPublicModel.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    final name = (data['salonName'] as String?)?.trim();
    final area = (data['area'] as String?)?.trim();
    final countryIso = (data['countryCode'] as String?)?.trim();
    final rawCcy = (data['currencyCode'] as String?)?.trim();
    final currencyCode = resolvedSalonMoneyCurrency(
      salonCurrencyCode: rawCcy,
      salonCountryIso:
          (countryIso != null && countryIso.isNotEmpty) ? countryIso : null,
    );
    return SalonPublicModel(
      id: doc.id,
      salonName: (name != null && name.isNotEmpty) ? name : 'Salon',
      area: (area != null && area.isNotEmpty) ? area : '',
      currencyCode: currencyCode,
      phone: (data['phone'] as String?)?.trim(),
      whatsapp: (data['whatsapp'] as String?)?.trim(),
      coverImageUrl: (data['coverImageUrl'] as String?)?.trim(),
      latitude: _nullableDouble(data['latitude']),
      longitude: _nullableDouble(data['longitude']),
      isPublic: data['isPublic'] == true,
      isActive: data['isActive'] == true,
      isOpen: data['isOpen'] == true,
      ratingAverage: _double(data['ratingAverage'], 0).clamp(0.0, 5.0),
      ratingCount: _int(data['ratingCount'], 0),
      startingPrice: _double(data['startingPrice'], 0),
      genderTarget: (data['genderTarget'] as String?)?.trim().toLowerCase(),
      searchKeywords: _stringList(data['searchKeywords']),
      areaKeywords: _stringList(data['areaKeywords']),
      serviceKeywords: _stringList(data['serviceKeywords']),
      createdAt: _ts(data['createdAt'] as Timestamp?),
      updatedAt: _ts(data['updatedAt'] as Timestamp?),
    );
  }
}
