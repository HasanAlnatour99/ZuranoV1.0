import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_for_country.dart';
import '../../../core/constants/attendance_approval.dart';
import '../../../core/constants/booking_operational_states.dart';
import '../../../core/constants/booking_statuses.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/session/app_session_status.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../../providers/session_provider.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../bookings/data/models/booking.dart';
import '../../employees/data/models/employee.dart';
import '../../expenses/data/models/expense.dart';
import '../../payroll/data/models/payroll_record.dart';
import '../../sales/data/models/sale.dart';
import '../../salon/data/models/salon.dart';
import '../../services/data/models/service.dart';
import 'owner_overview_state.dart';

/// Raw inputs the [OwnerOverviewController] needs to compute the UI state.
///
/// Separated from the controller so the aggregation logic can be unit-tested
/// with deterministic inputs (no Firestore streams).
class OwnerOverviewInputs {
  const OwnerOverviewInputs({
    required this.now,
    required this.salon,
    required this.sales,
    required this.bookings,
    required this.employees,
    required this.services,
    required this.attendanceToday,
    required this.pendingAttendanceRequests,
    required this.payroll,
    required this.expenses,
  });

  final DateTime now;
  final Salon? salon;
  final List<Sale> sales;
  final List<Booking> bookings;
  final List<Employee> employees;
  final List<SalonService> services;

  /// Attendance records with workDate in "today" — used for the checked-in
  /// badge and same-day approvals view.
  final List<AttendanceRecord> attendanceToday;

  /// Every attendance record awaiting owner/admin review (all dates). Powers
  /// the actionable "Needs attention" row and the review screen badge.
  final List<AttendanceRecord> pendingAttendanceRequests;

  final List<PayrollRecord> payroll;
  final List<Expense> expenses;
}

