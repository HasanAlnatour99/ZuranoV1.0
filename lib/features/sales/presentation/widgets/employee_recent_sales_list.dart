import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';
import 'employee_sale_list_row.dart';

const int kEmployeeRecentSalesPreviewLimit = 5;

class EmployeeRecentSalesList extends StatelessWidget {
  const EmployeeRecentSalesList({
    super.key,
    required this.sales,
    required this.currencyCode,
    required this.locale,
    this.isLoading = false,
    this.periodSubtitle,
    this.viewAllLabel,
    this.onViewAll,
  });

  final List<Sale> sales;
  final String currencyCode;
  final Locale locale;
  final bool isLoading;
  final String? periodSubtitle;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFmt = DateFormat.jm(locale.toString());
    final hasHeaderRow = periodSubtitle != null || onViewAll != null;
    final show = sales.take(kEmployeeRecentSalesPreviewLimit).toList(
          growable: false,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: _buildContent(
        l10n: l10n,
        timeFmt: timeFmt,
        hasHeaderRow: hasHeaderRow,
        show: show,
      ),
    );
  }

  Widget _buildContent({
    required AppLocalizations l10n,
    required DateFormat timeFmt,
    required bool hasHeaderRow,
    required List<Sale> show,
  }) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeaderRow)
            _RecentSalesHeader(
              l10n: l10n,
              periodSubtitle: periodSubtitle,
              viewAllLabel: viewAllLabel,
              onViewAll: onViewAll,
            ),
          _RecentSalesListSkeleton(includeTitleLine: !hasHeaderRow),
        ],
      );
    }

    if (sales.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeaderRow)
            _RecentSalesHeader(
              l10n: l10n,
              periodSubtitle: periodSubtitle,
              viewAllLabel: viewAllLabel,
              onViewAll: onViewAll,
            ),
          _EmptyRecentSales(l10n: l10n),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecentSalesHeader(
          l10n: l10n,
          periodSubtitle: periodSubtitle,
          viewAllLabel: viewAllLabel,
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        ...show.map(
          (s) => EmployeeSaleListRow(
            sale: s,
            currencyCode: currencyCode,
            locale: locale,
            timeFmt: timeFmt,
          ),
        ),
      ],
    );
  }
}

class _RecentSalesHeader extends StatelessWidget {
  const _RecentSalesHeader({
    required this.l10n,
    this.periodSubtitle,
    this.viewAllLabel,
    this.onViewAll,
  });

  final AppLocalizations l10n;
  final String? periodSubtitle;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.employeeSalesRecentTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF111827),
                ),
              ),
              if (periodSubtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  periodSubtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              viewAllLabel ?? l10n.employeeSalesViewAllHistory,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyRecentSales extends StatelessWidget {
  const _EmptyRecentSales({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8FF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: Colors.deepPurple.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.salesRecentEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.employeeSalesEmptyCta,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _RecentSalesListSkeleton extends StatelessWidget {
  const _RecentSalesListSkeleton({this.includeTitleLine = true});

  final bool includeTitleLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeTitleLine) ...[
          Container(
            height: 20,
            width: 140,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E0F5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
        ...List<Widget>.generate(3, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7D8FF)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
