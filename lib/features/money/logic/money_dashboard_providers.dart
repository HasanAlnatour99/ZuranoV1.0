import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/payroll_statuses.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../../core/time/iso_week.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../expenses/data/models/expense.dart';
import '../../payroll/data/models/payroll_record.dart';
import '../../payroll/data/models/payslip_model.dart';
import '../../sales/data/models/sale.dart';

enum MoneyInsightKind { topBarber, topService, largestExpenseCategory }

/// X-axis bucketing for the Finance dashboard sales vs expenses chart.
enum MoneyChartGranularity { daily, weekly, monthly, yearly }

class MoneyChartGranularityNotifier extends Notifier<MoneyChartGranularity> {
  @override
  MoneyChartGranularity build() => MoneyChartGranularity.daily;

  void select(MoneyChartGranularity value) {
    state = value;
  }
}

final moneyChartGranularityProvider =
    NotifierProvider<MoneyChartGranularityNotifier, MoneyChartGranularity>(
      MoneyChartGranularityNotifier.new,
    );

class MoneyMonthSelection extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void selectMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }
}

final moneySelectedMonthProvider =
    NotifierProvider<MoneyMonthSelection, DateTime>(MoneyMonthSelection.new);

final moneyMonthOptionsProvider = Provider<List<DateTime>>((ref) {
  final now = DateTime.now();
  return List<DateTime>.generate(
    6,
    (index) => DateTime(now.year, now.month - index),
    growable: false,
  );
});

class MoneyLeaderboardEntry {
  const MoneyLeaderboardEntry({
    required this.id,
    required this.label,
    required this.amount,
  });

  final String id;
  final String label;
  final double amount;
}

class MoneyCategoryBreakdown {
  const MoneyCategoryBreakdown({
    required this.category,
    required this.amount,
    required this.share,
  });

  final String category;
  final double amount;
  final double share;
}

class MoneyDashboardInsight {
  const MoneyDashboardInsight({
    required this.kind,
    required this.label,
    required this.value,
    this.amount,
  });

  final MoneyInsightKind kind;
  final String label;
  final String value;
  final double? amount;
}

class MoneyTrendPoint {
  const MoneyTrendPoint({
    required this.date,
    required this.sales,
    required this.expenses,
  });

  final DateTime date;
  final double sales;
  final double expenses;
}

class MoneyDashboardSummary {
  const MoneyDashboardSummary({
    required this.month,
    required this.salesTotal,
    required this.expensesTotal,
    required this.payrollTotal,
    required this.netProfit,
    required this.topBarber,
    required this.topService,
    required this.categoryBreakdown,
  });

  final DateTime month;
  final double salesTotal;
  final double expensesTotal;
  final double payrollTotal;
  final double netProfit;
  final MoneyLeaderboardEntry? topBarber;
  final MoneyLeaderboardEntry? topService;
  final List<MoneyCategoryBreakdown> categoryBreakdown;
}

/// Net payroll from payslips created by the payroll-run / QuickPay pipeline
/// ([PayslipModel.payrollRunId]). Only **paid** amounts count toward finance KPIs
/// so approved-but-unsettled runs do not reduce net profit.
///
/// When [inclusiveEndDay] is set (month-to-date mode), only payslips with a
/// non-null [PayslipModel.paidAt] whose local calendar day is in
/// `1..inclusiveEndDay` within that payslip's [PayslipModel.year]/[month] count.
double _payrollNetFromRunPayslips(
  Iterable<PayslipModel> payslips, {
  int? inclusiveEndDay,
}) {
  return payslips
      .where((p) => (p.payrollRunId ?? '').trim().isNotEmpty)
      .where((p) => p.status == PayrollStatuses.paid)
      .where((p) {
        if (inclusiveEndDay == null) return true;
        final paid = p.paidAt;
        if (paid == null) return false;
        final local = DateUtils.dateOnly(paid.toLocal());
        if (local.year != p.year || local.month != p.month) return false;
        return local.day <= inclusiveEndDay;
      })
      .fold<double>(0, (sum, p) => sum + p.netPay);
}

