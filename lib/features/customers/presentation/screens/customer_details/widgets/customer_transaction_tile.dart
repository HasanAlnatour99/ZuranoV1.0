import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/formatting/app_money_format.dart';
import '../../../../../../core/text/team_member_name.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';

class CustomerTransactionTile extends StatelessWidget {
  const CustomerTransactionTile({
    super.key,
    required this.sale,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
  });

  final Sale sale;
  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final services = sale.serviceNames.isNotEmpty
        ? sale.serviceNames.join(' · ')
        : l10n.customerDetailsServiceFallback;
    final barber = formatTeamMemberName(sale.employeeName);
    final when = DateFormat.yMMMd(
      locale.toString(),
    ).add_jm().format(sale.soldAt.toLocal());
    final sub = formatAppMoney(sale.subtotal, currencyCode, locale);
    final disc = sale.discount;
    final total = formatAppMoney(sale.total, currencyCode, locale);
    final discLabel = disc > 0
        ? '${l10n.addSaleDiscountTitle} ${formatAppMoney(disc, currencyCode, locale)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        services,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        barber,
                        style: const TextStyle(
                          color: FinanceDashboardColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        when,
                        style: const TextStyle(
                          color: FinanceDashboardColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: FinanceDashboardColors.textPrimary,
                      ),
                    ),
                    if (disc > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        discLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D28D9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 11,
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
