import 'package:geolocator/geolocator.dart';

import '../../data/models/public_salon_model.dart';
import '../../data/models/public_specialist_discovery_model.dart';
import '../../domain/customer_geo.dart';
import '../models/customer_home_ui_models.dart';

NearbyPlaceUi mapPublicSalonToNearbyPlaceUi(
  PublicSalonModel salon,
  Position? userPosition,
) {
  final dk = calculateDistanceKm(
    userLat: userPosition?.latitude,
    userLng: userPosition?.longitude,
    salonLat: salon.location?.latitude,
    salonLng: salon.location?.longitude,
  );
  final safeKm =
      dk != null && dk <= kCustomerNearbyDistanceDisplayMaxKm ? dk : null;

  return NearbyPlaceUi(
    id: salon.salonId,
    name: salon.salonName.trim().isNotEmpty ? salon.salonName : '—',
    imageUrl: salon.coverImageUrl.trim(),
    city: salon.city.trim(),
    country: salon.country.trim(),
    distanceKm: safeKm,
    rating: salon.ratingAvg,
    reviewCount: salon.ratingCount,
    isOpenNow: salon.isOpen,
    isNewSalon: salon.ratingCount == 0,
    tags: salon.tags.take(4).toList(growable: false),
  );
}

RecommendedSpecialistUi mapDiscoverySpecialistToUi(
  PublicSpecialistDiscoveryModel s,
) {
  return RecommendedSpecialistUi(
    id: s.specialistId,
    salonId: s.salonId,
    name: s.displayName.trim().isNotEmpty ? s.displayName : '—',
    title: s.roleTitle.trim().isNotEmpty ? s.roleTitle : '—',
    imageUrl: s.photoUrl.trim(),
    rating: s.ratingAvg,
    yearsExperience: null,
  );
}
