import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_roles.dart';
import '../../../features/attendance/data/models/attendance_record.dart';
import '../../../features/employees/data/models/employee.dart';
import '../../../features/payroll/data/models/payroll_record.dart';
import '../../../features/sales/data/models/sale.dart';
import '../../../features/services/data/models/service.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../../providers/session_provider.dart';

enum TeamFilter {
  all,
  active,
  checkedIn,
  inactive,
  topSellers,
  needsAttention,
  topServices,
  topPerformance,
}

enum TeamMemberStatus { active, checkedIn, late, inactive }

/// Owner team list ordering when the active [TeamFilter] does not define order.
enum TeamSort {
  nameAsc,
  nameDesc,
  roleThenName,
  joinedNewest,
  joinedOldest,
  salesTodayHigh,
  salesMonthHigh,
}

class TeamSummaryData {
  const TeamSummaryData({
    required this.totalBarbers,
    required this.checkedInToday,
    required this.workingNow,
    required this.salesToday,
    required this.commissionToday,
    required this.totalMembers,
    required this.absentToday,
  });

  final int totalBarbers;
  final int checkedInToday;
  /// Checked in and not checked out (or on break); matches [TeamAnalyticsData.workingNow].
  final int workingNow;
  final double salesToday;
  final double commissionToday;
  final int totalMembers;
  final int absentToday;
}

class TeamAnalyticsData {
  const TeamAnalyticsData({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.workingNow,
    required this.absentToday,
    required this.totalRevenueThisMonth,
    required this.servicesThisMonth,
    required this.topPerformerName,
  });

  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int workingNow;
  final int absentToday;
  final double totalRevenueThisMonth;
  final int servicesThisMonth;
  final String topPerformerName;
}

class BarberTodayMetrics {
  const BarberTodayMetrics({
    this.salesToday = 0,
    this.servicesToday = 0,
    this.commissionToday = 0,
  });

  final double salesToday;
  final int servicesToday;
  final double commissionToday;
}

class BarberMonthlyMetrics {
  const BarberMonthlyMetrics({
    this.commissionMonth = 0,
    this.salesMonth = 0,
    this.servicesMonth = 0,
  });

  final double commissionMonth;
  final double salesMonth;
  final int servicesMonth;
}

class TeamBarberCardData {
  const TeamBarberCardData({
    required this.employee,
    required this.status,
    required this.todayAttendance,
    required this.todayMetrics,
    required this.monthlyMetrics,
  });

  final Employee employee;
  final TeamMemberStatus status;
  final AttendanceRecord? todayAttendance;
  final BarberTodayMetrics todayMetrics;
  final BarberMonthlyMetrics monthlyMetrics;

  bool get isTopSeller => todayMetrics.salesToday > 0;

  bool get needsAttention {
    return status == TeamMemberStatus.late ||
        status == TeamMemberStatus.inactive ||
        (employee.attendanceRequired && todayAttendance == null);
  }

  String get searchIndex {
    return [
      employee.name,
      employee.email,
      employee.phone ?? '',
      employee.username ?? '',
      employee.role,
      employee.id,
    ].join(' ').toLowerCase();
  }
}

class RecentBarberSaleData {
  const RecentBarberSaleData({
    required this.serviceName,
    required this.price,
    required this.commission,
    required this.soldAt,
  });

  final String serviceName;
  final double price;
  final double commission;
  final DateTime soldAt;
}

class TopSoldServiceData {
  const TopSoldServiceData({
    required this.serviceId,
    required this.serviceName,
    required this.count,
    required this.revenue,
  });

  final String serviceId;
  final String serviceName;
  final int count;
  final double revenue;
}

class BarberDetailsData {
  const BarberDetailsData({
    required this.employee,
    required this.status,
    required this.todayAttendance,
    required this.attendanceRecords,
    required this.assignedServices,
    required this.visibleServices,
    required this.todaySales,
    required this.weekSales,
    required this.monthSales,
    required this.todayCommission,
    required this.monthCommission,
    required this.todayServicesCount,
    required this.monthServicesCount,
    required this.recentSales,
    required this.topSoldServices,
    required this.weeklyAttendanceCount,
    required this.lateCount,
    required this.missingCheckoutCount,
    required this.monthBonuses,
    required this.monthDeductions,
    required this.estimatedPayout,
    required this.payrollHistory,
  });

