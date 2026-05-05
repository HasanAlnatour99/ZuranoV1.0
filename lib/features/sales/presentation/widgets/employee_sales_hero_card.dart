import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/employee_sales_summary.dart';

class EmployeeSalesHeroCard extends StatelessWidget {
  const EmployeeSalesHeroCard({
    super.key,
    required this.summary,
    required this.currencyCode,
    required this.locale,
  });

  final EmployeeSalesSummary summary;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSales = summary.totalAmount > 0.001;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.employeeSalesTotalLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatAppMoney(summary.totalAmount, currencyCode, locale),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            if (!hasSales)
              Text(
                l10n.employeeSalesHeroNoSales,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                l10n.employeeSalesServicesCustomersRow(
                  summary.servicesCount.toString(),
                  summary.uniqueCustomersCount.toString(),
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                _mini(
                  context,
                  Icons.content_cut_rounded,
                  l10n.employeeSalesKpiServices,
                  summary.servicesCount.toString(),
                ),
                _mini(
                  context,
                  Icons.people_outline_rounded,
                  l10n.employeeSalesCustomersLabel,
                  summary.uniqueCustomersCount.toString(),
                ),
                _mini(
                  context,
                  Icons.show_chart_rounded,
                  l10n.employeeSalesKpiAvgService,
                  formatAppMoney(
                    summary.averageServiceValue,
                    currencyCode,
                    locale,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
