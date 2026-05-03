import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../logic/money_dashboard_providers.dart';
import '../utils/money_kpi_trend.dart';
import 'finance_insights_card.dart';
import 'finance_month_selector.dart';
import 'finance_quick_actions.dart';
import 'finance_summary_card.dart';
import 'finance_top_header.dart';
import 'sales_expenses_chart_card.dart';
import '../../../../providers/money_currency_providers.dart';

class MoneyDashboardModule extends ConsumerWidget {
  const MoneyDashboardModule({super.key, this.ownerShellHeroEmbedded = false});

  /// When true (owner dashboard Finance tab), the parent shows [OwnerDashboardHeroTabScaffold].
  final bool ownerShellHeroEmbedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final summaryAsync = ref.watch(moneyDashboardSummaryProvider);
    final prevAsync = ref.watch(moneyPreviousMonthSummaryProvider);
    final trendAsync = ref.watch(moneyTrendSeriesProvider);
    final insightsAsync = ref.watch(moneyInsightsProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final isLoading =
        summaryAsync.isLoading ||
        prevAsync.isLoading ||
        trendAsync.isLoading ||
        insightsAsync.isLoading;
    final error =
        summaryAsync.asError ??
        prevAsync.asError ??
        trendAsync.asError ??
        insightsAsync.asError;

    final scroll = ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        ownerShellHeroEmbedded ? 24 : 20,
        20,
        118,
      ),
      children: [
        Text(
          l10n.moneyDashboardTitle,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: FinanceDashboardColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.moneyDashboardSubtitle,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: FinanceDashboardColors.textSecondary,
          ),
        ),
        const SizedBox(height: 22),
        const FinanceMonthSelector(),
        const SizedBox(height: 20),
        if (isLoading)
          const _MoneyDashboardLoadingState()
        else if (error != null)
          AppEmptyState(
            title: l10n.moneyDashboardErrorTitle,
            message: l10n.moneyDashboardErrorMessage,
            icon: AppIcons.query_stats_rounded,
            compactTypography: true,
            primaryActionLabel: l10n.moneyDashboardRetry,
            onPrimaryAction: () {
              ref.invalidate(moneyDashboardSummaryProvider);
              ref.invalidate(moneyPreviousMonthSummaryProvider);
              ref.invalidate(moneyTrendSeriesProvider);
              ref.invalidate(moneyInsightsProvider);
            },
          )
        else
          _MoneyDashboardLoadedBody(
            l10n: l10n,
            locale: locale,
            currencyCode: currencyCode,
            summary: summaryAsync.requireValue,
            previous: prevAsync.requireValue,
            trendPoints: trendAsync.requireValue,
            insights: insightsAsync.requireValue,
            onSummaryMenu: () => _showFinanceSummaryMenu(context),
          ),
      ],
    );

    if (!ownerShellHeroEmbedded) {
      final user = ref.watch(sessionUserProvider).asData?.value;
      return ColoredBox(
        color: FinanceDashboardColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null) FinanceTopHeader(user: user),
              Expanded(child: scroll),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: FinanceDashboardColors.background,
      child: SafeArea(top: false, child: scroll),
    );
  }
}

