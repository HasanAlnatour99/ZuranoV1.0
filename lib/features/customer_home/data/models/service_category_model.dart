import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

/// Customer-safe row from `customerDiscovery/categories/items/{categoryId}`.
///
/// Curated list (CMS or Cloud Functions). The customer app uses this to render
/// the home category scroller with a stable [iconKey] resolver.
class ServiceCategoryModel {
  const ServiceCategoryModel({
    required this.id,
    required this.label,
    required this.labelAr,
    required this.iconKey,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String label;
  final String labelAr;

  /// Stable enum key resolved by the UI to a Material icon (e.g. `hair`,
  /// `beard`, `nails`, `spa`, `barbers`, `category_all`). Avoid embedding asset
  /// URLs as the icon key — use [imageUrl] for that.
  final String iconKey;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  String labelForLocale(Locale locale) {
    if (locale.languageCode == 'ar' && labelAr.trim().isNotEmpty) {
      return labelAr.trim();
    }
    return label.trim();
  }

  factory ServiceCategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    String trimmed(dynamic v) {
      if (v is String) return v.trim();
      return '';
    }

    final name = trimmed(data['name']);
    final label = trimmed(data['label']);
    final resolvedLabel = name.isNotEmpty ? name : label;

    return ServiceCategoryModel(
      id: doc.id,
      label: resolvedLabel,
      labelAr: trimmed(data['nameAr']).isNotEmpty
          ? trimmed(data['nameAr'])
          : trimmed(data['labelAr']),
      iconKey: trimmed(data['iconKey']),
      imageUrl: trimmed(data['imageUrl']),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] == true,
    );
  }
}
