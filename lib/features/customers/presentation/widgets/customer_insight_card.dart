import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../logic/customer_insights_providers.dart';
import '../../logic/customer_salon_insights.dart';

/// Compact “this month” CRM metrics above the customer list.
class CustomerInsightCard extends ConsumerWidget {
  const CustomerInsightCard({super.key, required this.salonId});

  final String salonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currency = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final async = ref.watch(customerSalonInsightsProvider(salonId));

    return async.when(
      loading: () => _InsightShell(
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: FinanceDashboardColors.primaryPurple,
            ),
          ),
        ),
      ),
      error: (err, _) => _InsightShell(
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.customersInsightsLoadError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => ref.invalidate(
                salonMonthlyCompletedSalesStreamProvider(salonId),
              ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
      data: (CustomerSalonInsights data) => _InsightShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.customersInsightsThisMonth,
                    style: const TextStyle(
                      color: FinanceDashboardColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FinanceDashboardColors.lightPurple.withValues(
                      alpha: 0.85,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FinanceDashboardColors.primaryPurple.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    size: 20,
                    color: FinanceDashboardColors.primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MetricRow(
              label: l10n.customersInsightsNewThisMonth,
              value: '${data.newCustomersThisMonth}',
            ),
            _MetricRow(
              label: l10n.customersInsightsReturningThisMonth,
              value: '${data.returningCustomersThisMonth}',
            ),
            _MetricRow(
              label: l10n.customersInsightsTotalCustomers,
              value: '${data.totalActiveCustomers}',
            ),
            _MetricRow(
              label: l10n.customersInsightsTotalSpent,
              value: formatSalonMoneyWithCode(
                data.totalSpentThisMonth,
                currency,
                locale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightShell extends StatelessWidget {
  const _InsightShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FinanceDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: FinanceDashboardColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
