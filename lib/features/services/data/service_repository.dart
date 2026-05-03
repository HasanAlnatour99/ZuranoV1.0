import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/firestore_page.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import 'models/service.dart';
import 'service_category_catalog.dart';

/// Repository for CRUD operations against
/// `salons/{salonId}/services/{serviceId}`.
class ServiceRepository {
  ServiceRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _services(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonServices(salonId));
  }

  DocumentReference<Map<String, dynamic>> _serviceDoc(
    String salonId,
    String serviceId,
  ) {
    if (serviceId.isEmpty) {
      throw ArgumentError.value(
        serviceId,
        'serviceId',
        'Service ID is required.',
      );
    }
    return _services(salonId).doc(serviceId);
  }

  void _assertValidService(SalonService service) {
    if (service.price <= 0) {
      throw ArgumentError.value(
        service.price,
        'price',
        'Price must be greater than 0.',
      );
    }
    if (service.durationMinutes <= 0) {
      throw ArgumentError.value(
        service.durationMinutes,
        'durationMinutes',
        'Duration must be greater than 0 minutes.',
      );
    }
    if (service.name.isEmpty) {
      throw ArgumentError.value(
        service.name,
        'name',
        'Service English name is required.',
      );
    }
    if (service.nameAr.trim().isEmpty) {
      throw ArgumentError.value(
        service.nameAr,
        'nameAr',
        'Service Arabic name is required.',
      );
    }
    final catKey = service.categoryKey?.trim();
    if (catKey == null || catKey.isEmpty) {
      throw ArgumentError.value(
        service.categoryKey,
        'categoryKey',
        'Service category is required.',
      );
    }
    if (catKey == ServiceCategoryKeys.other) {
      final custom = service.customCategoryName?.trim();
      if (custom == null || custom.isEmpty) {
        throw ArgumentError.value(
          service.customCategoryName,
          'customCategoryName',
          'Custom category name is required when category is Other.',
        );
      }
    }
  }

  /// Creates a new service. Returns the newly created document ID.
  Future<String> addService(String salonId, SalonService service) async {
    _assertValidService(service);
    final collection = _services(salonId);
    final document = service.id.isEmpty
        ? collection.doc()
        : collection.doc(service.id);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...service.toJson(),
      'id': document.id,
    });

    await document.set(payload);
    return document.id;
  }

  /// Updates an existing service via a merging set.
  Future<void> updateService(String salonId, SalonService service) {
    _assertValidService(service);
    final payload = Map<String, dynamic>.from(service.toJson());
    if (service.categoryKey?.trim() != ServiceCategoryKeys.other) {
      payload['customCategoryName'] = FieldValue.delete();
    }
    final iconTrim = service.iconKey?.trim();
    if (iconTrim == null || iconTrim.isEmpty) {
      payload['iconKey'] = FieldValue.delete();
    } else {
      payload['iconKey'] = iconTrim;
    }
    return _serviceDoc(salonId, service.id).set(
      FirestoreWritePayload.withServerTimestampForUpdate(payload),
      SetOptions(merge: true),
    );
  }

  /// Permanently deletes a service from `salons/{salonId}/services/{serviceId}`.
  Future<void> deleteService(String salonId, String serviceId) {
    return _serviceDoc(salonId, serviceId).delete();
  }

  /// One-shot fetch of services for a salon.
  ///
  /// Use [watchServices] when the UI should react to real-time updates.
  Future<List<SalonService>> getServices(
    String salonId, {
    bool onlyActive = false,
    String? categoryKey,
  }) async {
    final snapshot = await _servicesQuery(
      salonId,
      onlyActive: onlyActive,
      categoryKey: categoryKey,
    ).get();
    return snapshot.docs
        .map((doc) => SalonService.fromJson(doc.data()))
        .toList();
  }

  /// Real-time stream of services for a salon.
  Stream<List<SalonService>> watchServices(
    String salonId, {
    bool onlyActive = false,
    String? categoryKey,
  }) {
    return _servicesQuery(
      salonId,
      onlyActive: onlyActive,
      categoryKey: categoryKey,
    ).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => SalonService.fromJson(doc.data()))
          .toList(),
    );
  }

  /// Fetches a single service by its ID.
  Future<SalonService?> getService(String salonId, String serviceId) async {
    final snapshot = await _serviceDoc(salonId, serviceId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }

    return SalonService.fromJson(data);
  }

  /// Paged services (name, then [createdAt] descending). Use [FirestorePage.lastDocument]
  /// with [getServicesNextPage] for more.
  Future<FirestorePage<SalonService>> getServicesPage(
    String salonId, {
    bool onlyActive = false,
    String? categoryKey,
    int limit = 40,
    DocumentSnapshot? startAfter,
  }) async {
    final snapshot = await _servicesPageQuery(
      salonId,
      onlyActive: onlyActive,
      categoryKey: categoryKey,
      limit: limit,
      startAfter: startAfter,
    ).get();
    final docs = snapshot.docs;
    return FirestorePage(
      items: docs.map((d) => SalonService.fromJson(d.data())).toList(),
      limit: limit,
      lastDocument: docs.isEmpty ? null : docs.last,
    );
  }

  /// Next page after [previous]; returns an empty page if [!previous.hasMore].
  Future<FirestorePage<SalonService>> getServicesNextPage(
    String salonId,
    FirestorePage<SalonService> previous, {
    bool onlyActive = false,
    String? categoryKey,
  }) {
    if (!previous.hasMore || previous.lastDocument == null) {
      return Future.value(
        FirestorePage(
          items: const [],
          limit: previous.limit,
          lastDocument: null,
        ),
      );
    }
    return getServicesPage(
      salonId,
      onlyActive: onlyActive,
      categoryKey: categoryKey,
      limit: previous.limit,
      startAfter: previous.lastDocument,
    );
  }

  /// Toggles the `isActive` flag without rewriting the whole document.
  Future<void> setServiceActiveState({
    required String salonId,
    required String serviceId,
    required bool isActive,
  }) {
    return _serviceDoc(salonId, serviceId).set(
      FirestoreWritePayload.withServerTimestampForUpdate({
        'isActive': isActive,
      }),
      SetOptions(merge: true),
    );
  }

  Query<Map<String, dynamic>> _servicesQuery(
    String salonId, {
    required bool onlyActive,
    String? categoryKey,
  }) {
    Query<Map<String, dynamic>> query = _services(salonId);

    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    final trimmedKey = categoryKey?.trim();
    if (trimmedKey != null && trimmedKey.isNotEmpty) {
      query = query.where('categoryKey', isEqualTo: trimmedKey);
    }

    return query.orderBy('name').orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> _servicesPageQuery(
    String salonId, {
    required bool onlyActive,
    String? categoryKey,
    required int limit,
    DocumentSnapshot? startAfter,
  }) {
    var query = _servicesQuery(
      salonId,
      onlyActive: onlyActive,
      categoryKey: categoryKey,
    );
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.limit(limit);
  }
}
