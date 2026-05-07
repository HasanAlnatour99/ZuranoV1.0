import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../onboarding/application/device_country_iso.dart';
import '../../../onboarding/domain/value_objects/country_option.dart';
import '../../domain/customer_geo.dart';
import 'customer_location_providers.dart';
import '../../data/models/customer_banner_model.dart';
import '../../data/models/customer_category_model.dart';
import '../../data/models/customer_salon_model.dart';
import '../../data/models/customer_salon_preview_model.dart';
import '../../data/models/discovery_service_category_model.dart';
import '../../data/models/public_specialist_model.dart';
import '../../data/models/trending_service_model.dart';
import '../../data/repositories/customer_home_repository.dart';
import '../../data/repositories/customer_recent_activity_repository.dart';
import '../../data/models/recently_viewed_salon_model.dart';
import '../../data/models/last_booked_model.dart';
import '../../../../providers/app_settings_providers.dart' show sharedPreferencesProvider;

final customerHomeRepositoryProvider = Provider<CustomerHomeRepository>((ref) {
  return CustomerHomeRepository(ref.watch(firestoreProvider));
});

/// ISO 3166-1 alpha-2 for **all** customer discovery / search queries (e.g. `QA`).
final customerDiscoveryCountryCodeProvider = Provider<String>((ref) {
  final prefs = ref.watch(onboardingPrefsProvider);
  final fromPrefs = prefs.countryCode?.trim().toUpperCase();
  if (fromPrefs != null && fromPrefs.isNotEmpty) {
    return fromPrefs;
  }
  final device = tryDeviceLocaleCountryIso();
  if (device != null && device.isNotEmpty) {
    return device;
  }
  if (kDebugMode) {
    debugPrint(
      '[CustomerDiscovery] countryCode fallback QA (set onboarding country for production)',
    );
  }
  return 'QA';
});

/// English `salons.country` value for discovery queries (matches onboarding pick).
final customerDiscoveryCountryNameProvider = Provider<String>((ref) {
  final prefs = ref.watch(onboardingPrefsProvider);
  final name = prefs.countryName?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  final iso = prefs.countryCode?.trim();
  if (iso != null && iso.isNotEmpty) {
    return CountryOption.tryFindByIso(iso)?.nameEn ?? iso;
  }
  return kCustomerDiscoveryCountryFallback;
});

final selectedCustomerCategoryProvider = StateProvider.autoDispose<String>(
  (ref) => 'all',
);

final customerSearchTextProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final customerCategoriesProvider =
    StreamProvider.autoDispose<List<CustomerCategoryModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      return repo.watchCategories();
    });

final recommendedSalonsProvider =
    StreamProvider.autoDispose<List<CustomerSalonModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final categoryId = ref.watch(selectedCustomerCategoryProvider);
      final country = ref.watch(customerDiscoveryCountryNameProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchRecommendedSalons(
        discoveryCountryName: country,
        customerCountryCode: countryCode,
        categoryId: categoryId == 'all' ? null : categoryId,
      );
    });

/// Raw stream from Firestore (country + category); distance sort applied in [nearbySalonsProvider].
final _nearbySalonsFirestoreProvider =
    StreamProvider.autoDispose<List<CustomerSalonModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final categoryId = ref.watch(selectedCustomerCategoryProvider);
      final country = ref.watch(customerDiscoveryCountryNameProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchNearbySalons(
        discoveryCountryName: country,
        customerCountryCode: countryCode,
        categoryId: categoryId == 'all' ? null : categoryId,
      );
    });

