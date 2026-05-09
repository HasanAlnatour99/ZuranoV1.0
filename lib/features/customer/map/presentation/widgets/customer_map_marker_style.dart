import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/salon_map_item.dart';

/// Premium-feel marker hues: brand purple when open, muted when closed, distinct by type.
double mapMarkerHueForSalon(
  SalonMapItem salon, {
  required bool selected,
}) {
  if (selected) {
    return BitmapDescriptor.hueRose;
  }
  if (!salon.openNow) {
    return BitmapDescriptor.hueAzure;
  }
  switch (salon.businessType) {
    case 'barber':
      return BitmapDescriptor.hueViolet;
    case 'spa':
      return BitmapDescriptor.hueGreen;
    case 'mixed':
      return BitmapDescriptor.hueOrange;
    case 'salon':
    default:
      return BitmapDescriptor.hueMagenta;
  }
}