/// True when [instant]'s local date is in [month]'s calendar month and its
/// day-of-month is at most [inclusiveEndDay].
bool _isLocalOnOrBeforeDayInMonth(
  DateTime instant,
  DateTime month,
  int inclusiveEndDay,
) {
  final local = DateUtils.dateOnly(instant.toLocal());
  return local.year == month.year &&
      local.month == month.month &&
      local.day <= inclusiveEndDay;
}

/// Builds [MoneyDashboardSummary] for a calendar month from raw streams.
///
/// [inclusiveEndDay]: when non-null, only include sales ([Sale.soldAt]),
/// expenses ([Expense.incurredAt]), and paid payroll attributed via
/// [PayrollRecord.paidAt] / [PayslipModel.paidAt] up to that day-of-month in
/// the summary [month]. Paid legacy payroll without [PayrollRecord.paidAt] is
/// excluded in MTD mode so whole-month payouts are not mis-attributed.
MoneyDashboardSummary buildMoneyDashboardSummaryForMonth({
  required Iterable<Sale> sales,
  required Iterable<Expense> expenses,
  required Iterable<PayrollRecord> payroll,
  required Iterable<PayslipModel> runPayslips,
  required DateTime month,
  int? inclusiveEndDay,
}) {
  final mSales = sales.where((sale) {
    if (sale.reportYear != month.year ||
        sale.reportMonth != month.month ||
        sale.status != SaleStatuses.completed) {
      return false;
    }
    if (inclusiveEndDay != null &&
        !_isLocalOnOrBeforeDayInMonth(sale.soldAt, month, inclusiveEndDay)) {
      return false;
    }
    return true;
  });
  final mExpenses = expenses.where((expense) {
    if (expense.reportYear != month.year ||
        expense.reportMonth != month.month) {
      return false;
    }
    if (inclusiveEndDay != null &&
        !_isLocalOnOrBeforeDayInMonth(
          expense.incurredAt,
          month,
          inclusiveEndDay,
        )) {
      return false;
    }
    return true;
  });
  final mPayroll = payroll.where((record) {
    if (record.year != month.year ||
        record.month != month.month ||
        record.status != PayrollStatuses.paid) {
      return false;
    }
    if (inclusiveEndDay != null) {
      final paid = record.paidAt;
      if (paid == null) return false;
      if (!_isLocalOnOrBeforeDayInMonth(paid, month, inclusiveEndDay)) {
        return false;
      }
    }
    return true;
  });

  final salesTotal = mSales.fold<double>(0, (sum, sale) => sum + sale.total);
  final expensesTotal = mExpenses.fold<double>(
    0,
    (sum, expense) => sum + expense.amount,
  );
  final payrollFromRecords = mPayroll.fold<double>(
    0,
    (sum, record) => sum + record.netAmount,
  );
  final payrollFromRuns = _payrollNetFromRunPayslips(
    runPayslips,
    inclusiveEndDay: inclusiveEndDay,
  );
  final payrollTotal = payrollFromRecords + payrollFromRuns;

  return MoneyDashboardSummary(
    month: month,
    salesTotal: salesTotal,
    expensesTotal: expensesTotal,
    payrollTotal: payrollTotal,
    netProfit: salesTotal - expensesTotal - payrollTotal,
    topBarber: _computeTopBarber(mSales),
    topService: _computeTopService(mSales),
    categoryBreakdown: _buildCategoryBreakdown(mExpenses),
  );
}

final totalSalesTodayProvider = Provider<double>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final today = DateUtils.dateOnly(DateTime.now());
  return sales
      .where((sale) => _isSameDay(sale.soldAt, today))
      .fold<double>(0, (sum, sale) => sum + sale.total);
});

final totalSalesThisMonthProvider = Provider<double>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final now = DateTime.now();
  return sales
      .where(
        (sale) => sale.reportYear == now.year && sale.reportMonth == now.month,
      )
      .fold<double>(0, (sum, sale) => sum + sale.total);
});

