import '../../../../core/utils/currency_for_country.dart';
import '../../discovery/data/models/customer_place_model.dart';
import 'models/customer_search_result.dart';

extension CustomerSearchResultPlaceMapper on CustomerSearchResult {
  /// Maps search index rows into the shared discovery card model (salon rows only).
  CustomerPlaceModel toCustomerPlaceModel() {
    return CustomerPlaceModel(
      id: salonId,
      name: title,
      type: audience.trim().isEmpty ? 'salon' : audience,
      area: area,
      city: city,
      addressText: subtitle,
      coverImageUrl: imageUrl?.trim() ?? '',
      logoUrl: null,
      isActive: isActive,
      isPublic: isPublic,
      isPublished: true,
      ratingAvg: ratingAvg ?? 0,
      ratingCount: ratingCount ?? 0,
      minServicePrice: priceFrom?.toDouble() ?? 0,
      currency: currencyCodeForCountryIso(countryCode),
      location: null,
      openingHours: null,
      genderTarget: audience,
      hasOffer: hasOffer,
      searchKeywords: searchKeywords,
      isOpenNowCache: isOpenNow,
      isClosedToday: false,
      isAvailableToday: false,
      todayAvailableSlotsCount: 0,
      nextAvailableAt: null,
      openingStatusUpdatedAt: null,
    );
  }
}
