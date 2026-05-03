import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../application/providers/team_member_sales_providers.dart';
import '../../data/models/employee_sales_query.dart';
import '../../data/models/sales_date_filter.dart';
import '../../data/models/team_sales_insight_request.dart';
import '../widgets/sales_date_filter_bar.dart';
import '../widgets/sales_empty_state_card.dart';
import '../widgets/sales_history_card.dart';
import '../widgets/sales_history_empty_card.dart';
import '../widgets/sales_kpi_card.dart';
import '../widgets/sales_section_tile.dart';
import '../widgets/team_sales_smart_summary_card.dart';
import '../widgets/top_sold_services_card.dart';
import '../theme/team_member_profile_colors.dart';
import '../../../../l10n/app_localizations.dart';

class TeamMemberSalesTab extends ConsumerWidget {
  const TeamMemberSalesTab({
    super.key,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.currencyCode,
    required this.onAddSale,
  });

  final String salonId;
  final String employeeId;
  final String employeeName;
  final String currencyCode;
  final VoidCallback onAddSale;

  static bool _sameLocalDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  String _filterSummaryLabel(
    AppLocalizations l10n,
    Locale locale,
    SalesDateFilter f,
  ) {
    switch (f.kind) {
      case SalesDateFilterKind.thisMonth:
        return l10n.teamMemberSalesFilterThisMonth;
      case SalesDateFilterKind.today:
        return l10n.teamMemberSalesFilterToday;
      case SalesDateFilterKind.thisWeek:
        return l10n.teamMemberSalesFilterThisWeek;
      case SalesDateFilterKind.custom:
        final start = f.startInclusive;
        final endInclusive = f.endExclusive.subtract(const Duration(days: 1));
        final fmt = DateFormat.yMMMd(locale.toString());
        return '${fmt.format(start)} – ${fmt.format(endInclusive)}';
    }
  }

  static String _salesErrorMessage(Object error, AppLocalizations l10n) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return l10n.teamMemberSalesPermissionDenied;
    }
    return l10n.teamMemberSalesLoadError;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final query = EmployeeSalesQuery(
      salonId: salonId,
      employeeId: employeeId,
      employeeName: employeeName,
    );

    final historyAsync = ref.watch(teamMemberHistorySalesStreamProvider(query));
    final kpiAsync = ref.watch(teamMemberKpiSalesStreamProvider(query));
    final summary = ref.watch(teamMemberSalesSummaryProvider(query));
    final filter = ref.watch(teamSalesDateFilterProvider);

    final insightRequest = TeamSalesInsightRequest(
      query: query,
      historyStart: filter.startInclusive,
      historyEndExclusive: filter.endExclusive,
    );
    final insightAsync = ref.watch(
      teamMemberSalesInsightProvider(insightRequest),
    );

    if (historyAsync.isLoading || kpiAsync.isLoading) {
      return const ColoredBox(
        color: TeamMemberProfileColors.canvas,
        child: Center(
          child: CircularProgressIndicator(
            color: TeamMemberProfileColors.primary,
          ),
        ),
      );
    }

    if (historyAsync.hasError || kpiAsync.hasError) {
      final err = historyAsync.error ?? kpiAsync.error!;
      return ColoredBox(
        color: TeamMemberProfileColors.canvas,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _salesErrorMessage(err, l10n),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TeamMemberProfileColors.textSecondary,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ),
      );
    }

    final historySales = historyAsync.requireValue;
    final kpiSales = kpiAsync.requireValue;
    final now = DateTime.now();
    final noSalesToday = !kpiSales.any((s) => _sameLocalDay(s.soldAt, now));
    final showBigTodayEmpty =
        noSalesToday && filter.kind != SalesDateFilterKind.custom;
    final historyTotal = historySales.fold<double>(
      0,
      (sum, s) => sum + s.total,
    );

    return ColoredBox(
      color: TeamMemberProfileColors.canvas,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  children: [
                    SalesKpiCard(
                      icon: Icons.attach_money_rounded,
                      title: l10n.teamSalesRevenueToday,
                      value: formatMoney(
                        summary.revenueToday,
                        currencyCode,
                        locale,
                      ),
                    ),
                    SalesKpiCard(
                      icon: Icons.calendar_month_rounded,
                      title: l10n.teamSalesRevenueWeek,
                      value: formatMoney(
                        summary.revenueThisWeek,
                        currencyCode,
                        locale,
                      ),
                    ),
                    SalesKpiCard(
                      icon: Icons.event_note_rounded,
                      title: l10n.teamSalesRevenueMonth,
                      value: formatMoney(
                        summary.revenueThisMonth,
                        currencyCode,
                        locale,
                      ),
                    ),
                    SalesKpiCard(
                      icon: Icons.content_cut_rounded,
                      title: l10n.teamSalesServicesToday,
                      value: '${summary.servicesToday}',
                    ),
                    SalesKpiCard(
                      icon: Icons.bar_chart_rounded,
                      title: l10n.teamSalesServicesMonth,
                      value: '${summary.servicesThisMonth}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (showBigTodayEmpty)
                  SalesEmptyStateCard(
                    title: l10n.teamNoSalesTodayTitle,
                    subtitle: l10n.teamNoSalesTodaySubtitle,
                    actionLabel: l10n.teamMemberAddSaleAction,
                    onAddSale: onAddSale,
                  ),
                if (showBigTodayEmpty) const SizedBox(height: 16),
                TopSoldServicesCard(
                  services: summary.topSoldServices,
                  currencyCode: currencyCode,
                ),
                const SizedBox(height: 12),
                SalesSectionTile(
                  icon: Icons.confirmation_number_outlined,
                  title: l10n.teamSalesAverageTicketTitle,
                  subtitle: summary.averageTicketValue == 0
                      ? l10n.teamMemberSalesNotAvailableShort
                      : formatMoney(
                          summary.averageTicketValue,
                          currencyCode,
                          locale,
                        ),
                  trailing: const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                insightAsync.when(
                  data: (insight) {
                    if (insight == null || !insight.hasDisplayableContent) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TeamSalesSmartSummaryCard(insight: insight),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.teamMemberSalesHistoryTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: TeamMemberProfileColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TeamMemberProfileColors.softPurple,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: TeamMemberProfileColors.border,
                        ),
                      ),
                      child: Text(
                        l10n.teamMemberSalesShowing(
                          _filterSummaryLabel(l10n, locale, filter),
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TeamMemberProfileColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TeamMemberProfileColors.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: TeamMemberProfileColors.border,
                        ),
                      ),
                      child: Text(
                        l10n.teamMemberSalesHistoryTotal(
                          formatMoney(historyTotal, currencyCode, locale),
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: TeamMemberProfileColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SalesDateFilterBar(),
                const SizedBox(height: 12),
                if (historySales.isEmpty)
                  SalesHistoryEmptyCard(
                    title: l10n.teamMemberSalesEmptyHistoryTitle,
                    subtitle: l10n.teamMemberSalesEmptyHistorySubtitle,
                  )
                else
                  ...historySales.map(
                    (sale) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SalesHistoryCard(
                        sale: sale,
                        currencyCode: currencyCode,
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
