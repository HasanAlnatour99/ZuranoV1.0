class RecentlyViewedSalonModel {
  const RecentlyViewedSalonModel({
    required this.salonId,
    required this.name,
    required this.viewedAt,
    this.area,
    this.coverImageUrl,
  });

  final String salonId;
  final String name;
  final String? area;
  final String? coverImageUrl;
  final DateTime viewedAt;

  Map<String, dynamic> toJson() {
    return {
      'salonId': salonId,
      'name': name,
      'area': area,
      'coverImageUrl': coverImageUrl,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  factory RecentlyViewedSalonModel.fromJson(Map<String, dynamic> json) {
    final ts = json['viewedAt'];
    DateTime parseTs() {
      if (ts is String && ts.trim().isNotEmpty) {
        return DateTime.tryParse(ts.trim()) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return RecentlyViewedSalonModel(
      salonId: (json['salonId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      area: json['area']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      viewedAt: parseTs(),
    );
  }
}

