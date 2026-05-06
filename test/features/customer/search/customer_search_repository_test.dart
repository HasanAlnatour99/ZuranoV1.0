import 'package:barber_shop_app/features/customer/search/data/customer_search_repository.dart';
import 'package:barber_shop_app/features/customer/search/domain/models/customer_search_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// QA: validates `CustomerSearchRepository.search` against Firestore-shaped data.
///
/// Uses [FakeFirebaseFirestore] (same query patterns as production). For emulator
/// smoke tests run: `firebase emulators:exec "flutter test test/features/customer/search"`
void main() {
  const qa = 'QA';

  Map<String, dynamic> indexSalonDoc({
    required String salonId,
    required String countryCode,
    required bool isOpenNow,
    required bool hasOffer,
    required num priceFrom,
    required double ratingAvg,
    GeoPoint? location,
    List<String>? keywords,
  }) {
    return <String, dynamic>{
      'type': 'salon',
      'salonId': salonId,
      'targetId': salonId,
      'title': 'Salon $salonId',
      'subtitle': 'sub',
      'countryCode': countryCode,
      'countryName': 'Testland',
      'city': 'Doha',
      'area': 'West',
      'audience': 'unisex',
      'ratingAvg': ratingAvg,
      'ratingCount': 5,
      'priceFrom': priceFrom,
      'isOpenNow': isOpenNow,
      'hasOffer': hasOffer,
      'isActive': true,
      'isPublic': true,
      'searchKeywords': keywords ?? <String>['haircut', 'beard'],
      if (location != null) 'location': location,
    };
  }

  group('CustomerSearchRepository (Firebase-shaped)', () {
    test('audience men matches men + unisex via whereIn', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('men').set(
            indexSalonDoc(
              salonId: 'm1',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            )..['audience'] = 'men',
          );
      await fake.collection('customerSearchIndex').doc('ladies').set(
            indexSalonDoc(
              salonId: 'l1',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            )..['audience'] = 'ladies',
          );
      await fake.collection('customerSearchIndex').doc('uni').set(
            indexSalonDoc(
              salonId: 'u1',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            )..['audience'] = 'unisex',
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          audience: 'men',
        ),
      );

      final ids = out.map((e) => e.salonId).toSet();
      expect(ids.contains('m1'), isTrue);
      expect(ids.contains('u1'), isTrue);
      expect(ids.contains('l1'), isFalse);
    });

    test('filters by countryCode only', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('salon_qa').set(
            indexSalonDoc(
              salonId: 'qa1',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 40,
              ratingAvg: 4,
            ),
          );
      await fake.collection('customerSearchIndex').doc('salon_us').set(
            indexSalonDoc(
              salonId: 'us1',
              countryCode: 'US',
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 40,
              ratingAvg: 4,
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(const CustomerSearchFilter(countryCode: qa));

      expect(out, hasLength(1));
      expect(out.single.countryCode.toUpperCase(), qa);
    });

    test('openNowOnly restricts to isOpenNow rows', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('a').set(
            indexSalonDoc(
              salonId: 'a',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            ),
          );
      await fake.collection('customerSearchIndex').doc('b').set(
            indexSalonDoc(
              salonId: 'b',
              countryCode: qa,
              isOpenNow: false,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          openNowOnly: true,
        ),
      );

      expect(out, hasLength(1));
      expect(out.single.isOpenNow, isTrue);
    });

    test('offersOnly restricts to hasOffer rows', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('a').set(
            indexSalonDoc(
              salonId: 'a',
              countryCode: qa,
              isOpenNow: false,
              hasOffer: true,
              priceFrom: 10,
              ratingAvg: 4,
            ),
          );
      await fake.collection('customerSearchIndex').doc('b').set(
            indexSalonDoc(
              salonId: 'b',
              countryCode: qa,
              isOpenNow: false,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          offersOnly: true,
        ),
      );

      expect(out, hasLength(1));
      expect(out.single.hasOffer, isTrue);
    });

    test('query uses searchKeywords arrayContains', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('a').set(
            indexSalonDoc(
              salonId: 'a',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
              keywords: <String>['uniquekwxyz'],
            ),
          );
      await fake.collection('customerSearchIndex').doc('b').set(
            indexSalonDoc(
              salonId: 'b',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
              keywords: <String>['other'],
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          query: 'uniquekwxyz',
        ),
      );

      expect(out, hasLength(1));
      expect(out.single.salonId, 'a');
    });

    test('sort priceLowToHigh orders by priceFrom', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('hi').set(
            indexSalonDoc(
              salonId: 'hi',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 200,
              ratingAvg: 4,
            ),
          );
      await fake.collection('customerSearchIndex').doc('lo').set(
            indexSalonDoc(
              salonId: 'lo',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          sort: CustomerSearchSort.priceLowToHigh,
        ),
      );

      expect(out.map((e) => e.salonId).toList(), <String>['lo', 'hi']);
    });

    test('sort topRated orders by ratingAvg desc', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('customerSearchIndex').doc('low').set(
            indexSalonDoc(
              salonId: 'low',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 2,
            ),
          );
      await fake.collection('customerSearchIndex').doc('high').set(
            indexSalonDoc(
              salonId: 'high',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 5,
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        const CustomerSearchFilter(
          countryCode: qa,
          sort: CustomerSearchSort.topRated,
        ),
      );

      expect(out.first.salonId, 'high');
      expect(out.last.salonId, 'low');
    });

    test('sort nearby ranks by distance when user + salon coords exist', () async {
      final fake = FakeFirebaseFirestore();
      // User ~ Doha; near salon closer than far salon.
      await fake.collection('customerSearchIndex').doc('far').set(
            indexSalonDoc(
              salonId: 'far',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
              location: const GeoPoint(25.19, 51.41),
            ),
          );
      await fake.collection('customerSearchIndex').doc('near').set(
            indexSalonDoc(
              salonId: 'near',
              countryCode: qa,
              isOpenNow: true,
              hasOffer: false,
              priceFrom: 10,
              ratingAvg: 4,
              location: const GeoPoint(25.286, 51.531),
            ),
          );

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(
        CustomerSearchFilter(
          countryCode: qa,
          sort: CustomerSearchSort.nearby,
          userLatitude: 25.285,
          userLongitude: 51.531,
        ),
      );

      expect(out.first.salonId, 'near');
      expect(out.last.salonId, 'far');
      expect(out.first.distanceKm, isNotNull);
    });

    test('fallback reads publicSalons when index is empty', () async {
      final fake = FakeFirebaseFirestore();
      await fake.collection('publicSalons').doc('pub1').set(<String, dynamic>{
        'salonId': 'pub1',
        'countryCode': qa,
        'isPublic': true,
        'isActive': true,
        'salonName': 'Public Salon',
        'name': 'Public Salon',
        'city': 'Doha',
        'area': 'West',
        'countryName': 'Testland',
        'searchKeywords': <String>['haircut'],
        'startingPrice': 25,
        'ratingAverage': 4.2,
        'ratingCount': 3,
        'isOpen': true,
        'hasOffer': false,
        'latitude': 25.29,
        'longitude': 51.53,
      });

      final repo = CustomerSearchRepository(fake);
      final out = await repo.search(const CustomerSearchFilter(countryCode: qa));

      expect(out, isNotEmpty);
      expect(out.single.title.toLowerCase(), contains('public'));
    });
  });

  group('QA notes — product gaps', () {
    test(
      'availableTodayOnly is not applied in repository yet (no index field)',
      () {
        // customerSearchIndex mirror (functions/src/customerSearchIndex.ts) has no
        // availability flag; chip toggles UI state only until backend exposes one.
        expect(true, isTrue);
      },
    );
  });
}
