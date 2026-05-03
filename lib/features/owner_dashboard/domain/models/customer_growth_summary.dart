class CustomerGrowthSummary {
  const CustomerGrowthSummary({
    required this.newToday,
    required this.returningToday,
    required this.totalThisMonth,
  });

  const CustomerGrowthSummary.empty()
    : newToday = 0,
      returningToday = 0,
      totalThisMonth = 0;

  final int newToday;
  final int returningToday;
  final int totalThisMonth;
}
