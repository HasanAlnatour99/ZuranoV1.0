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
  final CustomerSearchSort sort;
  final String? audience; // men | ladies | unisex
  final bool nearbyOnly;
  final bool openNowOnly;
  final bool offersOnly;
  final bool availableTodayOnly;

  const CustomerSearchFilter({
    this.query = '',
    this.sort = CustomerSearchSort.recommended,
    this.audience,
    this.nearbyOnly = false,
    this.openNowOnly = false,
    this.offersOnly = false,
    this.availableTodayOnly = false,
  });

  CustomerSearchFilter copyWith({
    String? query,
    CustomerSearchSort? sort,
    String? audience,
    bool? nearbyOnly,
    bool? openNowOnly,
    bool? offersOnly,
    bool? availableTodayOnly,
  }) {
    return CustomerSearchFilter(
      query: query ?? this.query,
      sort: sort ?? this.sort,
      audience: audience ?? this.audience,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      offersOnly: offersOnly ?? this.offersOnly,
      availableTodayOnly: availableTodayOnly ?? this.availableTodayOnly,
    );
  }
}

