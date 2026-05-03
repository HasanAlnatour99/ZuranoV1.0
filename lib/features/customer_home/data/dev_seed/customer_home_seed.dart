import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../services/data/service_category_catalog.dart';

/// Development-only curated discovery data for `salons/*`, `customerDiscovery/*`,
/// and mirrored `publicSalons/*` (+ public services/team) so guest browse still works.
Future<void> seedCustomerHomeDemoData(FirebaseFirestore db) async {
  if (!kDebugMode) {
    return;
  }

  final ts = <String, FieldValue>{
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  final batch = db.batch();

  void setCat(
    String id, {
    required String label,
    required String iconKey,
    required String imageUrl,
    required int sortOrder,
  }) {
    final ref = db
        .collection(FirestorePaths.customerDiscovery)
        .doc(FirestorePaths.customerDiscoveryCategoriesDoc)
        .collection(FirestorePaths.customerDiscoveryItems)
        .doc(id);
    batch.set(ref, {
      'label': label,
      'iconKey': iconKey,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': true,
      'debugSeed': true,
      ...ts,
    }, SetOptions(merge: true));
  }

  void setTrend(
    String id, {
    required String label,
    required String iconKey,
    required String bookingCountText,
    required int bookingCount,
    required String categoryId,
    required int sortOrder,
  }) {
    final ref = db
        .collection(FirestorePaths.customerDiscovery)
        .doc(FirestorePaths.customerDiscoveryTrendingServicesDoc)
        .collection(FirestorePaths.customerDiscoveryItems)
        .doc(id);
    batch.set(ref, {
      'label': label,
      'iconKey': iconKey,
      'bookingCountText': bookingCountText,
      'bookingCount': bookingCount,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'isActive': true,
      'debugSeed': true,
      ...ts,
    }, SetOptions(merge: true));
  }

  final jan2020 = DateTime.utc(2020);

  batch.set(
    db
        .collection(FirestorePaths.customerDiscovery)
        .doc(FirestorePaths.customerDiscoveryBannersDoc)
        .collection(FirestorePaths.customerDiscoveryItems)
        .doc('welcome_rewards'),
    {
      'title': 'Glow more, pay less ✨',
      'subtitle': 'Earn points on every booking and unlock exclusive rewards.',
      'ctaText': 'View offers',
      'type': 'rewards',
      'isActive': true,
      'sortOrder': 0,
      'startAt': Timestamp.fromDate(jan2020),
      'debugSeed': true,
      ...ts,
    },
    SetOptions(merge: true),
  );

  const catAvatar = 'https://picsum.photos/seed/zur_cat/200';

  setCat(
    'all',
    label: 'All',
    iconKey: 'category_all',
    imageUrl: '',
    sortOrder: -1,
  );
  setCat(
    'hair',
    label: 'Hair',
    iconKey: 'hair',
    imageUrl: catAvatar,
    sortOrder: 0,
  );
  setCat(
    'nails',
    label: 'Nails',
    iconKey: 'nails',
    imageUrl: catAvatar,
    sortOrder: 1,
  );
  setCat(
    'beauty',
    label: 'Beauty',
    iconKey: 'beauty',
    imageUrl: catAvatar,
    sortOrder: 2,
  );
  setCat(
    'barbers',
    label: 'Barbers',
    iconKey: 'barbers',
    imageUrl: catAvatar,
    sortOrder: 3,
  );
  setCat(
    'spa',
    label: 'Spa',
    iconKey: 'spa',
    imageUrl: catAvatar,
    sortOrder: 4,
  );
  setCat(
    'makeup',
    label: 'Makeup',
    iconKey: 'makeup',
    imageUrl: catAvatar,
    sortOrder: 5,
  );

  setTrend(
    'haircut',
    label: 'Haircut',
    iconKey: 'haircut',
    bookingCountText: '12.3k bookings',
    bookingCount: 12300,
    categoryId: 'hair',
    sortOrder: 0,
  );
  setTrend(
    'blow_dry',
    label: 'Blow Dry',
    iconKey: 'blow_dry',
    bookingCountText: '9.8k bookings',
    bookingCount: 9800,
    categoryId: 'hair',
    sortOrder: 1,
  );
  setTrend(
    'gel_nails',
    label: 'Gel Nails',
    iconKey: 'gel_nails',
    bookingCountText: '8.1k bookings',
    bookingCount: 8100,
    categoryId: 'nails',
    sortOrder: 2,
  );
  setTrend(
    'facial',
    label: 'Facial',
    iconKey: 'facial',
    bookingCountText: '7.4k bookings',
    bookingCount: 7400,
    categoryId: 'beauty',
    sortOrder: 3,
  );
  setTrend(
    'hair_color',
    label: 'Hair Color',
    iconKey: 'hair_color',
    bookingCountText: '6.2k bookings',
    bookingCount: 6200,
    categoryId: 'hair',
    sortOrder: 4,
  );

  void seedDiscoverySalon({
    required String id,
    required String name,
    required String city,
    required String area,
    required String country,
    required double latitude,
    required double longitude,
    required List<String> tags,
    required List<String> categoryIds,
    required List<String> searchKeywords,
    required double ratingAverage,
    required int ratingCount,
    required String distanceKmText,
    required String coverImageUrl,
    required String logoUrl,
    required bool isPromoted,
    String? discountText,
  }) {
    final privateRef = db.collection(FirestorePaths.salons).doc(id);
    batch.set(privateRef, {
      'id': id,
      'salonId': id,
      'name': name,
      'nameLower': name.toLowerCase(),
      'city': city,
      'area': area,
      'country': country,
      'countryCode': 'QA',
      'address': '$area, $city',
      'latitude': latitude,
      'longitude': longitude,
      'isPublished': true,
      'isOpen': true,
      'isPromoted': isPromoted,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'distanceKmText': distanceKmText,
      'priceLevel': '\$\$',
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'tags': tags,
      'categoryIds': categoryIds,
      'searchKeywords': searchKeywords,
      ...?(discountText == null
          ? null
          : <String, dynamic>{'discountText': discountText}),
      'ownerUid': 'discovery_seed_uid',
      'ownerName': 'Discovery Seed Owner',
      'ownerEmail': 'discovery_seed@example.com',
      'phone': '+97400000000',
      'isActive': true,
      'currencyCode': 'QAR',
      'debugSeed': true,
      ...FirestoreWritePayload.withServerTimestampsForCreate({}),
    }, SetOptions(merge: true));

    final srvRef = db
        .collection(FirestorePaths.salons)
        .doc(id)
        .collection(FirestorePaths.services)
        .doc('${id}_srv_default');
    batch.set(
      srvRef,
      FirestoreWritePayload.withServerTimestampsForCreate({
        'id': '${id}_srv_default',
        'salonId': id,
        'name': 'Signature cut',
        'serviceName': 'Signature cut',
        'nameAr': 'قصة توقيع',
        'durationMinutes': 45,
        'price': 120,
        'bookingCount': 1200,
        'categoryKey': ServiceCategoryKeys.haircutStyling,
        'categoryLabel': 'Haircut & Styling',
        'category': 'Haircut & Styling',
        'isActive': true,
        'categoryId': 'hair',
        'debugSeed': true,
      }),
      SetOptions(merge: true),
    );

    final pubRef = db.collection(FirestorePaths.publicSalons).doc(id);
    batch.set(pubRef, {
      'salonName': name,
      'area': area,
      'phone': '+97400000000',
      'coverImageUrl': coverImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isPublic': true,
      'isActive': true,
      'isOpen': true,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'startingPrice': 50,
      'searchKeywords': [
        ...searchKeywords.map((k) => k.toLowerCase()),
        name.toLowerCase(),
        city.toLowerCase(),
      ],
      'debugSeed': true,
      ...FirestoreWritePayload.withServerTimestampsForCreate({}),
    }, SetOptions(merge: true));

    final pubSrvRef = pubRef.collection(FirestorePaths.services).doc('main');

    batch.set(
      pubSrvRef,
      FirestoreWritePayload.withServerTimestampsForCreate({
        'name': 'Signature Cut',
        'nameAr': 'قصة توقيع',
        'displayName': 'Signature Cut',
        'categoryKey': ServiceCategoryKeys.haircutStyling,
        'category': 'Haircut & Styling',
        'categoryLabel': 'Haircut & Styling',
        'price': 120,
        'durationMinutes': 45,
        'isActive': true,
        'isCustomerVisible': true,
        'sortOrder': 0,
        'salonId': id,
        'debugSeed': true,
      }),
      SetOptions(merge: true),
    );

    final teamRef = pubRef
        .collection(FirestorePaths.publicSalonTeam)
        .doc('barber_demo');
    batch.set(
      teamRef,
      FirestoreWritePayload.withServerTimestampsForCreate({
        'fullName': 'Demo Barber',
        'displayName': 'Demo Barber',
        'roleLabel': 'Barber',
        'isActive': true,
        'isBookable': true,
        'allowCustomerBooking': true,
        'ratingAverage': 4.8,
        'ratingCount': 120,
        'sortOrder': 0,
        'salonId': id,
        'debugSeed': true,
      }),
      SetOptions(merge: true),
    );
  }

  const coverGlow =
      'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=900&q=80';
  const coverLuxe =
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=900&q=80';
  const coverBliss =
      'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?auto=format&fit=crop&w=900&q=80';
  const coverSilk =
      'https://images.unsplash.com/photo-1521590839667-ce7cae9ebcf6?auto=format&fit=crop&w=900&q=80';
  const coverG =
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=900&q=80';

  seedDiscoverySalon(
    id: 'zurano_demo_glow_house',
    name: 'Glow House Salon',
    city: 'Al Wakrah',
    area: 'Al Wakrah',
    country: 'Qatar',
    latitude: 25.162,
    longitude: 51.59,
    tags: ['Hair', 'Nails', 'Beauty'],
    categoryIds: ['hair', 'nails', 'beauty'],
    searchKeywords: ['glow', 'house', 'wakrah', 'hair'],
    ratingAverage: 4.9,
    ratingCount: 128,
    distanceKmText: '—',
    coverImageUrl: coverGlow,
    logoUrl: 'https://picsum.photos/seed/glow/logo/96',
    isPromoted: true,
  );

  seedDiscoverySalon(
    id: 'zurano_demo_luxe',
    name: 'The Luxe Studio',
    city: 'Doha',
    area: 'West Bay',
    country: 'Qatar',
    latitude: 25.325,
    longitude: 51.528,
    tags: ['Hair', 'Makeup', 'Spa'],
    categoryIds: ['hair', 'makeup', 'spa'],
    searchKeywords: ['luxe', 'doha', 'makeup'],
    ratingAverage: 4.8,
    ratingCount: 96,
    distanceKmText: '—',
    coverImageUrl: coverLuxe,
    logoUrl: 'https://picsum.photos/seed/luxe/logo/96',
    isPromoted: true,
  );

  seedDiscoverySalon(
    id: 'zurano_demo_bliss',
    name: 'Bliss Beauty Lounge',
    city: 'Al Rayyan',
    area: 'Al Rayyan',
    country: 'Qatar',
    latitude: 25.292,
    longitude: 51.424,
    tags: ['Nails', 'Spa'],
    categoryIds: ['nails', 'spa'],
    searchKeywords: ['bliss', 'rayyan', 'nails'],
    ratingAverage: 4.7,
    ratingCount: 84,
    distanceKmText: '—',
    coverImageUrl: coverBliss,
    logoUrl: 'https://picsum.photos/seed/bliss/logo/96',
    isPromoted: true,
  );

  seedDiscoverySalon(
    id: 'zurano_demo_silk_shine',
    name: 'Silk & Shine Salon',
    city: 'Al Wakrah',
    area: 'Al Wakrah',
    country: 'Qatar',
    latitude: 25.165,
    longitude: 51.597,
    tags: ['Hair', 'Nails', 'Spa'],
    categoryIds: ['hair', 'nails', 'spa'],
    searchKeywords: ['silk', 'shine'],
    ratingAverage: 4.8,
    ratingCount: 312,
    distanceKmText: '0.6 km',
    coverImageUrl: coverSilk,
    logoUrl: 'https://picsum.photos/seed/silk/logo/96',
    isPromoted: false,
    discountText: '20% off',
  );

  seedDiscoverySalon(
    id: 'zurano_demo_gents',
    name: 'Gentlemen’s Lounge',
    city: 'Al Wakrah',
    area: 'Al Wakrah',
    country: 'Qatar',
    latitude: 25.171,
    longitude: 51.602,
    tags: ['Haircut', 'Beard', 'Shave'],
    categoryIds: ['hair', 'barbers'],
    searchKeywords: ['barber', 'beard'],
    ratingAverage: 4.7,
    ratingCount: 198,
    distanceKmText: '1.1 km',
    coverImageUrl: coverG,
    logoUrl: 'https://picsum.photos/seed/gents/logo/96',
    isPromoted: false,
    discountText: '15% off',
  );

  await batch.commit();
}