  final Employee employee;
  final TeamMemberStatus status;
  final AttendanceRecord? todayAttendance;
  final List<AttendanceRecord> attendanceRecords;
  final List<SalonService> assignedServices;
  final List<SalonService> visibleServices;
  final double todaySales;
  final double weekSales;
  final double monthSales;
  final double todayCommission;
  final double monthCommission;
  final int todayServicesCount;
  final int monthServicesCount;
  final List<RecentBarberSaleData> recentSales;
  final List<TopSoldServiceData> topSoldServices;
  final int weeklyAttendanceCount;
  final int lateCount;
  final int missingCheckoutCount;
  final double monthBonuses;
  final double monthDeductions;
  final double estimatedPayout;
  final List<PayrollRecord> payrollHistory;
}

class _TeamSourceData {
  const _TeamSourceData({
    required this.employees,
    required this.sales,
    required this.attendanceToday,
  });

  final List<Employee> employees;
  final List<Sale> sales;
  final List<AttendanceRecord> attendanceToday;
}

class TeamFilterNotifier extends Notifier<TeamFilter> {
  @override
  TeamFilter build() => TeamFilter.all;

  void setFilter(TeamFilter filter) => state = filter;
}

class TeamSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

class TeamSortNotifier extends Notifier<TeamSort> {
  @override
  TeamSort build() => TeamSort.nameAsc;

  void setSort(TeamSort sort) => state = sort;
}

final teamFilterProvider =
    NotifierProvider.autoDispose<TeamFilterNotifier, TeamFilter>(
      TeamFilterNotifier.new,
    );

final teamSearchQueryProvider =
    NotifierProvider.autoDispose<TeamSearchQueryNotifier, String>(
      TeamSearchQueryNotifier.new,
    );

final teamSortProvider =
    NotifierProvider.autoDispose<TeamSortNotifier, TeamSort>(
      TeamSortNotifier.new,
    );

final teamSummaryProvider = Provider<AsyncValue<TeamSummaryData>>((ref) {
  final source = ref.watch(_teamSourceDataProvider);
  return source.whenData((data) {
    final members = _staffMembers(data.employees);
    final attendanceByEmployee = _attendanceByEmployee(data.attendanceToday);
    final salesToday = _salesForToday(data.sales);
    final workingNow = members.where((employee) {
      final attendance = attendanceByEmployee[employee.id];
      return attendance?.countsAsWorkingOnSalon ?? false;
    }).length;
    return TeamSummaryData(
      totalBarbers: members
          .where((employee) => employee.role == UserRoles.barber)
          .length,
      checkedInToday: members
          .where(
            (employee) => attendanceByEmployee[employee.id]?.checkInAt != null,
          )
          .length,
      workingNow: workingNow,
      salesToday: salesToday.fold<double>(0, (sum, sale) => sum + sale.total),
      commissionToday: salesToday.fold<double>(
        0,
        (sum, sale) =>
            sum + (sale.commissionAmount ?? _saleCommissionFromRate(sale)),
      ),
      totalMembers: members.length,
      absentToday: members
          .where(
            (employee) =>
                employee.isActive &&
                employee.attendanceRequired &&
                attendanceByEmployee[employee.id] == null,
          )
          .length,
    );
  });
});

final teamAnalyticsProvider = Provider<AsyncValue<TeamAnalyticsData>>((ref) {
  final source = ref.watch(_teamSourceDataProvider);
  return source.whenData((data) {
    final members = _staffMembers(data.employees);
    final activeMembers = members.where((e) => e.isActive).length;
    final attendanceByEmployee = _attendanceByEmployee(data.attendanceToday);
    final workingNow = members.where((employee) {
      final attendance = attendanceByEmployee[employee.id];
      return attendance?.countsAsWorkingOnSalon ?? false;
    }).length;
    final absentToday = members
        .where(
          (employee) =>
              employee.isActive &&
              employee.attendanceRequired &&
              attendanceByEmployee[employee.id] == null,
        )
        .length;
    final monthSales = _salesForMonth(data.sales);
    final monthlyRevenue = monthSales.fold<double>(
      0,
      (sum, sale) => sum + sale.total,
    );
    final monthlyServices = _servicesCount(monthSales);
    final salesByEmployee = <String, double>{};
    for (final sale in monthSales) {
      salesByEmployee[sale.employeeId] =
          (salesByEmployee[sale.employeeId] ?? 0) + sale.total;
    }
    String topPerformerName = '-';
    if (salesByEmployee.isNotEmpty && members.isNotEmpty) {
      final topId = salesByEmployee.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topPerformerName = members
          .firstWhere(
            (employee) => employee.id == topId.first.key,
            orElse: () => members.first,
          )
          .name;
    }
    return TeamAnalyticsData(
      totalMembers: members.length,
      activeMembers: activeMembers,
      inactiveMembers: members.length - activeMembers,
      workingNow: workingNow,
      absentToday: absentToday,
      totalRevenueThisMonth: monthlyRevenue,
      servicesThisMonth: monthlyServices,
      topPerformerName: topPerformerName,
    );
  });
});

