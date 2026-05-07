import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Row under `customerDiscovery/serviceCategories/items/{categoryId}`.
class DiscoveryServiceCategoryModel {
  const DiscoveryServiceCategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.iconKey,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String name;
  final String nameAr;
  final String iconKey;
  final int sortOrder;
  final bool isActive;

  String labelForLocale(Locale locale) {
    if (locale.languageCode == 'ar' && nameAr.trim().isNotEmpty) {
      return nameAr.trim();
    }
    return name.trim();
  }

  factory DiscoveryServiceCategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final n = (data['name'] as String?)?.trim();
    final label = (data['label'] as String?)?.trim();
    return DiscoveryServiceCategoryModel(
      id: doc.id,
      name: (n != null && n.isNotEmpty) ? n : (label ?? ''),
      nameAr: (data['nameAr'] as String?)?.trim() ?? '',
      iconKey: (data['iconKey'] as String?)?.trim() ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? false,
    );
  }
}
