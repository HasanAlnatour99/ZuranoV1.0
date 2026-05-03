import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerCategoryModel {
  const CustomerCategoryModel({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String label;
  final String iconKey;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  factory CustomerCategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return CustomerCategoryModel(
      id: doc.id,
      label: data['label'] as String? ?? '',
      iconKey: data['iconKey'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}
