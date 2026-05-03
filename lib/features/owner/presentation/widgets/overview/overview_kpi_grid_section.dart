import 'package:flutter/material.dart';
import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../logic/owner_overview_state.dart';
import 'overview_design_tokens.dart';
import 'overview_metric_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// 2×2 KPI band: revenue, services (completed sales today), working now, pending approvals.
class OverviewKpiGridSection extends StatelessWidget {
  const OverviewKpiGridSection({
    super.key,
    required this.state,
    required this.locale,
    this.onServicesTap,
    this.onCheckedInTap,
    this.onPendingTap,
  });

  final OwnerOverviewState state;
  final Locale locale;
  final VoidCallback? onServicesTap;
  final VoidCallback? onCheckedInTap;
  final VoidCallback? onPendingTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final revenue = formatAppMoney(
      state.todayRevenue,
      state.currencyCode,
      locale,
    );
    final revDiff = state.todayRevenue - state.yesterdayRevenue;
    final revDelta = _moneyDeltaLine(l10n, revDiff, state.currencyCode, locale);

    final servicesDelta = _countDeltaLine(
      l10n,
      state.completedSalesTodayCount - state.completedSalesYesterdayCount,
    );

    final pendingApprovals = state.pendingApprovalsCount;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        // Slightly taller cards to prevent text overflow in localized copy.
        childAspectRatio: 1.0,
      ),
      children: [
        OverviewMetricCard(
          icon: AppIcons.payments_outlined,
          title: l10n.ownerOverviewStatRevenueToday,
          value: revenue,
          color: OwnerOverviewTokens.purple,
          comparison: revDelta,
          comparisonPositive: revDiff == 0 ? null : revDiff > 0,
          onTap: () {},
        ),
        OverviewMetricCard(
          icon: AppIcons.design_services_outlined,
          title: l10n.ownerOverviewStatServicesToday,
          value: '${state.completedSalesTodayCount}',
          color: OwnerOverviewTokens.blue,
          comparison: servicesDelta,
          comparisonPositive:
              state.completedSalesTodayCount ==
                  state.completedSalesYesterdayCount
              ? null
              : state.completedSalesTodayCount >
                    state.completedSalesYesterdayCount,
          onTap: onServicesTap,
        ),
        OverviewMetricCard(
          icon: AppIcons.groups_outlined,
          title: l10n.ownerOverviewStatWorkingNow,
          value: '${state.checkedInEmployeesToday}',
          color: OwnerOverviewTokens.green,
          comparison: l10n.ownerOverviewTeamActiveBarbersLabel(
            state.totalEmployeesCount,
          ),
          comparisonPositive: null,
          onTap: onCheckedInTap,
        ),
        OverviewMetricCard(
          icon: AppIcons.fact_check_outlined,
          title: l10n.ownerOverviewKpiPendingApprovals,
          value: '$pendingApprovals',
          color: OwnerOverviewTokens.orange,
          comparison: pendingApprovals > 0 ? l10n.ownerOverviewReview : null,
          comparisonPositive: null,
          onTap: pendingApprovals > 0 ? onPendingTap : null,
        ),
      ],
    );
  }

  static String? _moneyDeltaLine(
    AppLocalizations l10n,
    double diff,
    String currency,
    Locale locale,
  ) {
    if (diff == 0) return l10n.ownerOverviewStatDeltaSameAsYesterday;
    final abs = formatAppMoney(diff.abs(), currency, locale);
    final signed = diff > 0 ? '+$abs' : '-$abs';
    return l10n.ownerOverviewStatDeltaVsYesterday(signed);
  }

  static String? _countDeltaLine(AppLocalizations l10n, int diff) {
    if (diff == 0) return l10n.ownerOverviewStatDeltaSameAsYesterday;
    final body = diff > 0 ? '+$diff' : '$diff';
    return l10n.ownerOverviewStatDeltaVsYesterday(body);
  }
}
