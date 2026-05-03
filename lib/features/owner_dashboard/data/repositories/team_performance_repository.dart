import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../employees/data/models/employee.dart';
import '../../../sales/data/models/sale.dart';
import '../../domain/models/team_performance_item.dart';

/// Aggregates “top barbers today” from data already held in session streams
/// (recent sales + employees), so no extra Firestore composite index is required.
abstract final class TeamPerformanceRepository {
  /// Uses [recentSales] (e.g. newest 500 from [SalesRepository.watchSales]) and
  /// filters to **today’s** completed sales in **local** time. If today’s volume
  /// exceeds that window, totals can be incomplete until pagination is added.
  static List<TeamPerformanceItem> buildTodayTopBarbers({
    required String salonId,
    required List<Sale> recentSales,
    required List<Employee> employees,
    required DateTime now,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    final grouped = <String, _BarberSalesAccumulator>{};

    for (final sale in recentSales) {
      if (sale.status != SaleStatuses.completed) continue;
      final sid = sale.salonId.trim();
      if (sid.isNotEmpty && sid != salonId.trim()) continue;
      if (!_sameLocalDay(sale.soldAt, now)) continue;

      if (sale.lineItems.isEmpty) {
        final id =
            (sale.barberId.trim().isNotEmpty ? sale.barberId : sale.employeeId)
                .trim();
        if (id.isEmpty) continue;
        grouped.putIfAbsent(id, _BarberSalesAccumulator.new);
        final acc = grouped[id]!;
        acc.revenue += sale.total;
        acc.servicesCount += 1;
        continue;
      }
      for (final line in sale.lineItems) {
        final id = line.employeeId.trim();
        if (id.isEmpty) continue;
        grouped.putIfAbsent(id, _BarberSalesAccumulator.new);
        final acc = grouped[id]!;
        acc.revenue += line.total;
        acc.servicesCount += line.quantity <= 0 ? 1 : line.quantity;
      }
    }

    if (grouped.isEmpty) return const [];

    final byId = {for (final e in employees) e.id: e};
    final items = <TeamPerformanceItem>[];

    for (final entry in grouped.entries) {
      final employee = byId[entry.key];
      if (employee == null) continue;
      if (!employee.isActive) continue;
      final role = employee.role.trim();
      if (role != UserRoles.barber && role != UserRoles.employee) continue;

      final salesAgg = entry.value;
      final name = employee.name.trim();
      final avatar = employee.avatarUrl?.trim();
      items.add(
        TeamPerformanceItem(
          barberId: employee.id,
          displayName: name,
          profileImageUrl: avatar == null || avatar.isEmpty ? null : avatar,
          revenue: salesAgg.revenue,
          servicesCount: salesAgg.servicesCount,
        ),
      );
    }

    items.sort((a, b) => b.revenue.compareTo(a.revenue));
    return items.take(3).toList(growable: false);
  }

  static bool _sameLocalDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}

class _BarberSalesAccumulator {
  double revenue = 0;
  int servicesCount = 0;
}
