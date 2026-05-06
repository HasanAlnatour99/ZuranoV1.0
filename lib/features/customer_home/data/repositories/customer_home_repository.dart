import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import '../../../../core/firestore/firestore_paths.dart';
import '../../domain/customer_discovery_country_match.dart';
import '../../domain/customer_geo.dart';
import '../models/customer_banner_model.dart';
import '../models/customer_category_model.dart';
import '../models/customer_salon_model.dart';
import '../models/trending_service_model.dart';

class CustomerHomeRepository {
  CustomerHomeRepository(this._db);

  final FirebaseFirestore _db;

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
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(limit);

    final fallbackSalonRootQuery = _db
        .collection(FirestorePaths.salons)
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
          return CustomerSalonModel(
            id: doc.id,
            name: (data['salonName'] as String?)?.trim() ?? '',
            city: (data['city'] as String?)?.trim() ?? '',
            area: (data['area'] as String?)?.trim() ?? '',
            country:
                (data['countryName'] as String?)?.trim() ??
                (data['country'] as String?)?.trim() ??
                discoveryCountryName,
            address: (data['address'] as String?)?.trim() ?? '',
            latitude: (data['latitude'] as num?)?.toDouble(),
            longitude: (data['longitude'] as num?)?.toDouble(),
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
        final categoryFiltered =
            (categoryId != null && categoryId != 'all')
                ? parsed
                    .where((s) => s.categoryIds.contains(categoryId))
                    .toList(growable: false)
                : parsed;

        yield preferCountryFilteredElseAll(
          categoryFiltered,
          discoveryCountryName,
          customerCountryCode: cc,
        );
      }
    })();
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
      'publicSalons country+isPublic+isActive',
      _db
          .collection(FirestorePaths.publicSalons)
          .where('countryCode', isEqualTo: cc)
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(20),
    );

    await countQuery(
      'published salons root + countryCode',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('countryCode', isEqualTo: cc)
          .limit(20),
    );

    await countQuery(
      'published + category hair (if index exists)',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
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