final teamAttendanceStatusTodayProvider =
    Provider<AsyncValue<Map<String, AttendanceRecord?>>>((ref) {
      final source = ref.watch(_teamSourceDataProvider);
      return source.whenData(
        (data) => _attendanceByEmployee(data.attendanceToday),
      );
    });

final teamBarberTodayMetricsProvider =
    Provider<AsyncValue<Map<String, BarberTodayMetrics>>>((ref) {
      final source = ref.watch(_teamSourceDataProvider);
      return source.whenData((data) => _todayMetricsByEmployee(data.sales));
    });

final teamBarberMonthlyCommissionProvider =
    Provider<AsyncValue<Map<String, BarberMonthlyMetrics>>>((ref) {
      final source = ref.watch(_teamSourceDataProvider);
      return source.whenData((data) => _monthlyMetricsByEmployee(data.sales));
    });

final teamBarberCardsProvider = Provider<AsyncValue<List<TeamBarberCardData>>>((
  ref,
) {
  final source = ref.watch(_teamSourceDataProvider);
  final attendanceAsync = ref.watch(teamAttendanceStatusTodayProvider);
  final todayMetricsAsync = ref.watch(teamBarberTodayMetricsProvider);
  final monthlyMetricsAsync = ref.watch(teamBarberMonthlyCommissionProvider);
  return _combineAsyncValues<List<TeamBarberCardData>>(
    [source, attendanceAsync, todayMetricsAsync, monthlyMetricsAsync],
    () {
      final members = _staffMembers(source.requireValue.employees)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final attendanceByEmployee = attendanceAsync.requireValue;
      final todayMetrics = todayMetricsAsync.requireValue;
      final monthMetrics = monthlyMetricsAsync.requireValue;
      return members
          .map(
            (employee) => TeamBarberCardData(
              employee: employee,
              status: _statusFor(employee, attendanceByEmployee[employee.id]),
              todayAttendance: attendanceByEmployee[employee.id],
              todayMetrics:
                  todayMetrics[employee.id] ?? const BarberTodayMetrics(),
              monthlyMetrics:
                  monthMetrics[employee.id] ?? const BarberMonthlyMetrics(),
            ),
          )
          .toList(growable: false);
    },
  );
});

final filteredTeamBarberCardsProvider =
    Provider<AsyncValue<List<TeamBarberCardData>>>((ref) {
      final cardsAsync = ref.watch(teamBarberCardsProvider);
      final filter = ref.watch(teamFilterProvider);
      final sort = ref.watch(teamSortProvider);
      final query = ref.watch(teamSearchQueryProvider).trim().toLowerCase();
      return cardsAsync.whenData((cards) {
        final filtered = cards
            .where((card) {
              final matchesFilter = switch (filter) {
                TeamFilter.all => true,
                TeamFilter.active =>
                  card.employee.isActive &&
                      card.status != TeamMemberStatus.inactive,
                TeamFilter.checkedIn =>
                  card.todayAttendance?.countsAsWorkingOnSalon ?? false,
                TeamFilter.inactive => card.status == TeamMemberStatus.inactive,
                TeamFilter.topSellers => card.isTopSeller,
                TeamFilter.needsAttention => card.needsAttention,
                TeamFilter.topServices => card.monthlyMetrics.servicesMonth > 0,
                TeamFilter.topPerformance => card.monthlyMetrics.salesMonth > 0,
              };
              if (!matchesFilter) {
                return false;
              }
              if (query.isEmpty) {
                return true;
              }
              return card.searchIndex.contains(query);
            })
            .toList(growable: false);

        switch (filter) {
          case TeamFilter.topSellers:
            filtered.sort(
              (a, b) =>
                  b.todayMetrics.salesToday.compareTo(a.todayMetrics.salesToday),
            );
            break;
          case TeamFilter.topServices:
            filtered.sort(
              (a, b) => b.monthlyMetrics.servicesMonth.compareTo(
                a.monthlyMetrics.servicesMonth,
              ),
            );
            break;
          case TeamFilter.topPerformance:
            filtered.sort((a, b) {
              final salesCompare = b.monthlyMetrics.salesMonth.compareTo(
                a.monthlyMetrics.salesMonth,
              );
              if (salesCompare != 0) {
                return salesCompare;
              }
              final servicesCompare = b.monthlyMetrics.servicesMonth.compareTo(
                a.monthlyMetrics.servicesMonth,
              );
              if (servicesCompare != 0) {
                return servicesCompare;
              }
              return b.monthlyMetrics.commissionMonth.compareTo(
                a.monthlyMetrics.commissionMonth,
              );
            });
            break;
          case TeamFilter.all:
          case TeamFilter.active:
          case TeamFilter.checkedIn:
          case TeamFilter.inactive:
          case TeamFilter.needsAttention:
            break;
        }
        if (!_teamFilterUsesBuiltinSort(filter)) {
          _sortTeamBarberCards(filtered, sort);
        }
        return filtered;
      });
    });

