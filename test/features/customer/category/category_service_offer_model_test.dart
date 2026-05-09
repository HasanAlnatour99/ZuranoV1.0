import 'package:barber_shop_app/features/customer/category/data/models/category_service_offer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses latitude/longitude from index row', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('customerSearchIndex').doc('row').set({
      'type': 'service',
      'salonId': 's1',
      'targetId': 'svc1',
      'title': 'Cut',
      'salonName': 'Shop',
      'durationMinutes': 30,
      'city': 'Doha',
      'area': 'West',
      'countryCode': 'QA',
      'latitude': 25.278,
      'longitude': 51.500,
      'geohash': 'tjjbbdh45',
    });
    final doc = await db.collection('customerSearchIndex').doc('row').get();
    final m = CategoryServiceOfferModel.fromFirestore(doc);
    expect(m.latitude, closeTo(25.278, 0.001));
    expect(m.longitude, closeTo(51.500, 0.001));
    expect(m.geohash, 'tjjbbdh45');
  });

  test('falls back to GeoPoint location when lat/lng missing', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('customerSearchIndex').doc('row').set({
      'type': 'service',
      'salonId': 's1',
      'targetId': 'svc1',
      'title': 'Cut',
      'salonName': 'Shop',
      'durationMinutes': 30,
      'city': '',
      'area': '',
      'countryCode': 'QA',
      'location': const GeoPoint(25.1, 51.2),
    });
    final doc = await db.collection('customerSearchIndex').doc('row').get();
    final m = CategoryServiceOfferModel.fromFirestore(doc);
    expect(m.latitude, 25.1);
    expect(m.longitude, 51.2);
  });

  test('invalid geo is ignored safely', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('customerSearchIndex').doc('row').set({
      'type': 'service',
      'salonId': 's1',
      'targetId': 'svc1',
      'title': 'Cut',
      'salonName': 'Shop',
      'durationMinutes': 30,
      'city': '',
      'area': '',
      'countryCode': 'QA',
      'latitude': double.nan,
      'longitude': 51.0,
    });
    final doc = await db.collection('customerSearchIndex').doc('row').get();
    final m = CategoryServiceOfferModel.fromFirestore(doc);
    expect(m.latitude, isNull);
    expect(m.longitude, isNull);
  });
}
