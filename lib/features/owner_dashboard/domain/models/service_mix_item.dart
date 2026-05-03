class ServiceMixItem {
  const ServiceMixItem({
    required this.serviceKey,
    required this.serviceLabel,
    required this.count,
    required this.revenue,
    required this.percentage,
  });

  final String serviceKey;
  final String serviceLabel;
  final int count;
  final double revenue;

  /// 0.0 to 1.0 share of today's completed service count.
  final double percentage;
}
