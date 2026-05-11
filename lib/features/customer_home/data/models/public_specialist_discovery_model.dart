import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_serializers.dart';

/// Customer-safe specialist row from `customerDiscovery/specialists/items/{specialistId}`.
///
/// Maintained by Cloud Functions from private `salons/{salonId}/employees/{employeeId}`.
///
/// Home/search parity: [fromCustomerSearchIndex] maps the same `customerSearchIndex`
/// documents as search (`functions/src/customerSearchIndex.ts`) when the discovery
/// collection is empty or not mirrored yet.
///
/// Privacy contract: this model intentionally has no payroll, attendance,
/// commission, salary, hours-worked, or any private HR fields.
class PublicSpecialistDiscoveryModel {
  const PublicSpecialistDiscoveryModel({
    required this.specialistId,
    required this.salonId,
    required this.salonName,
    required this.displayName,
    required this.roleTitle,
    required this.photoUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.serviceCategoryIds,
    required this.isActive,
    required this.visibleToCustomers,
    required this.acceptsBookings,
    required this.availableToday,
    required this.countryCode,
    required this.city,
    required this.sortOrder,
    this.nextAvailableSlotText,
  });

  final String specialistId;
  final String salonId;
  final String salonName;
  final String displayName;
  final String roleTitle;
  final String photoUrl;
  final double ratingAvg;
  final int ratingCount;
  final List<String> serviceCategoryIds;

  /// Customer discovery gate. Mirrors the Firestore query (`isActive == true`).
  final bool isActive;

  /// Owner-controlled toggle: hide individual barber from public discovery.
  final bool visibleToCustomers;

  /// Owner-controlled toggle: barber participates in customer booking flows.
  final bool acceptsBookings;

  /// Server-computed: barber has at least one open slot for the salon's
  /// current business day in their timezone. Customer app reads this directly
  /// for the "Available today" section.
  final bool availableToday;

  /// ISO 3166-1 alpha-2, uppercased.
  final String countryCode;
  final String city;
  final int sortOrder;
  final String? nextAvailableSlotText;

  bool get isReadyForCustomerHome =>
      isActive && visibleToCustomers && acceptsBookings;

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory PublicSpecialistDiscoveryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    String trimmed(dynamic v, [String fallback = '']) {
      if (v is String) {
        final t = v.trim();
        if (t.isNotEmpty) return t;
      }
      return fallback;
    }

    int intField(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.round();
      return fallback;
    }

    double doubleField(dynamic v, [double fallback = 0]) {
      if (v is num) return v.toDouble();
      return fallback;
    }

    return PublicSpecialistDiscoveryModel(
      specialistId: trimmed(data['specialistId'], doc.id),
      salonId: trimmed(data['salonId']),
      salonName: trimmed(data['salonName']),
      displayName: trimmed(data['displayName']),
      roleTitle: trimmed(data['roleTitle']),
      photoUrl: trimmed(data['photoUrl']),
      ratingAvg: doubleField(data['ratingAvg']).clamp(0.0, 5.0).toDouble(),
      ratingCount: intField(data['ratingCount']),
      serviceCategoryIds: _stringList(data['serviceCategoryIds']),
      isActive: data['isActive'] == true,
      visibleToCustomers: data['visibleToCustomers'] == true,
      acceptsBookings: data['acceptsBookings'] == true,
      availableToday: data['availableToday'] == true,
      countryCode: trimmed(data['countryCode']).toUpperCase(),
      city: trimmed(data['city']),
      sortOrder: intField(data['sortOrder']),
      nextAvailableSlotText: trimmed(data['nextAvailableSlotText']).isEmpty
          ? null
          : trimmed(data['nextAvailableSlotText']),
    );
  }

  /// Maps `customerSearchIndex/{docId}` specialist rows (same pipeline as search).
  factory PublicSpecialistDiscoveryModel.fromCustomerSearchIndex(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final title = (FirestoreSerializers.string(data['title']) ?? '').trim();
    final subtitle = (FirestoreSerializers.string(data['subtitle']) ?? '').trim();
    final parts = subtitle
        .split(RegExp(r'\s*•\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final roleTitle = parts.isNotEmpty ? parts[0] : '';
    final salonName =
        parts.length > 1 ? parts.sublist(1).join(' • ') : '';

    final targetRaw = FirestoreSerializers.string(data['targetId'])?.trim();
    final salonId =
        (FirestoreSerializers.string(data['salonId']) ?? '').trim();

    final photo = (FirestoreSerializers.string(data['imageUrl']) ?? '').trim();
    final cc =
        (FirestoreSerializers.string(data['countryCode']) ?? '').trim().toUpperCase();
    final city = (FirestoreSerializers.string(data['city']) ?? '').trim();

    var ratingAvg = FirestoreSerializers.doubleValue(data['ratingAvg']);
    ratingAvg = ratingAvg.clamp(0.0, 5.0);
    final ratingCount = FirestoreSerializers.intValue(data['ratingCount']);

    final specialistId = (targetRaw != null && targetRaw.isNotEmpty)
        ? targetRaw
        : doc.id;

    return PublicSpecialistDiscoveryModel(
      specialistId: specialistId,
      salonId: salonId,
      salonName: salonName.isNotEmpty ? salonName : '—',
      displayName: title.isNotEmpty ? title : '—',
      roleTitle: roleTitle.isNotEmpty ? roleTitle : '—',
      photoUrl: photo,
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      serviceCategoryIds: const [],
      isActive: data['isActive'] != false,
      visibleToCustomers: true,
      acceptsBookings: true,
      availableToday: data['availableToday'] == true,
      countryCode: cc,
      city: city,
      sortOrder: 0,
      nextAvailableSlotText: null,
    );
  }
}
