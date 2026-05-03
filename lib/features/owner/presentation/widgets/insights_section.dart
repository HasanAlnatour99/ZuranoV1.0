import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/insights/data/models/salon_insight.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart'
    show insightsStreamProvider;
import '../../../../providers/money_currency_providers.dart';

class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key});

  static String _valueLabel(
    SalonInsight insight,
    String currencyCode,
    Locale locale,
  ) {
    switch (insight.type) {
      case SalonInsightTypes.topBarberRevenue:
      case SalonInsightTypes.weekTotalRevenue:
        return formatAppMoney(insight.value, currencyCode, locale);
      case SalonInsightTypes.busiestDay:
        return '${insight.value.round()}';
      default:
        return '${insight.value}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final insightsAsync = ref.watch(insightsStreamProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ownerInsightsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.ownerInsightsSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        insightsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(l10n.ownerInsightsError),
          data: (insights) {
            final weekly = insights
                .where(
                  (e) => SalonInsightTypes.weeklyBusinessTypes.contains(e.type),
                )
                .toList();
            if (weekly.isEmpty) {
              return Text(
                l10n.ownerInsightsEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              children: weekly.map((insight) {
                final valueText = _valueLabel(insight, currencyCode, locale);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: Card(
                    child: ListTile(
                      title: Text(insight.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(insight.message),
                          if (insight.weekKey != null &&
                              insight.weekKey!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              insight.weekKey!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        valueText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