final totalExpensesThisMonthProvider = Provider<double>((ref) {
  final expenses =
      ref.watch(expensesStreamProvider).asData?.value ?? const <Expense>[];
  final now = DateTime.now();
  return expenses
      .where(
        (expense) =>
            expense.reportYear == now.year && expense.reportMonth == now.month,
      )
      .fold<double>(0, (sum, expense) => sum + expense.amount);
});

final salonTotalCommissionTodayProvider = Provider<double>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final today = DateUtils.dateOnly(DateTime.now());
  return sales
      .where((sale) => _isSameDay(sale.soldAt, today))
      .fold<double>(0, (sum, sale) => sum + (sale.commissionAmount ?? 0));
});

final salonTotalCommissionMonthProvider = Provider<double>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final now = DateTime.now();
  return sales
      .where(
        (sale) => sale.reportYear == now.year && sale.reportMonth == now.month,
      )
      .fold<double>(0, (sum, sale) => sum + (sale.commissionAmount ?? 0));
});

final expenseCategoryBreakdownProvider = Provider<List<MoneyCategoryBreakdown>>(
  (ref) {
    final expenses =
        ref.watch(expensesStreamProvider).asData?.value ?? const <Expense>[];
    final now = DateTime.now();
    return _buildCategoryBreakdown(
      expenses.where(
        (expense) =>
            expense.reportYear == now.year && expense.reportMonth == now.month,
      ),
    );
  },
);

final topBarberProvider = Provider<MoneyLeaderboardEntry?>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final now = DateTime.now();
  return _computeTopBarber(
    sales.where(
      (sale) => sale.reportYear == now.year && sale.reportMonth == now.month,
    ),
  );
});

final topServiceProvider = Provider<MoneyLeaderboardEntry?>((ref) {
  final sales = ref.watch(salesStreamProvider).asData?.value ?? const <Sale>[];
  final now = DateTime.now();
  return _computeTopService(
    sales.where(
      (sale) => sale.reportYear == now.year && sale.reportMonth == now.month,
    ),
  );
});

final netProfitThisMonthProvider = Provider<double>((ref) {
  final sales = ref.watch(totalSalesThisMonthProvider);
  final expenses = ref.watch(totalExpensesThisMonthProvider);
  final payroll = ref.watch(_currentMonthPayrollTotalProvider);
  return sales - expenses - payroll;
});

final moneyDashboardSummaryProvider =
    Provider<AsyncValue<MoneyDashboardSummary>>((ref) {
      final month = ref.watch(moneySelectedMonthProvider);
      final now = DateTime.now();
      final selectedIsCurrentMonth =
          month.year == now.year && month.month == now.month;
      final inclusiveEndDay = selectedIsCurrentMonth ? now.day : null;
      final key = (year: month.year, month: month.month);
      final salesAsync = ref.watch(salesByMonthStreamProvider(key));
      final expensesAsync = ref.watch(expensesByMonthStreamProvider(key));
      final payrollAsync = ref.watch(payrollByMonthStreamProvider(key));
      final payslipsAsync = ref.watch(payslipsByMonthStreamProvider(key));

      return _combineAsyncValues<MoneyDashboardSummary>(
        [salesAsync, expensesAsync, payrollAsync, payslipsAsync],
        () {
          return buildMoneyDashboardSummaryForMonth(
            sales: salesAsync.requireValue,
            expenses: expensesAsync.requireValue,
            payroll: payrollAsync.requireValue,
            runPayslips: payslipsAsync.requireValue,
            month: month,
            inclusiveEndDay: inclusiveEndDay,
          );
        },
      );
    });

