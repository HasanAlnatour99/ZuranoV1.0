import 'package:geolocator/geolocator.dart';

import '../data/models/customer_salon_model.dart';

/// English country label used on `salons/*` for discovery when onboarding has
/// no country yet (matches legacy seed data).
const String kCustomerDiscoveryCountryFallback = 'Qatar';

/// Above this distance (km), nearby cards hide km (e.g. emulator GPS far from Qatar).
const double kCustomerNearbyDistanceDisplayMaxKm = 300;

/// Sentinel sort key when salon coordinates are missing (after GPS is available).
const double _kUnknownDistanceSortKm = 999999;

/// Returns distance in km, or null if any coordinate is missing.
double? calculateDistanceKm({
  required double? userLat,
  required double? userLng,
  required double? salonLat,
  required double? salonLng,
}) {
  if (userLat == null ||
      userLng == null ||
      salonLat == null ||
      salonLng == null) {
    return null;
  }
  final meters = Geolocator.distanceBetween(
    userLat,
    userLng,
    salonLat,
    salonLng,
  );
  return meters / 1000.0;
}

/// Nearby list: Firestore returns published salons for the discovery country only (no city filter).
/// This sorts in memory: by distance when [user] is available, otherwise by rating.
List<CustomerSalonModel> sortNearbySalonsByDistance(
  List<CustomerSalonModel> salons,
  Position? user,
) {
  final copy = [...salons];
  if (user == null) {
    copy.sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));
    return copy;
  }
  copy.sort((a, b) {
    final da = calculateDistanceKm(
      userLat: user.latitude,
      userLng: user.longitude,
      salonLat: a.latitude,
      salonLng: a.longitude,
    );
    final db = calculateDistanceKm(
      userLat: user.latitude,
      userLng: user.longitude,
      salonLat: b.latitude,
      salonLng: b.longitude,
    );
    final aa = da ?? _kUnknownDistanceSortKm;
    final bb = db ?? _kUnknownDistanceSortKm;
    final c = aa.compareTo(bb);
    if (c != 0) {
      return c;
    }
    return b.ratingAverage.compareTo(a.ratingAverage);
  });
  return copy;
}
