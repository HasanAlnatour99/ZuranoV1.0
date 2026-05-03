import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/sale_payment_method_localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';

class RecentSalesCard extends StatelessWidget {
  const RecentSalesCard({
    super.key,
    required this.sales,
    required this.currencyCode,
    required this.locale,
    required this.title,
    required this.viewAllLabel,
    required this.emptyTitle,
    required this.emptyMessage,
    this.onViewAll,
    this.maxItems = 8,
  });

  final List<Sale> sales;
  final String currencyCode;
  final Locale locale;
  final String title;
  final String viewAllLabel;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onViewAll;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slice = sales.take(maxItems).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FinanceDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: FinanceDashboardColors.textPrimary,
                  ),
                ),
              ),
              if (onViewAll != null && sales.length > maxItems)
                TextButton(onPressed: onViewAll, child: Text(viewAllLabel)),
            ],
          ),
          if (slice.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 52,
                    color: FinanceDashboardColors.primaryPurple.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    emptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: FinanceDashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: FinanceDashboardColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slice.length,
              separatorBuilder: (_, index) => Divider(
                height: 1,
                color: FinanceDashboardColors.border.withValues(alpha: 0.7),
              ),
              itemBuilder: (context, index) {
                final sale = slice[index];
                final serviceName = sale.lineItems.isNotEmpty
                    ? sale.lineItems.first.serviceName
                    : sale.serviceNames.isEmpty
                    ? l10n.salesScreenUnknownService
                    : sale.serviceNames.first;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    context.push(AppRoutes.ownerSaleDetails(sale.id));
                  },
                  title: Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${formatTeamMemberName(sale.employeeName)} · ${localizedSalePaymentMethod(l10n, sale.paymentMethod)} · ${DateFormat.jm(locale.toString()).format(sale.soldAt.toLocal())}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: FinanceDashboardColors.textSecondary,
                    ),
                  ),
                  trailing: Text(
                    formatAppMoney(sale.total, currencyCode, locale),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FinanceDashboardColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
