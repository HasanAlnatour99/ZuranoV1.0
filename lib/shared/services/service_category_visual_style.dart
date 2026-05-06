import 'package:flutter/material.dart';

import '../../features/services/data/service_category_catalog.dart';

/// Premium icon + soft tile background + foreground for [ServiceCategoryKeys].
class ServiceCategoryVisualStyle {
  const ServiceCategoryVisualStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

/// Maps catalog keys (and legacy/icon overrides) to consistent salon/service visuals.
abstract final class ServiceCategoryVisualStyleResolver {
  const ServiceCategoryVisualStyleResolver._();

  static Color _hexBg(String hex6) =>
      Color(int.parse('FF${hex6.replaceFirst('#', '')}', radix: 16));

  static Color _hexFg(String hex6) =>
      Color(int.parse('FF${hex6.replaceFirst('#', '')}', radix: 16));

  /// Resolves [ServiceCategoryVisualStyle] for chips, cards, and receipts.
  ///
  /// Priority:
  /// 1. [iconKey] if it matches a known catalog key.
  /// 2. [categoryKey] if set.
  /// 3. [ServiceCategoryKeys.migrateLegacyCategoryLabelToKey] on [categoryLabel].
  /// 4. [ServiceCategoryKeys.inferKeyFromLooseLabel] on label and name.
  /// 5. [ServiceCategoryKeys.other].
  static ServiceCategoryVisualStyle resolve({
    String? iconKey,
    String? categoryKey,
    String? categoryLabel,
    String? serviceName,
  }) {
    final ik = iconKey?.trim();
    if (ik != null && ik.isNotEmpty) {
      final byIcon = _styleForResolvedKey(ik);
      if (byIcon != null) {
        return byIcon;
      }
    }

    final ck = categoryKey?.trim();
    if (ck != null && ck.isNotEmpty) {
      final byCat = _styleForResolvedKey(ck);
      if (byCat != null) {
        return byCat;
      }
    }

    final migrated = ServiceCategoryKeys.migrateLegacyCategoryLabelToKey(
      categoryLabel,
    );
    if (migrated != null) {
      return _styleForResolvedKey(migrated)!;
    }

    final combined = '${categoryLabel ?? ''} ${serviceName ?? ''}'.trim();
    final inferred =
        ServiceCategoryKeys.inferKeyFromLooseLabel(categoryLabel) ??
        ServiceCategoryKeys.inferKeyFromLooseLabel(serviceName) ??
        ServiceCategoryKeys.inferKeyFromLooseLabel(combined);
    if (inferred != null) {
      return _styleForResolvedKey(inferred)!;
    }

    return _styleForResolvedKey(ServiceCategoryKeys.other)!;
  }

  static ServiceCategoryVisualStyle? _styleForResolvedKey(String key) {
    switch (key) {
      case ServiceCategoryKeys.hair:
        return ServiceCategoryVisualStyle(
          icon: Icons.face_retouching_natural_rounded,
          background: _hexBg('#EAF7FF'),
          foreground: _hexFg('#1687C9'),
        );
      case ServiceCategoryKeys.barberBeard:
        return ServiceCategoryVisualStyle(
          icon: Icons.content_cut_rounded,
          background: _hexBg('#F1E8FF'),
          foreground: _hexFg('#7B2FF7'),
        );
      case ServiceCategoryKeys.nails:
        return ServiceCategoryVisualStyle(
          icon: Icons.back_hand_rounded,
          background: _hexBg('#FFF0F7'),
          foreground: _hexFg('#D63384'),
        );
      case ServiceCategoryKeys.hairRemovalWaxing:
        return ServiceCategoryVisualStyle(
          icon: Icons.auto_fix_high_rounded,
          background: _hexBg('#FFF7E6'),
          foreground: _hexFg('#D97706'),
        );
      case ServiceCategoryKeys.browsLashes:
        return ServiceCategoryVisualStyle(
          icon: Icons.visibility_rounded,
          background: _hexBg('#EEF2FF'),
          foreground: _hexFg('#4F46E5'),
        );
      case ServiceCategoryKeys.facialSkincare:
        return ServiceCategoryVisualStyle(
          icon: Icons.face_rounded,
          background: _hexBg('#EAFBF1'),
          foreground: _hexFg('#159957'),
        );
      case ServiceCategoryKeys.makeup:
        return ServiceCategoryVisualStyle(
          icon: Icons.brush_rounded,
          background: _hexBg('#FFF0F6'),
          foreground: _hexFg('#C026D3'),
        );
      case ServiceCategoryKeys.massageSpa:
        return ServiceCategoryVisualStyle(
          icon: Icons.spa_rounded,
          background: _hexBg('#ECFDF5'),
          foreground: _hexFg('#059669'),
        );
      case ServiceCategoryKeys.packages:
        return ServiceCategoryVisualStyle(
          icon: Icons.auto_awesome_rounded,
          background: _hexBg('#FFF4E5'),
          foreground: _hexFg('#E88A00'),
        );
      case ServiceCategoryKeys.coloring:
        return ServiceCategoryVisualStyle(
          icon: Icons.palette_rounded,
          background: _hexBg('#FDF2F8'),
          foreground: _hexFg('#DB2777'),
        );
      case ServiceCategoryKeys.texturedHair:
        return ServiceCategoryVisualStyle(
          icon: Icons.waves_rounded,
          background: _hexBg('#EFF6FF'),
          foreground: _hexFg('#2563EB'),
        );
      case ServiceCategoryKeys.bridal:
        return ServiceCategoryVisualStyle(
          icon: Icons.diamond_rounded,
          background: _hexBg('#FEF3C7'),
          foreground: _hexFg('#B45309'),
        );
      case ServiceCategoryKeys.tanning:
        return ServiceCategoryVisualStyle(
          icon: Icons.wb_sunny_rounded,
          background: _hexBg('#FFF7ED'),
          foreground: _hexFg('#EA580C'),
        );
      case ServiceCategoryKeys.medSpa:
        return ServiceCategoryVisualStyle(
          icon: Icons.health_and_safety_rounded,
          background: _hexBg('#E0F2FE'),
          foreground: _hexFg('#0284C7'),
        );
      case ServiceCategoryKeys.menGrooming:
        return ServiceCategoryVisualStyle(
          icon: Icons.person_rounded,
          background: _hexBg('#F1E8FF'),
          foreground: _hexFg('#6D28D9'),
        );
      case ServiceCategoryKeys.haircutStyling:
        return ServiceCategoryVisualStyle(
          icon: Icons.content_cut_rounded,
          background: _hexBg('#EAF7FF'),
          foreground: _hexFg('#1687C9'),
        );
      case ServiceCategoryKeys.hairTreatments:
        return ServiceCategoryVisualStyle(
          icon: Icons.spa_rounded,
          background: _hexBg('#F0FDFA'),
          foreground: _hexFg('#0D9488'),
        );
      case ServiceCategoryKeys.scalpTreatments:
        return ServiceCategoryVisualStyle(
          icon: Icons.water_drop_rounded,
          background: _hexBg('#EFF6FF'),
          foreground: _hexFg('#2563EB'),
        );
      case ServiceCategoryKeys.keratinSmoothing:
        return ServiceCategoryVisualStyle(
          icon: Icons.air_rounded,
          background: _hexBg('#F5F3FF'),
          foreground: _hexFg('#7C3AED'),
        );
      case ServiceCategoryKeys.hairExtensions:
        return ServiceCategoryVisualStyle(
          icon: Icons.add_circle_outline_rounded,
          background: _hexBg('#ECFEFF'),
          foreground: _hexFg('#0891B2'),
        );
      case ServiceCategoryKeys.kidsServices:
        return ServiceCategoryVisualStyle(
          icon: Icons.child_care_rounded,
          background: _hexBg('#FEF9C3'),
          foreground: _hexFg('#CA8A04'),
        );
      case ServiceCategoryKeys.manicurePedicure:
        return ServiceCategoryVisualStyle(
          icon: Icons.front_hand_rounded,
          background: _hexBg('#FFF0F7'),
          foreground: _hexFg('#D63384'),
        );
      case ServiceCategoryKeys.nailArt:
        return ServiceCategoryVisualStyle(
          icon: Icons.color_lens_rounded,
          background: _hexBg('#FAE8FF'),
          foreground: _hexFg('#A21CAF'),
        );
      case ServiceCategoryKeys.threading:
        return ServiceCategoryVisualStyle(
          icon: Icons.timeline_rounded,
          background: _hexBg('#F8FAFC'),
          foreground: _hexFg('#475569'),
        );
      case ServiceCategoryKeys.lashExtensions:
        return ServiceCategoryVisualStyle(
          icon: Icons.remove_red_eye_rounded,
          background: _hexBg('#EEF2FF'),
          foreground: _hexFg('#4F46E5'),
        );
      case ServiceCategoryKeys.bodyTreatments:
        return ServiceCategoryVisualStyle(
          icon: Icons.self_improvement_rounded,
          background: _hexBg('#ECFDF5'),
          foreground: _hexFg('#059669'),
        );
      case ServiceCategoryKeys.makeupPermanent:
        return ServiceCategoryVisualStyle(
          icon: Icons.auto_fix_high_rounded,
          background: _hexBg('#FDF2F8'),
          foreground: _hexFg('#DB2777'),
        );
      case ServiceCategoryKeys.other:
        return ServiceCategoryVisualStyle(
          icon: Icons.auto_awesome_rounded,
          background: _hexBg('#F3F4F6'),
          foreground: _hexFg('#6B7280'),
        );
      default:
        return null;
    }
  }
}
