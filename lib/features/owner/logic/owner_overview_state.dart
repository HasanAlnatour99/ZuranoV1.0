import 'package:flutter/foundation.dart';

/// Revenue chart range on the owner overview screen (default: month).
enum OwnerOverviewRevenueChartPeriod { day, week, month }

/// Floor status for a barber row on the owner overview team widget.
enum OwnerTeamBarberStatus { checkedIn, notCheckedIn, onService, late }

/// One barber preview row (avatar, name, attendance, activity).
@immutable
class OwnerTeamBarberPreview {
  const OwnerTeamBarberPreview({
    required this.employeeId,
    required this.name,
    required this.status,
    this.activityDetail,
  });

  final String employeeId;
  final String name;
  final OwnerTeamBarberStatus status;

  /// e.g. service name while [status] is [OwnerTeamBarberStatus.onService].
  final String? activityDetail;
}

/// Top barber insight derived from completed sales aggregation.
///
/// The controller fills this from `Sale.barberId` → cumulative sale total for
/// a given window (today for overview, month for payroll previews). Widgets
/// must never compute this themselves.
@immutable
class TopBarberInsight {
  const TopBarberInsight({
    required this.barberId,
    required this.barberName,
    required this.totalSales,
    required this.contributionPercent,
  });

  final String barberId;
  final String barberName;
  final double totalSales;

  /// [totalSales] as a percentage of the total window revenue (`0..100`).
  /// Returns `0` when the total revenue is `0`.
  final double contributionPercent;
}

/// Latest completed sale shown in the owner overview activity card.
@immutable
class OwnerOverviewLatestSale {
  const OwnerOverviewLatestSale({
    required this.serviceLabel,
    required this.barberName,
    required this.amount,
    required this.soldAt,
  });

  final String serviceLabel;
  final String barberName;
  final double amount;
  final DateTime soldAt;
}

/// Active service row for the overview "Recent services" strip.
@immutable
class OwnerOverviewServicePreview {
  const OwnerOverviewServicePreview({required this.name, required this.price});

  final String name;
  final double price;
}