/// Pure aggregation: maps repository data into a UI-ready [OwnerOverviewState].
///
/// Exposed so that it can be reused from unit tests without pulling in
/// Riverpod providers.
OwnerOverviewState computeOwnerOverviewState(OwnerOverviewInputs input) {
  final now = input.now;
  final salon = input.salon;

  // --- Sales aggregations -------------------------------------------------
  final completedSales = input.sales
      .where((s) => s.status == SaleStatuses.completed)
      .toList();
  final latestSale = _latestSaleInsight(completedSales);

  final todaySales = completedSales
      .where((s) => _sameLocalDay(s.soldAt, now))
      .toList();
  final todayRevenue = todaySales.fold<double>(0, (a, s) => a + _saleTotal(s));

  final yesterday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 1));
  final yesterdaySales = completedSales
      .where((s) => _sameLocalDay(s.soldAt, yesterday))
      .toList();
  final yesterdayRevenue = yesterdaySales.fold<double>(
    0,
    (a, s) => a + _saleTotal(s),
  );

  final monthSales = completedSales
      .where((s) => s.reportYear == now.year && s.reportMonth == now.month)
      .toList();
  final monthRevenue = monthSales.fold<double>(0, (a, s) => a + _saleTotal(s));

  final previousMonth = _previousMonth(now);
  final previousMonthSales = completedSales.where(
    (s) =>
        s.reportYear == previousMonth.year &&
        s.reportMonth == previousMonth.month,
  );
  final previousMonthRevenue = previousMonthSales.isEmpty
      ? null
      : previousMonthSales.fold<double>(0, (a, s) => a + _saleTotal(s));

  // --- Bookings aggregations ---------------------------------------------
  final activeBookings = input.bookings
      .where(
        (b) =>
            b.status != BookingStatuses.cancelled &&
            b.status != BookingStatuses.rescheduled,
      )
      .toList();

  final bookingsToday = activeBookings
      .where((b) => _sameLocalDay(b.startAt, now))
      .toList();
  final bookingsYesterdayCount = activeBookings
      .where((b) => _sameLocalDay(b.startAt, yesterday))
      .length;
  final bookingsYesterdayList = activeBookings
      .where((b) => _sameLocalDay(b.startAt, yesterday))
      .toList();
  final completedBookingsYesterday = bookingsYesterdayList
      .where((b) => b.status == BookingStatuses.completed)
      .length;
  final completedBookingsToday = bookingsToday
      .where((b) => b.status == BookingStatuses.completed)
      .length;
  final pendingBookingsCount = activeBookings
      .where((b) => b.status == BookingStatuses.pending)
      .length;

  // --- Employees aggregations --------------------------------------------
  final activeEmployees = input.employees.where((e) => e.isActive).toList();
  final inactiveEmployeesCount = input.employees
      .where((e) => !e.isActive)
      .length;

  final barbers = activeEmployees
      .where((e) => e.role == UserRoles.barber)
      .toList();
  final activeBarberCount = barbers.length;
  final barberIds = barbers.map((e) => e.id).toSet();

  final activeEmployeeIds = activeEmployees.map((e) => e.id).toSet();
  final checkedInEmployeesToday = input.attendanceToday
      .where(
        (a) =>
            a.countsAsWorkingOnSalon &&
            activeEmployeeIds.contains(a.employeeId),
      )
      .map((a) => a.employeeId)
      .toSet()
      .length;

  final checkedInBarberIdsToday = input.attendanceToday
      .where(
        (a) =>
            a.countsAsWorkingOnSalon && barberIds.contains(a.employeeId),
      )
      .map((a) => a.employeeId)
      .toSet();
  final checkedInBarbersToday = checkedInBarberIdsToday.length;

  var barbersNotCheckedInAlertCount = 0;
  final teamBarberPreview = <OwnerTeamBarberPreview>[];
  for (final barber in barbers) {
    final bToday = bookingsToday.where((b) => b.barberId == barber.id).toList();
    final checkedIn = checkedInBarberIdsToday.contains(barber.id);
    final onFloor = _barberOnFloor(bToday);
    if (!checkedIn && !onFloor) {
      barbersNotCheckedInAlertCount++;
    }
    final late = !checkedIn && !onFloor && _barberLate(now, bToday);
    final status = onFloor
        ? OwnerTeamBarberStatus.onService
        : late
        ? OwnerTeamBarberStatus.late
        : checkedIn
        ? OwnerTeamBarberStatus.checkedIn
        : OwnerTeamBarberStatus.notCheckedIn;
    teamBarberPreview.add(
      OwnerTeamBarberPreview(
        employeeId: barber.id,
        name: barber.name,
        status: status,
        activityDetail: onFloor ? _floorActivityDetail(bToday) : null,
      ),
    );
  }
  teamBarberPreview.sort((a, b) {
    final byRank = _teamStatusRank(
      a.status,
    ).compareTo(_teamStatusRank(b.status));
    if (byRank != 0) return byRank;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  final teamPreviewTop = teamBarberPreview.take(3).toList();

  final weekStart = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 6));
  final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final weekSales = completedSales.where((s) {
    final ld = s.soldAt.toLocal();
    final day = DateTime(ld.year, ld.month, ld.day);
    return !day.isBefore(weekStartDay);
  }).toList();
  final weekTop = _topServiceUsage(weekSales);

  // Count every pending request across all dates — owners review the full
  // queue on a dedicated screen, not just today's records.
  final pendingApprovalsCount = input.pendingAttendanceRequests
      .where((a) => a.approvalStatus == AttendanceApprovalStatuses.pending)
      .length;

  // --- Services aggregations ---------------------------------------------
  final activeServices = input.services.where((s) => s.isActive).toList();
  final averageActiveServicePrice = activeServices.isEmpty
      ? 0.0
      : activeServices.fold<double>(0, (a, s) => a + s.price) /
            activeServices.length;

  // --- Derived "top" metrics ---------------------------------------------
  final topBarberTodayInsight = _topBarberInsight(todaySales, todayRevenue);
  final topServiceToday = _topServiceByUsage(todaySales);
  final mostBookedServiceThisMonth = _topServiceByUsage(monthSales);

  // --- Commissions -------------------------------------------------------
  // Prefer the historical `commissionAmount` snapshot persisted on each sale.
  // Fall back to live `employee.commissionRate` for legacy sales that pre-date
  // the snapshot (see Sale.commissionAmount doc). This fallback is temporary
  // and only covers documents written before the snapshot rollout.
  final commissionByEmployee = <String, double>{
    for (final e in activeEmployees.where(
      (e) => e.role == UserRoles.barber || e.role == UserRoles.admin,
    ))
      e.id: (e.commissionRate / 100).clamp(0, 1).toDouble(),
  };
  var estimatedCommission = 0.0;
  for (final sale in monthSales) {
    final snapshot = sale.commissionAmount;
    if (snapshot != null) {
      estimatedCommission += snapshot;
      continue;
    }
    final rate =
        commissionByEmployee[sale.employeeId] ??
        commissionByEmployee[sale.barberId] ??
        0;
    estimatedCommission += _saleTotal(sale) * rate;
  }

  // --- Expenses & payroll ------------------------------------------------
  final expensesThisMonth = input.expenses
      .where((e) => e.reportYear == now.year && e.reportMonth == now.month)
      .fold<double>(0, (a, e) => a + e.amount);

  final payrollRunExists = input.payroll.any(
    (p) => p.year == now.year && p.month == now.month,
  );

  final netResultThisMonth =
      monthRevenue - estimatedCommission - expensesThisMonth;

  final today0 = DateTime(now.year, now.month, now.day);
  final last7DaysDailyRevenue = List<double>.generate(7, (i) {
    final day = today0.subtract(Duration(days: 6 - i));
    return completedSales
        .where((s) => _sameLocalDay(s.soldAt, day))
        .fold<double>(0, (a, s) => a + _saleTotal(s));
  });

  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final currentMonthDailyRevenue = List<double>.generate(daysInMonth, (i) {
    final day = DateTime(now.year, now.month, i + 1);
    return completedSales
        .where((s) => _sameLocalDay(s.soldAt, day))
        .fold<double>(0, (a, s) => a + _saleTotal(s));
  });

  final completedSalesYesterdayCount = yesterdaySales.length;
  final todayHourlyRevenue = List<double>.filled(24, 0);
  for (final s in todaySales) {
    final h = s.soldAt.toLocal().hour;
    if (h >= 0 && h < 24) {
      todayHourlyRevenue[h] += _saleTotal(s);
    }
  }

  final servicePreviewCandidates =
      activeServices.map((s) {
          final label = s.serviceName.trim().isNotEmpty
              ? s.serviceName.trim()
              : s.name.trim();
          return OwnerOverviewServicePreview(
            name: label.isEmpty ? s.name : label,
            price: s.price,
          );
        }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  final servicePreviewTop3 = servicePreviewCandidates.take(3).toList();

  // --- Salon metadata ----------------------------------------------------
  final salonCity = _resolveSalonCity(salon);

  return OwnerOverviewState(
    currencyCode: resolvedSalonMoneyCurrency(
      salonCurrencyCode: salon?.currencyCode,
      salonCountryIso: salon?.countryCode,
    ),
    salonName: salon?.name,
    salonCity: salonCity,
    ownerName: salon?.ownerName,
    monthRevenue: monthRevenue,
    previousMonthRevenue: previousMonthRevenue,
    todayRevenue: todayRevenue,
    yesterdayRevenue: yesterdayRevenue,
    bookingsToday: bookingsToday.length,
    completedBookingsToday: completedBookingsToday,
    completedBookingsYesterday: completedBookingsYesterday,
    pendingBookingsCount: pendingBookingsCount,
    checkedInEmployeesToday: checkedInEmployeesToday,
    bookingsYesterdayCount: bookingsYesterdayCount,
    activeBarberCount: activeBarberCount,
    checkedInBarbersToday: checkedInBarbersToday,
    barbersNotCheckedInAlertCount: barbersNotCheckedInAlertCount,
    completedSalesTodayCount: todaySales.length,
    completedSalesYesterdayCount: completedSalesYesterdayCount,
    topServiceThisWeekName: weekTop?.label,
    topServiceThisWeekUses: weekTop?.count ?? 0,
    teamBarberPreview: teamPreviewTop,
    last7DaysDailyRevenue: last7DaysDailyRevenue,
    todayHourlyRevenue: todayHourlyRevenue,
    currentMonthDailyRevenue: currentMonthDailyRevenue,
    servicePreviewTop3: servicePreviewTop3,
    latestSale: latestSale,
    pendingApprovalsCount: pendingApprovalsCount,
    activeServicesCount: activeServices.length,
    totalServicesCount: input.services.length,
    averageActiveServicePrice: averageActiveServicePrice,
    totalEmployeesCount: activeEmployees.length,
    topServiceToday: topServiceToday,
    topBarberToday: topBarberTodayInsight?.barberName,
    topBarberTodayInsight: topBarberTodayInsight,
    mostBookedServiceThisMonth: mostBookedServiceThisMonth,
    estimatedCommissionThisMonth: estimatedCommission,
    expensesThisMonth: expensesThisMonth,
    netResultThisMonth: netResultThisMonth,
    payrollRunExistsForCurrentMonth: payrollRunExists,
    inactiveEmployeesCount: inactiveEmployeesCount,
    hasMonthRevenue: monthSales.isNotEmpty,
    hasTodayRevenue: todaySales.isNotEmpty,
    isLoading: false,
  );
}