final employeeSalesStreamProvider = StreamProvider.autoDispose
    .family<List<Sale>, String>((ref, employeeId) {
      final repo = ref.watch(salesRepositoryProvider);
      return watchSessionSalonId(ref).asyncExpand((salonId) {
        if (salonId == null || salonId.isEmpty || employeeId.isEmpty) {
          return Stream.value(const <Sale>[]);
        }
        return repo.watchSales(salonId, employeeId: employeeId, limit: 250);
      });
    });

final employeeAttendanceStreamProvider = StreamProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, employeeId) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return watchSessionSalonId(ref).asyncExpand((salonId) {
        if (salonId == null || salonId.isEmpty || employeeId.isEmpty) {
          return Stream.value(const <AttendanceRecord>[]);
        }
        return repo.watchAttendance(
          salonId,
          employeeId: employeeId,
          limit: 180,
        );
      });
    });

final barberDetailsProvider = Provider.autoDispose
    .family<AsyncValue<BarberDetailsData>, String>((ref, employeeId) {
      final employeesAsync = ref.watch(employeesStreamProvider);
      final servicesAsync = ref.watch(servicesStreamProvider);
      final salesAsync = ref.watch(employeeSalesStreamProvider(employeeId));
      final attendanceAsync = ref.watch(
        employeeAttendanceStreamProvider(employeeId),
      );
      final payrollAsync = ref.watch(payrollStreamProvider);

      return _combineAsyncValues<BarberDetailsData>(
        [
          employeesAsync,
          servicesAsync,
          salesAsync,
          attendanceAsync,
          payrollAsync,
        ],
        () {
          final employees = employeesAsync.requireValue;
          final employee = employees.firstWhere(
            (item) => item.id == employeeId,
            orElse: () => throw StateError('Employee not found.'),
          );
          final services = servicesAsync.requireValue;
          final sales = salesAsync.requireValue;
          final attendance = attendanceAsync.requireValue;
          final payroll = payrollAsync.requireValue
              .where((record) => record.employeeId == employeeId)
              .toList(growable: false);

          final todayAttendance = _todayAttendanceFor(attendance);
          final todaySales = _salesForToday(sales);
          final weekSales = _salesForWeek(sales);
          final monthSales = _salesForMonth(sales);
          final assignedServices = employee.assignedServiceIds.isEmpty
              ? const <SalonService>[]
              : services
                    .where(
                      (service) =>
                          employee.assignedServiceIds.contains(service.id),
                    )
                    .toList(growable: false);
          final visibleServices = assignedServices
              .where((service) => service.bookable && service.isActive)
              .toList(growable: false);
          final payrollHistory = [...payroll]
            ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
          final monthPayroll = payrollHistory
              .where(_isInCurrentMonthPayroll)
              .toList();
          final monthBonus = monthPayroll.fold<double>(
            0,
            (sum, record) => sum + record.bonusAmount,
          );
          final monthDeductions = monthPayroll.fold<double>(
            0,
            (sum, record) => sum + record.deductionAmount,
          );
          final monthCommission = monthSales.fold<double>(
            0,
            (sum, sale) =>
                sum + (sale.commissionAmount ?? _saleCommissionFromRate(sale)),
          );
          final estimatedPayout = monthPayroll.isNotEmpty
              ? monthPayroll.fold<double>(
                  0,
                  (sum, record) => sum + record.netAmount,
                )
              : monthCommission + monthBonus - monthDeductions;
          final recentSales = _recentSaleItems(sales);
          final topSoldServices = _topSoldServices(monthSales);
          final weeklyRecords = attendance
              .where(_isInCurrentWeekAttendance)
              .toList();

          return BarberDetailsData(
            employee: employee,
            status: _statusFor(employee, todayAttendance),
            todayAttendance: todayAttendance,
            attendanceRecords: attendance,
            assignedServices: assignedServices,
            visibleServices: visibleServices,
            todaySales: todaySales.fold<double>(
              0,
              (sum, sale) => sum + sale.total,
            ),
            weekSales: weekSales.fold<double>(
              0,
              (sum, sale) => sum + sale.total,
            ),
            monthSales: monthSales.fold<double>(
              0,
              (sum, sale) => sum + sale.total,
            ),
            todayCommission: todaySales.fold<double>(
              0,
              (sum, sale) =>
                  sum +
                  (sale.commissionAmount ?? _saleCommissionFromRate(sale)),
            ),
            monthCommission: monthCommission,
            todayServicesCount: _servicesCount(todaySales),
            monthServicesCount: _servicesCount(monthSales),
            recentSales: recentSales,
            topSoldServices: topSoldServices,
            weeklyAttendanceCount: weeklyRecords
                .where((record) => record.checkInAt != null)
                .length,
            lateCount: attendance
                .where(
                  (record) => record.minutesLate > 0 || record.status == 'late',
                )
                .length,
            missingCheckoutCount: attendance
                .where(
                  (record) =>
                      record.checkInAt != null && record.checkOutAt == null,
                )
                .length,
            monthBonuses: monthBonus,
            monthDeductions: monthDeductions,
            estimatedPayout: estimatedPayout,
            payrollHistory: payrollHistory,
          );
        },
      );
    });

