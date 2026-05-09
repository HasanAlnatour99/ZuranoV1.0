import 'package:barber_shop_app/features/customer/map/data/customer_map_nearby_merge.dart';
import 'package:barber_shop_app/features/customer/map/domain/salon_map_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const _center = LatLng(25.2854, 51.5310);

SalonMapItem _pin(String id, LatLng position) {
  return SalonMapItem(
    id: id,
    name: id,
    area: '',
    city: '',
    country: '',
    addressText: '',
    position: position,
    ratingAvg: 0,
    ratingCount: 0,
    openStatus: 'unknown',
  );
}

void main() {
  group('CustomerMapNearbyMerge.dedupeAndExactDistance', () {
    test('dedupes by salon id keeping last occurrence', () {
      final close = _pin('a', const LatLng(25.2864, 51.5310));
      final farDuplicate = _pin('a', const LatLng(25.45, 51.5310));

      final merged = CustomerMapNearbyMerge.dedupeAndExactDistance(
        items: [close, farDuplicate],
        center: _center,
        radiusKm: 10,
      );

      expect(merged, isEmpty);
    });

    test('removes geohash false positives outside exact radius', () {
      final inside = _pin('in', const LatLng(25.2864, 51.5310));
      final outside = _pin('out', const LatLng(25.42, 51.5310));

      final merged = CustomerMapNearbyMerge.dedupeAndExactDistance(
        items: [inside, outside],
        center: _center,
        radiusKm: 10,
      );

      expect(merged.map((e) => e.id), ['in']);
      expect(merged.single.distanceMeters, isNotNull);
    });
  });
}
