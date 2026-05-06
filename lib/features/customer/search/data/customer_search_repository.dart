import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../domain/models/customer_search_filter.dart';
import '../domain/models/customer_search_result.dart';

class CustomerSearchRepository {
  CustomerSearchRepository(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<CustomerSearchResult>> search(CustomerSearchFilter filter) async {
    final cc = filter.countryCode.trim().toUpperCase();
    if (cc.isEmpty) {
      throw ArgumentError.value(filter.countryCode, 'countryCode', 'Country code is required.');
    }

    final queryText = filter.query.trim().toLowerCase();

    Query<Map<String, dynamic>> query = firestore
        .collection(FirestorePaths.customerSearchIndex)
        .where('countryCode', isEqualTo: cc)
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(30);

    if (queryText.isNotEmpty) {
      query = query.where('searchKeywords', arrayContains: queryText);
    }

    if (filter.audience != null) {
      query = query.where('audience', whereIn: [filter.audience, 'unisex']);
    }

    if (filter.openNowOnly) {
      query = query.where('isOpenNow', isEqualTo: true);
    }

    if (filter.offersOnly) {
      query = query.where('hasOffer', isEqualTo: true);
    }

    final snapshot = await query.get();
    final results = snapshot.docs
        .map((doc) => _CustomerSearchResultDto.fromFirestore(doc).toDomain())
        .toList();

    if (kDebugMode) {
      final mismatch = results.where((r) => r.countryCode.toUpperCase() != cc).length;
      if (mismatch > 0) {
        debugPrint(
          '[CustomerSearch] blocked cross-country results by country filter '
          '(unexpected=$mismatch)',
        );
      }
      debugPrint(
        '[CustomerSearch] countryCode=$cc query=$queryText results=${results.length}',
      );
    }

    switch (filter.sort) {
      case CustomerSearchSort.priceLowToHigh:
        results.sort(
          (a, b) => (a.priceFrom ?? 999999).compareTo(b.priceFrom ?? 999999),
        );
        break;
      case CustomerSearchSort.priceHighToLow:
        results.sort((a, b) => (b.priceFrom ?? 0).compareTo(a.priceFrom ?? 0));
        break;
      case CustomerSearchSort.topRated:
        results.sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
        break;
      case CustomerSearchSort.offers:
        results.sort((a, b) => (b.hasOffer ? 1 : 0).compareTo(a.hasOffer ? 1 : 0));
        break;
      case CustomerSearchSort.openNow:
        results.sort((a, b) => (b.isOpenNow ? 1 : 0).compareTo(a.isOpenNow ? 1 : 0));
        break;
      case CustomerSearchSort.nearby:
      case CustomerSearchSort.recommended:
        break;
    }

    return results;
  }
}

class _CustomerSearchResultDto {
  const _CustomerSearchResultDto({
    required this.id,
    required this.salonId,
    required this.targetId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.countryCode,
    required this.countryName,
    required this.city,
    required this.area,
    required this.searchKeywords,
    required this.isOpenNow,
    required this.hasOffer,
    required this.audience,
    required this.isActive,
    required this.isPublic,
    this.imageUrl,
    this.ratingAvg,
    this.ratingCount,
    this.distanceKm,
    this.priceFrom,
  });

  final String id;
  final String salonId;
  final String targetId;
  final String type;
  final String title;
  final String subtitle;
  final String countryCode;
  final String countryName;
  final String city;
  final String area;
  final String? imageUrl;
  final double? ratingAvg;
  final int? ratingCount;
  final double? distanceKm;
  final num? priceFrom;
  final bool isOpenNow;
  final bool hasOffer;
  final String audience;
  final List<String> searchKeywords;
  final bool isActive;
  final bool isPublic;

  CustomerSearchResult toDomain() {
    return CustomerSearchResult(
      id: id,
      salonId: salonId,
      targetId: targetId,
      type: _parseType(type),
      title: title,
      subtitle: subtitle,
      countryCode: countryCode,
      countryName: countryName,
      city: city,
      area: area,
      imageUrl: imageUrl,
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      distanceKm: distanceKm,
      priceFrom: priceFrom,
      isOpenNow: isOpenNow,
      hasOffer: hasOffer,
      audience: audience,
      searchKeywords: searchKeywords,
      isActive: isActive,
      isPublic: isPublic,
    );
  }

  static CustomerSearchResultType _parseType(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'salon':
        return CustomerSearchResultType.salon;
      case 'service':
        return CustomerSearchResultType.service;
      case 'specialist':
        return CustomerSearchResultType.specialist;
      default:
        return CustomerSearchResultType.salon;
    }
  }

  factory _CustomerSearchResultDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final salonId = FirestoreSerializers.string(data['salonId']) ?? '';
    final targetRaw = FirestoreSerializers.string(data['targetId']);
    final targetId =
        (targetRaw != null && targetRaw.isNotEmpty) ? targetRaw : salonId;
    final cc =
        (FirestoreSerializers.string(data['countryCode']) ?? '').trim().toUpperCase();

    return _CustomerSearchResultDto(
      id: doc.id,
      salonId: salonId,
      targetId: targetId,
      type: FirestoreSerializers.string(data['type']) ?? 'salon',
      title: FirestoreSerializers.string(data['title']) ?? '',
      subtitle: FirestoreSerializers.string(data['subtitle']) ?? '',
      countryCode: cc,
      countryName:
          (FirestoreSerializers.string(data['countryName']) ?? '').trim(),
      city: (FirestoreSerializers.string(data['city']) ?? '').trim(),
      area: (FirestoreSerializers.string(data['area']) ?? '').trim(),
      imageUrl: FirestoreSerializers.string(data['imageUrl']),
      ratingAvg: FirestoreSerializers.doubleValue(data['ratingAvg']) == 0
          ? (data['ratingAvg'] is num ? (data['ratingAvg'] as num).toDouble() : null)
          : FirestoreSerializers.doubleValue(data['ratingAvg']),
      ratingCount: (data['ratingCount'] is num)
          ? (data['ratingCount'] as num).toInt()
          : null,
      distanceKm: (data['distanceKm'] is num)
          ? (data['distanceKm'] as num).toDouble()
          : null,
      priceFrom: data['priceFrom'] is num ? data['priceFrom'] as num : null,
      isOpenNow: data['isOpenNow'] == true,
      hasOffer: data['hasOffer'] == true,
      isActive: data['isActive'] != false,
      isPublic: data['isPublic'] == true,
      audience: (FirestoreSerializers.string(data['audience']) ?? 'unisex')
          .trim()
          .toLowerCase(),
      searchKeywords: (data['searchKeywords'] is List)
          ? (data['searchKeywords'] as List)
              .map((e) => '$e'.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList(growable: false)
          : const <String>[],
    );
  }
}