/// Near-me list ordered by GPS distance to each salon when [customerCurrentPositionProvider] resolves.
final nearbySalonsProvider =
    Provider.autoDispose<AsyncValue<List<CustomerSalonModel>>>((ref) {
      final salonsAsync = ref.watch(_nearbySalonsFirestoreProvider);
      final positionAsync = ref.watch(customerCurrentPositionProvider);
      return salonsAsync.when(
        data: (list) {
          return positionAsync.when(
            data: (pos) => AsyncValue.data(
              sortNearbySalonsByDistance(list, pos),
            ),
            loading: () => AsyncValue.data(list),
            error: (e, st) => AsyncValue.data(
              sortNearbySalonsByDistance(list, null),
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    });

/// Premium home — recommended carousel (`publicSalons` preview rows).
final recommendedSalonPreviewsProvider =
    StreamProvider.autoDispose<List<CustomerSalonPreviewModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final categoryId = ref.watch(selectedCustomerCategoryProvider);
      final country = ref.watch(customerDiscoveryCountryNameProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchRecommendedSalonPreviews(
        discoveryCountryName: country,
        customerCountryCode: countryCode,
        categoryId: categoryId == 'all' ? null : categoryId,
      );
    });

/// Premium home — `customerDiscovery/serviceCategories/items`.
final discoveryServiceCategoriesProvider =
    StreamProvider.autoDispose<List<DiscoveryServiceCategoryModel>>((ref) {
      return ref
          .watch(customerHomeRepositoryProvider)
          .watchDiscoveryServiceCategories();
    });

final _nearbySalonPreviewsFirestoreProvider =
    StreamProvider.autoDispose<List<CustomerSalonPreviewModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final categoryId = ref.watch(selectedCustomerCategoryProvider);
      final country = ref.watch(customerDiscoveryCountryNameProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchNearbySalonPreviews(
        discoveryCountryName: country,
        customerCountryCode: countryCode,
        categoryId: categoryId == 'all' ? null : categoryId,
      );
    });

/// Nearby list with GPS distance ordering when available.
final nearbySalonPreviewsProvider =
    Provider.autoDispose<AsyncValue<List<CustomerSalonPreviewModel>>>((ref) {
      final salonsAsync = ref.watch(_nearbySalonPreviewsFirestoreProvider);
      final positionAsync = ref.watch(customerCurrentPositionProvider);
      return salonsAsync.when(
        data: (list) {
          return positionAsync.when(
            data: (pos) => AsyncValue.data(
              sortNearbySalonPreviewsByDistance(list, pos),
            ),
            loading: () => AsyncValue.data(list),
            error: (e, st) => AsyncValue.data(
              sortNearbySalonPreviewsByDistance(list, null),
            ),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    });

/// Doc ids in `users/{uid}/favorites/*` (empty when signed out).
final favoriteSalonIdsProvider =
    StreamProvider.autoDispose<Set<String>>((ref) {
      final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        return Stream.value(<String>{});
      }
      final db = ref.watch(firestoreProvider);
      return db
          .collection(FirestorePaths.users)
          .doc(uid)
          .collection(FirestorePaths.favorites)
          .snapshots()
          .map((s) => s.docs.map((d) => d.id).toSet());
    });

final trendingServicesProvider =
    StreamProvider.autoDispose<List<TrendingServiceModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      return repo.watchTrendingServices();
    });

final activeBannersProvider =
    StreamProvider.autoDispose<List<CustomerBannerModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      return repo.watchActiveBanners();
    });

final recommendedSpecialistsProvider =
    StreamProvider.autoDispose<List<PublicSpecialistModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchRecommendedSpecialists(countryCode: countryCode);
    });

final todayAvailableSpecialistsProvider =
    StreamProvider.autoDispose<List<PublicSpecialistModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
      return repo.watchTodayAvailableSpecialists(countryCode: countryCode);
    });

final customerRecentActivityRepositoryProvider =
    Provider<CustomerRecentActivityRepository>((ref) {
      return CustomerRecentActivityRepository(ref.watch(sharedPreferencesProvider));
    });

final recentlyViewedSalonsProvider =
    FutureProvider.autoDispose<List<RecentlyViewedSalonModel>>((ref) async {
      final repo = ref.watch(customerRecentActivityRepositoryProvider);
      return repo.getRecentlyViewed();
    });

final lastBookedProvider = FutureProvider.autoDispose<LastBookedModel?>((ref) async {
  final repo = ref.watch(customerRecentActivityRepositoryProvider);
  return repo.getLastBooked();
});
