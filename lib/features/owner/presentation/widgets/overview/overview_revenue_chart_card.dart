import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../logic/owner_overview_revenue_chart_period_notifier.dart';
import '../../../logic/owner_overview_state.dart';
import 'dashboard_section_card.dart';
import 'overview_design_tokens.dart';

/// Completed-sales revenue line chart: **day** (24h), rolling **week**, or **month**.
class OverviewRevenueChartCard extends ConsumerWidget {
  const OverviewRevenueChartCard({
    super.key,
    required this.state,
    required this.locale,
  });

  final OwnerOverviewState state;
  final Locale locale;

  static const double _chartHeight = 132;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final period = ref.watch(ownerOverviewRevenueChartPeriodProvider);
    final periodNotifier =
        ref.read(ownerOverviewRevenueChartPeriodProvider.notifier);

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final List<double> series;
    double totalLabelAmount;
    String title;
    String subtitle;
    String totalCaption;
    String emptyCaption;
    int maxXIndex;

    if (period == OwnerOverviewRevenueChartPeriod.month) {
      series =
          state.currentMonthDailyRevenue.length == daysInMonth
              ? List<double>.from(state.currentMonthDailyRevenue)
              : List<double>.generate(
                  daysInMonth,
                  (int i) =>
                      i < state.currentMonthDailyRevenue.length
                          ? state.currentMonthDailyRevenue[i]
                          : 0,
                );
      totalLabelAmount = state.monthRevenue;
      title = l10n.ownerOverviewRevenueMonthLabel;
      subtitle = l10n.ownerOverviewRevenueMonthSubtitle;
      totalCaption =
          l10n.ownerOverviewRevenueMonthTotal(
            formatAppMoney(totalLabelAmount, state.currencyCode, locale),
          );
      emptyCaption = l10n.ownerOverviewRevenueMonthEmpty;
      maxXIndex = series.length > 1 ? series.length - 1 : 0;
    } else if (period == OwnerOverviewRevenueChartPeriod.week) {
      series = state.last7DaysDailyRevenue.length == 7
          ? List<double>.from(state.last7DaysDailyRevenue)
          : List<double>.filled(7, 0);
      totalLabelAmount = series.fold<double>(0, (double a, double b) => a + b);
      title = l10n.ownerOverviewRevenueThisWeekTitle;
      subtitle = l10n.ownerOverviewRevenueThisWeekSubtitle;
      totalCaption = l10n.ownerOverviewRevenueThisWeekTotal(
        formatAppMoney(totalLabelAmount, state.currencyCode, locale),
      );
      emptyCaption = l10n.ownerOverviewRevenueThisWeekEmpty;
      maxXIndex = 6;
    } else {
      series = state.todayHourlyRevenue.length == 24
          ? List<double>.from(state.todayHourlyRevenue)
          : List<double>.filled(24, 0);
      totalLabelAmount = state.todayRevenue;
      title = l10n.ownerOverviewRevenueTodayByHourTitle;
      subtitle = l10n.ownerOverviewRevenueTodayByHourSubtitle;
      totalCaption = l10n.ownerOverviewRevenueTodayByHourTotal(
        formatAppMoney(totalLabelAmount, state.currencyCode, locale),
      );
      emptyCaption = l10n.ownerOverviewRevenueTodayByHourEmpty;
      maxXIndex = 23;
    }

