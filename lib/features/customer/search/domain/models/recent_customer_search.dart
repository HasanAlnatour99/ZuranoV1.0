class RecentCustomerSearch {
  final String query;
  final String? type;
  final DateTime createdAt;

  const RecentCustomerSearch({
    required this.query,
    required this.createdAt,
    this.type,
  });
}

