import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/data/service_category_catalog.dart';

/// Customer-safe service row from `publicSalons/{salonId}/services/{serviceId}`.
class CustomerServicePublicModel {
  const CustomerServicePublicModel({
    required this.id,
    required this.salonId,
    required this.name,
    this.nameAr = '',
    required this.displayName,
    required this.category,
    required this.categoryLabel,
    this.categoryKey,
    this.iconKey,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    required this.isActive,
    required this.isCustomerVisible,
    required this.sortOrder,
    this.searchKeywords = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String name;

  /// Arabic service name from public mirror (`nameAr`).
  final String nameAr;
  final String displayName;
  final String category;
  final String categoryLabel;

  /// Canonical catalog key when mirrored from owner services; drives icons.
  final String? categoryKey;

  /// Optional service-level icon override (same key vocabulary as [categoryKey]).
  final String? iconKey;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final bool isActive;
  final bool isCustomerVisible;
  final int sortOrder;
  final List<String> searchKeywords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Title line (display name with name fallback).
  String get displayTitle =>
      displayName.trim().isNotEmpty ? displayName.trim() : name.trim();

  /// Pass `Localizations.localeOf(context).languageCode`.
  String localizedTitleForLanguageCode(String languageCode) {
    if (languageCode == 'ar') {
      final ar = nameAr.trim();
      if (ar.isNotEmpty) return ar;
    }
    return displayTitle;
  }

  /// Key used with [ServiceCategoryIconResolver] (never empty).
  String get resolvedCategoryKeyForIcon {
    final k = categoryKey?.trim();
    if (k != null && k.isNotEmpty) {
      return k;
    }
    final migrated = ServiceCategoryKeys.migrateLegacyCategoryLabelToKey(
      categoryLabel.trim().isNotEmpty ? categoryLabel : category,
    );
    return migrated ?? ServiceCategoryKeys.other;
  }

  static DateTime? _ts(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static List<String> _stringList(Object? v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static double _double(Object? v, double fallback) {
    if (v is num) {
      return v.toDouble();
    }
    return fallback;
  }

  static int _int(Object? v, int fallback) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.round();
    }
    return fallback;
  }

  static String _string(Object? value) {
    return value is String ? value.trim() : '';
  }

  factory CustomerServicePublicModel.fromFirestore(
    DocumentSnapshot doc,
    String salonId,
  ) {
    final raw = doc.data();
    final data = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

    final nameRaw = _string(data['name']);
    final nameArRaw = _string(data['nameAr']);
    final displayNameRaw = _string(data['displayName']);
    final name = nameRaw.isNotEmpty ? nameRaw : 'Service';
    final displayName = displayNameRaw.isNotEmpty ? displayNameRaw : name;

    final categoryRaw = _string(data['category']);
    final categoryLabelRaw = _string(data['categoryLabel']);
    final category = categoryRaw.isNotEmpty ? categoryRaw : 'Other';
    final categoryLabel = categoryLabelRaw.isNotEmpty
        ? categoryLabelRaw
        : category;

    var categoryKey = _string(data['categoryKey']);
    if (categoryKey.isEmpty) {
      final migrated = ServiceCategoryKeys.migrateLegacyCategoryLabelToKey(
        categoryLabelRaw.isNotEmpty ? categoryLabelRaw : categoryRaw,
      );
      categoryKey = migrated ?? '';
    }
    final iconKeyRaw = _string(data['iconKey']);

    final vis = data['isCustomerVisible'];
    final isCustomerVisible = vis is bool ? vis : true;

    var duration = _int(data['durationMinutes'], 0);
    if (duration <= 0) {
      duration = _int(data['duration'], 30);
    }
    if (duration <= 0) {
      duration = 30;
    }

    return CustomerServicePublicModel(
      id: doc.id,
      salonId: _string(data['salonId']).isNotEmpty
          ? _string(data['salonId'])
          : salonId,
      name: name,
      nameAr: nameArRaw,
      displayName: displayName,
      category: category,
      categoryLabel: categoryLabel,
      categoryKey: categoryKey.isNotEmpty ? categoryKey : null,
      iconKey: iconKeyRaw.isNotEmpty ? iconKeyRaw : null,
      description: _string(data['description']).isNotEmpty
          ? _string(data['description'])
          : null,
      price: _double(data['price'], 0),
      durationMinutes: duration,
      imageUrl: _string(data['imageUrl']).isNotEmpty
          ? _string(data['imageUrl'])
          : null,
      isActive: data['isActive'] == true,
      isCustomerVisible: isCustomerVisible,
      sortOrder: _int(data['sortOrder'], 999),
      searchKeywords: _stringList(data['searchKeywords']),
      createdAt: _ts(data['createdAt']),
      updatedAt: _ts(data['updatedAt']),
    );
  }
}
