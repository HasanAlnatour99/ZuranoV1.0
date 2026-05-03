import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/attendance/data/models/attendance_record.dart';
import '../features/bookings/data/models/booking.dart';
import '../features/employees/data/models/employee.dart';
import '../features/expenses/data/models/expense.dart';
import '../features/insights/data/models/salon_insight.dart';
import '../features/payroll/data/models/payroll_record.dart';
import '../features/payroll/data/models/payslip_model.dart';
import '../features/sales/data/models/sale.dart';
import '../features/salon/data/models/salon.dart';
import '../features/services/data/models/service.dart';
import '../features/violations/data/models/violation.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';
import 'session_provider.dart';
import '../core/constants/user_roles.dart';
import '../core/session/app_session_status.dart';

/// Calendar month filter for [salesByMonthStreamProvider] (local date parts).
typedef SalesMonthKey = ({int year, int month});

Stream<T> _guardedSalonStream<T>(
  Ref ref, {
  required T emptyValue,
  required Stream<T> Function(String salonId) onSalon,
}) {
  final sessionState = ref.watch(appSessionBootstrapProvider);
  final sessionUser = ref.watch(sessionUserProvider).asData?.value;
  final role = sessionUser?.role ?? sessionState.user?.role;
  final hasSalonScopedRole =
      role == UserRoles.owner ||
      role == UserRoles.admin ||
      role == UserRoles.barber ||
      role == UserRoles.readonly ||
      role == UserRoles.employee;

  if (sessionState.status == AppSessionStatus.unauthenticated ||
      !hasSalonScopedRole) {
    return Stream<T>.value(emptyValue);
  }

  if (ref.watch(firebaseAuthProvider).currentUser == null) {
    return Stream<T>.value(emptyValue);
  }
  return watchSessionSalonId(ref).asyncExpand((salonId) {
    final isSignedOut = ref.read(firebaseAuthProvider).currentUser == null;
    if (isSignedOut || salonId == null || salonId.isEmpty) {
      return Stream<T>.value(emptyValue);
    }
    return onSalon(salonId);
  });
}

/// Real-time services for the signed-in user's salon.
///
/// Yields an empty list when logged out or when [AppUser.salonId] is missing.
/// Uses [watchSessionSalonId] so Firestore listens reset when the salon changes.
final servicesStreamProvider = StreamProvider<List<SalonService>>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return _guardedSalonStream<List<SalonService>>(
    ref,
    emptyValue: const <SalonService>[],
    onSalon: repo.watchServices,
  );
});

/// Real-time sales for the signed-in user's salon (newest first; repository default limit).
///
/// Yields an empty list when logged out or when [AppUser.salonId] is missing.
final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  return _guardedSalonStream<List<Sale>>(
    ref,
    emptyValue: const <Sale>[],
    onSalon: (salonId) => repo.watchSales(salonId, limit: 500),
  );
});

/// Weekly smart insights for the signed-in owner's salon (owner/admin read in rules).
final insightsStreamProvider = StreamProvider<List<SalonInsight>>((ref) {
  final repo = ref.watch(insightsRepositoryProvider);
  return _guardedSalonStream<List<SalonInsight>>(
    ref,
    emptyValue: const <SalonInsight>[],
    onSalon: repo.watchInsights,
  );
});

/// Real-time bookings for the signed-in user's salon (newest [startAt] first; repository default limit).
///
/// Yields an empty list when logged out or when [AppUser.salonId] is missing.
final bookingsStreamProvider = StreamProvider<List<Booking>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return _guardedSalonStream<List<Booking>>(
    ref,
    emptyValue: const <Booking>[],
    onSalon: repo.watchBookingsBySalon,
  );
});

/// Salon document for the signed-in staff user's [AppUser.salonId].
final sessionSalonStreamProvider = StreamProvider<Salon?>((ref) {
  final repo = ref.watch(salonRepositoryProvider);
  return _guardedSalonStream<Salon?>(
    ref,
    emptyValue: null,
    onSalon: repo.watchSalon,
  );
});

/// Violations for the signed-in user's salon (newest [Violation.occurredAt] first).
final violationsStreamProvider = StreamProvider<List<Violation>>((ref) {
  final repo = ref.watch(violationRepositoryProvider);
  return _guardedSalonStream<List<Violation>>(
    ref,
    emptyValue: const <Violation>[],
    onSalon: (salonId) => repo.watchViolations(salonId, limit: 400),
  );
});

final payrollStreamProvider = StreamProvider<List<PayrollRecord>>((ref) {
  final repo = ref.watch(payrollRepositoryProvider);
  return _guardedSalonStream<List<PayrollRecord>>(
    ref,
    emptyValue: const <PayrollRecord>[],
    onSalon: (salonId) => repo.watchPayroll(salonId, limit: 48),
  );
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return _guardedSalonStream<List<Expense>>(
    ref,
    emptyValue: const <Expense>[],
    onSalon: (salonId) => repo.watchExpenses(salonId, limit: 400),
  );
});

/// Employees for the signed-in user's salon (includes inactive for management UIs).
final employeesStreamProvider = StreamProvider<List<Employee>>((ref) {
  final repo = ref.watch(employeeRepositoryProvider);
  return _guardedSalonStream<List<Employee>>(
    ref,
    emptyValue: const <Employee>[],
    onSalon: (salonId) => repo.watchEmployees(salonId, onlyActive: false),
  );
});

typedef AttendanceDayQuery = ({DateTime day});

