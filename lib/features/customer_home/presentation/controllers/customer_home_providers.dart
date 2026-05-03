import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../../../providers/firebase_providers.dart';
import '../../../../providers/onboarding_providers.dart';
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
      return repo.watchRecommendedSalons(
        discoveryCountryName: country,
        categoryId: categoryId == 'all' ? null : categoryId,
      );
    });

final nearbySalonsProvider =
    StreamProvider.autoDispose<List<CustomerSalonModel>>((ref) {
      final repo = ref.watch(customerHomeRepositoryProvider);
      final categoryId = ref.watch(selectedCustomerCategoryProvider);
      final country = ref.watch(customerDiscoveryCountryNameProvider);
      return repo.watchNearbySalons(
        discoveryCountryName: country,
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
