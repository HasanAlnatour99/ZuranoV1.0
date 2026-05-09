import 'package:barber_shop_app/features/customer/map/domain/salon_map_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalonMapItem.maybeFromDiscoveryDoc', () {
    test('prefers root latitude/longitude over GeoPoint location', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('publicSalons').doc('s1').set({
        'salonName': 'Precision',
        'latitude': 25.1,
        'longitude': 51.1,
        'location': const GeoPoint(25.9, 51.9),
        'isActive': true,
        'isPublished': true,
        'isPublic': true,
      });

      final doc = await fs.collection('publicSalons').doc('s1').get();
      final item = SalonMapItem.maybeFromDiscoveryDoc(doc);

      expect(item, isNotNull);
      expect(item!.position.latitude, 25.1);
      expect(item.position.longitude, 51.1);
    });

    test('falls back to GeoPoint when latitude/longitude missing', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('publicSalons').doc('s2').set({
        'salonName': 'GeoOnly',
        'location': const GeoPoint(25.22, 51.44),
      });

      final doc = await fs.collection('publicSalons').doc('s2').get();
      final item = SalonMapItem.maybeFromDiscoveryDoc(doc);

      expect(item, isNotNull);
      expect(item!.position.latitude, 25.22);
      expect(item.position.longitude, 51.44);
    });

    test('parses without geohash without throwing', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('publicSalons').doc('s3').set({
        'salonName': 'NoHash',
        'latitude': 25.25,
        'longitude': 51.5,
      });

      final doc = await fs.collection('publicSalons').doc('s3').get();
      final item = SalonMapItem.maybeFromDiscoveryDoc(doc);

      expect(item, isNotNull);
      expect(item!.geohash, isNull);
    });
  });
}
