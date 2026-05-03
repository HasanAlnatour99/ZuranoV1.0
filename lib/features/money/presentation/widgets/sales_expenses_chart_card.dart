import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/money_dashboard_providers.dart';
import 'premium_finance_card.dart';

class SalesExpensesChartCard extends ConsumerWidget {
  const SalesExpensesChartCard({
    super.key,
    required this.points,
    required this.title,
    required this.salesLegend,
    required this.expensesLegend,
    required this.locale,
  });

  final List<MoneyTrendPoint> points;
  final String title;
  final String salesLegend;
  final String expensesLegend;
  final Locale locale;

  /// Spacing for bottom X labels so fl_chart does not build one child per day
  /// (which overlaps on narrow screens). Targets about six ticks across the span.
  static double _xAxisBottomInterval(int pointCount) {
    if (pointCount <= 1) return 1;
    final span = pointCount - 1;
    const maxTicks = 6;
    return math.max(1.0, (span / (maxTicks - 1)).ceilToDouble());
  }

  static String _trendSubtitle(
    AppLocalizations l10n,
    MoneyChartGranularity g,
  ) {
    return switch (g) {
      MoneyChartGranularity.daily => l10n.moneyDashboardTrendSubtitleDaily,
      MoneyChartGranularity.weekly => l10n.moneyDashboardTrendSubtitleWeekly,
      MoneyChartGranularity.monthly => l10n.moneyDashboardTrendSubtitleMonthly,
      MoneyChartGranularity.yearly => l10n.moneyDashboardTrendSubtitleYearly,
    };
  }

  static String _granularityLabel(
    AppLocalizations l10n,
    MoneyChartGranularity g,
  ) {
    return switch (g) {
      MoneyChartGranularity.daily => l10n.moneyDashboardChartGranularityDaily,
      MoneyChartGranularity.weekly =>
        l10n.moneyDashboardChartGranularityWeekly,
      MoneyChartGranularity.monthly =>
        l10n.moneyDashboardChartGranularityMonthly,
      MoneyChartGranularity.yearly =>
        l10n.moneyDashboardChartGranularityYearly,
    };
  }

  static String _formatPointDate(
    Locale locale,
    MoneyChartGranularity g,
    DateTime date,
  ) {
    final loc = locale.toString();
    switch (g) {
      case MoneyChartGranularity.daily:
      case MoneyChartGranularity.weekly:
        return DateFormat.MMMd(loc).format(date);
      case MoneyChartGranularity.monthly:
        return DateFormat.yMMM(loc).format(date);
      case MoneyChartGranularity.yearly:
        return DateFormat.y(loc).format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final g = ref.watch(moneyChartGranularityProvider);
    final n = points.length;
    if (n == 0) {
      return const SizedBox.shrink();
    }

    final salesSpots = <FlSpot>[
      for (var i = 0; i < n; i++) FlSpot(i.toDouble(), points[i].sales),
    ];
    final expensesSpots = <FlSpot>[
      for (var i = 0; i < n; i++) FlSpot(i.toDouble(), points[i].expenses),
    ];

    var maxVal = 0.0;
    for (final p in points) {
      if (p.sales > maxVal) maxVal = p.sales;
      if (p.expenses > maxVal) maxVal = p.expenses;
    }
    // Avoid forcing a huge Y floor (old clamp to 800): small totals vanished
    // near the baseline. When everything is zero, keep a small range so the
    // flat line is still visible above the axis.
    final maxY = maxVal <= 0
        ? 1.0
        : math.max(maxVal * 1.15, 1e-9);

    final bottomInterval = _xAxisBottomInterval(n);

    return PremiumFinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FinanceDashboardColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _trendSubtitle(l10n, g),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<MoneyChartGranularity>(
                tooltip: l10n.moneyDashboardChartGranularityPickerTitle,
                onSelected: (value) => ref
                    .read(moneyChartGranularityProvider.notifier)
                    .select(value),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: MoneyChartGranularity.daily,
                    child: Text(l10n.moneyDashboardChartGranularityDaily),
                  ),
                  PopupMenuItem(
                    value: MoneyChartGranularity.weekly,
                    child: Text(l10n.moneyDashboardChartGranularityWeekly),
                  ),
                  PopupMenuItem(
                    value: MoneyChartGranularity.monthly,
                    child: Text(l10n.moneyDashboardChartGranularityMonthly),
                  ),
                  PopupMenuItem(
                    value: MoneyChartGranularity.yearly,
                    child: Text(l10n.moneyDashboardChartGranularityYearly),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: FinanceDashboardColors.lightPurple.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FinanceDashboardColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _granularityLabel(l10n, g),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FinanceDashboardColors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: FinanceDashboardColors.deepPurple.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (n - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: FinanceDashboardColors.border.withValues(
                      alpha: 0.65,
                    ),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > maxY + 0.01) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          NumberFormat.compact(
                            locale: locale.toString(),
                          ).format(value),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: FinanceDashboardColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: bottomInterval,
                      getTitlesWidget: (value, meta) {
                        final i = value.round().clamp(0, n - 1);
                        final d = points[i].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _formatPointDate(locale, g, d),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: FinanceDashboardColors.textSecondary,
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
                    getTooltipItems: (touchedSpots) {
                      return [
                        for (final s in touchedSpots)
                          LineTooltipItem(
                            '${_formatPointDate(locale, g, points[s.x.toInt().clamp(0, n - 1)].date)}\n'
                            '${NumberFormat.compact(locale: locale.toString()).format(s.y)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                      ];
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: salesSpots,
                    isCurved: true,
                    curveSmoothness: 0.28,
                    barWidth: 3,
                    color: FinanceDashboardColors.primaryPurple,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FinanceDashboardColors.primaryPurple.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: expensesSpots,
                    isCurved: true,
                    curveSmoothness: 0.28,
                    barWidth: 2.2,
                    color: FinanceDashboardColors.expensePink,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FinanceDashboardColors.expensePink.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _LegendDot(
                color: FinanceDashboardColors.primaryPurple,
                label: salesLegend,
              ),
              _LegendDot(
                color: FinanceDashboardColors.expensePink,
                label: expensesLegend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FinanceDashboardColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
