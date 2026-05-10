import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:barber_shop_app/core/constants/app_routes.dart';
import 'package:barber_shop_app/core/formatting/app_money_format.dart';
import 'package:barber_shop_app/core/widgets/app_skeleton.dart';
import 'package:barber_shop_app/features/owner/dashboard_v2/application/owner_dashboard_actions_controller.dart';
import 'package:barber_shop_app/features/owner/dashboard_v2/application/owner_dashboard_providers.dart';
import 'package:barber_shop_app/features/owner/logic/owner_overview_controller.dart';
import 'package:barber_shop_app/features/owner/logic/owner_overview_state.dart';
import 'package:barber_shop_app/features/owner_dashboard/presentation/widgets/customer_growth_card.dart';
import 'package:barber_shop_app/features/owner_dashboard/presentation/widgets/service_mix_card.dart';
import 'package:barber_shop_app/features/owner_dashboard/presentation/widgets/team_performance_mini_bars_card.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/l10n/app_localizations.dart';

import '../owner_zurano_bottom_nav.dart';

String _salonIdForInsights(AppUser user) => (user.salonId ?? '').trim();

class _OwnerPremiumColors {
  static const background = Color(0xFFF7F4FF);
  static const purple = Color(0xFF7B2FF7);
  static const purple2 = Color(0xFF9D6CFF);
  static const lavender = Color(0xFFF1E8FF);
  static const dark = Color(0xFF161622);
  static const muted = Color(0xFF6F6A7A);
  static const success = Color(0xFF16A34A);
}

/// Premium purple/lavender owner overview body (Overview tab content only).
class OwnerPremiumOverviewBody extends ConsumerWidget {
  const OwnerPremiumOverviewBody({
    super.key,
    required this.user,
  });

  /// Wired for hero/header parity and future personalization; overview data is provider-driven.
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(ownerOverviewControllerProvider);
    final dailyAsync = ref.watch(todayDashboardSnapshotProvider);
    final monthlyAsync = ref.watch(currentMonthDashboardSnapshotProvider);
    final actions = ref.watch(ownerDashboardActionsControllerProvider);

    final daily = dailyAsync.asData?.value;
    final monthly = monthlyAsync.asData?.value;

    if (overview.isLoading) {
      return const ColoredBox(
        color: _OwnerPremiumColors.background,
        child: _PremiumOverviewSkeleton(),
      );
    }

    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;

    final revenueToday =
        daily?.revenueToday ?? overview.todayRevenue;
    final bookingsToday =
        daily?.bookingsToday ?? overview.bookingsToday;
    final teamOnDuty =
        daily?.checkedInEmployees ?? overview.checkedInEmployeesToday;
    final pendingApprovals = overview.pendingApprovalsCount;
    final currencyCode = overview.currencyCode;

    final revenueLabel =
        formatAppMoney(revenueToday, currencyCode, locale);

    final insightMessage = revenueToday > 0
        ? l10n.ownerOverviewTodayInsightRevenue(revenueLabel)
        : bookingsToday == 0
            ? l10n.ownerOverviewTodayInsightNoActivity
            : l10n.ownerOverviewTodayInsightBookings(bookingsToday);

    final monthlyHint = (monthly?.topServiceName?.trim().isNotEmpty ?? false)
        ? l10n.ownerOverviewInsightTopServiceWeek(monthly!.topServiceName!.trim())
        : null;

