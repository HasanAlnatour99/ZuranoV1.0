import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/device_geolocation_service.dart';

/// Current GPS position when possible; soft-fallback to last known; otherwise `null`.
///
/// [maxLastKnownAge] avoids sorting / labels by a stale cached fix (e.g. emulator or old trip).
final customerCurrentPositionProvider = FutureProvider.autoDispose<Position?>((
  ref,
) async {
  final svc = DeviceGeolocationService();
  return svc.tryGetCurrentPosition(
    timeout: const Duration(seconds: 15),
    accuracy: LocationAccuracy.high,
    maxLastKnownAge: const Duration(minutes: 45),
  );
});

/// Reverse-geocoded place for the customer home header (from [customerCurrentPositionProvider]).
final customerHomeResolvedPlaceProvider =
    FutureProvider.autoDispose<Placemark?>((ref) async {
      final position = await ref.watch(customerCurrentPositionProvider.future);
      if (position == null) {
        return null;
      }
      try {
        final marks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (marks.isEmpty) {
          return null;
        }
        return marks.first;
      } on Object {
        return null;
      }
    });
