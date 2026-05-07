import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer-safe specialist row from `publicSpecialists/{specialistId}`.
class PublicSpecialistModel {
  const PublicSpecialistModel({
    required this.specialistId,
    required this.salonId,
    required this.salonName,
    required this.displayName,
    required this.roleTitle,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedBookingsCount,
    required this.serviceCategoryIds,
    required this.isAvailableToday,
    required this.countryCode,
    required this.isActive,
    required this.isPublic,
    required this.sortScore,
    this.photoUrl,
    this.nextAvailableSlotText,
    this.city,
  });

  final String specialistId;
  final String salonId;
  final String salonName;
  final String displayName;
  final String roleTitle;
  final String? photoUrl;
  final double ratingAvg;
  final int ratingCount;
  final int completedBookingsCount;
  final List<String> serviceCategoryIds;
  final bool isAvailableToday;
  final String? nextAvailableSlotText;
  final String? city;
  final String countryCode;
  final bool isActive;
  final bool isPublic;
  final int sortScore;

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory PublicSpecialistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    int intField(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.round();
      return fallback;
    }

    double doubleField(dynamic v, double fallback) {
      if (v is num) return v.toDouble();
      return fallback;
    }

    final cc = (data['countryCode'] as String?)?.trim().toUpperCase() ?? '';

    return PublicSpecialistModel(
      specialistId: (data['specialistId'] as String?)?.trim() ?? doc.id,
      salonId: (data['salonId'] as String?)?.trim() ?? '',
      salonName: (data['salonName'] as String?)?.trim() ?? '',
      displayName: (data['displayName'] as String?)?.trim() ?? '',
      roleTitle: (data['roleTitle'] as String?)?.trim() ?? '',
      photoUrl: (data['photoUrl'] as String?)?.trim(),
      ratingAvg: doubleField(data['ratingAvg'], 0).clamp(0.0, 5.0),
      ratingCount: intField(data['ratingCount'], 0),
      completedBookingsCount: intField(data['completedBookingsCount'], 0),
      serviceCategoryIds: _stringList(data['serviceCategoryIds']),
      isAvailableToday: data['isAvailableToday'] == true,
      nextAvailableSlotText: (data['nextAvailableSlotText'] as String?)?.trim(),
      city: (data['city'] as String?)?.trim(),
      countryCode: cc,
      isActive: data['isActive'] == true,
      isPublic: data['isPublic'] == true,
      sortScore: intField(data['sortScore'], 0),
    );
  }
}

