import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../../../providers/firebase_providers.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../onboarding/application/device_country_iso.dart';
import '../../../onboarding/domain/value_objects/country_option.dart';
import '../../domain/customer_geo.dart';
import '../../data/models/customer_banner_model.dart';
import '../../data/models/customer_category_model.dart';
import '../../data/models/customer_salon_model.dart';
import '../../data/models/trending_service_model.dart';
import '../../data/repositories/customer_home_repository.dart';

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

final nearbySalonsProvider =
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
