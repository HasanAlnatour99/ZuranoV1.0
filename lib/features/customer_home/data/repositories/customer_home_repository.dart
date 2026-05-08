import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import '../../../../core/firestore/firestore_paths.dart';
import '../../domain/customer_discovery_country_match.dart';
import '../../domain/customer_geo.dart';
import '../../domain/salon_coordinates.dart';
import '../models/customer_banner_model.dart';
import '../models/customer_category_model.dart';
import '../models/customer_salon_model.dart';
import '../models/customer_salon_preview_model.dart';
import '../models/discovery_service_category_model.dart';
import '../models/public_salon_model.dart';
import '../models/public_specialist_discovery_model.dart';
import '../models/public_specialist_model.dart';
import '../models/service_category_model.dart';
import '../models/trending_service_model.dart';

/// Customer discovery reads for Zurano home.
///
/// Suggested security rules (align with client queries):
/// - `publicSalons/{id}`: `allow read` when `isActive == true && isPublic == true`.
/// - `customerDiscovery/serviceCategories/items/{id}`: `allow read` when `isActive == true`
///   (and list queries stay within your `limit` cap, as in [customerHomeQueryLimitBounded]).
/// - `users/{uid}/favorites/{salonId}`: `allow read, write` when `request.auth.uid == uid`
///   (anonymous Auth still has a uid).
class CustomerHomeRepository {
  CustomerHomeRepository(this._db);

  final FirebaseFirestore _db;

  /// Case-insensitive match against `CustomerSalonModel.categoryIds`.
  static List<CustomerSalonPreviewModel> _filterPreviewsByCategoryId(
    List<CustomerSalonPreviewModel> parsed,
    String? categoryId,
  ) {
    final id = categoryId?.trim() ?? '';
    if (id.isEmpty || id.toLowerCase() == 'all') {
      return parsed;
    }
    final want = id.toLowerCase();
    return parsed
        .where(
          (s) => s.categoryIds.any(
            (c) => c.trim().toLowerCase() == want,
          ),
        )
        .toList(growable: false);
  }

  static List<CustomerSalonModel> _filterSalonsByCategoryId(
    List<CustomerSalonModel> parsed,
    String? categoryId,
  ) {
    final id = categoryId?.trim() ?? '';
    if (id.isEmpty || id.toLowerCase() == 'all') {
      return parsed;
    }
    final want = id.toLowerCase();
    return parsed
        .where(
          (s) => s.categoryIds.any(
            (c) => c.trim().toLowerCase() == want,
          ),
        )
        .toList(growable: false);
  }

  CollectionReference<Map<String, dynamic>> get _categoriesItems => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryCategoriesDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  CollectionReference<Map<String, dynamic>> get _trendingItems => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryTrendingServicesDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  CollectionReference<Map<String, dynamic>> get _bannerItems => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryBannersDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  CollectionReference<Map<String, dynamic>> get _serviceCategoriesItems => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryServiceCategoriesDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  CollectionReference<Map<String, dynamic>> get _publicSpecialists =>
      _db.collection(FirestorePaths.publicSpecialists);

  /// Canonical customer discovery sources (production paths).
  ///
  /// Customer app reads these and ONLY these for the home screen:
  ///  - `publicSalons/{salonId}`
  ///  - `customerDiscovery/categories/items/{categoryId}`
  ///  - `customerDiscovery/specialists/items/{specialistId}`
  CollectionReference<Map<String, dynamic>> get _publicSalons =>
      _db.collection(FirestorePaths.publicSalons);

