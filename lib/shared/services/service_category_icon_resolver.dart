import 'package:flutter/material.dart';

import 'package:barber_shop_app/features/services/data/service_category_catalog.dart';

/// Maps [SalonService.categoryKey] / optional [SalonService.iconKey] to [IconData].
///
/// Priority: non-empty [iconKey], else [categoryKey], else [ServiceCategoryKeys.other].
abstract final class ServiceCategoryIconResolver {
  const ServiceCategoryIconResolver._();

  /// Key persisted on sale line items (`serviceIcon`) for receipt-style UIs.
  static String persistedIconKey({String? iconKey, String? categoryKey}) {
    final i = iconKey?.trim();
    if (i != null && i.isNotEmpty) {
      return i;
    }
    final c = categoryKey?.trim();
    if (c != null && c.isNotEmpty) {
      return c;
    }
    return ServiceCategoryKeys.other;
  }

  static IconData resolve({String? iconKey, String? categoryKey}) {
    final trimmedIcon = iconKey?.trim();
    final raw = (trimmedIcon != null && trimmedIcon.isNotEmpty)
        ? trimmedIcon
        : (categoryKey?.trim() ?? '');
    final key = raw.isEmpty ? ServiceCategoryKeys.other : raw;
    return _forKey(key);
  }

  static IconData _forKey(String key) {
    switch (key) {
      case ServiceCategoryKeys.hair:
        return Icons.face_retouching_natural_rounded;
      case ServiceCategoryKeys.barberBeard:
        return Icons.content_cut_rounded;
      case ServiceCategoryKeys.nails:
        return Icons.back_hand_rounded;
      case ServiceCategoryKeys.hairRemovalWaxing:
        return Icons.auto_fix_high_rounded;
      case ServiceCategoryKeys.browsLashes:
        return Icons.visibility_rounded;
      case ServiceCategoryKeys.facialSkincare:
        return Icons.face_rounded;
      case ServiceCategoryKeys.makeup:
        return Icons.brush_rounded;
      case ServiceCategoryKeys.massageSpa:
        return Icons.spa_rounded;
      case ServiceCategoryKeys.packages:
        return Icons.redeem_rounded;
      case ServiceCategoryKeys.coloring:
        return Icons.palette_rounded;
      case ServiceCategoryKeys.texturedHair:
        return Icons.waves_rounded;
      case ServiceCategoryKeys.bridal:
        return Icons.diamond_rounded;
      case ServiceCategoryKeys.tanning:
        return Icons.wb_sunny_rounded;
      case ServiceCategoryKeys.medSpa:
        return Icons.health_and_safety_rounded;
      case ServiceCategoryKeys.menGrooming:
        return Icons.person_rounded;
      case ServiceCategoryKeys.haircutStyling:
        return Icons.content_cut_rounded;
      case ServiceCategoryKeys.hairTreatments:
        return Icons.spa_rounded;
      case ServiceCategoryKeys.scalpTreatments:
        return Icons.water_drop_rounded;
      case ServiceCategoryKeys.keratinSmoothing:
        return Icons.air_rounded;
      case ServiceCategoryKeys.hairExtensions:
        return Icons.add_circle_outline_rounded;
      case ServiceCategoryKeys.kidsServices:
        return Icons.child_care_rounded;
      case ServiceCategoryKeys.manicurePedicure:
        return Icons.back_hand_rounded;
      case ServiceCategoryKeys.nailArt:
        return Icons.color_lens_rounded;
      case ServiceCategoryKeys.threading:
        return Icons.timeline_rounded;
      case ServiceCategoryKeys.lashExtensions:
        return Icons.remove_red_eye_rounded;
      case ServiceCategoryKeys.bodyTreatments:
        return Icons.self_improvement_rounded;
      case ServiceCategoryKeys.makeupPermanent:
        return Icons.auto_fix_high_rounded;
      case ServiceCategoryKeys.other:
        return Icons.auto_awesome_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