/// Prior month totals for KPI trend copy (vs Mar, etc.).
///
/// When the selected month is the current calendar month, totals are capped to
/// the same day range as [moneyDashboardSummaryProvider] (like-for-like vs
/// partial month-to-date).
final moneyPreviousMonthSummaryProvider =
    Provider<AsyncValue<MoneyDashboardSummary>>((ref) {
      final month = ref.watch(moneySelectedMonthProvider);
      final now = DateTime.now();
      final selectedIsCurrentMonth =
          month.year == now.year && month.month == now.month;
      final previous = DateTime(month.year, month.month - 1);
      final prevInclusiveEndDay = selectedIsCurrentMonth
          ? math.min(
              now.day,
              DateUtils.getDaysInMonth(previous.year, previous.month),
            )
          : null;
      final prevKey = (year: previous.year, month: previous.month);
      final salesAsync = ref.watch(salesByMonthStreamProvider(prevKey));
      final expensesAsync = ref.watch(expensesByMonthStreamProvider(prevKey));
      final payrollAsync = ref.watch(payrollByMonthStreamProvider(prevKey));
      final payslipsAsync = ref.watch(payslipsByMonthStreamProvider(prevKey));

      return _combineAsyncValues<MoneyDashboardSummary>(
        [salesAsync, expensesAsync, payrollAsync, payslipsAsync],
        () {
          return buildMoneyDashboardSummaryForMonth(
            sales: salesAsync.requireValue,
            expenses: expensesAsync.requireValue,
            payroll: payrollAsync.requireValue,
            runPayslips: payslipsAsync.requireValue,
            month: previous,
            inclusiveEndDay: prevInclusiveEndDay,
          );
        },
      );
    });

final moneyTrendSeriesProvider = Provider<AsyncValue<List<MoneyTrendPoint>>>((
  ref,
) {
  final month = ref.watch(moneySelectedMonthProvider);
  final granularity = ref.watch(moneyChartGranularityProvider);
  final salesAsync = ref.watch(salesStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);

  return _combineAsyncValues<List<MoneyTrendPoint>>(
    [salesAsync, expensesAsync],
    () {
      final sales = salesAsync.requireValue;
      final expenses = expensesAsync.requireValue;
      switch (granularity) {
        case MoneyChartGranularity.daily:
          return _moneyTrendPointsDaily(month, sales, expenses);
        case MoneyChartGranularity.weekly:
          return _moneyTrendPointsWeekly(month, sales, expenses);
        case MoneyChartGranularity.monthly:
          return _moneyTrendPointsMonthly(month, sales, expenses);
        case MoneyChartGranularity.yearly:
          return _moneyTrendPointsYearly(month, sales, expenses);
      }
    },
  );
});

final moneyInsightsProvider = Provider<AsyncValue<List<MoneyDashboardInsight>>>(
  (ref) {
    final summaryAsync = ref.watch(moneyDashboardSummaryProvider);
    return summaryAsync.whenData((summary) {
      final insights = <MoneyDashboardInsight>[];
      if (summary.topBarber != null && summary.topBarber!.amount > 0) {
        insights.add(
          MoneyDashboardInsight(
            kind: MoneyInsightKind.topBarber,
            label: summary.topBarber!.label,
            value: summary.topBarber!.amount.toStringAsFixed(0),
            amount: summary.topBarber!.amount,
          ),
        );
      }
      if (summary.topService != null && summary.topService!.amount > 0) {
        insights.add(
          MoneyDashboardInsight(
            kind: MoneyInsightKind.topService,
            label: summary.topService!.label,
            value: summary.topService!.amount.toStringAsFixed(0),
            amount: summary.topService!.amount,
          ),
        );
      }
      if (summary.categoryBreakdown.isNotEmpty) {
        final first = summary.categoryBreakdown.first;
        insights.add(
          MoneyDashboardInsight(
            kind: MoneyInsightKind.largestExpenseCategory,
            label: first.category,
            value: '${(first.share * 100).round()}%',
            amount: first.amount,
          ),
        );
      }
      return insights.take(3).toList(growable: false);
    });
  },
);

final _currentMonthPayrollTotalProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final key = (year: now.year, month: now.month);
  final payroll = ref
          .watch(payrollByMonthStreamProvider(key))
          .asData
          ?.value ??
      const <PayrollRecord>[];
  final payslips = ref
          .watch(payslipsByMonthStreamProvider(key))
          .asData
          ?.value ??
      const <PayslipModel>[];
  final fromRecords = payroll
      .where((record) => record.status == PayrollStatuses.paid)
      .fold<double>(0, (sum, record) => sum + record.netAmount);
  return fromRecords + _payrollNetFromRunPayslips(payslips);
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
  if (values.any((value) => value.isLoading && !value.hasValue)) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(builder());
}

