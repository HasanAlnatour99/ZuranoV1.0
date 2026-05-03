import '../../data/models/sale.dart';

/// Staff-visible customer label for a sale (never [Sale.customerId] / UIDs).
String visibleSaleCustomerName(Sale sale) {
  final display = sale.customerDisplayName?.trim();
  if (display != null && display.isNotEmpty) return display;
  final name = sale.customerName?.trim();
  if (name != null && name.isNotEmpty) return name;
  return 'Guest';
}
