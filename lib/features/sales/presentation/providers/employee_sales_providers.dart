import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../data/models/sale.dart';
import '../utils/sale_customer_display.dart';
import '../../domain/employee_sales_period.dart';
import '../../domain/employee_sales_summary.dart';
import 'employee_sales_period_notifier.dart';

final employeeSalesDateRangeProvider = Provider.autoDispose<DateTimeRange>((
  ref,
) {
  final period = ref.watch(employeeSalesPeriodProvider);
  final now = DateTime.now();

  switch (period) {
    case EmployeeSalesPeriod.today:
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      return DateTimeRange(start: start, end: end);

    case EmployeeSalesPeriod.week:
      final todayStart = DateTime(now.year, now.month, now.day);
      final start = todayStart.subtract(
        Duration(days: now.weekday - DateTime.monday),
      );
      final end = start.add(const Duration(days: 7));
      return DateTimeRange(start: start, end: end);

    case EmployeeSalesPeriod.month:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return DateTimeRange(start: start, end: end);
  }
});

final employeeSalesStreamProvider = StreamProvider.autoDispose<List<Sale>>((
  ref,
) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final range = ref.watch(employeeSalesDateRangeProvider);
  final salonId = user?.salonId?.trim();
  final employeeId = user?.employeeId?.trim();
  if (user == null ||
      !user.isActive ||
      salonId == null ||
      salonId.isEmpty ||
      employeeId == null ||
      employeeId.isEmpty) {
    return Stream<List<Sale>>.value(const []);
  }

  return ref
      .read(salesRepositoryProvider)
      .watchEmployeeCompletedSalesByDateRange(
        salonId: salonId,
        employeeId: employeeId,
        startDate: range.start,
        endDate: range.end,
      );
});

final employeeSalesSummaryProvider = Provider.autoDispose<EmployeeSalesSummary>(
  (ref) {
    final sales = ref.watch(employeeSalesStreamProvider).asData?.value ?? [];

    final total = sales.fold<double>(0, (sum, sale) => sum + sale.total);

    final servicesCount = sales.fold<int>(
      0,
      (sum, sale) =>
          sum + sale.lineItems.fold<int>(0, (q, line) => q + line.quantity),
    );

    final commission = sales.fold<double>(
      0,
      (sum, sale) => sum + (sale.commissionAmount ?? 0),
    );

    final average = servicesCount == 0 ? 0.0 : total / servicesCount;

    final customerKeys = <String>{};
    for (final sale in sales) {
      final cid = sale.customerId?.trim();
      if (cid != null && cid.isNotEmpty) {
        customerKeys.add('id:$cid');
      } else {
        final name = visibleSaleCustomerName(sale);
        customerKeys.add(name == 'Guest' ? 'walkin:${sale.id}' : 'name:$name');
      }
    }

    return EmployeeSalesSummary(
      totalAmount: total,
      servicesCount: servicesCount,
      estimatedCommission: commission,
      averageServiceValue: average,
      uniqueCustomersCount: customerKeys.length,
    );
  },
);
