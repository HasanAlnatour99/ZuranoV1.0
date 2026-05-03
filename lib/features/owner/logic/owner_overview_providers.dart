import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/booking_statuses.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../bookings/data/models/booking.dart';
import '../../sales/data/models/sale.dart';
import '../../../core/utils/currency_for_country.dart';
import '../../../providers/salon_streams_provider.dart';

bool _sameLocalCalendarDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

bool _isTodayBooking(Booking b) {
  if (b.status == BookingStatuses.cancelled ||
      b.status == BookingStatuses.rescheduled) {
    return false;
  }
  return _sameLocalCalendarDay(b.startAt, DateTime.now());
}

bool _countsAsCompletedSale(Sale s) => s.status == SaleStatuses.completed;

/// Sum of line item totals; falls back to [Sale.total] when there are no lines.
double _saleLinePricesSum(Sale s) {
  if (s.lineItems.isEmpty) {
    return s.total;
  }
  return s.lineItems.fold<double>(0, (a, li) => a + li.total);
}

/// Firestore-backed overview metrics for the owner dashboard MVP.
class OwnerOverviewTodayRevenue {
  const OwnerOverviewTodayRevenue({
    required this.amount,
    required this.isEmpty,
  });

  final double amount;
  final bool isEmpty;
}

/// Completed sales total for the current calendar month (local).
class OwnerOverviewMonthRevenue {
  const OwnerOverviewMonthRevenue({
    required this.amount,
    required this.isEmpty,
  });

  final double amount;
  final bool isEmpty;
}

class OwnerOverviewBookingsToday {
  const OwnerOverviewBookingsToday({
    required this.count,
    required this.isEmpty,
  });

  final int count;
  final bool isEmpty;
}

class OwnerOverviewTopBarberMonth {
  const OwnerOverviewTopBarberMonth({
    required this.barberId,
    required this.name,
    required this.revenue,
  });

  final String barberId;
  final String name;
  final double revenue;
}

class OwnerOverviewTopServiceMonth {
  const OwnerOverviewTopServiceMonth({
    required this.serviceId,
    required this.displayName,
    required this.usageCount,
  });

  final String serviceId;
  final String displayName;
  final int usageCount;
}

class OwnerOverviewMetrics {
  const OwnerOverviewMetrics({
    required this.currencyCode,
    required this.todayRevenue,
    required this.monthRevenue,
    required this.bookingsToday,
    required this.topBarber,
    required this.topService,
  });

  final String currencyCode;
  final OwnerOverviewTodayRevenue todayRevenue;
  final OwnerOverviewMonthRevenue monthRevenue;
  final OwnerOverviewBookingsToday bookingsToday;
  final OwnerOverviewTopBarberMonth? topBarber;
  final OwnerOverviewTopServiceMonth? topService;
}

OwnerOverviewMetrics _computeMetrics({
  required List<Sale> sales,
  required List<Booking> bookings,
  required String currencyCode,
}) {
  final now = DateTime.now();

  final todayCompletedSales = sales
      .where(
        (s) =>
            _countsAsCompletedSale(s) && _sameLocalCalendarDay(s.soldAt, now),
      )
      .toList();
  final todayRevenueSum = todayCompletedSales.fold<double>(
    0,
    (a, s) => a + _saleLinePricesSum(s),
  );
  final todayRevenue = OwnerOverviewTodayRevenue(
    amount: todayRevenueSum,
    isEmpty: todayCompletedSales.isEmpty,
  );

  final monthSales = sales
      .where(
        (s) =>
            _countsAsCompletedSale(s) &&
            s.reportYear == now.year &&
            s.reportMonth == now.month,
      )
      .toList();
  final monthRevenueSum = monthSales.fold<double>(
    0,
    (a, s) => a + _saleLinePricesSum(s),
  );
  final monthRevenue = OwnerOverviewMonthRevenue(
    amount: monthRevenueSum,
    isEmpty: monthSales.isEmpty,
  );

  final todayBookings = bookings.where(_isTodayBooking).toList();
  final bookingsToday = OwnerOverviewBookingsToday(
    count: todayBookings.length,
    isEmpty: todayBookings.isEmpty,
  );

  OwnerOverviewTopBarberMonth? topBarber;
  if (monthSales.isNotEmpty) {
    final byBarber = <String, ({String name, double total})>{};
    for (final s in monthSales) {
      final id = s.barberId.trim().isEmpty ? s.employeeId : s.barberId;
      final prev = byBarber[id];
      final sum = (prev?.total ?? 0) + s.total;
      final name = s.employeeName.trim().isNotEmpty
          ? s.employeeName
          : (prev?.name ?? id);
      byBarber[id] = (name: name, total: sum);
    }
    if (byBarber.isNotEmpty) {
      final best = byBarber.entries.reduce(
        (a, b) => a.value.total >= b.value.total ? a : b,
      );
      topBarber = OwnerOverviewTopBarberMonth(
        barberId: best.key,
        name: best.value.name,
        revenue: best.value.total,
      );
    }
  }

  OwnerOverviewTopServiceMonth? topService;
  if (monthSales.isNotEmpty) {
    final byService = <String, ({String label, int count})>{};
    for (final s in monthSales) {
      for (final line in s.lineItems) {
        final rawId = line.serviceId.trim();
        final key = rawId.isNotEmpty
            ? rawId
            : line.serviceName.trim().isNotEmpty
            ? 'name:${line.serviceName.trim()}'
            : '';
        if (key.isEmpty) {
          continue;
        }
        final prev = byService[key];
        final usage = (prev?.count ?? 0) + line.quantity;
        final label = line.serviceName.trim().isNotEmpty
            ? line.serviceName
            : line.serviceId;
        byService[key] = (label: label, count: usage);
      }
    }
    if (byService.isNotEmpty) {
      final best = byService.entries.reduce(
        (a, b) => a.value.count >= b.value.count ? a : b,
      );
      topService = OwnerOverviewTopServiceMonth(
        serviceId: best.key.startsWith('name:') ? '' : best.key,
        displayName: best.value.label,
        usageCount: best.value.count,
      );
    }
  }

  return OwnerOverviewMetrics(
    currencyCode: currencyCode,
    todayRevenue: todayRevenue,
    monthRevenue: monthRevenue,
    bookingsToday: bookingsToday,
    topBarber: topBarber,
    topService: topService,
  );
}

