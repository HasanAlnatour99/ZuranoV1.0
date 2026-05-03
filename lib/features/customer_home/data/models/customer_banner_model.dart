import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerBannerModel {
  const CustomerBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.type,
    required this.isActive,
    required this.sortOrder,
    this.startAt,
    this.endAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String ctaText;
  final String type;
  final bool isActive;
  final int sortOrder;
  final Timestamp? startAt;
  final Timestamp? endAt;

  bool isVisibleNow(Timestamp now) {
    if (!isActive) {
      return false;
    }
    if (startAt != null && now.compareTo(startAt!) < 0) {
      return false;
    }
    if (endAt != null && now.compareTo(endAt!) > 0) {
      return false;
    }
    return true;
  }

  factory CustomerBannerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return CustomerBannerModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      ctaText: data['ctaText'] as String? ?? '',
      type: data['type'] as String? ?? 'promo',
      isActive: data['isActive'] as bool? ?? false,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      startAt: data['startAt'] as Timestamp?,
      endAt: data['endAt'] as Timestamp?,
    );
  }
}
