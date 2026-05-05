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

/// Inclusive local calendar days → Firestore query uses \([start, end)\) end-exclusive.
@immutable
class EmployeeSalesHistoryRangeKey {
  const EmployeeSalesHistoryRangeKey({
    required this.fromDay,
    required this.toDay,
  });

  final DateTime fromDay;
  final DateTime toDay;

  @override
  bool operator ==(Object other) {
    if (other is! EmployeeSalesHistoryRangeKey) return false;
    return _day(fromDay) == _day(other.fromDay) &&
        _day(toDay) == _day(other.toDay);
  }

  @override
  int get hashCode => Object.hash(_day(fromDay), _day(toDay));

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}

(DateTime monday, DateTime sunday) employeeSalesHistoryWeekBounds(
  DateTime anchor,
) {
  final day = DateTime(anchor.year, anchor.month, anchor.day);
  final mondayOffset = day.weekday - DateTime.monday;
  final monday = day.subtract(Duration(days: mondayOffset));
  final sunday = monday.add(const Duration(days: 6));
  return (monday, sunday);
}

(DateTime start, DateTime lastDayOfMonth) employeeSalesHistoryCalendarMonthBounds(
  DateTime now,
) {
  final start = DateTime(now.year, now.month);
  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
  return (start, lastDayOfMonth);
}

/// Full sales list for [EmployeeSalesHistoryRangeKey] (same UI entry as Attendance “View all”).
final employeeSalesHistoryRangeProvider = StreamProvider.autoDispose
    .family<List<Sale>, EmployeeSalesHistoryRangeKey>((ref, key) {
      final user = ref.watch(sessionUserProvider).asData?.value;
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

      final startDate =
          DateTime(key.fromDay.year, key.fromDay.month, key.fromDay.day);
      final endDate = DateTime(key.toDay.year, key.toDay.month, key.toDay.day)
          .add(const Duration(days: 1));

      return ref.read(salesRepositoryProvider).watchEmployeeCompletedSalesByDateRange(
            salonId: salonId,
            employeeId: employeeId,
            startDate: startDate,
            endDate: endDate,
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
