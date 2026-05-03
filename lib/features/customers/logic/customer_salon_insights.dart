import '../../../core/constants/sale_reporting.dart';
import '../../sales/data/models/sale.dart';
import '../data/models/customer.dart';

/// Aggregated salon customer metrics for the owner list (current calendar month, local).
class CustomerSalonInsights {
  const CustomerSalonInsights({
    required this.newCustomersThisMonth,
    required this.returningCustomersThisMonth,
    required this.totalActiveCustomers,
    required this.totalSpentThisMonth,
  });

  final int newCustomersThisMonth;
  final int returningCustomersThisMonth;
  final int totalActiveCustomers;
  final double totalSpentThisMonth;
}

/// Derives insights from the live customer directory and completed POS sales for [month].
CustomerSalonInsights computeCustomerSalonInsights({
  required List<Customer> customers,
  required List<Sale> salesThisMonth,
  required DateTime now,
}) {
  final monthStart = DateTime(now.year, now.month, 1);
  final active = customers.where((c) => c.isActive).toList();

  var newThisMonth = 0;
  for (final c in active) {
    final created = c.createdAt;
    if (created == null) continue;
    if (!created.isBefore(monthStart)) {
      newThisMonth++;
    }
  }

  final customerById = {for (final c in customers) c.id: c};
  final returningIds = <String>{};

  for (final sale in salesThisMonth) {
    if (sale.status != SaleStatuses.completed) continue;
    final cid = sale.customerId?.trim();
    if (cid == null || cid.isEmpty) continue;
    final c = customerById[cid];
    if (c == null || !c.isActive) continue;
    final created = c.createdAt;
    final firstVisit = c.firstVisitAt;
    final existedBeforeMonth = (created != null && created.isBefore(monthStart)) ||
        (firstVisit != null && firstVisit.isBefore(monthStart));
    if (existedBeforeMonth) {
      returningIds.add(cid);
    }
  }

  var spent = 0.0;
  for (final sale in salesThisMonth) {
    if (sale.status != SaleStatuses.completed) continue;
    spent += sale.total;
  }

  return CustomerSalonInsights(
    newCustomersThisMonth: newThisMonth,
    returningCustomersThisMonth: returningIds.length,
    totalActiveCustomers: active.length,
    totalSpentThisMonth: spent,
  );
}
