import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../application/analytics_actions_controller.dart';
import '../../application/analytics_providers.dart';
import '../widgets/analytics_period_selector.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/top_employee_card.dart';
import '../widgets/top_service_card.dart';

class OwnerAnalyticsScreen extends ConsumerWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final selectedMonth = ref.watch(selectedAnalyticsMonthProvider);
    final analyticsAsync = ref.watch(monthlyAnalyticsProvider);
    final actions = ref.watch(analyticsActionsControllerProvider);

    final monthLabel = DateFormat.yMMM(locale.toString()).format(selectedMonth);

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      appBar: AppBar(
        backgroundColor: FinanceDashboardColors.background,
        foregroundColor: FinanceDashboardColors.textPrimary,
        elevation: 0,
        title: Text(l10n.ownerAnalyticsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            l10n.ownerAnalyticsSubtitle(monthLabel),
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AnalyticsPeriodSelector(
            selectedMonth: selectedMonth,
            onChanged: (m) => ref.read(selectedAnalyticsMonthProvider.notifier).select(m),
            onGenerate: actions.isLoading
                ? null
                : () => ref
                    .read(analyticsActionsControllerProvider.notifier)
                    .generateForMonth(selectedMonth),
          ),
          const SizedBox(height: 16),
          analyticsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(
                  color: FinanceDashboardColors.primaryPurple,
                ),
              ),
            ),
            error: (error, stackTrace) => AppEmptyState(
              title: l10n.ownerAnalyticsErrorTitle,
              message: l10n.ownerAnalyticsErrorMessage,
              icon: Icons.query_stats_rounded,
              compactTypography: true,
              primaryActionLabel: l10n.ownerAnalyticsRetry,
              onPrimaryAction: () => ref.invalidate(monthlyAnalyticsProvider),
            ),
            data: (model) {
              if (model == null) {
                return AppEmptyState(
                  title: l10n.ownerAnalyticsEmptyTitle,
                  message: l10n.ownerAnalyticsEmptyMessage,
                  icon: Icons.insights_rounded,
                  compactTypography: true,
                  primaryActionLabel: l10n.ownerAnalyticsGenerate,
                  onPrimaryAction: actions.isLoading
                      ? null
                      : () => ref
                          .read(analyticsActionsControllerProvider.notifier)
                          .generateForMonth(selectedMonth),
                );
              }

              final gross = formatSalonMoneyWithCode(
                model.grossRevenue,
                currencyCode,
                locale,
              );
              final payroll = formatSalonMoneyWithCode(
                model.payrollCost,
                currencyCode,
                locale,
              );
              final expenses = formatSalonMoneyWithCode(
                model.expensesTotal,
                currencyCode,
                locale,
              );
              final net = formatSalonMoneyWithCode(
                model.netProfit,
                currencyCode,
                locale,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnalyticsSummaryCard(
                    grossRevenue: gross,
                    payrollCost: payroll,
                    expensesTotal: expenses,
                    netProfit: net,
                    salesCount: model.salesCount,
                    bookingsCount: model.bookingsCount,
                    completedBookingsCount: model.completedBookingsCount,
                    averageTicket: formatSalonMoneyWithCode(
                      model.averageTicket,
                      currencyCode,
                      locale,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.ownerAnalyticsTopEmployees,
                    style: const TextStyle(
                      color: FinanceDashboardColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (model.topEmployees.isEmpty)
                    Text(
                      l10n.ownerAnalyticsNoTopEmployees,
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ...model.topEmployees.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TopEmployeeCard(
                          employeeName: e.employeeName,
                          salesTotal: formatSalonMoneyWithCode(
                            e.salesTotal,
                            currencyCode,
                            locale,
                          ),
                          salesCount: e.salesCount,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.ownerAnalyticsTopServices,
                    style: const TextStyle(
                      color: FinanceDashboardColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (model.topServices.isEmpty)
                    Text(
                      l10n.ownerAnalyticsNoTopServices,
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ...model.topServices.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TopServiceCard(
                          serviceName: s.serviceName,
                          revenue: formatSalonMoneyWithCode(
                            s.revenue,
                            currencyCode,
                            locale,
                          ),
                          count: s.count,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