OwnerOverviewLatestSale? _latestSaleInsight(List<Sale> completedSales) {
  if (completedSales.isEmpty) return null;
  final sorted = completedSales.toList()
    ..sort((a, b) => _saleEntryTime(b).compareTo(_saleEntryTime(a)));
  final sale = sorted.first;
  final serviceLabel = _saleServiceLabel(sale);
  final barberName = sale.employeeName.trim();
  return OwnerOverviewLatestSale(
    serviceLabel: serviceLabel,
    barberName: barberName,
    amount: _saleTotal(sale),
    soldAt: sale.soldAt,
  );
}

DateTime _saleEntryTime(Sale sale) {
  return sale.createdAt ?? sale.updatedAt ?? sale.soldAt;
}

String _saleServiceLabel(Sale sale) {
  final names = sale.serviceNames
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList();
  if (names.isNotEmpty) {
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1}';
  }
  for (final item in sale.lineItems) {
    final name = item.serviceName.trim();
    if (name.isNotEmpty) return name;
  }
  return '';
}

bool _sameLocalDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

double _saleTotal(Sale s) {
  if (s.lineItems.isEmpty) {
    return s.total;
  }
  return s.lineItems.fold<double>(0, (a, li) => a + li.total);
}

({int year, int month}) _previousMonth(DateTime now) {
  final first = DateTime(now.year, now.month, 1);
  final prev = DateTime(first.year, first.month - 1, 1);
  return (year: prev.year, month: prev.month);
}