MoneyLeaderboardEntry? _computeTopBarber(Iterable<Sale> sales) {
  final totals = <String, MoneyLeaderboardEntry>{};
  for (final sale in sales) {
    final id = sale.employeeId.trim().isNotEmpty
        ? sale.employeeId
        : sale.barberId;
    if (id.isEmpty) continue;
    final current = totals[id];
    totals[id] = MoneyLeaderboardEntry(
      id: id,
      label: sale.employeeName.trim().isEmpty ? id : sale.employeeName,
      amount: (current?.amount ?? 0) + sale.total,
    );
  }
  if (totals.isEmpty) return null;
  return totals.values.reduce((best, next) {
    if (next.amount > best.amount) return next;
    return best;
  });
}

MoneyLeaderboardEntry? _computeTopService(Iterable<Sale> sales) {
  final totals = <String, MoneyLeaderboardEntry>{};
  for (final sale in sales) {
    if (sale.lineItems.isEmpty) {
      final label = sale.serviceNames.isEmpty ? '' : sale.serviceNames.first;
      if (label.isEmpty) continue;
      final current = totals[label];
      totals[label] = MoneyLeaderboardEntry(
        id: label,
        label: label,
        amount: (current?.amount ?? 0) + sale.total,
      );
      continue;
    }
    for (final line in sale.lineItems) {
      final key = line.serviceId.trim().isEmpty
          ? line.serviceName
          : line.serviceId;
      if (key.isEmpty) continue;
      final current = totals[key];
      totals[key] = MoneyLeaderboardEntry(
        id: key,
        label: line.serviceName,
        amount: (current?.amount ?? 0) + line.total,
      );
    }
  }
  if (totals.isEmpty) return null;
  return totals.values.reduce((best, next) {
    if (next.amount > best.amount) return next;
    return best;
  });
}

