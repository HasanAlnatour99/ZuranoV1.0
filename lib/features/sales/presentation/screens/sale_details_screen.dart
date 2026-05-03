import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/sale_payment_method_localized.dart';
import '../../../../core/formatting/sale_status_localized.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';
import '../utils/sale_customer_display.dart';
import '../../logic/sale_details_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../providers/money_currency_providers.dart';

class SaleDetailsScreen extends ConsumerWidget {
  const SaleDetailsScreen({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final saleAsync = ref.watch(saleDetailsProvider(saleId));

    return Scaffold(
      appBar: AppPageHeader(title: Text(l10n.salesDetailsTitle)),
      body: saleAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.salesScreenErrorTitle,
              message: l10n.salesScreenErrorMessage,
              icon: AppIcons.receipt_long_outlined,
              centerContent: true,
            ),
          ),
        ),
        data: (sale) {
          if (sale == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: AppEmptyState(
                  title: l10n.salesDetailsNotFoundTitle,
                  message: l10n.salesDetailsNotFoundMessage,
                  icon: AppIcons.find_in_page_outlined,
                  centerContent: true,
                ),
              ),
            );
          }

          return AppMotionPlayback(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large + 32,
              ),
              children: [
                AppEntranceMotion(
                  motionId: 'sale-details-summary-$saleId',
                  child: _SaleHeroCard(
                    sale: sale,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppEntranceMotion(
                  motionId: 'sale-details-overview-$saleId',
                  index: 1,
                  child: _OverviewCard(
                    sale: sale,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppEntranceMotion(
                  motionId: 'sale-details-lines-$saleId',
                  index: 2,
                  child: _LineItemsCard(
                    sale: sale,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SaleHeroCard extends StatelessWidget {
  const _SaleHeroCard({
    required this.sale,
    required this.currencyCode,
    required this.locale,
  });

  final Sale sale;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatAppMoney(sale.total, currencyCode, locale),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.small / 2),
          Text(
            DateFormat.yMMMMEEEEd(
              locale.toString(),
            ).add_jm().format(sale.soldAt.toLocal()),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              _HeroChip(
                label:
                    '${l10n.salesDetailsStatusLabel}: ${localizedSaleStatus(l10n, sale.status)}',
              ),
              _HeroChip(
                label:
                    '${l10n.salesDetailsPaymentLabel}: ${localizedSalePaymentMethod(l10n, sale.paymentMethod)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.sale,
    required this.currencyCode,
    required this.locale,
  });

  final Sale sale;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.salesDetailsOverviewTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(
            label: l10n.salesDetailsCustomerLabel,
            value: visibleSaleCustomerName(sale),
          ),
          _DetailRow(
            label: l10n.salesScreenBarberFilter,
            value: formatTeamMemberName(sale.employeeName),
          ),
          _DetailRow(
            label: l10n.salesDetailsRecordedByLabel,
            value: _valueOrDash(sale.createdByName),
          ),
          _DetailRow(
            label: l10n.salesDetailsSoldAtLabel,
            value: DateFormat.yMMMd(
              locale.toString(),
            ).add_jm().format(sale.soldAt.toLocal()),
          ),
          _DetailRow(
            label: l10n.salesDetailsSubtotalLabel,
            value: formatAppMoney(sale.subtotal, currencyCode, locale),
          ),
          _DetailRow(
            label: l10n.salesDetailsTaxLabel,
            value: formatAppMoney(sale.tax, currencyCode, locale),
          ),
          _DetailRow(
            label: l10n.salesDetailsDiscountLabel,
            value: formatAppMoney(sale.discount, currencyCode, locale),
          ),
          _DetailRow(
            label: l10n.salesDetailsCommissionLabel,
            value: sale.commissionAmount == null
                ? '—'
                : formatAppMoney(sale.commissionAmount!, currencyCode, locale),
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _valueOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '—' : trimmed;
  }
}

class _LineItemsCard extends StatelessWidget {
  const _LineItemsCard({
    required this.sale,
    required this.currencyCode,
    required this.locale,
  });

  final Sale sale;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = sale.lineItems;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.salesDetailsLineItemsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.medium),
          if (items.isEmpty)
            Text(l10n.salesScreenUnknownService)
          else
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const Divider(height: AppSpacing.large),
              _LineItemRow(
                item: items[index],
                currencyCode: currencyCode,
                locale: locale,
              ),
            ],
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({
    required this.item,
    required this.currencyCode,
    required this.locale,
  });

  final SaleLineItem item;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.serviceName.trim().isEmpty
                    ? AppLocalizations.of(context)!.salesScreenUnknownService
                    : item.serviceName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatTeamMemberName(item.employeeName)} · ${item.quantity} x ${formatAppMoney(item.unitPrice, currencyCode, locale)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Text(
          formatAppMoney(item.total, currencyCode, locale),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.medium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
