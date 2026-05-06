/// Stable keys for `SalonService.categoryKey` (Firestore + filtering).
abstract final class ServiceCategoryKeys {
  static const String hair = 'hair';
  static const String barberBeard = 'barber_beard';
  static const String nails = 'nails';
  static const String hairRemovalWaxing = 'hair_removal_waxing';
  static const String other = 'other';
  static const String browsLashes = 'brows_lashes';
  static const String facialSkincare = 'facial_skincare';
  static const String makeup = 'makeup';
  static const String massageSpa = 'massage_spa';
  static const String packages = 'packages';
  static const String coloring = 'coloring';
  static const String texturedHair = 'textured_hair';
  static const String bridal = 'bridal';
  static const String tanning = 'tanning';
  static const String medSpa = 'med_spa';
  static const String menGrooming = 'men_grooming';
  static const String haircutStyling = 'haircut_styling';
  static const String hairTreatments = 'hair_treatments';
  static const String scalpTreatments = 'scalp_treatments';
  static const String keratinSmoothing = 'keratin_smoothing';
  static const String hairExtensions = 'hair_extensions';
  static const String kidsServices = 'kids_services';
  static const String manicurePedicure = 'manicure_pedicure';
  static const String nailArt = 'nail_art';
  static const String threading = 'threading';
  static const String lashExtensions = 'lash_extensions';
  static const String bodyTreatments = 'body_treatments';
  static const String makeupPermanent = 'makeup_permanent';

  /// Keys shown in the category picker (Add / Edit), in product order.
  static const List<String> pickerOrderedKeys = [
    hair,
    barberBeard,
    nails,
    hairRemovalWaxing,
    other,
    browsLashes,
    facialSkincare,
    makeup,
    massageSpa,
    packages,
    coloring,
    texturedHair,
    bridal,
    tanning,
    medSpa,
    menGrooming,
    haircutStyling,
    hairTreatments,
    scalpTreatments,
    keratinSmoothing,
    hairExtensions,
    kidsServices,
    manicurePedicure,
    nailArt,
    threading,
    lashExtensions,
    bodyTreatments,
    makeupPermanent,
  ];

  /// First row of the owner chip bar (after [All]): Hair, Barber/Beard, Nails.
  static const List<String> topBarHeadKeys = [hair, barberBeard, nails];

  /// Keys after the 5th “Other / custom” slot in the chip bar.
  static const List<String> topBarTailKeys = [
    hairRemovalWaxing,
    browsLashes,
    facialSkincare,
    makeup,
    massageSpa,
    packages,
    coloring,
    texturedHair,
    bridal,
    tanning,
    medSpa,
    menGrooming,
    haircutStyling,
    hairTreatments,
    scalpTreatments,
    keratinSmoothing,
    hairExtensions,
    kidsServices,
    manicurePedicure,
    nailArt,
    threading,
    lashExtensions,
    bodyTreatments,
    makeupPermanent,
  ];

  static bool isKnownKey(String? key) {
    if (key == null || key.isEmpty) {
      return false;
    }
    return pickerOrderedKeys.contains(key);
  }

  /// Maps legacy English [SalonService.category] labels to keys.
  /// English default for [categoryLabel] when migrating or seeding documents.
  static String defaultEnglishLabelForKey(String key) {
    switch (key) {
      case hair:
        return 'Hair';
      case barberBeard:
        return 'Barber / Beard';
      case nails:
        return 'Nails';
      case hairRemovalWaxing:
        return 'Hair Removal / Waxing';
      case other:
        return 'Other';
      case browsLashes:
        return 'Brows & Lashes';
      case facialSkincare:
        return 'Facial / Skincare';
      case makeup:
        return 'Makeup';
      case massageSpa:
        return 'Massage / Spa';
      case packages:
        return 'Packages';
      case coloring:
        return 'Coloring';
      case texturedHair:
        return 'Textured Hair';
      case bridal:
        return 'Bridal';
      case tanning:
        return 'Tanning';
      case medSpa:
        return 'Med Spa';
      case menGrooming:
        return 'Men Grooming';
      case haircutStyling:
        return 'Haircut & Styling';
      case hairTreatments:
        return 'Hair Treatments';
      case scalpTreatments:
        return 'Scalp Treatments';
      case keratinSmoothing:
        return 'Keratin / Smoothing';
      case hairExtensions:
        return 'Hair Extensions';
      case kidsServices:
        return 'Kids Services';
      case manicurePedicure:
        return 'Manicure / Pedicure';
      case nailArt:
        return 'Nail Art';
      case threading:
        return 'Threading';
      case lashExtensions:
        return 'Lash Extensions';
      case bodyTreatments:
        return 'Body Treatments';
      case makeupPermanent:
        return 'Permanent Makeup';
      default:
        return key;
    }
  }

