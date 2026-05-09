import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'salon_map_item.dart';

/// Customer-facing discovery ranking & chip filters for the map / bottom sheet.
///
/// Radius filtering can be skipped when the upstream repository already applied
/// an exact-distance geo query ([applyRadiusFilter] == false).
class CustomerMapDiscoveryEngine {
  const CustomerMapDiscoveryEngine._();

  /// When salon markers after chip filtering exceed this count, the presentation
  /// layer assigns salon pins to a [ClusterManager] for platform-side clustering.
  static const int kMarkerClusterThreshold = 20;

  static List<SalonMapItem> filterAndSort({
    required List<SalonMapItem> salons,
    required LatLng center,
    required double radiusKm,
    required CustomerMapFilterState filters,
    bool applyRadiusFilter = true,
  }) {
    final metersLimit = radiusKm * 1000;
    List<SalonMapItem> stage = salons;
    if (applyRadiusFilter) {
      stage = salons.where((s) {
        final d = s.distanceMeters;
        if (d == null) return false;
        return d <= metersLimit;
      }).toList();
    }

    final filtered =
        stage.where((s) => passesChipFilters(s, filters)).toList()
          ..sort(compareDiscoveryOrder);

    return filtered;
  }

  static bool passesChipFilters(SalonMapItem s, CustomerMapFilterState f) {
    if (f.openNowOnly && !s.openNow) {
      return false;
    }
    if (f.topRatedOnly && s.ratingAvg < 4) {
      return false;
    }
    switch (f.businessType) {
      case MapBusinessTypeChip.all:
        return true;
      case MapBusinessTypeChip.barber:
        return s.businessType == 'barber' || s.businessType == 'mixed';
      case MapBusinessTypeChip.salon:
        return s.businessType == 'salon' || s.businessType == 'mixed';
      case MapBusinessTypeChip.spa:
        return s.businessType == 'spa' || s.businessType == 'mixed';
    }
  }

  /// Open → distance → rating → next slot → name.
  ///
  /// TODO(product): derive sort keys from real booking availability instead of
  /// denormalized [SalonMapItem.nextAvailableAt] alone.
  static int compareDiscoveryOrder(SalonMapItem a, SalonMapItem b) {
    if (a.openNow != b.openNow) {
      return a.openNow ? -1 : 1;
    }
    final da = a.distanceMeters ?? double.maxFinite;
    final db = b.distanceMeters ?? double.maxFinite;
    final byDist = da.compareTo(db);
    if (byDist != 0) {
      return byDist;
    }
    final byRating = b.ratingAvg.compareTo(a.ratingAvg);
    if (byRating != 0) {
      return byRating;
    }
    final na = a.nextAvailableAt;
    final nb = b.nextAvailableAt;
    if (na != null && nb != null) {
      return na.compareTo(nb);
    }
    if (na != null) {
      return -1;
    }
    if (nb != null) {
      return 1;
    }
    return a.name.compareTo(b.name);
  }
}

class CustomerMapFilterState {
  const CustomerMapFilterState({
    this.businessType = MapBusinessTypeChip.all,
    this.openNowOnly = false,
    this.topRatedOnly = false,
  });

  final MapBusinessTypeChip businessType;
  final bool openNowOnly;
  final bool topRatedOnly;

  CustomerMapFilterState copyWith({
    MapBusinessTypeChip? businessType,
    bool? openNowOnly,
    bool? topRatedOnly,
  }) {
    return CustomerMapFilterState(
      businessType: businessType ?? this.businessType,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      topRatedOnly: topRatedOnly ?? this.topRatedOnly,
    );
  }
}

enum MapBusinessTypeChip { all, barber, salon, spa }