final _teamSourceDataProvider = Provider<AsyncValue<_TeamSourceData>>((ref) {
  final employeesAsync = ref.watch(employeesStreamProvider);
  final salesAsync = ref.watch(salesStreamProvider);
  final attendanceAsync = ref.watch(salonAttendanceTodayStreamProvider);

  return _combineAsyncValues<_TeamSourceData>(
    [employeesAsync, salesAsync, attendanceAsync],
    () => _TeamSourceData(
      employees: employeesAsync.requireValue,
      sales: salesAsync.requireValue,
      attendanceToday: attendanceAsync.requireValue,
    ),
  );
});

AsyncValue<T> _combineAsyncValues<T>(
  List<AsyncValue<dynamic>> values,
  T Function() builder,
) {
  for (final value in values) {
    final error = value.asError;
    if (error != null) {
      return AsyncValue.error(error.error, error.stackTrace);
    }
  }
  for (final value in values) {
    if (value.isLoading) {
      return const AsyncValue.loading();
    }
  }
  return AsyncValue.data(builder());
}

List<Employee> _staffMembers(List<Employee> employees) {
  return employees
      .where((employee) => employee.role != UserRoles.owner)
      .toList(growable: false);
}

Map<String, AttendanceRecord?> _attendanceByEmployee(
  List<AttendanceRecord> records,
) {
  final output = <String, AttendanceRecord?>{};
  for (final record in records) {
    final current = output[record.employeeId];
    if (current == null) {
      output[record.employeeId] = record;
      continue;
    }
    final currentTime = current.checkInAt ?? current.workDate;
    final nextTime = record.checkInAt ?? record.workDate;
    if (nextTime.isAfter(currentTime)) {
      output[record.employeeId] = record;
    }
  }
  return output;
}

Map<String, BarberTodayMetrics> _todayMetricsByEmployee(List<Sale> sales) {
  final output = <String, BarberTodayMetrics>{};
  for (final sale in _salesForToday(sales)) {
    final current = output[sale.employeeId] ?? const BarberTodayMetrics();
    output[sale.employeeId] = BarberTodayMetrics(
      salesToday: current.salesToday + sale.total,
      servicesToday: current.servicesToday + _servicesCount([sale]),
      commissionToday:
          current.commissionToday +
          (sale.commissionAmount ?? _saleCommissionFromRate(sale)),
    );
  }
  return output;
}

