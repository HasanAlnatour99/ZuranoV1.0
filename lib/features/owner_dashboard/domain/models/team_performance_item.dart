/// One barber row for the owner overview “team performance” mini chart.
class TeamPerformanceItem {
  const TeamPerformanceItem({
    required this.barberId,
    required this.displayName,
    required this.profileImageUrl,
    required this.revenue,
    required this.servicesCount,
  });

  final String barberId;
  final String displayName;
  final String? profileImageUrl;
  final double revenue;
  final int servicesCount;
}
