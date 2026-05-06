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
  });
}