    final hasRevenue = series.any((double value) => value > 0);
    final maxY = series.isEmpty
        ? 0.0
        : series.reduce((double a, double b) => a > b ? a : b);
    final top = maxY <= 0 ? 1.0 : maxY * 1.15;
    final spots = <FlSpot>[
      for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i]),
    ];

    final isMonth = period == OwnerOverviewRevenueChartPeriod.month;
    final isWeek = period == OwnerOverviewRevenueChartPeriod.week;
    final isDay = period == OwnerOverviewRevenueChartPeriod.day;

    return DashboardSectionCard(
      margin: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 16),
      useStatCardStyle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: OwnerOverviewTypography.chartTitle,
                        fontWeight: FontWeight.w900,
                        color: OwnerOverviewTokens.textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        fontSize: OwnerOverviewTypography.chartSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Flexible(
                child: Text(
                  totalCaption,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: OwnerOverviewTypography.chartBadge,
                    fontWeight: FontWeight.w800,
                    color: OwnerOverviewTokens.purple,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Center(
            child: SegmentedButton<OwnerOverviewRevenueChartPeriod>(
              showSelectedIcon: false,
              segments: <ButtonSegment<OwnerOverviewRevenueChartPeriod>>[
                ButtonSegment<OwnerOverviewRevenueChartPeriod>(
                  value: OwnerOverviewRevenueChartPeriod.day,
                  label: Text(l10n.ownerOverviewRevenuePeriodDay),
                ),
                ButtonSegment<OwnerOverviewRevenueChartPeriod>(
                  value: OwnerOverviewRevenueChartPeriod.week,
                  label: Text(l10n.ownerOverviewRevenuePeriodWeek),
                ),
                ButtonSegment<OwnerOverviewRevenueChartPeriod>(
                  value: OwnerOverviewRevenueChartPeriod.month,
                  label: Text(l10n.ownerOverviewRevenuePeriodMonth),
                ),
              ],
              selected: <OwnerOverviewRevenueChartPeriod>{period},
              onSelectionChanged: (Set<OwnerOverviewRevenueChartPeriod> next) {
                periodNotifier.setPeriod(next.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF5B21B6);
                  }
                  return Colors.grey.shade600;
                }),
                backgroundColor:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFF4ECFF);
                  }
                  return Colors.white;
                }),
              ),
            ),
          ),
          const Gap(14),
          SizedBox(
            height: _chartHeight,
            child: hasRevenue
                ? LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: math.max(0, maxXIndex).toDouble(),
                      minY: 0,
                      maxY: top,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: scheme.outlineVariant.withValues(alpha: 0.45),
                          strokeWidth: 0.8,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isMonth
                                ? 24
                                : isDay
                                ? 26
                                : 22,
                            interval: isMonth && series.length > 14
                                ? 5
                                : 1,
                            getTitlesWidget: (double value, TitleMeta _) {
                              final index = value.round().clamp(
                                0,
                                series.length - 1,
                              );
                              if (isMonth) {
                                if (series.length > 14 &&
                                    index % 5 != 0 &&
                                    index != 0 &&
                                    index != series.length - 1) {
                                  return const SizedBox.shrink();
                                }
                              }
                              if (isDay) {
                                if (index % 4 != 0 && index != 23) {
                                  return const SizedBox.shrink();
                                }
                              }
                              String label;
                              if (isMonth) {
                                final day = DateTime(
                                  now.year,
                                  now.month,
                                  index + 1,
                                );
                                label = DateFormat.d(
                                  locale.toString(),
                                ).format(day);
                              } else if (isWeek) {
                                final day =
                                    now.subtract(Duration(days: 6 - index));
                                label = DateFormat.E(
                                  locale.toString(),
                                ).format(day);
                              } else {
                                final atHour = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  index,
                                );
                                label = DateFormat.j(
                                  locale.toString(),
                                ).format(atHour);
                              }
                              return Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 6),
                                child: Text(
                                  label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontSize:
                                            OwnerOverviewTypography.chartAxis,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems:
                              (List<LineBarSpot> spots) =>
                                  spots.map((LineBarSpot s) {
                                  final formatted = formatAppMoney(
                                    s.y,
                                    state.currencyCode,
                                    locale,
                                  );
                                  String line;
                                  if (isMonth) {
                                    final day = DateTime(
                                      now.year,
                                      now.month,
                                      s.spotIndex + 1,
                                    );
                                    line =
                                        '${DateFormat.MMMd(locale.toString()).format(day)} · $formatted';
                                  } else if (isWeek) {
                                    final day = now.subtract(
                                      Duration(days: 6 - s.spotIndex),
                                    );
                                    line =
                                        '${DateFormat.MMMEd(locale.toString()).format(day)} · $formatted';
                                  } else {
                                    final atHour = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      s.spotIndex,
                                    );
                                    line =
                                        '${DateFormat.jm(locale.toString()).format(atHour)} · $formatted';
                                  }
                                  return LineTooltipItem(
                                    line,
                                    TextStyle(
                                      color: scheme.onInverseSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          OwnerOverviewTypography.chartTooltip,
                                    ),
                                  );
                                }).toList(),
                        ),
                      ),
                      lineBarsData: <LineChartBarData>[
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: OwnerOverviewTokens.purple,
                          barWidth: isMonth
                              ? 2.2
                              : isDay
                              ? 2
                              : 3,
                          dotData: FlDotData(
                            show: isWeek,
                            getDotPainter: (
                              FlSpot spot,
                              double xPct,
                              LineChartBarData bar,
                              int i,
                            ) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: OwnerOverviewTokens.purple,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                OwnerOverviewTokens.purple.withValues(
                                  alpha: 0.2,
                                ),
                                OwnerOverviewTokens.purple.withValues(
                                  alpha: 0.02,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.show_chart,
                          color: OwnerOverviewTokens.purple.withValues(
                            alpha: 0.42,
                          ),
                          size: 30,
                        ),
                        const Gap(8),
                        Text(
                          emptyCaption,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        OwnerOverviewTypography.chartSubtitle,
                                  ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