/// Aggregated, UI-ready snapshot for the salon owner's Overview screen.
///
/// Values are derived from existing Firestore collections (sales, bookings,
/// employees, attendance, services, payroll, expenses) by
/// `OwnerOverviewController`. The screen should never compute business logic
/// from raw collections itself.
@immutable
class OwnerOverviewState {
  const OwnerOverviewState({
    this.currencyCode = 'USD',
    this.salonName,
    this.salonCity,
    this.ownerName,
    this.monthRevenue = 0,
    this.previousMonthRevenue,
    this.todayRevenue = 0,
    this.yesterdayRevenue = 0,
    this.bookingsToday = 0,
    this.completedBookingsToday = 0,
    this.completedBookingsYesterday = 0,
    this.pendingBookingsCount = 0,
    this.checkedInEmployeesToday = 0,
    this.pendingApprovalsCount = 0,
    this.activeServicesCount = 0,
    this.totalServicesCount = 0,
    this.averageActiveServicePrice = 0,
    this.totalEmployeesCount = 0,
    this.topServiceToday,
    this.topBarberToday,
    this.topBarberTodayInsight,
    this.mostBookedServiceThisMonth,
    this.estimatedCommissionThisMonth = 0,
    this.expensesThisMonth = 0,
    this.netResultThisMonth = 0,
    this.payrollRunExistsForCurrentMonth = false,
    this.inactiveEmployeesCount = 0,
    this.hasMonthRevenue = false,
    this.hasTodayRevenue = false,
    this.completedSalesTodayCount = 0,
    this.completedSalesYesterdayCount = 0,
    this.bookingsYesterdayCount = 0,
    this.activeBarberCount = 0,
    this.checkedInBarbersToday = 0,
    this.barbersNotCheckedInAlertCount = 0,
    this.topServiceThisWeekName,
    this.topServiceThisWeekUses = 0,
    this.teamBarberPreview = const [],
    this.last7DaysDailyRevenue = const [0, 0, 0, 0, 0, 0, 0],
    this.todayHourlyRevenue = _kDefaultTodayHourlyRevenue,
    this.currentMonthDailyRevenue = const [],
    this.servicePreviewTop3 = const [],
    this.latestSale,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Empty loading snapshot used before the first aggregation completes.
  const OwnerOverviewState.loading() : this(isLoading: true);

  /// ISO currency code from the salon document (fallback: USD).
  final String currencyCode;

  /// Optional salon display name (for the header subtitle).
  final String? salonName;

  /// Optional salon city (for the header subtitle).
  final String? salonCity;

  /// Owner display name (for the header greeting).
  final String? ownerName;

  /// Completed sales total for the current calendar month (local).
  final double monthRevenue;

  /// Same metric for the previous month, when available (for change hint).
  final double? previousMonthRevenue;

  /// Completed sales total for the local current day.
  final double todayRevenue;

  /// Completed sales total for the previous local calendar day.
  final double yesterdayRevenue;

  /// Count of bookings whose [Booking.startAt] is today (excludes cancelled
  /// and rescheduled rows).
  final int bookingsToday;

  /// Subset of [bookingsToday] marked as completed today.
  final int completedBookingsToday;

  /// Bookings on the previous local day marked completed.
  final int completedBookingsYesterday;

  /// Count of bookings whose status is pending (awaiting confirmation).
  final int pendingBookingsCount;

  /// Count of active employees currently checked in today.
  final int checkedInEmployeesToday;

  /// Count of attendance records today still awaiting owner review.
  final int pendingApprovalsCount;

  /// Count of services with `isActive = true`.
  final int activeServicesCount;

  /// Count of all services (active + inactive) under the salon.
  final int totalServicesCount;

  /// Average price across [activeServicesCount] services; `0` when empty.
  final double averageActiveServicePrice;

  /// Count of active employees under the salon.
  final int totalEmployeesCount;

  /// Service with the highest booking/sale usage today, by display name.
  final String? topServiceToday;

  /// Barber with the highest sales total today, by display name (legacy
  /// shortcut for existing UI). Prefer [topBarberTodayInsight] for richer
  /// contribution data.
  final String? topBarberToday;

  /// Fully qualified top-barber insight for today, or `null` when no barber
  /// has a completed sale yet today.
  final TopBarberInsight? topBarberTodayInsight;

  /// Most booked service this month, by display name.
  final String? mostBookedServiceThisMonth;

  /// Sum of sales * employee commission rate for the current month.
  final double estimatedCommissionThisMonth;

  /// Completed expenses total for the current month.
  final double expensesThisMonth;

  /// `monthRevenue - estimatedCommissionThisMonth - expensesThisMonth`.
  final double netResultThisMonth;

  /// `true` when a payroll record exists for the current month/year.
  final bool payrollRunExistsForCurrentMonth;

  /// Count of employees marked as inactive.
  final int inactiveEmployeesCount;

  /// `true` when at least one completed sale exists this month.
  final bool hasMonthRevenue;

  /// `true` when at least one completed sale exists today.
  final bool hasTodayRevenue;

  /// Number of completed sale documents recorded today (local calendar).
  final int completedSalesTodayCount;

  /// Completed sale documents on the previous local calendar day.
  final int completedSalesYesterdayCount;

  /// Completed sales revenue by hour (0–23) for the local current day.
  final List<double> todayHourlyRevenue;

  /// Active bookings (non-cancelled) scheduled for yesterday (local day).
  final int bookingsYesterdayCount;

  /// Active employees with role barber.
  final int activeBarberCount;

  /// Barbers with a same-day check-in and no check-out yet.
  final int checkedInBarbersToday;

  /// Barbers who should check in: not checked in and not currently on the floor.
  final int barbersNotCheckedInAlertCount;

  /// Top service by line-item usage in the rolling last 7 days (inclusive).
  final String? topServiceThisWeekName;

  /// Usage count backing [topServiceThisWeekName]; `0` when unknown.
  final int topServiceThisWeekUses;

  /// Up to three barber rows for the team preview, pre-sorted for display.
  final List<OwnerTeamBarberPreview> teamBarberPreview;

  /// Completed sales total per local day, oldest → newest (7 values).
  ///
  /// Index `0` is six days before "today", index `6` is today.
  final List<double> last7DaysDailyRevenue;

  /// Completed sales total per local calendar day in the current month.
  ///
  /// Index `0` is day 1, length matches the number of days in [DateTime.month].
  final List<double> currentMonthDailyRevenue;

  /// Up to three active services (name + price) for the overview list.
  final List<OwnerOverviewServicePreview> servicePreviewTop3;

  /// Most recent completed sale, derived from the existing sales stream.
  final OwnerOverviewLatestSale? latestSale;

  final bool isLoading;
  final String? errorMessage;

  /// `true` when [errorMessage] is non-empty.
  bool get hasError => (errorMessage ?? '').isNotEmpty;

  OwnerOverviewState copyWith({
    String? currencyCode,
    Object? salonName = _sentinel,
    Object? salonCity = _sentinel,
    Object? ownerName = _sentinel,
    double? monthRevenue,
    Object? previousMonthRevenue = _sentinel,
    double? todayRevenue,
    double? yesterdayRevenue,
    int? bookingsToday,
    int? completedBookingsToday,
    int? completedBookingsYesterday,
    int? pendingBookingsCount,
    int? checkedInEmployeesToday,
    int? pendingApprovalsCount,
    int? activeServicesCount,
    int? totalServicesCount,
    double? averageActiveServicePrice,
    int? totalEmployeesCount,
    Object? topServiceToday = _sentinel,
    Object? topBarberToday = _sentinel,
    Object? topBarberTodayInsight = _sentinel,
    Object? mostBookedServiceThisMonth = _sentinel,
    double? estimatedCommissionThisMonth,
    double? expensesThisMonth,
    double? netResultThisMonth,
    bool? payrollRunExistsForCurrentMonth,
    int? inactiveEmployeesCount,
    bool? hasMonthRevenue,
    bool? hasTodayRevenue,
    int? completedSalesTodayCount,
    int? completedSalesYesterdayCount,
    int? bookingsYesterdayCount,
    int? activeBarberCount,
    int? checkedInBarbersToday,
    int? barbersNotCheckedInAlertCount,
    Object? topServiceThisWeekName = _sentinel,
    int? topServiceThisWeekUses,
    List<OwnerTeamBarberPreview>? teamBarberPreview,
    List<double>? last7DaysDailyRevenue,
    List<double>? todayHourlyRevenue,
    List<double>? currentMonthDailyRevenue,
    List<OwnerOverviewServicePreview>? servicePreviewTop3,
    Object? latestSale = _sentinel,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return OwnerOverviewState(
      currencyCode: currencyCode ?? this.currencyCode,
      salonName: identical(salonName, _sentinel)
          ? this.salonName
          : salonName as String?,
      salonCity: identical(salonCity, _sentinel)
          ? this.salonCity
          : salonCity as String?,
      ownerName: identical(ownerName, _sentinel)
          ? this.ownerName
          : ownerName as String?,
      monthRevenue: monthRevenue ?? this.monthRevenue,
      previousMonthRevenue: identical(previousMonthRevenue, _sentinel)
          ? this.previousMonthRevenue
          : previousMonthRevenue as double?,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      yesterdayRevenue: yesterdayRevenue ?? this.yesterdayRevenue,
      bookingsToday: bookingsToday ?? this.bookingsToday,
      completedBookingsToday:
          completedBookingsToday ?? this.completedBookingsToday,
      completedBookingsYesterday:
          completedBookingsYesterday ?? this.completedBookingsYesterday,
      pendingBookingsCount: pendingBookingsCount ?? this.pendingBookingsCount,
      checkedInEmployeesToday:
          checkedInEmployeesToday ?? this.checkedInEmployeesToday,
      pendingApprovalsCount:
          pendingApprovalsCount ?? this.pendingApprovalsCount,
      activeServicesCount: activeServicesCount ?? this.activeServicesCount,
      totalServicesCount: totalServicesCount ?? this.totalServicesCount,
      averageActiveServicePrice:
          averageActiveServicePrice ?? this.averageActiveServicePrice,
      totalEmployeesCount: totalEmployeesCount ?? this.totalEmployeesCount,
      topServiceToday: identical(topServiceToday, _sentinel)
          ? this.topServiceToday
          : topServiceToday as String?,
      topBarberToday: identical(topBarberToday, _sentinel)
          ? this.topBarberToday
          : topBarberToday as String?,
      topBarberTodayInsight: identical(topBarberTodayInsight, _sentinel)
          ? this.topBarberTodayInsight
          : topBarberTodayInsight as TopBarberInsight?,
      mostBookedServiceThisMonth:
          identical(mostBookedServiceThisMonth, _sentinel)
          ? this.mostBookedServiceThisMonth
          : mostBookedServiceThisMonth as String?,
      estimatedCommissionThisMonth:
          estimatedCommissionThisMonth ?? this.estimatedCommissionThisMonth,
      expensesThisMonth: expensesThisMonth ?? this.expensesThisMonth,
      netResultThisMonth: netResultThisMonth ?? this.netResultThisMonth,
      payrollRunExistsForCurrentMonth:
          payrollRunExistsForCurrentMonth ??
          this.payrollRunExistsForCurrentMonth,
      inactiveEmployeesCount:
          inactiveEmployeesCount ?? this.inactiveEmployeesCount,
      hasMonthRevenue: hasMonthRevenue ?? this.hasMonthRevenue,
      hasTodayRevenue: hasTodayRevenue ?? this.hasTodayRevenue,
      completedSalesTodayCount:
          completedSalesTodayCount ?? this.completedSalesTodayCount,
      completedSalesYesterdayCount:
          completedSalesYesterdayCount ?? this.completedSalesYesterdayCount,
      bookingsYesterdayCount:
          bookingsYesterdayCount ?? this.bookingsYesterdayCount,
      activeBarberCount: activeBarberCount ?? this.activeBarberCount,
      checkedInBarbersToday:
          checkedInBarbersToday ?? this.checkedInBarbersToday,
      barbersNotCheckedInAlertCount:
          barbersNotCheckedInAlertCount ?? this.barbersNotCheckedInAlertCount,
      topServiceThisWeekName: identical(topServiceThisWeekName, _sentinel)
          ? this.topServiceThisWeekName
          : topServiceThisWeekName as String?,
      topServiceThisWeekUses:
          topServiceThisWeekUses ?? this.topServiceThisWeekUses,
      teamBarberPreview: teamBarberPreview ?? this.teamBarberPreview,
      last7DaysDailyRevenue:
          last7DaysDailyRevenue ?? this.last7DaysDailyRevenue,
      todayHourlyRevenue: todayHourlyRevenue ?? this.todayHourlyRevenue,
      currentMonthDailyRevenue:
          currentMonthDailyRevenue ?? this.currentMonthDailyRevenue,
      servicePreviewTop3: servicePreviewTop3 ?? this.servicePreviewTop3,
      latestSale: identical(latestSale, _sentinel)
          ? this.latestSale
          : latestSale as OwnerOverviewLatestSale?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  /// Design-time / widget-test snapshot with realistic shape (not for production).
  factory OwnerOverviewState.previewDashboard() {
    return OwnerOverviewState(
      salonName: 'Studio Luxe',
      ownerName: 'Hasan',
      currencyCode: 'USD',
      monthRevenue: 12400,
      previousMonthRevenue: 10200,
      todayRevenue: 150,
      yesterdayRevenue: 120,
      bookingsToday: 5,
      bookingsYesterdayCount: 6,
      completedBookingsToday: 3,
      completedBookingsYesterday: 2,
      completedSalesTodayCount: 3,
      completedSalesYesterdayCount: 2,
      pendingBookingsCount: 1,
      checkedInEmployeesToday: 2,
      checkedInBarbersToday: 2,
      activeBarberCount: 4,
      barbersNotCheckedInAlertCount: 2,
      hasMonthRevenue: true,
      hasTodayRevenue: true,
      topServiceThisWeekName: 'Beard trim',
      topServiceThisWeekUses: 5,
      topBarberTodayInsight: const TopBarberInsight(
        barberId: 'b1',
        barberName: 'Ahmed',
        totalSales: 102,
        contributionPercent: 68,
      ),
      teamBarberPreview: const [
        OwnerTeamBarberPreview(
          employeeId: 'b1',
          name: 'Ahmed',
          status: OwnerTeamBarberStatus.onService,
          activityDetail: 'Beard trim',
        ),
        OwnerTeamBarberPreview(
          employeeId: 'b2',
          name: 'Omar',
          status: OwnerTeamBarberStatus.checkedIn,
        ),
        OwnerTeamBarberPreview(
          employeeId: 'b3',
          name: 'Salim',
          status: OwnerTeamBarberStatus.late,
        ),
      ],
      last7DaysDailyRevenue: const [120, 180, 90, 210, 160, 240, 195],
      todayHourlyRevenue: List<double>.generate(24, (int i) => i == 14 ? 65.0 : 0),
      currentMonthDailyRevenue: List<double>.generate(
        30,
        (int i) => (i.isEven ? 80.0 : 40.0) + i * 2,
      ),
      servicePreviewTop3: const [
        OwnerOverviewServicePreview(name: 'Haircut', price: 25),
        OwnerOverviewServicePreview(name: 'Beard trim', price: 15),
        OwnerOverviewServicePreview(name: 'Color', price: 60),
      ],
      latestSale: OwnerOverviewLatestSale(
        serviceLabel: 'Beard trim',
        barberName: 'Ahmed',
        amount: 35,
        soldAt: DateTime(2026, 4, 25, 14, 30),
      ),
    );
  }
}

const List<double> _kDefaultTodayHourlyRevenue = <double>[
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

const Object _sentinel = Object();
