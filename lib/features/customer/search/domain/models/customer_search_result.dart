enum CustomerSearchResultType {
  salon,
  service,
  specialist,
}

class CustomerSearchResult {
  final String id;
  final String salonId;
  /// Service id or employee id depending on [type]; mirrors `customerSearchIndex.targetId`.
  final String targetId;
  final CustomerSearchResultType type;
  final String title;
  final String subtitle;
  final String? imageUrl;

  final String countryCode;
  final String countryName;
  final String city;
  final String area;

  final double? ratingAvg;
  final int? ratingCount;
  final double? distanceKm;
  final num? priceFrom;
  final bool isOpenNow;
  final bool hasOffer;
  final String audience;
  final List<String> searchKeywords;

  final bool isActive;
  final bool isPublic;

  /// Active services count when mirrored on `customerSearchIndex` (optional).
  final int? serviceCount;

  /// Active team / employees count when mirrored (optional).
  final int? teamCount;

  /// True when the salon (or specialist) has at least one bookable slot today.
  /// Maintained by Cloud Functions on `customerSearchIndex` rows.
  final bool availableToday;

  /// Earliest bookable slot for this row, when known.
  final DateTime? nextAvailableAt;

  const CustomerSearchResult({
    required this.id,
    required this.salonId,
    required this.targetId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.countryCode,
    required this.countryName,
    required this.city,
    required this.area,
    required this.searchKeywords,
    required this.isActive,
    required this.isPublic,
    this.imageUrl,
    this.ratingAvg,
    this.ratingCount,
    this.distanceKm,
    this.priceFrom,
    this.isOpenNow = false,
    this.hasOffer = false,
    this.audience = 'unisex',
    this.serviceCount,
    this.teamCount,
    this.availableToday = false,
    this.nextAvailableAt,
  });

  CustomerSearchResult copyWith({
    double? distanceKm,
    int? serviceCount,
    int? teamCount,
    bool? availableToday,
    DateTime? nextAvailableAt,
  }) {
    return CustomerSearchResult(
      id: id,
      salonId: salonId,
      targetId: targetId,
      type: type,
      title: title,
      subtitle: subtitle,
      countryCode: countryCode,
      countryName: countryName,
      city: city,
      area: area,
      searchKeywords: searchKeywords,
      isActive: isActive,
      isPublic: isPublic,
      imageUrl: imageUrl,
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      distanceKm: distanceKm ?? this.distanceKm,
      priceFrom: priceFrom,
      isOpenNow: isOpenNow,
      hasOffer: hasOffer,
      audience: audience,
      serviceCount: serviceCount ?? this.serviceCount,
      teamCount: teamCount ?? this.teamCount,
      availableToday: availableToday ?? this.availableToday,
      nextAvailableAt: nextAvailableAt ?? this.nextAvailableAt,
    );
  }
}
