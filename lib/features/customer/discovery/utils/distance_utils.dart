import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../customer_home/domain/customer_geo.dart';

/// Straight-line distance helpers for discovery cards.
abstract final class DistanceUtils {
  /// Localized distance line for image overlay (includes “away” phrasing where applicable).
  static String distanceLabelForCard({
    required GeoPoint? salonLocation,
    required Position? user,
    required AppLocalizations l10n,
  }) {
    final km = calculateDistanceKm(
      userLat: user?.latitude,
      userLng: user?.longitude,
      salonLat: salonLocation?.latitude,
      salonLng: salonLocation?.longitude,
    );
    if (km == null || km > kCustomerNearbyDistanceDisplayMaxKm) {
      return l10n.placeCardDistanceUnavailable;
    }
    final rounded = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
    return l10n.placeCardDistanceKmAway(rounded);
  }

  /// Split strings so the meta row can show “{km} km” + subtitle “away” without brittle trimming.
  static ({String overlayLine, String metaKmTitle}) distancePartsForCard({
    required GeoPoint? salonLocation,
    required Position? user,
    required AppLocalizations l10n,
  }) {
    final km = calculateDistanceKm(
      userLat: user?.latitude,
      userLng: user?.longitude,
      salonLat: salonLocation?.latitude,
      salonLng: salonLocation?.longitude,
    );
    if (km == null || km > kCustomerNearbyDistanceDisplayMaxKm) {
      final fallback = l10n.placeCardDistanceUnavailable;
      return (overlayLine: fallback, metaKmTitle: fallback);
    }
    final rounded = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
    return (
      overlayLine: l10n.placeCardDistanceKmAway(rounded),
      metaKmTitle: l10n.placeCardDistanceKmOnly(rounded),
    );
  }

  /// Numeric km for sorting/filtering, or `null` if unavailable.
  static double? distanceKm({
    required GeoPoint? salonLocation,
    required Position? user,
  }) {
    if (salonLocation == null || user == null) {
      return null;
    }
    return calculateDistanceKm(
      userLat: user.latitude,
      userLng: user.longitude,
      salonLat: salonLocation.latitude,
      salonLng: salonLocation.longitude,
    );
  }
}