Map<String, BarberMonthlyMetrics> _monthlyMetricsByEmployee(List<Sale> sales) {
  final output = <String, BarberMonthlyMetrics>{};
  for (final sale in _salesForMonth(sales)) {
    final current = output[sale.employeeId] ?? const BarberMonthlyMetrics();
    output[sale.employeeId] = BarberMonthlyMetrics(
      commissionMonth:
          current.commissionMonth +
          (sale.commissionAmount ?? _saleCommissionFromRate(sale)),
      salesMonth: current.salesMonth + sale.total,
      servicesMonth: current.servicesMonth + _servicesCount([sale]),
    );
  }
  return output;
}

TeamMemberStatus _statusFor(Employee employee, AttendanceRecord? attendance) {
  if (!employee.isActive) {
    return TeamMemberStatus.inactive;
  }
  if (attendance == null) {
    return TeamMemberStatus.active;
  }
  if (attendance.minutesLate > 0 || attendance.status == 'late') {
    return TeamMemberStatus.late;
  }
  if (attendance.checkInAt != null) {
    return TeamMemberStatus.checkedIn;
  }
  return TeamMemberStatus.active;
}

AttendanceRecord? _todayAttendanceFor(List<AttendanceRecord> attendance) {
  final byEmployee = _attendanceByEmployee(attendance);
  if (byEmployee.isEmpty) {
    return null;
  }
  return byEmployee.values.firstOrNull;
}

List<Sale> _salesForToday(List<Sale> sales) {
  final now = DateTime.now();
  return sales
      .where((sale) {
        final soldAt = sale.soldAt.toLocal();
        return soldAt.year == now.year &&
            soldAt.month == now.month &&
            soldAt.day == now.day;
      })
      .toList(growable: false);
}

List<Sale> _salesForWeek(List<Sale> sales) {
  final start = _startOfWeek(DateTime.now());
  return sales
      .where((sale) => !sale.soldAt.toLocal().isBefore(start))
      .toList(growable: false);
}

List<Sale> _salesForMonth(List<Sale> sales) {
  final now = DateTime.now();
  return sales
      .where((sale) {
        final soldAt = sale.soldAt.toLocal();
        return soldAt.year == now.year && soldAt.month == now.month;
      })
      .toList(growable: false);
}

int _servicesCount(List<Sale> sales) {
  return sales.fold<int>(0, (sum, sale) {
    if (sale.lineItems.isEmpty) {
      return sum + 1;
    }
    return sum +
        sale.lineItems.fold<int>(
          0,
          (lineSum, item) => lineSum + (item.quantity < 1 ? 1 : item.quantity),
        );
  });
}

double _saleCommissionFromRate(Sale sale) {
  return Sale.computeCommissionAmount(
        total: sale.total,
        ratePercent: sale.commissionRateUsed,
      ) ??
      0;
}

List<RecentBarberSaleData> _recentSaleItems(List<Sale> sales) {
  final rows = <RecentBarberSaleData>[];
  for (final sale in [...sales]..sort((a, b) => b.soldAt.compareTo(a.soldAt))) {
    if (sale.lineItems.isEmpty) {
      rows.add(
        RecentBarberSaleData(
          serviceName: sale.serviceNames.isEmpty ? '' : sale.serviceNames.first,
          price: sale.total,
          commission: sale.commissionAmount ?? _saleCommissionFromRate(sale),
          soldAt: sale.soldAt,
        ),
      );
      continue;
    }
    for (final line in sale.lineItems) {
      rows.add(
        RecentBarberSaleData(
          serviceName: line.serviceName,
          price: line.total,
          commission:
              (sale.commissionAmount ?? _saleCommissionFromRate(sale)) /
              sale.lineItems.length,
          soldAt: sale.soldAt,
        ),
      );
    }
  }
  return rows.take(8).toList(growable: false);
}

