import 'package:barber_shop_app/features/customer/map/domain/customer_map_discovery_engine.dart';
import 'package:barber_shop_app/features/customer/map/domain/salon_map_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const _doha = LatLng(25.2854, 51.5310);

SalonMapItem _salon({
  required String id,
  String name = 'Salon',
  String businessType = 'mixed',
  bool openNow = false,
  String openStatus = 'unknown',
  double ratingAvg = 0,
  int ratingCount = 0,
  double distanceMeters = 0,
  DateTime? nextAvailableAt,
}) {
  return SalonMapItem(
    id: id,
    name: name,
    area: 'West Bay',
    city: 'Doha',
    country: 'Qatar',
    addressText: 'Doha',
    position: _doha,
    ratingAvg: ratingAvg,
    ratingCount: ratingCount,
    openStatus: openStatus,
    businessType: businessType,
    openNow: openNow,
    nextAvailableAt: nextAvailableAt,
    distanceMeters: distanceMeters,
  );
}

void main() {
  group('CustomerMapDiscoveryEngine.filterAndSort', () {
    test('applyRadiusFilter false keeps upstream radius slice intact', () {
      final far = _salon(id: 'far', distanceMeters: 9000);
      final near = _salon(id: 'near', distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [far, near],
        center: _doha,
        radiusKm: 3,
        filters: const CustomerMapFilterState(),
        applyRadiusFilter: false,
      );

      expect(result.map((s) => s.id).toSet(), {'far', 'near'});
    });

    test('geo-sized input still respects chip filters', () {
      final barber = _salon(
        id: 'b',
        businessType: 'barber',
        distanceMeters: 100,
      );
      final spa = _salon(id: 's', businessType: 'spa', distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [barber, spa],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(
          businessType: MapBusinessTypeChip.barber,
        ),
        applyRadiusFilter: false,
      );

      expect(result.map((s) => s.id), ['b']);
    });

    test('drops salons outside the radius', () {
      final inRadius = _salon(id: 'in', distanceMeters: 1500);
      final outOfRadius = _salon(id: 'far', distanceMeters: 9000);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [inRadius, outOfRadius],
        center: _doha,
        radiusKm: 3,
        filters: const CustomerMapFilterState(),
      );

      expect(result.map((s) => s.id), ['in']);
    });

    test('drops salons with null distance', () {
      final hasDistance = _salon(id: 'a', distanceMeters: 100);
      final noDistance = SalonMapItem(
        id: 'b',
        name: 'No distance',
        area: '',
        city: '',
        country: '',
        addressText: '',
        position: _doha,
        ratingAvg: 0,
        ratingCount: 0,
        openStatus: 'unknown',
      );

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [hasDistance, noDistance],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(),
      );

      expect(result.map((s) => s.id), ['a']);
    });

    test('businessType chip = barber keeps barber + mixed', () {
      final barber = _salon(id: 'b', businessType: 'barber', distanceMeters: 100);
      final mixed = _salon(id: 'm', businessType: 'mixed', distanceMeters: 100);
      final spa = _salon(id: 's', businessType: 'spa', distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [barber, mixed, spa],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(
          businessType: MapBusinessTypeChip.barber,
        ),
      );

      expect(result.map((s) => s.id).toSet(), {'b', 'm'});
    });

    test('businessType chip = spa keeps spa + mixed only', () {
      final barber = _salon(id: 'b', businessType: 'barber', distanceMeters: 100);
      final mixed = _salon(id: 'm', businessType: 'mixed', distanceMeters: 100);
      final spa = _salon(id: 's', businessType: 'spa', distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [barber, mixed, spa],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(
          businessType: MapBusinessTypeChip.spa,
        ),
      );

      expect(result.map((s) => s.id).toSet(), {'s', 'm'});
    });

    test('openNowOnly removes closed places', () {
      final open = _salon(id: 'open', openNow: true, distanceMeters: 100);
      final closed = _salon(id: 'closed', openNow: false, distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [open, closed],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(openNowOnly: true),
      );

      expect(result.map((s) => s.id), ['open']);
    });

    test('topRatedOnly keeps rating >= 4.0', () {
      final low = _salon(id: 'low', ratingAvg: 3.5, distanceMeters: 100);
      final high = _salon(id: 'high', ratingAvg: 4.6, distanceMeters: 100);
      final exact = _salon(id: 'exact', ratingAvg: 4, distanceMeters: 100);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [low, high, exact],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(topRatedOnly: true),
      );

      expect(result.map((s) => s.id).toSet(), {'high', 'exact'});
    });

    test('sorts open before closed', () {
      final closedNear =
          _salon(id: 'closed', openNow: false, distanceMeters: 100);
      final openFar =
          _salon(id: 'open', openNow: true, distanceMeters: 800);

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [closedNear, openFar],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(),
      );

      expect(result.first.id, 'open');
    });

    test('within open group sorts by distance, then rating, then nextAvailable',
        () {
      final base = DateTime(2026, 1, 1, 9);
      final near = _salon(
        id: 'near',
        openNow: true,
        distanceMeters: 200,
        ratingAvg: 4.0,
      );
      final farLowerRating = _salon(
        id: 'farLow',
        openNow: true,
        distanceMeters: 800,
        ratingAvg: 3.0,
        nextAvailableAt: base.add(const Duration(hours: 2)),
      );
      final farHigherRating = _salon(
        id: 'farHigh',
        openNow: true,
        distanceMeters: 800,
        ratingAvg: 4.9,
        nextAvailableAt: base.add(const Duration(hours: 1)),
      );

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [farLowerRating, near, farHigherRating],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(),
      );

      expect(result.map((s) => s.id), ['near', 'farHigh', 'farLow']);
    });

    test('breaks rating ties by earliest nextAvailableAt, then by name', () {
      final base = DateTime(2026, 1, 1, 9);
      final later = _salon(
        id: 'later',
        name: 'Bravo',
        openNow: true,
        distanceMeters: 100,
        ratingAvg: 4.5,
        nextAvailableAt: base.add(const Duration(hours: 2)),
      );
      final earlier = _salon(
        id: 'earlier',
        name: 'Alpha',
        openNow: true,
        distanceMeters: 100,
        ratingAvg: 4.5,
        nextAvailableAt: base,
      );
      final noSlot = _salon(
        id: 'noSlot',
        name: 'Aether',
        openNow: true,
        distanceMeters: 100,
        ratingAvg: 4.5,
      );

      final result = CustomerMapDiscoveryEngine.filterAndSort(
        salons: [later, noSlot, earlier],
        center: _doha,
        radiusKm: 5,
        filters: const CustomerMapFilterState(),
      );

      expect(result.map((s) => s.id), ['earlier', 'later', 'noSlot']);
    });
  });

  group('CustomerMapFilterState.copyWith', () {
    test('preserves untouched fields', () {
      const start = CustomerMapFilterState(
        businessType: MapBusinessTypeChip.barber,
        openNowOnly: true,
        topRatedOnly: false,
      );

      final copy = start.copyWith(topRatedOnly: true);

      expect(copy.businessType, MapBusinessTypeChip.barber);
      expect(copy.openNowOnly, true);
      expect(copy.topRatedOnly, true);
    });
  });
}