void _showFinanceSummaryMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(ctx)!.moneyDashboardSummaryHeadline,
            style: Theme.of(
              ctx,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(ctx)!.moneyDashboardSubtitle,
            style: Theme.of(ctx).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _MoneyDashboardLoadedBody extends StatelessWidget {
  const _MoneyDashboardLoadedBody({
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.summary,
    required this.previous,
    required this.trendPoints,
    required this.insights,
    required this.onSummaryMenu,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;
  final MoneyDashboardSummary summary;
  final MoneyDashboardSummary previous;
  final List<MoneyTrendPoint> trendPoints;
  final List<MoneyDashboardInsight> insights;
  final VoidCallback onSummaryMenu;

  @override
  Widget build(BuildContext context) {
    final prevMonthLabel = DateFormat.MMM(
      locale.toString(),
    ).format(previous.month);

    final salesTrend = buildMoneyKpiTrendLine(
      kind: MoneyKpiTrendKind.sales,
      current: summary.salesTotal,
      previous: previous.salesTotal,
      previousMonthAbbrev: prevMonthLabel,
      l10n: l10n,
    );
    final expTrend = buildMoneyKpiTrendLine(
      kind: MoneyKpiTrendKind.expenses,
      current: summary.expensesTotal,
      previous: previous.expensesTotal,
      previousMonthAbbrev: prevMonthLabel,
      l10n: l10n,
    );
    final payTrend = buildMoneyKpiTrendLine(
      kind: MoneyKpiTrendKind.payroll,
      current: summary.payrollTotal,
      previous: previous.payrollTotal,
      previousMonthAbbrev: prevMonthLabel,
      l10n: l10n,
    );
    final netTrend = buildMoneyKpiTrendLine(
      kind: MoneyKpiTrendKind.netProfit,
      current: summary.netProfit,
      previous: previous.netProfit,
      previousMonthAbbrev: prevMonthLabel,
      l10n: l10n,
    );

    final insightLines = <String>[
      for (final i in insights) _localizeInsightAction(l10n, locale, i),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceSummaryCard(
          monthTitle: DateFormat.yMMMM(locale.toString()).format(summary.month),
          salesLabel: l10n.moneyDashboardSalesTotal,
          expensesLabel: l10n.moneyDashboardExpensesTotal,
          payrollLabel: l10n.moneyDashboardPayrollTotal,
          netLabel: l10n.moneyDashboardNetProfit,
          salesValue: formatAppMoney(summary.salesTotal, currencyCode, locale),
          expensesValue: formatAppMoney(
            summary.expensesTotal,
            currencyCode,
            locale,
          ),
          payrollValue: formatAppMoney(
            summary.payrollTotal,
            currencyCode,
            locale,
          ),
          netValue: formatAppMoney(summary.netProfit, currencyCode, locale),
          salesTrend: salesTrend.label,
          expensesTrend: expTrend.label,
          payrollTrend: payTrend.label,
          netTrend: netTrend.label,
          salesTrendColor: salesTrend.color,
          expensesTrendColor: expTrend.color,
          payrollTrendColor: payTrend.color,
          netTrendColor: netTrend.color,
          netProfitIcon: summary.netProfit >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          netProfitIconColor: summary.netProfit >= 0
              ? null
              : FinanceDashboardColors.expensePink,
          netProfitIconBackground: summary.netProfit >= 0
              ? null
              : FinanceDashboardColors.expensePinkSoft,
          netLossWarning: summary.netProfit < 0
              ? l10n.moneyDashboardNetLossWarning
              : null,
          onMorePressed: onSummaryMenu,
        ),
        const SizedBox(height: 20),
        SalesExpensesChartCard(
          points: trendPoints,
          title: l10n.moneyDashboardTrendTitle,
          salesLegend: l10n.moneyDashboardSalesLegend,
          expensesLegend: l10n.moneyDashboardExpensesLegend,
          locale: locale,
        ),
        const SizedBox(height: 20),
        FinanceInsightsCard(
          title: l10n.moneyDashboardInsightsTitle,
          insightLines: insightLines,
          emptyMessage: l10n.moneyDashboardInsightsEmpty,
        ),
        const SizedBox(height: 16),
        FinanceQuickActions(
          payrollTitle: l10n.payrollDashboardTitle,
          payrollSubtitle: l10n.moneyDashboardQuickPayrollSubtitle,
          salesTitle: l10n.salesScreenTitle,
          salesSubtitle: l10n.moneyDashboardQuickSalesBody,
          expensesTitle: l10n.expensesScreenTitle,
          expensesSubtitle: l10n.moneyDashboardQuickExpensesBody,
          onPayroll: () =>
              context.push('${AppRoutes.ownerPayroll}?from=finance'),
          onSales: () => context.push(AppRoutes.ownerSales),
          onExpenses: () => context.push(AppRoutes.ownerExpenses),
        ),
      ],
    );
  }
}

class _MoneyDashboardLoadingState extends StatelessWidget {
  const _MoneyDashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AppSkeletonBlock(height: 200),
        SizedBox(height: 20),
        AppSkeletonBlock(height: 280),
        SizedBox(height: 20),
        AppSkeletonBlock(height: 120),
        SizedBox(height: 20),
        AppSkeletonBlock(height: 88),
      ],
    );
  }
}

String _localizeInsightAction(
  AppLocalizations l10n,
  Locale locale,
  MoneyDashboardInsight insight,
) {
  final amountText = NumberFormat.compact(
    locale: locale.toString(),
  ).format(insight.amount ?? 0);
  switch (insight.kind) {
    case MoneyInsightKind.topBarber:
      return l10n.moneyDashboardInsightActionTopBarber(
        insight.label,
        amountText,
      );
    case MoneyInsightKind.topService:
      return l10n.moneyDashboardInsightActionTopService(
        insight.label,
        amountText,
      );
    case MoneyInsightKind.largestExpenseCategory:
      final label = insight.label.trim().isEmpty
          ? l10n.moneyDashboardUncategorized
          : insight.label;
      return l10n.moneyDashboardInsightActionExpenseCategory(
        label,
        insight.value,
      );
  }
}
