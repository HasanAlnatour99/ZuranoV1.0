import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/booking/availability_schedule.dart';
import '../../../domain/customer_available_today_logic.dart';
import '../../../domain/customer_salon_audience.dart';
import '../../utils/opening_hours_utils.dart';

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
    this.weeklyAvailability,
    this.genderTarget,
    this.hasOffer = false,
    this.searchKeywords = const [],
    this.serviceCategoryIds = const [],
    this.isOpenNowCache,
    this.isClosedToday = false,
    this.isAvailableToday = false,
    this.todayAvailableSlotsCount = 0,
    this.nextAvailableAt,
    this.openingStatusUpdatedAt,
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

  /// Owner weekly hours (`salons/{salonId}` — same shape as [Salon.weeklyAvailability]).
  final WeeklyAvailability? weeklyAvailability;

  /// Optional browse filters (may be absent on older salon docs).
  final String? genderTarget;
  final bool hasOffer;
  final List<String> searchKeywords;
  final List<String> serviceCategoryIds;

  /// Denormalized cache when present (`true` = open now at last write).
  final bool? isOpenNowCache;

  /// Salon does not operate today or owner marked day off.
  final bool isClosedToday;

  /// Denormalized: backend slot aggregation says slots exist today.
  final bool isAvailableToday;

  final int todayAvailableSlotsCount;

  final DateTime? nextAvailableAt;

  final DateTime? openingStatusUpdatedAt;

  /// Discovery filter for “Available today” (not the same as [isOpenNowCache]).
  ///
  /// Uses backend slot fields when present; otherwise approximates from
  /// [weeklyAvailability] until aggregation is deployed.
  bool get meetsAvailableTodayFilter => salonPassesAvailableTodayDiscovery(
        isClosedToday: isClosedToday,
        isAvailableToday: isAvailableToday,
        todayAvailableSlotsCount: todayAvailableSlotsCount,
        openingStatusUpdatedAt: openingStatusUpdatedAt,
        weeklyAvailability: weeklyAvailability,
      );

  /// Open **right now** for discovery chips and “Open now” filter.
  ///
  /// Precedence: denormalized [isOpenNowCache] → legacy [openingHours] map →
  /// [weeklyAvailability] from owner settings. If none apply, closed.
  bool get isOpenNowEffective {
    if (isOpenNowCache != null) {
      return isOpenNowCache!;
    }
    if (openingHours != null && openingHours!.isNotEmpty) {
      return !OpeningHoursUtils.isClosedNow(openingHours);
    }
    if (weeklyAvailability != null) {
      return !OpeningHoursUtils.isClosedNowFromWeeklyAvailability(
        weeklyAvailability!,
      );
    }
    return false;
  }

  factory CustomerPlaceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime? ts(dynamic v) {
      if (v is Timestamp) {
        return v.toDate();
      }
      return null;
    }

    int intField(dynamic v, int fallback) {
      if (v is int) {
        return v;
      }
      if (v is num) {
        return v.round();
      }
      return fallback;
    }

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
      weeklyAvailability:
          WeeklyAvailability.maybeParse(data['weeklyAvailability']),
      genderTarget: readSalonAudienceForCustomers(data),
      hasOffer: data['hasOffer'] == true,
      searchKeywords: keywords,
      serviceCategoryIds: (() {
        final raw = data['serviceCategoryIds'] ?? data['categoryIds'];
        if (raw is List) {
          return raw
              .map((e) => '$e'.trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
        }
        return const <String>[];
      })(),
      isOpenNowCache: data['isOpenNow'] is bool
          ? data['isOpenNow'] as bool
          : null,
      isClosedToday: data['isClosedToday'] == true,
      isAvailableToday: data['isAvailableToday'] == true,
      todayAvailableSlotsCount: intField(data['todayAvailableSlotsCount'], 0),
      nextAvailableAt: ts(data['nextAvailableAt']),
      openingStatusUpdatedAt: ts(data['openingStatusUpdatedAt']),
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