    return ColoredBox(
      key: ValueKey<String>(user.uid),
      color: _OwnerPremiumColors.background,
      child: Stack(
        children: [
          RefreshIndicator(
            color: _OwnerPremiumColors.purple,
            onRefresh: () => ref
                .read(ownerDashboardActionsControllerProvider.notifier)
                .refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                OwnerZuranoBottomNav.ownerShellScrollBottomPadding(context),
              ),
              children: [
                if (overview.hasError) _ErrorHintCard(message: l10n.genericError),
                _BusinessOverviewCard(
                  overview: overview,
                  revenueToday: revenueToday,
                  hourly: overview.todayHourlyRevenue,
                  locale: locale,
                  l10n: l10n,
                ),
                const Gap(16),
                _QuickActionsRow(l10n: l10n),
                const Gap(18),
                _KpiGridSection(
                  overview: overview,
                  revenueToday: revenueToday,
                  bookingsToday: bookingsToday,
                  teamOnDuty: teamOnDuty,
                  pendingApprovals: pendingApprovals,
                  locale: locale,
                  l10n: l10n,
                ),
                const Gap(18),
                _SmartInsightCard(
                  l10n: l10n,
                  insightBody: insightMessage,
                  monthlyHint: monthlyHint,
                  pendingApprovals: pendingApprovals,
                  pendingBookings: overview.pendingBookingsCount,
                ),
                if (_salonIdForInsights(user).isNotEmpty) ...[
                  const Gap(18),
                  TeamPerformanceMiniBarsCard(
                    salonId: _salonIdForInsights(user),
                    currencyCode: overview.currencyCode,
                  ),
                  const Gap(16),
                  ServiceMixCard(
                    salonId: _salonIdForInsights(user),
                    currencyCode: overview.currencyCode,
                  ),
                  const Gap(16),
                  CustomerGrowthCard(salonId: _salonIdForInsights(user)),
                ],
                if (actions.errorMessage != null) ...[
                  const Gap(12),
                  Text(
                    l10n.genericError,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: _OwnerPremiumColors.purple,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }
}

class _PremiumOverviewSkeleton extends StatelessWidget {
  const _PremiumOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        OwnerZuranoBottomNav.ownerShellScrollBottomPadding(context),
      ),
      children: [
        const AppSkeletonBlock(height: 240),
        const Gap(16),
        const AppSkeletonBlock(height: 56),
        const Gap(16),
        const AppSkeletonBlock(height: 160),
        const Gap(16),
        const AppSkeletonBlock(height: 120),
        const Gap(18),
        const AppSkeletonBlock(height: 200),
        const Gap(16),
        const AppSkeletonBlock(height: 200),
        const Gap(16),
        const AppSkeletonBlock(height: 220),
      ],
    );
  }
}

class _ErrorHintCard extends StatelessWidget {
  const _ErrorHintCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessOverviewCard extends StatelessWidget {
  const _BusinessOverviewCard({
    required this.overview,
    required this.revenueToday,
    required this.hourly,
    required this.locale,
    required this.l10n,
  });

  final OwnerOverviewState overview;
  final double revenueToday;
  final List<double> hourly;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final currencyCode = overview.currencyCode;
    final revenueLabel =
        formatAppMoney(revenueToday, currencyCode, locale);
    final revDiff = revenueToday - overview.yesterdayRevenue;
    final trendText = _revenueTrendLabel(
      l10n: l10n,
      revDiff: revDiff,
      currencyCode: currencyCode,
      locale: locale,
    );
    final trendPositive = revDiff > 0;
    final trendMuted = revDiff == 0;

    final hours = List<double>.from(
      hourly.length >= 24 ? hourly.sublist(0, 24) : hourly,
    );
    while (hours.length < 24) {
      hours.add(0);
    }

    final dotHour = DateTime.now().hour.clamp(0, 23);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
                  l10n.ownerPremiumOverviewBusinessTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _OwnerPremiumColors.dark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _OwnerPremiumColors.lavender,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _OwnerPremiumColors.purple.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _OwnerPremiumColors.purple.withValues(alpha: 0.85),
                    ),
                    const Gap(6),
                    Text(
                      l10n.ownerDashboardV2TodayLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _OwnerPremiumColors.dark,
                      ),
                    ),
                    const Gap(4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _OwnerPremiumColors.muted.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(18),
          Text(
            l10n.ownerOverviewTotalRevenueLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _OwnerPremiumColors.muted,
            ),
          ),
          const Gap(6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  revenueLabel,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: _OwnerPremiumColors.dark,
                  ),
                ),
              ),
              if (trendText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendMuted
                            ? Icons.remove_rounded
                            : trendPositive
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                        size: 14,
                        color: trendMuted
                            ? _OwnerPremiumColors.muted
                            : trendPositive
                                ? _OwnerPremiumColors.success
                                : Theme.of(context).colorScheme.error,
                      ),
                      const Gap(4),
                      Text(
                        trendText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: trendMuted
                              ? _OwnerPremiumColors.muted
                              : trendPositive
                                  ? _OwnerPremiumColors.success
                                  : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap(16),
          SizedBox(
            height: 96,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                hours,
                dotHour: dotHour,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [0, 6, 12, 18, 23].map((h) {
              return Text(
                _formatHourLabel(locale, h),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _OwnerPremiumColors.muted.withValues(alpha: 0.85),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _formatHourLabel(Locale locale, int hour) {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day, hour);
    return DateFormat.jm(locale.toString()).format(t);
  }

  static String? _revenueTrendLabel({
    required AppLocalizations l10n,
    required double revDiff,
    required String currencyCode,
    required Locale locale,
  }) {
    return _moneyDeltaLine(l10n, revDiff, currencyCode, locale);
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
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(AppRoutes.ownerSalesAdd),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _OwnerPremiumColors.purple,
                      _OwnerPremiumColors.purple2,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _OwnerPremiumColors.purple.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          l10n.ownerOverviewQuickAddSale,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.push(AppRoutes.bookingsNew),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _OwnerPremiumColors.purple.withValues(alpha: 0.45),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: _OwnerPremiumColors.purple.withValues(alpha: 0.9),
                      size: 22,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        l10n.ownerPremiumOverviewNewBooking,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: _OwnerPremiumColors.dark,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _OwnerPremiumColors.muted.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiGridSection extends StatelessWidget {
  const _KpiGridSection({
    required this.overview,
    required this.revenueToday,
    required this.bookingsToday,
    required this.teamOnDuty,
    required this.pendingApprovals,
    required this.locale,
    required this.l10n,
  });

  final OwnerOverviewState overview;
  final double revenueToday;
  final int bookingsToday;
  final int teamOnDuty;
  final int pendingApprovals;
  final Locale locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final revDiff = revenueToday - overview.yesterdayRevenue;
    final bookingsDelta =
        bookingsToday - overview.bookingsYesterdayCount;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      children: [
        _KpiMiniCard(
          icon: Icons.bar_chart_rounded,
          iconColor: _OwnerPremiumColors.purple,
          title: l10n.ownerOverviewStatRevenueToday,
          value: formatAppMoney(revenueToday, overview.currencyCode, locale),
          trend: _moneyDeltaLabel(
            l10n,
            revDiff,
            overview.currencyCode,
            locale,
          ),
          trendPositive: revDiff > 0,
          trendMuted: revDiff == 0,
          sparkline: overview.last7DaysDailyRevenue,
          onTap: () => context.push(AppRoutes.ownerSales),
        ),
        _KpiMiniCard(
          icon: Icons.event_available_rounded,
          iconColor: const Color(0xFF2563EB),
          title: l10n.ownerOverviewStatBookingsToday,
          value: '$bookingsToday',
          trend: _countDeltaLabel(l10n, bookingsDelta),
          trendPositive: bookingsDelta > 0,
          trendMuted: bookingsDelta == 0,
          sparkline: _twoPointTrend(
            overview.bookingsYesterdayCount,
            bookingsToday,
          ),
          onTap: () => context.push(AppRoutes.ownerBookings),
        ),
        _KpiMiniCard(
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF2563EB),
          title: l10n.ownerPremiumOverviewTeamOnDutyTitle,
          value: l10n.ownerPremiumOverviewTeamMembersCount(
            teamOnDuty,
            overview.totalEmployeesCount,
          ),
          trend: null,
          trendPositive: null,
          trendMuted: true,
          avatarUrls: overview.teamBarberPreview.take(4).toList(),
          onTap: () => context.go(AppRoutes.ownerTeam),
        ),
        _KpiMiniCard(
          icon: Icons.work_outline_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: l10n.ownerOverviewKpiPendingApprovals,
          value: '$pendingApprovals',
          subtitle: pendingApprovals > 0
              ? l10n.ownerOverviewTodayInsightPendingApprovals(pendingApprovals)
              : l10n.ownerOverviewNeedsAttentionNone,
          trend: null,
          trendPositive: null,
          trendMuted: true,
          pendingDots: pendingApprovals.clamp(0, 4),
          onTap: pendingApprovals > 0
              ? () => context.push(AppRoutes.attendanceRequestsReview)
              : null,
        ),
      ],
    );
  }

  static String? _moneyDeltaLabel(
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

  static String? _countDeltaLabel(AppLocalizations l10n, int diff) {
    if (diff == 0) return l10n.ownerOverviewStatDeltaSameAsYesterday;
    final body = diff > 0 ? '+$diff' : '$diff';
    return l10n.ownerOverviewStatDeltaVsYesterday(body);
  }

  static List<double> _twoPointTrend(int yesterday, int today) {
    final a = yesterday.toDouble();
    final b = today.toDouble();
    return <double>[a, a, b, b];
  }
}

/// [Padding] cannot use negative insets; overlap avatars with translation instead.
Offset _kpiAvatarOverlapOffset(BuildContext context, int index) {
  if (index == 0) return Offset.zero;
  const overlap = 6.0;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return Offset(rtl ? overlap : -overlap, 0);
}

class _KpiMiniCard extends StatelessWidget {
  const _KpiMiniCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.trend,
    required this.trendPositive,
    required this.trendMuted,
    required this.onTap,
    this.sparkline,
    this.subtitle,
    this.avatarUrls = const [],
    this.pendingDots = 0,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool? trendPositive;
  final bool trendMuted;
  final List<double>? sparkline;
  final List<OwnerTeamBarberPreview> avatarUrls;
  final int pendingDots;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spark = sparkline;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _OwnerPremiumColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _OwnerPremiumColors.dark,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _OwnerPremiumColors.muted.withValues(alpha: 0.95),
                  ),
                ),
              ],
              if (trend != null) ...[
                const Gap(6),
                Row(
                  children: [
                    Icon(
                      trendMuted
                          ? Icons.remove_rounded
                          : (trendPositive ?? false)
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                      size: 12,
                      color: trendMuted
                          ? _OwnerPremiumColors.muted
                          : (trendPositive ?? false)
                              ? _OwnerPremiumColors.success
                              : Theme.of(context).colorScheme.error,
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        trend!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: trendMuted
                              ? _OwnerPremiumColors.muted
                              : (trendPositive ?? false)
                                  ? _OwnerPremiumColors.success
                                  : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (avatarUrls.isNotEmpty)
                Row(
                  children: [
                    for (var i = 0; i < avatarUrls.length; i++)
                      Transform.translate(
                        offset: _kpiAvatarOverlapOffset(context, i),
                        child: _AvatarInitial(
                          name: avatarUrls[i].name,
                        ),
                      ),
                  ],
                )
              else if (pendingDots > 0)
                Row(
                  children: List.generate(
                    pendingDots,
                    (i) => Padding(
                      padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 4),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            _OwnerPremiumColors.lavender.withValues(alpha: 0.9),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _OwnerPremiumColors.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (spark != null && spark.length >= 2)
                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SparklinePainter(spark, dotHour: null),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    return CircleAvatar(
      radius: 14,
      backgroundColor: _OwnerPremiumColors.lavender,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _OwnerPremiumColors.purple,
        ),
      ),
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard({
    required this.l10n,
    required this.insightBody,
    required this.monthlyHint,
    required this.pendingApprovals,
    required this.pendingBookings,
  });

  final AppLocalizations l10n;
  final String insightBody;
  final String? monthlyHint;
  final int pendingApprovals;
  final int pendingBookings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _OwnerPremiumColors.lavender,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _OwnerPremiumColors.purple.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: _OwnerPremiumColors.purple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: _OwnerPremiumColors.purple.withValues(alpha: 0.95),
                    ),
                    const Gap(8),
                    Text(
                      l10n.ownerPremiumOverviewSmartInsightTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _OwnerPremiumColors.purple,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  insightBody,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: _OwnerPremiumColors.dark,
                  ),
                ),
                if (monthlyHint != null) ...[
                  const Gap(8),
                  Text(
                    monthlyHint!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _OwnerPremiumColors.muted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
                if (pendingApprovals > 0) ...[
                  const Gap(8),
                  Text(
                    l10n.ownerOverviewTodayInsightPendingApprovals(
                      pendingApprovals,
                    ),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
                if (pendingBookings > 0) ...[
                  const Gap(6),
                  Text(
                    l10n.ownerOverviewAttentionPendingBookings(pendingBookings),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                const Gap(12),
                TextButton(
                  onPressed: () => context.push(AppRoutes.ownerBookings),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.ownerPremiumOverviewViewInsight,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _OwnerPremiumColors.purple,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _OwnerPremiumColors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Icon(
            Icons.chair_outlined,
            size: 44,
            color: _OwnerPremiumColors.purple.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, {this.dotHour});

  final List<double> values;
  final int? dotHour;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).abs() < 0.01 ? 1.0 : maxValue - minValue;

    final path = Path();
    Offset? dotCenter;

    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (dotHour != null && i == dotHour) {
        dotCenter = Offset(x, y);
      }
    }

    final paint = Paint()
      ..color = _OwnerPremiumColors.purple
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    final dc = dotCenter;
    if (dc != null) {
      canvas.drawCircle(dc, 5, Paint()..color = _OwnerPremiumColors.purple);
      canvas.drawCircle(
        dc,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.dotHour != dotHour;
  }
}
