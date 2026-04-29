import 'package:flutter/material.dart';
import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../logic/owner_overview_state.dart';
import 'overview_design_tokens.dart';
import 'overview_metric_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// 2×2 KPI band: revenue, bookings, checked-in barbers, pending requests.
class OverviewKpiGridSection extends StatelessWidget {
  const OverviewKpiGridSection({
    super.key,
    required this.state,
    required this.locale,
    this.onBookingsTap,
    this.onCheckedInTap,
    this.onPendingTap,
  });

  final OwnerOverviewState state;
  final Locale locale;
  final VoidCallback? onBookingsTap;
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

    final bookDelta = _countDeltaLine(
      l10n,
      state.bookingsToday - state.bookingsYesterdayCount,
    );

    final pendingRequests =
        state.pendingBookingsCount + state.pendingApprovalsCount;

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
          icon: AppIcons.event_outlined,
          title: l10n.ownerOverviewStatBookingsToday,
          value: '${state.bookingsToday}',
          color: OwnerOverviewTokens.blue,
          comparison: bookDelta,
          comparisonPositive:
              state.bookingsToday == state.bookingsYesterdayCount
              ? null
              : state.bookingsToday > state.bookingsYesterdayCount,
          onTap: onBookingsTap,
        ),
        OverviewMetricCard(
          icon: AppIcons.how_to_reg_outlined,
          title: l10n.ownerOverviewStatCheckedIn,
          value: '${state.checkedInBarbersToday}',
          color: OwnerOverviewTokens.green,
          comparison: l10n.ownerOverviewTeamActiveBarbersLabel(
            state.activeBarberCount,
          ),
          comparisonPositive: null,
          onTap: onCheckedInTap,
        ),
        OverviewMetricCard(
          icon: AppIcons.rule_folder_outlined,
          title: l10n.ownerOverviewKpiPendingRequests,
          value: '$pendingRequests',
          color: OwnerOverviewTokens.orange,
          comparison: pendingRequests > 0 ? l10n.ownerOverviewReview : null,
          comparisonPositive: null,
          onTap: pendingRequests > 0 ? onPendingTap : null,
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