List<MoneyCategoryBreakdown> _buildCategoryBreakdown(
  Iterable<Expense> expenses,
) {
  final totals = <String, double>{};
  var overall = 0.0;
  for (final expense in expenses) {
    final category = expense.category.trim();
    overall += expense.amount;
    totals.update(
      category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  final rows =
      totals.entries
          .map(
            (entry) => MoneyCategoryBreakdown(
              category: entry.key,
              amount: entry.value,
              share: overall <= 0 ? 0 : entry.value / overall,
            ),
          )
          .toList(growable: false)
        ..sort((a, b) => b.amount.compareTo(a.amount));
  return rows;
}

bool _isSameDay(DateTime value, DateTime day) {
  final local = value.toLocal();
  return local.year == day.year &&
      local.month == day.month &&
      local.day == day.day;
}

List<MoneyTrendPoint> _moneyTrendPointsDaily(
  DateTime month,
  List<Sale> sales,
  List<Expense> expenses,
) {
  final y = month.year;
  final m = month.month;
  final daysInMonth = DateUtils.getDaysInMonth(y, m);
  final salesByDay = <DateTime, double>{};
  final expensesByDay = <DateTime, double>{};

  for (final sale in sales) {
    if (sale.status != SaleStatuses.completed) {
      continue;
    }
    if (sale.reportYear != y || sale.reportMonth != m) {
      continue;
    }
    final day = DateUtils.dateOnly(sale.soldAt.toLocal());
    salesByDay.update(
      day,
      (value) => value + sale.total,
      ifAbsent: () => sale.total,
    );
  }

  for (final expense in expenses) {
    if (expense.reportYear != y || expense.reportMonth != m) {
      continue;
    }
    final day = DateUtils.dateOnly(expense.incurredAt.toLocal());
    expensesByDay.update(
      day,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }

  return List<MoneyTrendPoint>.generate(daysInMonth, (index) {
    final date = DateTime(y, m, index + 1);
    return MoneyTrendPoint(
      date: date,
      sales: salesByDay[date] ?? 0,
      expenses: expensesByDay[date] ?? 0,
    );
  }, growable: false);
}

List<MoneyTrendPoint> _moneyTrendPointsWeekly(
  DateTime month,
  List<Sale> sales,
  List<Expense> expenses,
) {
  final y = month.year;
  final m = month.month;
  final totals = <({int wy, int wn}), ({double s, double e})>{};

  void addWeek(DateTime localDay, double saleDelta, double expDelta) {
    final utc = DateTime.utc(localDay.year, localDay.month, localDay.day);
    final spec = isoWeekSpecForUtcDate(utc);
    final key = (wy: spec.weekYear, wn: spec.weekNumber);
    final cur = totals[key] ?? (s: 0.0, e: 0.0);
    totals[key] = (
      s: cur.s + saleDelta,
      e: cur.e + expDelta,
    );
  }

  for (final sale in sales) {
    if (sale.status != SaleStatuses.completed) {
      continue;
    }
    if (sale.reportYear != y || sale.reportMonth != m) {
      continue;
    }
    addWeek(DateUtils.dateOnly(sale.soldAt.toLocal()), sale.total, 0);
  }
  for (final expense in expenses) {
    if (expense.reportYear != y || expense.reportMonth != m) {
      continue;
    }
    addWeek(DateUtils.dateOnly(expense.incurredAt.toLocal()), 0, expense.amount);
  }

  // Include every ISO week that touches the selected month (even with no
  // transactions), so the chart always has multiple X points and matches daily.
  final daysInMonth = DateUtils.getDaysInMonth(y, m);
  final weekKeys = <({int wy, int wn})>[];
  final seenWeeks = <({int wy, int wn})>{};
  for (var day = 1; day <= daysInMonth; day++) {
    final localDay = DateTime(y, m, day);
    final utc = DateTime.utc(localDay.year, localDay.month, localDay.day);
    final spec = isoWeekSpecForUtcDate(utc);
    final key = (wy: spec.weekYear, wn: spec.weekNumber);
    if (seenWeeks.add(key)) {
      weekKeys.add(key);
    }
  }
  weekKeys.sort(
    (a, b) => a.wy != b.wy ? a.wy.compareTo(b.wy) : a.wn.compareTo(b.wn),
  );

  return [
    for (final k in weekKeys)
      MoneyTrendPoint(
        date: isoWeekMondayUtc(k.wy, k.wn),
        sales: totals[k]?.s ?? 0.0,
        expenses: totals[k]?.e ?? 0.0,
      ),
  ];
}

List<MoneyTrendPoint> _moneyTrendPointsMonthly(
  DateTime anchor,
  List<Sale> sales,
  List<Expense> expenses,
) {
  final out = <MoneyTrendPoint>[];
  for (var i = 0; i < 6; i++) {
    final d = DateTime(anchor.year, anchor.month - 5 + i);
    final y = d.year;
    final m = d.month;
    var s = 0.0;
    var e = 0.0;
    for (final sale in sales) {
      if (sale.status != SaleStatuses.completed) {
        continue;
      }
      if (sale.reportYear == y && sale.reportMonth == m) {
        s += sale.total;
      }
    }
    for (final expense in expenses) {
      if (expense.reportYear == y && expense.reportMonth == m) {
        e += expense.amount;
      }
    }
    out.add(MoneyTrendPoint(date: DateTime(y, m), sales: s, expenses: e));
  }
  return out;
}

List<MoneyTrendPoint> _moneyTrendPointsYearly(
  DateTime anchor,
  List<Sale> sales,
  List<Expense> expenses,
) {
  final out = <MoneyTrendPoint>[];
  final endYear = anchor.year;
  for (var i = 0; i < 5; i++) {
    final year = endYear - 4 + i;
    var s = 0.0;
    var e = 0.0;
    for (final sale in sales) {
      if (sale.status != SaleStatuses.completed) {
        continue;
      }
      if (sale.reportYear == year) {
        s += sale.total;
      }
    }
    for (final expense in expenses) {
      if (expense.reportYear == year) {
        e += expense.amount;
      }
    }
    out.add(MoneyTrendPoint(date: DateTime(year), sales: s, expenses: e));
  }
  return out;
}