List<TopSoldServiceData> _topSoldServices(List<Sale> sales) {
  final aggregate = <String, TopSoldServiceData>{};
  for (final sale in sales) {
    if (sale.lineItems.isEmpty) {
      final key = sale.serviceNames.isEmpty
          ? 'sale:${sale.id}'
          : sale.serviceNames.first;
      final current = aggregate[key];
      aggregate[key] = TopSoldServiceData(
        serviceId: '',
        serviceName: sale.serviceNames.isEmpty ? '' : sale.serviceNames.first,
        count: (current?.count ?? 0) + 1,
        revenue: (current?.revenue ?? 0) + sale.total,
      );
      continue;
    }
    for (final line in sale.lineItems) {
      final key = line.serviceId.isEmpty
          ? 'name:${line.serviceName}'
          : line.serviceId;
      final current = aggregate[key];
      aggregate[key] = TopSoldServiceData(
        serviceId: line.serviceId,
        serviceName: line.serviceName,
        count: (current?.count ?? 0) + (line.quantity < 1 ? 1 : line.quantity),
        revenue: (current?.revenue ?? 0) + line.total,
      );
    }
  }

  final list = aggregate.values.toList(growable: false);
  list.sort((a, b) {
    final countCompare = b.count.compareTo(a.count);
    if (countCompare != 0) {
      return countCompare;
    }
    return b.revenue.compareTo(a.revenue);
  });
  return list.take(5).toList(growable: false);
}

DateTime _startOfWeek(DateTime date) {
  final local = date.toLocal();
  final start = DateTime(local.year, local.month, local.day);
  return start.subtract(Duration(days: start.weekday - DateTime.monday));
}

bool _isInCurrentWeekAttendance(AttendanceRecord record) {
  final start = _startOfWeek(DateTime.now());
  return !record.workDate.toLocal().isBefore(start);
}

bool _isInCurrentMonthPayroll(PayrollRecord record) {
  final now = DateTime.now();
  return record.year == now.year && record.month == now.month;
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Prefer [Employee.hiredAt], then [Employee.createdAt], for team ordering.
DateTime _employeeTenureSortKey(Employee e) {
  final hire = e.hiredAt;
  if (hire != null) {
    return hire;
  }
  final created = e.createdAt;
  if (created != null) {
    return created;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

bool _teamFilterUsesBuiltinSort(TeamFilter filter) {
  return switch (filter) {
    TeamFilter.topSellers ||
    TeamFilter.topServices ||
    TeamFilter.topPerformance =>
      true,
    TeamFilter.all ||
    TeamFilter.active ||
    TeamFilter.checkedIn ||
    TeamFilter.inactive ||
    TeamFilter.needsAttention =>
      false,
  };
}

void _sortTeamBarberCards(List<TeamBarberCardData> list, TeamSort sort) {
  int roleRank(String role) {
    if (role == UserRoles.admin) {
      return 0;
    }
    if (role == UserRoles.barber) {
      return 1;
    }
    return 2;
  }

  int nameCompare(TeamBarberCardData a, TeamBarberCardData b) =>
      a.employee.name.toLowerCase().compareTo(b.employee.name.toLowerCase());

  int compare(TeamBarberCardData a, TeamBarberCardData b) {
    switch (sort) {
      case TeamSort.nameAsc:
        return nameCompare(a, b);
      case TeamSort.nameDesc:
        return nameCompare(b, a);
      case TeamSort.roleThenName:
        final r = roleRank(a.employee.role).compareTo(
          roleRank(b.employee.role),
        );
        if (r != 0) {
          return r;
        }
        return nameCompare(a, b);
      case TeamSort.joinedNewest:
        final ad = _employeeTenureSortKey(a.employee);
        final bd = _employeeTenureSortKey(b.employee);
        final c = bd.compareTo(ad);
        if (c != 0) {
          return c;
        }
        return nameCompare(a, b);
      case TeamSort.joinedOldest:
        final ad = _employeeTenureSortKey(a.employee);
        final bd = _employeeTenureSortKey(b.employee);
        final c = ad.compareTo(bd);
        if (c != 0) {
          return c;
        }
        return nameCompare(a, b);
      case TeamSort.salesTodayHigh:
        final c = b.todayMetrics.salesToday.compareTo(a.todayMetrics.salesToday);
        if (c != 0) {
          return c;
        }
        return nameCompare(a, b);
      case TeamSort.salesMonthHigh:
        final c = b.monthlyMetrics.salesMonth.compareTo(
          a.monthlyMetrics.salesMonth,
        );
        if (c != 0) {
          return c;
        }
        return nameCompare(a, b);
    }
  }

  list.sort(compare);
}
