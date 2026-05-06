enum CustomerSearchResultType {
  salon,
  service,
  specialist,
}

class CustomerSearchResult {
  final String id;
  final String salonId;
  final CustomerSearchResultType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final double? ratingAvg;
  final int? ratingCount;
  final double? distanceKm;
  final num? priceFrom;
  final bool isOpenNow;
  final bool hasOffer;
  final String audience;
  final List<String> searchKeywords;

  const CustomerSearchResult({
    required this.id,
    required this.salonId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.searchKeywords,
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

