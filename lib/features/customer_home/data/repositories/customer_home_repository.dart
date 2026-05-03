import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firestore/firestore_paths.dart';
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

  Stream<List<CustomerSalonModel>> watchRecommendedSalons({
    required String discoveryCountryName,
    String? categoryId,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestorePaths.salons)
        .where('isPublished', isEqualTo: true)
        .where('isPromoted', isEqualTo: true)
        .where('country', isEqualTo: discoveryCountryName)
        .orderBy('ratingAverage', descending: true)
        .limit(10);

    if (categoryId != null && categoryId != 'all') {
      query = _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('isPromoted', isEqualTo: true)
          .where('country', isEqualTo: discoveryCountryName)
          .where('categoryIds', arrayContains: categoryId)
          .orderBy('ratingAverage', descending: true)
          .limit(10);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(CustomerSalonModel.fromFirestore)
          .toList(growable: false),
    );
  }

  /// Published salons in [discoveryCountryName] only (no city filter). Client sorts by GPS distance.
  Stream<List<CustomerSalonModel>> watchNearbySalons({
    required String discoveryCountryName,
    String? categoryId,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestorePaths.salons)
        .where('isPublished', isEqualTo: true)
        .where('country', isEqualTo: discoveryCountryName)
        .orderBy('ratingAverage', descending: true)
        .limit(50);

    if (categoryId != null && categoryId != 'all') {
      query = _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('country', isEqualTo: discoveryCountryName)
          .where('categoryIds', arrayContains: categoryId)
          .orderBy('ratingAverage', descending: true)
          .limit(50);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(CustomerSalonModel.fromFirestore)
          .toList(growable: false),
    );
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

    await countQuery(
      'published salons in discovery country',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('country', isEqualTo: discoveryCountryName)
          .orderBy('ratingAverage', descending: true)
          .limit(20),
    );

    await countQuery(
      'recommended salons in discovery country',
      _db
          .collection(FirestorePaths.salons)
          .where('isPublished', isEqualTo: true)
          .where('isPromoted', isEqualTo: true)
          .where('country', isEqualTo: discoveryCountryName)
          .orderBy('ratingAverage', descending: true)
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
