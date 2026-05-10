/// Presentation-only view models for the Zurano customer home screen.
class CustomerHomeCategoryUi {
  const CustomerHomeCategoryUi({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.isSelected,
  });

  final String id;
  final String name;
  final String iconKey;
  final bool isSelected;
}

class NearbyPlaceUi {
  const NearbyPlaceUi({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.city,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.isOpenNow,
    required this.isNewSalon,
    required this.tags,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String city;
  final String country;
  final double? distanceKm;
  final double rating;
  final int reviewCount;
  final bool isOpenNow;
  final bool isNewSalon;
  final List<String> tags;
}

class RecommendedSpecialistUi {
  const RecommendedSpecialistUi({
    required this.id,
    required this.salonId,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    this.yearsExperience,
  });

  final String id;
  final String salonId;
  final String name;
  final String title;
  final String imageUrl;
  final double rating;
  final int? yearsExperience;
}