  static String? migrateLegacyCategoryLabelToKey(String? legacyCategory) {
    final c = legacyCategory?.trim();
    if (c == null || c.isEmpty) {
      return null;
    }
    final lower = c.toLowerCase();
    switch (lower) {
      case 'hair':
        return hair;
      case 'beard':
      case 'barber / beard':
      case 'barber/beard':
        return barberBeard;
      case 'facial':
      case 'facial / skincare':
        return facialSkincare;
      case 'packages':
        return packages;
      case 'coloring':
        return coloring;
      case 'men grooming':
        return menGrooming;
      case 'haircut & styling':
      case 'haircut and styling':
        return haircutStyling;
      case 'hair treatments':
        return hairTreatments;
      case 'scalp treatments':
        return scalpTreatments;
      case 'keratin / smoothing':
      case 'keratin and smoothing':
        return keratinSmoothing;
      case 'hair extensions':
        return hairExtensions;
      case 'kids services':
        return kidsServices;
      case 'manicure / pedicure':
      case 'manicure and pedicure':
        return manicurePedicure;
      case 'nail art':
        return nailArt;
      case 'threading':
        return threading;
      case 'lash extensions':
        return lashExtensions;
      case 'body treatments':
        return bodyTreatments;
      case 'permanent makeup':
        return makeupPermanent;
      case 'haircut':
      case 'classic haircut':
      case 'combo':
        return haircutStyling;
      case 'kids':
      case 'kids haircut':
        return kidsServices;
      case 'skin fade':
      case 'fade':
        return haircutStyling;
      default:
        return null;
    }
  }

  /// When [migrateLegacyCategoryLabelToKey] returns null, infer from free-form labels.
  static String? inferKeyFromLooseLabel(String? label) {
    final raw = label?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final lower = raw.toLowerCase();

    if (RegExp(r'\b(kids?|children|child)\b').hasMatch(lower)) {
      return kidsServices;
    }
    if (lower.contains('combo')) {
      return haircutStyling;
    }
    if (lower.contains('beard') ||
        lower.contains('mustache') ||
        lower.contains('goatee') ||
        lower.contains('shave')) {
      return barberBeard;
    }
    if (lower.contains('fade') ||
        lower.contains('haircut') ||
        lower.contains('hair cut') ||
        lower.contains('clipper')) {
      return haircutStyling;
    }
    if (lower.contains('hair treatment') || lower.contains('hair mask')) {
      return hairTreatments;
    }
    if (lower.contains('threading')) {
      return threading;
    }
    if (lower.contains('wax')) {
      return hairRemovalWaxing;
    }
    if (lower.contains('color') ||
        lower.contains('dye') ||
        lower.contains('highlight')) {
      return coloring;
    }
    if (lower.contains('manicure') ||
        lower.contains('pedicure') ||
        RegExp(r'\bnails?\b').hasMatch(lower)) {
      return nails;
    }
    if (lower.contains('facial')) {
      return facialSkincare;
    }
    if (lower.contains('massage')) {
      return massageSpa;
    }
    if (lower.contains('package')) {
      return packages;
    }
    if (lower == 'hair' || lower.startsWith('hair ')) {
      return hair;
    }
    return null;
  }
}
