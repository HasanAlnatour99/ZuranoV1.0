import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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

  static ServiceCategoryVisualStyle _premiumVipStyle() =>
      ServiceCategoryVisualStyle(
        icon: LucideIcons.gem,
        background: _hexBg('#F5F3FF'),
        foreground: _hexFg('#7C3AED'),
      );

  static ServiceCategoryVisualStyle? _keywordHintStyle(
    String? categoryLabel,
    String? serviceName,
  ) {
    final s = '${categoryLabel ?? ''} ${serviceName ?? ''}'
        .toLowerCase()
        .trim();
    if (s.isEmpty) {
      return null;
    }
    if (s.contains('vip') || s.contains('premium')) {
      return _premiumVipStyle();
    }
    if (s.contains('kid') || s.contains('child')) {
      return _styleForResolvedKey(ServiceCategoryKeys.kidsServices)!;
    }
    if (s.contains('beard') || s.contains('shave')) {
      return _styleForResolvedKey(ServiceCategoryKeys.barberBeard)!;
    }
    if (s.contains('combo') || s.contains('package')) {
      return _styleForResolvedKey(ServiceCategoryKeys.packages)!;
    }
    if (s.contains('manicure') ||
        s.contains('pedicure') ||
        s.contains('nail')) {
      return _styleForResolvedKey(ServiceCategoryKeys.manicurePedicure)!;
    }
    return null;
  }

  /// Resolves [ServiceCategoryVisualStyle] for chips, cards, and receipts.
  ///
  /// Priority:
  /// 1. [iconKey] if it matches a known catalog key.
  /// 2. [categoryKey] if set.
  /// 3. [ServiceCategoryKeys.migrateLegacyCategoryLabelToKey] on [categoryLabel].
  /// 4. Keyword hints on [categoryLabel] + [serviceName] (vip, kids, beard, …).
  /// 5. [ServiceCategoryKeys.inferKeyFromLooseLabel] on label and name.
  /// 6. [ServiceCategoryKeys.other].
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

    final keyword = _keywordHintStyle(categoryLabel, serviceName);
    if (keyword != null) {
      return keyword;
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
          icon: LucideIcons.scissors,
          background: _hexBg('#EAF7FF'),
          foreground: _hexFg('#1687C9'),
        );
      case ServiceCategoryKeys.barberBeard:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.user,
          background: _hexBg('#F1E8FF'),
          foreground: _hexFg('#7B2FF7'),
        );
      case ServiceCategoryKeys.nails:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.hand,
          background: _hexBg('#FFF0F7'),
          foreground: _hexFg('#D63384'),
        );
      case ServiceCategoryKeys.hairRemovalWaxing:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.wand2,
          background: _hexBg('#FFF7E6'),
          foreground: _hexFg('#D97706'),
        );
      case ServiceCategoryKeys.browsLashes:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.eye,
          background: _hexBg('#EEF2FF'),
          foreground: _hexFg('#4F46E5'),
        );
      case ServiceCategoryKeys.facialSkincare:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.sparkles,
          background: _hexBg('#EAFBF1'),
          foreground: _hexFg('#159957'),
        );
      case ServiceCategoryKeys.makeup:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.brush,
          background: _hexBg('#FFF0F6'),
          foreground: _hexFg('#C026D3'),
        );
      case ServiceCategoryKeys.massageSpa:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.flower2,
          background: _hexBg('#ECFDF5'),
          foreground: _hexFg('#059669'),
        );
      case ServiceCategoryKeys.packages:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.sparkles,
          background: _hexBg('#FFF4E5'),
          foreground: _hexFg('#E88A00'),
        );
      case ServiceCategoryKeys.coloring:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.palette,
          background: _hexBg('#FDF2F8'),
          foreground: _hexFg('#DB2777'),
        );
      case ServiceCategoryKeys.texturedHair:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.waves,
          background: _hexBg('#EFF6FF'),
          foreground: _hexFg('#2563EB'),
        );
      case ServiceCategoryKeys.bridal:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.gem,
          background: _hexBg('#FEF3C7'),
          foreground: _hexFg('#B45309'),
        );
      case ServiceCategoryKeys.tanning:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.sun,
          background: _hexBg('#FFF7ED'),
          foreground: _hexFg('#EA580C'),
        );
      case ServiceCategoryKeys.medSpa:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.stethoscope,
          background: _hexBg('#E0F2FE'),
          foreground: _hexFg('#0284C7'),
        );
      case ServiceCategoryKeys.menGrooming:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.badge,
          background: _hexBg('#F1E8FF'),
          foreground: _hexFg('#6D28D9'),
        );
      case ServiceCategoryKeys.haircutStyling:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.scissors,
          background: _hexBg('#EAF7FF'),
          foreground: _hexFg('#1687C9'),
        );
      case ServiceCategoryKeys.hairTreatments:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.leaf,
          background: _hexBg('#F0FDFA'),
          foreground: _hexFg('#0D9488'),
        );
      case ServiceCategoryKeys.scalpTreatments:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.droplets,
          background: _hexBg('#EFF6FF'),
          foreground: _hexFg('#2563EB'),
        );
      case ServiceCategoryKeys.keratinSmoothing:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.wind,
          background: _hexBg('#F5F3FF'),
          foreground: _hexFg('#7C3AED'),
        );
      case ServiceCategoryKeys.hairExtensions:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.plusCircle,
          background: _hexBg('#ECFEFF'),
          foreground: _hexFg('#0891B2'),
        );
      case ServiceCategoryKeys.kidsServices:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.smile,
          background: _hexBg('#FEF9C3'),
          foreground: _hexFg('#CA8A04'),
        );
      case ServiceCategoryKeys.manicurePedicure:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.hand,
          background: _hexBg('#FFF0F7'),
          foreground: _hexFg('#D63384'),
        );
      case ServiceCategoryKeys.nailArt:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.palette,
          background: _hexBg('#FAE8FF'),
          foreground: _hexFg('#A21CAF'),
        );
      case ServiceCategoryKeys.threading:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.lineChart,
          background: _hexBg('#F8FAFC'),
          foreground: _hexFg('#475569'),
        );
      case ServiceCategoryKeys.lashExtensions:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.eye,
          background: _hexBg('#EEF2FF'),
          foreground: _hexFg('#4F46E5'),
        );
      case ServiceCategoryKeys.bodyTreatments:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.leaf,
          background: _hexBg('#ECFDF5'),
          foreground: _hexFg('#059669'),
        );
      case ServiceCategoryKeys.makeupPermanent:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.wand2,
          background: _hexBg('#FDF2F8'),
          foreground: _hexFg('#DB2777'),
        );
      case ServiceCategoryKeys.other:
        return ServiceCategoryVisualStyle(
          icon: LucideIcons.sparkles,
          background: _hexBg('#F3F4F6'),
          foreground: _hexFg('#6B7280'),
        );
      default:
        return null;
    }
  }
}
