import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../customer_home/domain/salon_coordinates.dart';
import '../domain/models/customer_search_filter.dart';
import '../domain/models/customer_search_result.dart';

int? _optionalNonNegativeInt(Map<String, dynamic> data, List<String> keys) {
  for (final k in keys) {
    final v = data[k];
    if (v is num) {
      final i = v.round();
      if (i >= 0) {
        return i;
      }
    }
  }
  return null;
}

/// Lowercases, trims, and collapses runs of whitespace to a single space.
///
/// Used to keep the customer search query in lock-step with the
/// `searchPrefixes` / `searchKeywords` tokens written by Cloud Functions —
/// see [`functions/src/customerSearchIndex.ts`].
@visibleForTesting
String normalizeCustomerSearchQuery(String raw) {
  final lowered = raw.toLowerCase().trim();
  if (lowered.isEmpty) {
    return '';
  }
  return lowered.replaceAll(RegExp(r'\s+'), ' ');
}

class CustomerSearchRepository {
  CustomerSearchRepository(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<CustomerSearchResult>> search(CustomerSearchFilter filter) async {
    final cc = filter.countryCode.trim().toUpperCase();
    if (cc.isEmpty) {
      throw ArgumentError.value(filter.countryCode, 'countryCode', 'Country code is required.');
    }

    final queryText = normalizeCustomerSearchQuery(filter.query);

    Query<Map<String, dynamic>> query = firestore
        .collection(FirestorePaths.customerSearchIndex)
        .where('countryCode', isEqualTo: cc)
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(30);

    // Prefix-friendly matching: Cloud Functions write `searchPrefixes` (an array
    // of progressively longer prefixes per token) so a single-letter typeahead
    // still hits Firestore's `arrayContains` index. Falls back gracefully when
    // older rows only carry `searchKeywords` because the controller widens the
    // visible list locally.
    if (queryText.isNotEmpty) {
      query = query.where('searchPrefixes', arrayContains: queryText);
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

    if (filter.availableTodayOnly) {
      query = query.where('availableToday', isEqualTo: true);
    }

    final snapshot = await query.get();
    var results = snapshot.docs
        .map(
          (doc) => _CustomerSearchResultDto.fromFirestore(doc).toDomain(
                userLatitude: filter.userLatitude,
                userLongitude: filter.userLongitude,
              ),
        )
        .toList();

    if (results.isEmpty) {
      results = await _searchPublicSalonsFallback(filter);
    }

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

    final sortByDistance =
        filter.sort == CustomerSearchSort.nearby || filter.nearbyOnly;
    if (sortByDistance) {
      _sortSearchResultsByDistance(results);
    }

    return results;
  }

  static const double _kNoDistanceSortKey = 1e9;

  static void _sortSearchResultsByDistance(List<CustomerSearchResult> results) {
    double rank(CustomerSearchResult r) {
      final d = r.distanceKm;
      if (d != null) {
        return d;
      }
      return _kNoDistanceSortKey;
    }

    results.sort((a, b) {
      final c = rank(a).compareTo(rank(b));
      if (c != 0) {
        return c;
      }
      return (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0);
    });
  }

  /// When `customerSearchIndex` has no rows yet (Functions/backfill), surface real salons.
  ///
  /// `firestore.rules` requires public salon reads to satisfy
  /// `isActive && isPublished && isPublic`, so all three flags must be on the
  /// query — otherwise customers get `permission-denied` instead of an empty
  /// list. See `firestore.rules` (publicSalons match).
  Future<List<CustomerSearchResult>> _searchPublicSalonsFallback(
    CustomerSearchFilter filter,
  ) async {
    final cc = filter.countryCode.trim().toUpperCase();
    final snap = await firestore
        .collection(FirestorePaths.publicSalons)
        .where('countryCode', isEqualTo: cc)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(50)
        .get();

    var mapped = snap.docs
        .map(
          (doc) => _CustomerSearchResultDto.fromPublicSalonDoc(
            doc.id,
            doc.data(),
          ).toDomain(
            userLatitude: filter.userLatitude,
            userLongitude: filter.userLongitude,
          ),
        )
        .toList();

    final q = normalizeCustomerSearchQuery(filter.query);
    if (q.isNotEmpty) {
      mapped = mapped.where((r) {
        if (r.title.toLowerCase().contains(q)) {
          return true;
        }
        if (r.subtitle.toLowerCase().contains(q)) {
          return true;
        }
        if (r.city.toLowerCase().contains(q)) {
          return true;
        }
        if (r.area.toLowerCase().contains(q)) {
          return true;
        }
        for (final k in r.searchKeywords) {
          if (k.contains(q)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    if (filter.openNowOnly) {
      mapped = mapped.where((r) => r.isOpenNow).toList();
    }
    if (filter.offersOnly) {
      mapped = mapped.where((r) => r.hasOffer).toList();
    }
    if (filter.availableTodayOnly) {
      // `publicSalons` rows do not yet expose availability — the salon-level
      // mirror only knows opening hours. Fall back to "open now" so an empty
      // index does not mask the chip entirely.
      mapped = mapped.where((r) => r.isOpenNow).toList();
    }

    if (kDebugMode) {
      debugPrint(
        '[CustomerSearch] publicSalons fallback countryCode=$cc '
        'query="$q" results=${mapped.length}',
      );
    }

    return mapped;
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
    required this.availableToday,
    this.imageUrl,
    this.ratingAvg,
    this.ratingCount,
    this.distanceKm,
    this.priceFrom,
    this.salonLatitude,
    this.salonLongitude,
    this.serviceCount,
    this.teamCount,
    this.nextAvailableAt,
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

  /// WGS84 when present on index / `publicSalons` (for client-side distance).
  final double? salonLatitude;
  final double? salonLongitude;

  final int? serviceCount;
  final int? teamCount;

  /// Cloud-Functions-derived availability flag (`availableToday == true` means
  /// the salon/specialist has at least one bookable slot in the customer's day).
  final bool availableToday;

  /// Earliest bookable slot timestamp, when known.
  final DateTime? nextAvailableAt;

  CustomerSearchResult toDomain({
    double? userLatitude,
    double? userLongitude,
  }) {
    double? dist = distanceKm;
    if (userLatitude != null &&
        userLongitude != null &&
        salonLatitude != null &&
        salonLongitude != null) {
      dist = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            salonLatitude!,
            salonLongitude!,
          ) /
          1000.0;
    }
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
      distanceKm: dist,
      priceFrom: priceFrom,
      isOpenNow: isOpenNow,
      hasOffer: hasOffer,
      audience: audience,
      searchKeywords: searchKeywords,
      isActive: isActive,
      isPublic: isPublic,
      serviceCount: serviceCount,
      teamCount: teamCount,
      availableToday: availableToday,
      nextAvailableAt: nextAvailableAt,
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

  factory _CustomerSearchResultDto.fromPublicSalonDoc(
    String docId,
    Map<String, dynamic> data,
  ) {
    final salonIdRaw = FirestoreSerializers.string(data['salonId']);
    final salonId =
        (salonIdRaw != null && salonIdRaw.trim().isNotEmpty)
        ? salonIdRaw.trim()
        : docId;
    final title =
        (FirestoreSerializers.string(data['salonName']) ??
                FirestoreSerializers.string(data['name']) ??
                '')
            .trim();
    final city = (FirestoreSerializers.string(data['city']) ?? '').trim();
    final area = (FirestoreSerializers.string(data['area']) ?? '').trim();
    final countryName =
        (FirestoreSerializers.string(data['countryName']) ??
                FirestoreSerializers.string(data['country']) ??
                '')
            .trim();
    final cc =
        (FirestoreSerializers.string(data['countryCode']) ?? '').trim().toUpperCase();
    final subtitle = [area, city].where((s) => s.isNotEmpty).join(', ');
    final keywords = (data['searchKeywords'] is List)
        ? (data['searchKeywords'] as List)
            .map((e) => '$e'.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList(growable: false)
        : const <String>[];
    final ratingAvg = FirestoreSerializers.doubleValue(data['ratingAverage']);
    final ratingCount = (data['ratingCount'] is num)
        ? (data['ratingCount'] as num).toInt()
        : null;
    final priceFrom = data['startingPrice'] is num ? data['startingPrice'] as num : null;
    final geo = tryParseSalonCoordinates(data);

    return _CustomerSearchResultDto(
      id: 'fallback_salon_$salonId',
      salonId: salonId,
      targetId: salonId,
      type: 'salon',
      title: title.isNotEmpty ? title : 'Salon',
      subtitle: subtitle,
      countryCode: cc,
      countryName: countryName,
      city: city,
      area: area,
      imageUrl: FirestoreSerializers.string(data['coverImageUrl']) ??
          FirestoreSerializers.string(data['logoUrl']),
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      distanceKm: null,
      priceFrom: priceFrom,
      isOpenNow: data['isOpen'] == true,
      hasOffer: data['hasOffer'] == true,
      audience: 'unisex',
      searchKeywords: keywords,
      isActive: data['isActive'] != false,
      isPublic: data['isPublic'] == true,
      availableToday: data['availableToday'] == true,
      nextAvailableAt: _readTimestamp(data['nextAvailableAt']),
      salonLatitude: geo?.latitude,
      salonLongitude: geo?.longitude,
      serviceCount: _optionalNonNegativeInt(
        Map<String, dynamic>.from(data),
        const ['serviceCount', 'servicesCount', 'activeServiceCount'],
      ),
      teamCount: _optionalNonNegativeInt(
        Map<String, dynamic>.from(data),
        const ['teamCount', 'teamSize', 'staffCount', 'employeeCount', 'activeTeamCount'],
      ),
    );
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
    final geo = tryParseSalonCoordinates(data);

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
      availableToday: data['availableToday'] == true,
      nextAvailableAt: _readTimestamp(data['nextAvailableAt']),
      salonLatitude: geo?.latitude,
      salonLongitude: geo?.longitude,
      serviceCount: _optionalNonNegativeInt(
        data,
        const ['serviceCount', 'servicesCount', 'activeServiceCount'],
      ),
      teamCount: _optionalNonNegativeInt(
        data,
        const ['teamCount', 'teamSize', 'staffCount', 'employeeCount', 'activeTeamCount'],
      ),
    );
  }
}

DateTime? _readTimestamp(Object? raw) {
  if (raw is Timestamp) {
    return raw.toDate();
  }
  if (raw is DateTime) {
    return raw;
  }
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw);
  }
  return null;
}
