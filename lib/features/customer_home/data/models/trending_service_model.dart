import 'package:cloud_firestore/cloud_firestore.dart';

class TrendingServiceModel {
  const TrendingServiceModel({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.bookingCountText,
    required this.bookingCount,
    required this.categoryId,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String label;
  final String iconKey;
  final String bookingCountText;
  final int bookingCount;
  final String categoryId;
  final bool isActive;
  final int sortOrder;

  factory TrendingServiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return TrendingServiceModel(
      id: doc.id,
      label: data['label'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? '',
      bookingCountText: data['bookingCountText'] as String? ?? '',
      bookingCount: (data['bookingCount'] as num?)?.toInt() ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
