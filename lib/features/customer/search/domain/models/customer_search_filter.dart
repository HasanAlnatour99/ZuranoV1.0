enum CustomerSearchSort {
  recommended,
  nearby,
  openNow,
  topRated,
  priceLowToHigh,
  priceHighToLow,
  offers,
}

class CustomerSearchFilter {
  final String query;
  /// ISO 3166-1 alpha-2 — required for all Firestore queries.
  final String countryCode;
  final CustomerSearchSort sort;
  final String? audience; // men | ladies | unisex
  final bool nearbyOnly;
  final bool openNowOnly;
  final bool offersOnly;
  final bool availableTodayOnly;

  /// Customer device WGS84 — used for [CustomerSearchSort.nearby] and [nearbyOnly] ranking.
  final double? userLatitude;
  final double? userLongitude;

  const CustomerSearchFilter({
    required this.countryCode,
    this.query = '',
    this.sort = CustomerSearchSort.recommended,
    this.audience,
    this.nearbyOnly = false,
    this.openNowOnly = false,
    this.offersOnly = false,
    this.availableTodayOnly = false,
    this.userLatitude,
    this.userLongitude,
  });

  CustomerSearchFilter copyWith({
    String? query,
    String? countryCode,
    CustomerSearchSort? sort,
    String? audience,
    bool? nearbyOnly,
    bool? openNowOnly,
    bool? offersOnly,
    bool? availableTodayOnly,
    double? userLatitude,
    double? userLongitude,
  }) {
    return CustomerSearchFilter(
      query: query ?? this.query,
      countryCode: countryCode ?? this.countryCode,
      sort: sort ?? this.sort,
      audience: audience ?? this.audience,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      offersOnly: offersOnly ?? this.offersOnly,
      availableTodayOnly: availableTodayOnly ?? this.availableTodayOnly,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
    );
  }
}