/// Group completed sales by `barberId` and return the richest seller with
/// their contribution percentage of [totalRevenue]. Ties resolve by highest
/// total first, then by barber name for determinism.
TopBarberInsight? _topBarberInsight(List<Sale> sales, double totalRevenue) {
  if (sales.isEmpty) return null;
  final byBarber = <String, ({String name, double total})>{};
  for (final s in sales) {
    final id = s.barberId.trim().isNotEmpty ? s.barberId : s.employeeId;
    if (id.isEmpty) continue;
    final prev = byBarber[id];
    final total = (prev?.total ?? 0) + _saleTotal(s);
    final name = s.employeeName.trim().isNotEmpty
        ? s.employeeName
        : (prev?.name ?? id);
    byBarber[id] = (name: name, total: total);
  }
  if (byBarber.isEmpty) return null;
  final sorted = byBarber.entries.toList()
    ..sort((a, b) {
      final byTotal = b.value.total.compareTo(a.value.total);
      if (byTotal != 0) return byTotal;
      return a.value.name.toLowerCase().compareTo(b.value.name.toLowerCase());
    });
  final best = sorted.first;
  final contribution = totalRevenue > 0
      ? (best.value.total / totalRevenue) * 100
      : 0.0;
  return TopBarberInsight(
    barberId: best.key,
    barberName: best.value.name,
    totalSales: best.value.total,
    contributionPercent: contribution,
  );
}

String? _topServiceByUsage(List<Sale> sales) {
  if (sales.isEmpty) return null;
  final byService = <String, ({String label, int count})>{};
  for (final s in sales) {
    for (final line in s.lineItems) {
      final id = line.serviceId.trim();
      final key = id.isNotEmpty
          ? id
          : line.serviceName.trim().isNotEmpty
          ? 'name:${line.serviceName.trim()}'
          : '';
      if (key.isEmpty) continue;
      final prev = byService[key];
      final label = line.serviceName.trim().isNotEmpty ? line.serviceName : id;
      byService[key] = (
        label: label,
        count: (prev?.count ?? 0) + (line.quantity <= 0 ? 1 : line.quantity),
      );
    }
  }
  if (byService.isEmpty) return null;
  final best = byService.entries.reduce(
    (a, b) => a.value.count >= b.value.count ? a : b,
  );
  return best.value.label;
}

String? _resolveSalonCity(Salon? salon) {
  final details = salon?.addressDetails;
  if (details == null) return null;
  final city = details.city.trim();
  return city.isEmpty ? null : city;
}

int _teamStatusRank(OwnerTeamBarberStatus status) {
  switch (status) {
    case OwnerTeamBarberStatus.onService:
      return 0;
    case OwnerTeamBarberStatus.late:
      return 1;
    case OwnerTeamBarberStatus.notCheckedIn:
      return 2;
    case OwnerTeamBarberStatus.checkedIn:
      return 3;
  }
}

bool _barberOnFloor(List<Booking> barberBookingsToday) {
  return barberBookingsToday.any(
    (b) =>
        b.status != BookingStatuses.cancelled &&
        b.status != BookingStatuses.rescheduled &&
        b.status != BookingStatuses.completed &&
        (b.operationalState == BookingOperationalStates.serviceStarted ||
            b.operationalState == BookingOperationalStates.customerArrived),
  );
}