/// Combined loading from [salesStreamProvider], [bookingsStreamProvider], and
/// [sessionSalonStreamProvider] (currency).
final ownerOverviewMetricsProvider = Provider<AsyncValue<OwnerOverviewMetrics>>(
  (ref) {
    final salesAsync = ref.watch(salesStreamProvider);
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final salonAsync = ref.watch(sessionSalonStreamProvider);

    if (salesAsync.isLoading ||
        bookingsAsync.isLoading ||
        salonAsync.isLoading) {
      return const AsyncLoading();
    }
    if (salesAsync.hasError) {
      return AsyncError(
        salesAsync.error!,
        salesAsync.stackTrace ?? StackTrace.empty,
      );
    }
    if (bookingsAsync.hasError) {
      return AsyncError(
        bookingsAsync.error!,
        bookingsAsync.stackTrace ?? StackTrace.empty,
      );
    }
    if (salonAsync.hasError) {
      return AsyncError(
        salonAsync.error!,
        salonAsync.stackTrace ?? StackTrace.empty,
      );
    }

    final sales = salesAsync.requireValue;
    final bookings = bookingsAsync.requireValue;
    final code = resolvedSalonMoneyCurrency(
      salonCurrencyCode: salonAsync.value?.currencyCode,
      salonCountryIso: salonAsync.value?.countryCode,
    );

    return AsyncData(
      _computeMetrics(sales: sales, bookings: bookings, currencyCode: code),
    );
  },
);

final ownerOverviewTodayRevenueProvider =
    Provider<AsyncValue<OwnerOverviewTodayRevenue>>((ref) {
      return ref
          .watch(ownerOverviewMetricsProvider)
          .when(
            data: (m) => AsyncData(m.todayRevenue),
            loading: () => const AsyncLoading(),
            error: (e, s) => AsyncError(e, s),
          );
    });

final ownerOverviewBookingsTodayProvider =
    Provider<AsyncValue<OwnerOverviewBookingsToday>>((ref) {
      return ref
          .watch(ownerOverviewMetricsProvider)
          .when(
            data: (m) => AsyncData(m.bookingsToday),
            loading: () => const AsyncLoading(),
            error: (e, s) => AsyncError(e, s),
          );
    });

final ownerOverviewTopBarberMonthProvider =
    Provider<AsyncValue<OwnerOverviewTopBarberMonth?>>((ref) {
      return ref
          .watch(ownerOverviewMetricsProvider)
          .when(
            data: (m) => AsyncData(m.topBarber),
            loading: () => const AsyncLoading(),
            error: (e, s) => AsyncError(e, s),
          );
    });

final ownerOverviewTopServiceMonthProvider =
    Provider<AsyncValue<OwnerOverviewTopServiceMonth?>>((ref) {
      return ref
          .watch(ownerOverviewMetricsProvider)
          .when(
            data: (m) => AsyncData(m.topService),
            loading: () => const AsyncLoading(),
            error: (e, s) => AsyncError(e, s),
          );
    });

