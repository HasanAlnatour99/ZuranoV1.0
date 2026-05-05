import 'package:flutter/material.dart';

import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../employee_today/presentation/employee_today_theme.dart';
import '../../data/employee_today_performance_model.dart';
import 'performance_hero_card.dart';
import 'performance_metric_card.dart';

/// Weighted performance score (0–100), KPI strip, CTA.
class EmployeeTodayPerformanceSection extends StatelessWidget {
  const EmployeeTodayPerformanceSection({
    super.key,
    required this.data,
    required this.currencyCode,
    required this.locale,
    required this.onAddSale,
  });

  final EmployeeTodayPerformanceModel data;
  final String currencyCode;
  final Locale locale;
  final VoidCallback onAddSale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final salesText = formatAppMoney(data.revenue, currencyCode, locale);
    final commissionText = formatAppMoney(
      data.commission,
      currencyCode,
      locale,
    );
    final attendanceText =
        '${data.attendanceScore.round().clamp(0, 100)}%';

    Widget metricRow(List<Widget> children) => Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: children,
        );

    return Column(
      crossAxisAlignment: isRtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          l10n.employeeTodayPerformanceTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: EmployeeTodayColors.deepText,
          ),
        ),
        const SizedBox(height: 12),
        PerformanceHeroCard(data: data),
        const SizedBox(height: 14),
        metricRow([
          Expanded(
            child: PerformanceMetricCard(
              icon: Icons.content_cut_rounded,
              label: l10n.employeeTodayPerformanceMetricServices,
              value: '${data.servicesCount}',
              accentColor: EmployeeTodayColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PerformanceMetricCard(
              icon: Icons.shopping_bag_outlined,
              label: l10n.employeeTodayPerformanceMetricSales,
              value: salesText,
              accentColor: const Color(0xFF16A34A),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        metricRow([
          Expanded(
            child: PerformanceMetricCard(
              icon: Icons.fingerprint_rounded,
              label: l10n.employeeTodayPerformanceMetricAttendanceScore,
              value: attendanceText,
              accentColor: const Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PerformanceMetricCard(
              icon: Icons.payments_outlined,
              label: l10n.employeeTodayPerformanceMetricCommission,
              value: commissionText,
              accentColor: const Color(0xFFF97316),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _PerformanceSmartMessageCard(
          message: data.smartTip(l10n),
          onAddSale: onAddSale,
        ),
      ],
    );
  }
}

class _PerformanceSmartMessageCard extends StatelessWidget {
  const _PerformanceSmartMessageCard({
    required this.message,
    required this.onAddSale,
  });

  final String message;
  final VoidCallback onAddSale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EmployeeTodayColors.cardBorder),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: EmployeeTodayColors.primaryPurple,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onAddSale,
            child: Text(l10n.employeeTodayPerformanceAddSale),
          ),
        ],
      ),
    );
  }
}