  CollectionReference<Map<String, dynamic>> get _discoveryCategories => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryCategoriesDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  CollectionReference<Map<String, dynamic>> get _discoverySpecialists => _db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoverySpecialistsDoc)
      .collection(FirestorePaths.customerDiscoveryItems);

  /// Production: nearby salons for the home screen, scoped by visibility flags.
  ///
  /// Reads `publicSalons` where `isActive == true`, `isPublished == true`,
  /// `isPublic == true`, capped at `limit`. Geo / category filtering and
  /// distance ordering happen in the provider/UI layer.
  Stream<List<PublicSalonModel>> watchNearbyPublicSalons({int limit = 100}) {
    return _publicSalons
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicSalonModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Production: customer-safe service categories for the home scroller.
  Stream<List<ServiceCategoryModel>> watchServiceCategories({int limit = 32}) {
    return _discoveryCategories
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ServiceCategoryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Production: specialists with at least one open slot for the salon's
  /// current business day (server-computed `availableToday == true`).
  Stream<List<PublicSpecialistDiscoveryModel>> watchAvailableTodaySpecialists({
    int limit = 20,
  }) {
    return _discoverySpecialists
        .where('isActive', isEqualTo: true)
        .where('visibleToCustomers', isEqualTo: true)
        .where('acceptsBookings', isEqualTo: true)
        .where('availableToday', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicSpecialistDiscoveryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Production: recommended specialists (customer-safe read model only).
  ///
  /// Excludes the `availableToday` filter so the carousel still has rows
  /// outside business hours. UI may further refine by rating/sortOrder.
  Stream<List<PublicSpecialistDiscoveryModel>> watchRecommendedDiscoverySpecialists({
    int limit = 10,
  }) {
    return _discoverySpecialists
        .where('isActive', isEqualTo: true)
        .where('visibleToCustomers', isEqualTo: true)
        .where('acceptsBookings', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicSpecialistDiscoveryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<CustomerCategoryModel>> watchCategories() {
    return _categoriesItems
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(CustomerCategoryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Single source for home lists: `salons/*` with `isPublished` (aligns with security rules).
  /// Country / legacy field mismatches are handled in memory via [preferCountryFilteredElseAll].
  Stream<List<CustomerSalonModel>> _watchPublishedSalonsForDiscovery({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    final limit = 100;
    final cc = customerCountryCode.trim().toUpperCase();
    final publicQuery = _db
        .collection(FirestorePaths.publicSalons)
        .where('countryCode', isEqualTo: cc)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(limit);

    final fallbackSalonRootQuery = _db
        .collection(FirestorePaths.salons)
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('countryCode', isEqualTo: cc)
        .limit(limit);

    return (() async* {
      await for (final snapshot in publicQuery.snapshots()) {
        if (kDebugMode) {
          debugPrint(
            '[CustomerHome] publicSalons country=$cc raw=${snapshot.docs.length}',
          );
        }

        var parsed = snapshot.docs.map((doc) {
          final data = doc.data();
          final parsedGeo = tryParseSalonCoordinates(data);
          final lat = (data['latitude'] as num?)?.toDouble() ?? parsedGeo?.latitude;
          final lng = (data['longitude'] as num?)?.toDouble() ?? parsedGeo?.longitude;
          return CustomerSalonModel(
            id: doc.id,
            name: (data['salonName'] as String?)?.trim() ?? '',
            city: (data['city'] as String?)?.trim() ?? '',
            area: (data['area'] as String?)?.trim() ?? '',
            country:
                (data['countryName'] as String?)?.trim() ??
                (data['country'] as String?)?.trim() ??
                discoveryCountryName,
            address: CustomerSalonModel.discoveryAddressLine(data),
            latitude: lat,
            longitude: lng,
            isPublished: true,
            isOpen: data['isOpen'] == true,
            isPromoted: data['isPromoted'] == true,
            ratingAverage: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
            ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
            distanceKmText: (data['distanceKmText'] as String?)?.trim() ?? '',
            priceLevel: (data['priceLevel'] as String?)?.trim() ?? '',
            logoUrl: (data['logoUrl'] as String?)?.trim() ?? '',
            coverImageUrl: (data['coverImageUrl'] as String?)?.trim() ?? '',
            tags: List<String>.from(data['tags'] ?? const <String>[]),
            categoryIds: List<String>.from(
              data['categoryIds'] ?? const <String>[],
            ),
            searchKeywords: List<String>.from(
              data['searchKeywords'] ?? const <String>[],
            ),
            countryCodeIso: (data['countryCode'] as String?)?.trim(),
            currencyCode: (data['currencyCode'] as String?)?.trim() ?? 'USD',
            discountText: (data['discountText'] as String?)?.trim(),
          );
        }).toList(growable: false);

        // If `publicSalons` is empty (or not yet mirrored), fall back to published salon root docs.
        if (parsed.isEmpty) {
          try {
            final fallback = await fallbackSalonRootQuery.get();
            if (kDebugMode) {
              debugPrint(
                '[CustomerHome] fallback salons/* raw=${fallback.docs.length}',
              );
            }
            parsed = fallback.docs
                .map(CustomerSalonModel.fromFirestore)
                .where((s) => s.isPublished)
                .toList(growable: false);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[CustomerHome] fallback salons/* failed: $e');
            }
          }
        }

        // Category filtering is optional on public docs; apply client-side for resilience.
        var categoryFiltered = _filterSalonsByCategoryId(parsed, categoryId);

        // If CMS categories are set but `publicSalons` never got `categoryIds`, the filter
        // would hide every salon. Only then fall back to the full in-country list.
        if (categoryFiltered.isEmpty &&
            parsed.isNotEmpty &&
            categoryId != null &&
            categoryId.trim().isNotEmpty &&
            categoryId != 'all') {
          final noCategoryData = parsed.every((s) => s.categoryIds.isEmpty);
          if (noCategoryData) {
            if (kDebugMode) {
              debugPrint(
                '[CustomerHome] category=$categoryId: no categoryIds on publicSalons; '
                'showing all salons for country',
              );
            }
            categoryFiltered = parsed;
          }
        }

        yield preferCountryFilteredElseAll(
          categoryFiltered,
          discoveryCountryName,
          customerCountryCode: cc,
        );
      }
    })();
  }

  /// Same sources as [_watchPublishedSalonsForDiscovery], mapped to [CustomerSalonPreviewModel]
  /// for the premium home sections (visibility + defensive fields).
  Stream<List<CustomerSalonPreviewModel>> _watchSalonPreviewsForDiscovery({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    final limit = 100;
    final cc = customerCountryCode.trim().toUpperCase();
    final publicQuery = _db
        .collection(FirestorePaths.publicSalons)
        .where('countryCode', isEqualTo: cc)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .limit(limit);

    final fallbackSalonRootQuery = _db
        .collection(FirestorePaths.salons)
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .where('countryCode', isEqualTo: cc)
        .limit(limit);

    return (() async* {
      await for (final snapshot in publicQuery.snapshots()) {
        if (kDebugMode) {
          debugPrint(
            '[CustomerHome] preview publicSalons country=$cc raw=${snapshot.docs.length}',
          );
        }

        var parsed = snapshot.docs
            .map(CustomerSalonPreviewModel.fromPublicSalonDoc)
            .toList(growable: false);

        if (parsed.isEmpty) {
          try {
            final fallback = await fallbackSalonRootQuery.get();
            if (kDebugMode) {
              debugPrint(
                '[CustomerHome] preview fallback salons/* raw=${fallback.docs.length}',
              );
            }
            parsed = fallback.docs
                .map((doc) {
                  final salon = CustomerSalonModel.fromFirestore(doc);
                  final ts = doc.data()['createdAt'] as Timestamp?;
                  return CustomerSalonPreviewModel.fromSalonModel(
                    salon,
                    createdAt: ts,
                  );
                })
                .where((s) => s.isVisibleForRecommended)
                .toList(growable: false);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('[CustomerHome] preview fallback salons/* failed: $e');
            }
          }
        }

        var categoryFiltered = _filterPreviewsByCategoryId(parsed, categoryId);

        if (categoryFiltered.isEmpty &&
            parsed.isNotEmpty &&
            categoryId != null &&
            categoryId.trim().isNotEmpty &&
            categoryId != 'all') {
          final noCategoryData = parsed.every((s) => s.categoryIds.isEmpty);
          if (noCategoryData) {
            if (kDebugMode) {
              debugPrint(
                '[CustomerHome] preview category=$categoryId: no categoryIds; '
                'showing all salons for country',
              );
            }
            categoryFiltered = parsed;
          }
        }

        yield preferCountryFilteredElseAllPreview(
          categoryFiltered,
          discoveryCountryName,
          customerCountryCode: cc,
        );
      }
    })();
  }

  List<CustomerSalonPreviewModel> _sortRecommendedPreviews(
    List<CustomerSalonPreviewModel> list,
  ) {
    final visible = list.where((p) => p.isVisibleForRecommended).toList();
    final out = [...visible];
    out.sort((a, b) {
      final r = b.ratingAvg.compareTo(a.ratingAvg);
      if (r != 0) {
        return r;
      }
      final c = b.ratingCount.compareTo(a.ratingCount);
      if (c != 0) {
        return c;
      }
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta != null && tb != null) {
        return tb.compareTo(ta);
      }
      return a.salonName.toLowerCase().compareTo(b.salonName.toLowerCase());
    });
    return out.take(5).toList(growable: false);
  }

  /// Recommended carousel: top ratings from `publicSalons` with visibility rules.
  Stream<List<CustomerSalonPreviewModel>> watchRecommendedSalonPreviews({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    return _watchSalonPreviewsForDiscovery(
      discoveryCountryName: discoveryCountryName,
      customerCountryCode: customerCountryCode,
      categoryId: categoryId,
    ).map(_sortRecommendedPreviews);
  }

  /// Nearby list source (distance sort applied in UI when GPS resolves).
  Stream<List<CustomerSalonPreviewModel>> watchNearbySalonPreviews({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    return _watchSalonPreviewsForDiscovery(
      discoveryCountryName: discoveryCountryName,
      customerCountryCode: customerCountryCode,
      categoryId: categoryId,
    ).map(
      (list) => list
          .where((p) => p.isVisibleForRecommended)
          .take(20)
          .toList(growable: false),
    );
  }

  /// `customerDiscovery/serviceCategories/items` — horizontal “trending categories” tiles.
  Stream<List<DiscoveryServiceCategoryModel>> watchDiscoveryServiceCategories() {
    return _serviceCategoriesItems
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(DiscoveryServiceCategoryModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<PublicSpecialistModel>> watchRecommendedSpecialists({
    required String countryCode,
  }) {
    final cc = countryCode.trim().toUpperCase();
    return _publicSpecialists
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('countryCode', isEqualTo: cc)
        .orderBy('sortScore', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicSpecialistModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<PublicSpecialistModel>> watchTodayAvailableSpecialists({
    required String countryCode,
  }) {
    final cc = countryCode.trim().toUpperCase();
    return _publicSpecialists
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('countryCode', isEqualTo: cc)
        .where('isAvailableToday', isEqualTo: true)
        .orderBy('sortScore', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicSpecialistModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// See Firestore rules: `users/{uid}/favorites/{salonId}` (anonymous Auth UIDs ok).
  Future<void> toggleFavorite({
    required String uid,
    required String salonId,
    required bool currentlyFavorite,
  }) async {
    final docRef = _db.doc(FirestorePaths.userFavorite(uid, salonId));
    if (currentlyFavorite) {
      await docRef.delete();
    } else {
      await docRef.set({
        'salonId': salonId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  List<CustomerSalonModel> _sortRecommended(
    List<CustomerSalonModel> list,
  ) {
    final out = [...list];
    out.sort((a, b) {
      final prom = (b.isPromoted ? 1 : 0).compareTo(a.isPromoted ? 1 : 0);
      if (prom != 0) {
        return prom;
      }
      final r = b.ratingAverage.compareTo(a.ratingAverage);
      if (r != 0) {
        return r;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return out.take(12).toList(growable: false);
  }

  Stream<List<CustomerSalonModel>> watchRecommendedSalons({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    return _watchPublishedSalonsForDiscovery(
      discoveryCountryName: discoveryCountryName,
      customerCountryCode: customerCountryCode,
      categoryId: categoryId,
    ).map(_sortRecommended);
  }

  /// Published salons scoped by `countryCode` on `publicSalons` (+ fallback `salons/*`).
  Stream<List<CustomerSalonModel>> watchNearbySalons({
    required String discoveryCountryName,
    required String customerCountryCode,
    String? categoryId,
  }) {
    return _watchPublishedSalonsForDiscovery(
      discoveryCountryName: discoveryCountryName,
      customerCountryCode: customerCountryCode,
      categoryId: categoryId,
    ).map((list) => list.take(50).toList(growable: false));
  }

  Stream<List<TrendingServiceModel>> watchTrendingServices() {
    return _trendingItems
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TrendingServiceModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<CustomerBannerModel>> watchActiveBanners() {
    final now = Timestamp.now();
    return _bannerItems
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(5)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(CustomerBannerModel.fromFirestore)
              .where((b) => b.isVisibleNow(now))
              .take(5)
              .toList(growable: false);
        });
  }

  /// Debug-only: logs document counts for the same constraints as customer-home streams.
  /// Call once from Customer Home in debug; read console for `[CUSTOMER_HOME_COUNT]`.
  Future<void> debugCustomerHomeCounts({
    required String discoveryCountryName,
    required String customerCountryCode,
  }) async {
    if (!kDebugMode) {
      return;
    }

    try {
      debugPrint(
        '[CUSTOMER_HOME_COUNT] projectId=${Firebase.app().options.projectId}',
      );
    } catch (e) {
      debugPrint('[CUSTOMER_HOME_COUNT] projectId UNKNOWN: $e');
    }

    Future<void> countQuery(
      String label,
      Query<Map<String, dynamic>> query,
    ) async {
      try {
        final result = await query.get();
        debugPrint('[CUSTOMER_HOME_COUNT] $label = ${result.docs.length}');
        for (final doc in result.docs.take(5)) {
          debugPrint(
            '[CUSTOMER_HOME_COUNT] $label doc=${doc.id} data=${doc.data()}',
          );
        }
      } catch (e) {
        debugPrint('[CUSTOMER_HOME_COUNT] $label FAILED: $e');
      }
    }

    await countQuery(
      'salons debugSeed (sample)',
      _db
          .collection(FirestorePaths.salons)
          .where('debugSeed', isEqualTo: true)
          .limit(20),
    );

    final cc = customerCountryCode.trim().toUpperCase();
    await countQuery(
      'publicSalons country+isActive+isPublished+isPublic',
      _db
          .collection(FirestorePaths.publicSalons)
          .where('countryCode', isEqualTo: cc)
          .where('isActive', isEqualTo: true)
          .where('isPublished', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .limit(20),
    );

    await countQuery(
      'published salons root + countryCode',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .where('countryCode', isEqualTo: cc)
          .limit(20),
    );

    await countQuery(
      'published + category hair (if index exists)',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .where('categoryIds', arrayContains: 'hair')
          .limit(20),
    );

    await countQuery(
      'categories',
      _categoriesItems
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .limit(20),
    );

    await countQuery(
      'serviceCategories items',
      _serviceCategoriesItems
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .limit(20),
    );

    await countQuery(
      'trending services',
      _trendingItems
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .limit(20),
    );
  }

  /// Debug-only: merges missing discovery fields on `salons/*` docs with `debugSeed: true` only.
  /// Does not run in release. Does not touch production salons without the dev flag.
  Future<void> repairCustomerHomeSalonFields() async {
    if (!kDebugMode) {
      return;
    }

    final salons = await _db
        .collection(FirestorePaths.salons)
        .where('debugSeed', isEqualTo: true)
        .limit(50)
        .get();
    var updated = 0;
    for (final doc in salons.docs) {
      final data = doc.data();
      await doc.reference.set(<String, dynamic>{
        'country': data['country'] ?? kCustomerDiscoveryCountryFallback,
        'isPublished': data['isPublished'] ?? true,
        'isOpen': data['isOpen'] ?? true,
        'ratingAverage': data['ratingAverage'] ?? 4.5,
        'ratingCount': data['ratingCount'] ?? 0,
        'categoryIds': data['categoryIds'] ?? <String>['hair'],
        'tags': data['tags'] ?? <String>['Hair'],
        'debugSeed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      updated++;
    }
    debugPrint(
      '[CUSTOMER_HOME_REPAIR] Merged discovery fields on $updated debugSeed salons.',
    );
  }
}