/// Attendance rows for the signed-in owner's salon on the local current day.
///
/// Emits an empty list when logged out or when [AppUser.salonId] is missing.
/// Uses a bounded `workDate` window so the repository query stays small.
final salonAttendanceTodayStreamProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return _guardedSalonStream<List<AttendanceRecord>>(
        ref,
        emptyValue: const <AttendanceRecord>[],
        onSalon: (salonId) {
          final now = DateTime.now();
          final start = DateTime(now.year, now.month, now.day);
          final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
          return repo.watchAttendance(
            salonId,
            workDateFrom: start,
            workDateTo: end,
            limit: 120,
          );
        },
      );
    });

/// Attendance records currently awaiting owner/admin approval for the signed-in
/// user's salon. Ordered newest first by `workDate`. Empty list when logged out.
final pendingAttendanceRequestsStreamProvider =
    StreamProvider<List<AttendanceRecord>>((ref) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return _guardedSalonStream<List<AttendanceRecord>>(
        ref,
        emptyValue: const <AttendanceRecord>[],
        onSalon: repo.watchPendingAttendanceRequests,
      );
    });

/// Attendance rows for the current barber on a local calendar day.
final barberAttendanceForDayStreamProvider =
    StreamProvider.family<List<AttendanceRecord>, AttendanceDayQuery>((
      ref,
      query,
    ) {
      if (ref.watch(firebaseAuthProvider).currentUser == null) {
        return Stream.value(const <AttendanceRecord>[]);
      }
      final sessionState = ref.watch(appSessionBootstrapProvider);
      if (sessionState.status == AppSessionStatus.unauthenticated) {
        return Stream.value(const <AttendanceRecord>[]);
      }
      final session =
          ref.watch(sessionUserProvider).asData?.value ?? sessionState.user;
      final salonId = session?.salonId ?? '';
      final employeeId = session?.employeeId ?? '';
      final repo = ref.watch(attendanceRepositoryProvider);
      if (salonId.isEmpty || employeeId.isEmpty) {
        return Stream.value(const <AttendanceRecord>[]);
      }
      final d = query.day;
      final start = DateTime(d.year, d.month, d.day);
      final end = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
      return repo.watchAttendance(
        salonId,
        employeeId: employeeId,
        workDateFrom: start,
        workDateTo: end,
      );
    });

/// Sales in [SalesMonthKey] for the signed-in user's salon ([Sale.reportYear] / [Sale.reportMonth]).
final salesByMonthStreamProvider =
    StreamProvider.family<List<Sale>, SalesMonthKey>((ref, month) {
      final repo = ref.watch(salesRepositoryProvider);
      return _guardedSalonStream<List<Sale>>(
        ref,
        emptyValue: const <Sale>[],
        onSalon: (salonId) {
          return repo.watchSales(
            salonId,
            reportYear: month.year,
            reportMonth: month.month,
            limit: 2500,
          );
        },
      );
    });

/// Expenses whose [Expense.reportYear] / [Expense.reportMonth] match [SalesMonthKey].
final expensesByMonthStreamProvider =
    StreamProvider.family<List<Expense>, SalesMonthKey>((ref, month) {
      final repo = ref.watch(expenseRepositoryProvider);
      return _guardedSalonStream<List<Expense>>(
        ref,
        emptyValue: const <Expense>[],
        onSalon: (salonId) {
          return repo.watchExpenses(
            salonId,
            reportYear: month.year,
            reportMonth: month.month,
            limit: 800,
          );
        },
      );
    });

/// Payroll rows for the salon calendar month ([PayrollRecord.year] / [month]).
final payrollByMonthStreamProvider =
    StreamProvider.family<List<PayrollRecord>, SalesMonthKey>((ref, month) {
      final repo = ref.watch(payrollRepositoryProvider);
      return _guardedSalonStream<List<PayrollRecord>>(
        ref,
        emptyValue: const <PayrollRecord>[],
        onSalon: (salonId) {
          return repo.watchPayroll(
            salonId,
            year: month.year,
            month: month.month,
            limit: 240,
          );
        },
      );
    });

/// Payslips for the salon calendar month (used with payroll runs; see [PayslipModel.payrollRunId]).
final payslipsByMonthStreamProvider =
    StreamProvider.family<List<PayslipModel>, SalesMonthKey>((ref, month) {
      final repo = ref.watch(payslipRepositoryProvider);
      return _guardedSalonStream<List<PayslipModel>>(
        ref,
        emptyValue: const <PayslipModel>[],
        onSalon: (salonId) {
          return repo.watchPayslipsForSalonCalendarMonth(
            salonId: salonId,
            year: month.year,
            month: month.month,
          );
        },
      );
    });

/// Bookings assigned to [barberId] (empty id yields an empty stream).
final bookingsByBarberStreamProvider =
    StreamProvider.family<List<Booking>, String>((ref, barberId) {
      final repo = ref.watch(bookingRepositoryProvider);
      if (barberId.isEmpty) {
        return Stream.value(const <Booking>[]);
      }
      return _guardedSalonStream<List<Booking>>(
        ref,
        emptyValue: const <Booking>[],
        onSalon: (salonId) =>
            repo.watchBookingsBySalon(salonId, barberId: barberId),
      );
    });

/// Services whose [SalonService.categoryKey] equals [categoryKey] (trimmed).
///
/// An empty [categoryKey] skips the category filter (same ordering as [servicesStreamProvider]).
final servicesByCategoryStreamProvider =
    StreamProvider.family<List<SalonService>, String>((ref, categoryKey) {
      final repo = ref.watch(serviceRepositoryProvider);
      return _guardedSalonStream<List<SalonService>>(
        ref,
        emptyValue: const <SalonService>[],
        onSalon: (salonId) {
          final trimmed = categoryKey.trim();
          return repo.watchServices(
            salonId,
            categoryKey: trimmed.isEmpty ? null : trimmed,
          );
        },
      );
    });
