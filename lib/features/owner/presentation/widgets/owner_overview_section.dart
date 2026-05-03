import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../users/data/models/app_user.dart';
import '../../logic/owner_overview_controller.dart';
import '../../logic/owner_overview_state.dart';
import 'overview/owner_dashboard_hero_header.dart';
import 'overview/overview_action_button.dart';
import 'overview/overview_design_tokens.dart';
import 'overview/overview_kpi_grid_section.dart';
import 'overview/overview_revenue_chart_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'package:barber_shop_app/features/owner_dashboard/presentation/widgets/overview_bottom_insights_section.dart';
import 'package:barber_shop_app/features/owner_dashboard/presentation/widgets/team_performance_mini_bars_card.dart';
import 'owner_zurano_bottom_nav.dart';

Widget _buildTodayInsightCard({
  required BuildContext context,
  required OwnerOverviewState state,
  required AppLocalizations l10n,
  required Locale locale,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final revenueToday = state.todayRevenue;
  final bookingsToday = state.bookingsToday;
  final pendingApprovals = state.pendingApprovalsCount;
  final pendingBookings = state.pendingBookingsCount;
  final revenueLabel = formatAppMoney(revenueToday, state.currencyCode, locale);

  final insightMessage = revenueToday > 0
      ? l10n.ownerOverviewTodayInsightRevenue(revenueLabel)
      : bookingsToday == 0
      ? l10n.ownerOverviewTodayInsightNoActivity
      : l10n.ownerOverviewTodayInsightBookings(bookingsToday);

  return Container(
    margin: const EdgeInsets.fromLTRB(4, 0, 4, 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: OwnerOverviewTokens.purple.withValues(alpha: 0.08),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: OwnerOverviewTokens.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: OwnerOverviewTypography.insightIcon,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      l10n.ownerOverviewTodayInsightTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: OwnerOverviewTypography.insightTitle,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(14),
              Text(
                insightMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: OwnerOverviewTypography.insightBody,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: Color(0xFF374151),
                ),
              ),
              if (pendingApprovals > 0) ...[
                const Gap(8),
                Text(
                  l10n.ownerOverviewTodayInsightPendingApprovals(
                    pendingApprovals,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              if (pendingBookings > 0) ...[
                const Gap(6),
                Text(
                  l10n.ownerOverviewAttentionPendingBookings(pendingBookings),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Gap(16),
              Row(
                children: [
                  OverviewActionButton(
                    icon: AppIcons.add_rounded,
                    label: l10n.ownerOverviewQuickAddSale,
                    primary: true,
                    onTap: () => context.push(AppRoutes.ownerSalesAdd),
                  ),
                  const SizedBox(width: 12),
                  OverviewActionButton(
                    icon: AppIcons.event_available_outlined,
                    label: l10n.ownerOverviewQuickBooking,
                    onTap: () => context.push(AppRoutes.bookingsNew),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: OwnerOverviewTokens.purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.insert_chart_outlined_rounded,
            color: OwnerOverviewTokens.purple.withValues(alpha: 0.55),
            size: 30,
          ),
        ),
      ],
    ),
  );
}

Widget _buildBody({
  required BuildContext context,
  required WidgetRef ref,
  required AppUser user,
  required OwnerOverviewState state,
  required AppLocalizations l10n,
  required Locale locale,
}) {
  Widget animated(Widget child, int i) {
    return child
        .animate()
        .fadeIn(
          duration: const Duration(milliseconds: OwnerOverviewSection._animMs),
          delay: Duration(milliseconds: 40 * i),
        )
        .slideY(
          begin: 0.035,
          end: 0,
          duration: const Duration(milliseconds: OwnerOverviewSection._animMs),
          delay: Duration(milliseconds: 40 * i),
          curve: Curves.easeOutCubic,
        );
  }

  var index = 0;
  final children = <Widget>[
    animated(
      _buildTodayInsightCard(
        context: context,
        state: state,
        l10n: l10n,
        locale: locale,
      ),
      index++,
    ),
    const Gap(12),
    animated(
      OverviewKpiGridSection(
        state: state,
        locale: locale,
        onServicesTap: () => context.push(AppRoutes.ownerSales),
        onCheckedInTap: () => context.go(AppRoutes.ownerTeam),
        onPendingTap: () => context.push(AppRoutes.attendanceRequestsReview),
      ),
      index++,
    ),
    const Gap(16),
    animated(OverviewRevenueChartCard(state: state, locale: locale), index++),
    const Gap(16),
    animated(
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: TeamPerformanceMiniBarsCard(
          salonId: user.salonId ?? '',
          currencyCode: state.currencyCode,
        ),
      ),
      index++,
    ),
    const Gap(16),
    animated(
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
        child: OverviewBottomInsightsSection(
          salonId: user.salonId ?? '',
          currencyCode: state.currencyCode,
        ),
      ),
      index++,
    ),
  ];

  final scrollBottomPad = OwnerZuranoBottomNav.ownerShellScrollBottomPadding(
    context,
  );

  return AppMotionPlayback(
    child: ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(18, 24, 18, scrollBottomPad),
      children: children,
    ),
  );
}

/// Owner Overview: premium header, welcome, KPIs, revenue chart (month / week), insights.
class OwnerOverviewSection extends ConsumerWidget {
  const OwnerOverviewSection({super.key, required this.user});

  final AppUser user;

  static const _animMs = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final state = ref.watch(ownerOverviewControllerProvider);

    if (state.isLoading) {
      return const _OverviewLoadingScaffold();
    }

    if (state.hasError && !state.hasMonthRevenue && state.bookingsToday == 0) {
      return Scaffold(
        backgroundColor: kOwnerDashboardHeroCanvas,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Text(
              l10n.genericError,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kOwnerDashboardHeroCanvas,
      body: Column(
        children: [
          OwnerDashboardHeroHeader(user: user),
          Expanded(
            child: _buildBody(
              context: context,
              ref: ref,
              user: user,
              state: state,
              l10n: l10n,
              locale: locale,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewLoadingScaffold extends StatelessWidget {
  const _OverviewLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOwnerDashboardHeroCanvas,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 8,
          16,
          120,
        ),
        children: [
          const AppSkeletonBlock(height: 56),
          const Gap(12),
          const AppSkeletonBlock(height: 100),
          const Gap(12),
          const AppSkeletonBlock(height: 200),
          const Gap(10),
          const AppSkeletonBlock(height: 160),
          const Gap(10),
          const AppSkeletonBlock(height: 120),
        ],
      ),
    );
  }
}