bool _barberLate(DateTime now, List<Booking> barberBookingsToday) {
  final n = now.toLocal();
  return barberBookingsToday.any((b) {
    if (b.status != BookingStatuses.pending &&
        b.status != BookingStatuses.confirmed) {
      return false;
    }
    return b.startAt.toLocal().isBefore(n);
  });
}

String? _floorActivityDetail(List<Booking> barberBookingsToday) {
  final active =
      barberBookingsToday
          .where(
            (b) =>
                b.operationalState == BookingOperationalStates.serviceStarted ||
                b.operationalState == BookingOperationalStates.customerArrived,
          )
          .toList()
        ..sort((a, b) => b.startAt.compareTo(a.startAt));
  if (active.isEmpty) return null;
  final name = (active.first.serviceName ?? '').trim();
  return name.isEmpty ? null : name;
}

({String label, int count})? _topServiceUsage(List<Sale> sales) {
  if (sales.isEmpty) return null;
  final byService = <String, ({String label, int count})>{};
  for (final s in sales) {
    for (final line in s.lineItems) {
      final id = line.serviceId.trim();
      final key = id.isNotEmpty
          ? id
          : line.serviceName.trim().isNotEmpty
          ? 'name:${line.serviceName.trim()}'
          : '';
      if (key.isEmpty) continue;
      final prev = byService[key];
      final qty = line.quantity <= 0 ? 1 : line.quantity;
      final label = line.serviceName.trim().isNotEmpty
          ? line.serviceName
          : line.serviceId;
      byService[key] = (label: label, count: (prev?.count ?? 0) + qty);
    }
  }
  if (byService.isEmpty) return null;
  final best = byService.entries.reduce(
    (a, b) => a.value.count >= b.value.count ? a : b,
  );
  return (label: best.value.label, count: best.value.count);
}

/// Owner overview state backed by every stream we need for the dashboard.
///
/// Safe to read even while individual streams are still connecting: missing
/// data degrades gracefully to `0` / `null` so one slow collection does not
/// block the whole page from rendering.
final ownerOverviewControllerProvider = Provider<OwnerOverviewState>((ref) {
  final sessionState = ref.watch(appSessionBootstrapProvider);
  final sessionUser = ref.watch(sessionUserProvider).asData?.value;
  final resolvedRole = sessionUser?.role ?? sessionState.user?.role;
  if (sessionState.status == AppSessionStatus.unauthenticated ||
      (resolvedRole != UserRoles.owner && resolvedRole != UserRoles.admin)) {
    return const OwnerOverviewState.loading();
  }

  final salonAsync = ref.watch(sessionSalonStreamProvider);
  final salesAsync = ref.watch(salesStreamProvider);
  final bookingsAsync = ref.watch(bookingsStreamProvider);
  final employeesAsync = ref.watch(employeesStreamProvider);
  final servicesAsync = ref.watch(servicesStreamProvider);
  final attendanceAsync = ref.watch(salonAttendanceTodayStreamProvider);
  final pendingRequestsAsync = ref.watch(
    pendingAttendanceRequestsStreamProvider,
  );
  final payrollAsync = ref.watch(payrollStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);

  // Only salon availability is critical for overview shell rendering.
  if (salonAsync.isLoading && !salonAsync.hasValue) {
    return const OwnerOverviewState.loading().copyWith(
      errorMessage: 'blocking: sessionSalonStreamProvider',
    );
  }

  final firstError =
      [
        salesAsync,
        bookingsAsync,
        employeesAsync,
        servicesAsync,
        attendanceAsync,
        pendingRequestsAsync,
        payrollAsync,
        expensesAsync,
        salonAsync,
      ].firstWhere(
        (a) => a.hasError && !a.hasValue,
        orElse: () => const AsyncData<Object?>(null),
      );

  final inputs = OwnerOverviewInputs(
    now: DateTime.now(),
    salon: salonAsync.asData?.value,
    sales: salesAsync.asData?.value ?? const [],
    bookings: bookingsAsync.asData?.value ?? const [],
    employees: employeesAsync.asData?.value ?? const [],
    services: servicesAsync.asData?.value ?? const [],
    attendanceToday: attendanceAsync.asData?.value ?? const [],
    pendingAttendanceRequests: pendingRequestsAsync.asData?.value ?? const [],
    payroll: payrollAsync.asData?.value ?? const [],
    expenses: expensesAsync.asData?.value ?? const [],
  );

  final state = computeOwnerOverviewState(inputs);
  return state.copyWith(
    errorMessage: firstError.hasError ? firstError.error.toString() : null,
  );
});
