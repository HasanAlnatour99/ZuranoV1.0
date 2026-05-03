import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/money/presentation/widgets/finance_quick_action_tile.dart';
import '../../../../features/money/presentation/widgets/premium_finance_card.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../widgets/payroll_month_selector.dart';
import '../widgets/payroll_week_selector.dart';
import '../widgets/payroll_status_chip.dart';

Widget _payrollGridCell(Widget child) {
  return Padding(
    padding: const EdgeInsetsDirectional.all(12),
    child: Align(
      alignment: AlignmentDirectional.topStart,
      child: child,
    ),
  );
}

class PayrollDashboardScreen extends ConsumerWidget {
  const PayrollDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final summaryAsync = ref.watch(payrollDashboardSummaryProvider);
    final missingAsync = ref.watch(employeesMissingPayrollSetupProvider);
    final selectedMonth = ref.watch(payrollDashboardMonthProvider);
    final selectedWeek = ref.watch(payrollDashboardIsoWeekProvider);
    final salonCadence = ref.watch(payrollHubSalonCadenceProvider);
    final weeklyHub = salonCadence == SalonPayrollPeriods.weekly;
    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      appBar: AppPageHeader(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ZuranoPremiumUiColors.background,
        foregroundColor: ZuranoPremiumUiColors.textPrimary,
        fallbackLocation: AppRoutes.ownerDashboard,
        title: Text(
          l10n.payrollDashboardTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
      ),
      body: summaryAsync.when(
        loading: () =>
            const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppEmptyState(
              title: l10n.payrollDashboardTitle,
              message: l10n.payrollGenericError,
              icon: AppIcons.payments_outlined,
              centerContent: true,
            ),
          ),
        ),
        data: (summary) {
          final missing = missingAsync.asData?.value ?? const [];

          return AppMotionPlayback(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 118),
              children: [
                Text(
                  l10n.ownerPayrollFinanceBreadcrumb,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ZuranoPremiumUiColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (weeklyHub)
                      PayrollWeekSelector(
                        weekYear: selectedWeek.y,
                        weekNumber: selectedWeek.n,
                        onChanged: (y, n) => ref
                            .read(payrollDashboardIsoWeekProvider.notifier)
                            .selectWeek(y, n),
                      )
                    else
                      PayrollMonthSelector(
                        selectedMonth: selectedMonth,
                        onChanged: (m) => ref
                            .read(payrollDashboardMonthProvider.notifier)
                            .selectMonth(m),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  weeklyHub
                      ? l10n.payrollDashboardSubtitleWeek(
                          l10n.payrollIsoWeekShortLabel(
                            selectedWeek.y,
                            selectedWeek.n.toString().padLeft(2, '0'),
                          ),
                        )
                      : l10n.payrollDashboardSubtitle(
                          DateFormat.yMMMM(
                            locale.toString(),
                          ).format(summary.month),
                        ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                AppEntranceMotion(
                  motionId: 'payroll-kpi-strip',
                  child: PremiumFinanceCard(
                    zuranoPremiumStyle: true,
                    child: Table(
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: ZuranoPremiumUiColors.border,
                        ),
                        verticalInside: BorderSide(
                          color: ZuranoPremiumUiColors.border,
                        ),
                      ),
                      defaultColumnWidth: const FlexColumnWidth(1),
                      children: [
                        TableRow(
                          children: [
                            _payrollGridCell(
                              _PayrollKpiMini(
                                label: l10n.payrollSummaryNetPay,
                                value: formatAppMoney(
                                  summary.totalNetPay,
                                  currencyCode,
                                  locale,
                                ),
                                trend: weeklyHub
                                    ? l10n.payrollDashboardKpiThisWeek
                                    : l10n.payrollDashboardKpiTrendLabel,
                                icon:
                                    AppIcons.account_balance_wallet_outlined,
                                iconColor: ZuranoPremiumUiColors.primaryPurple,
                                iconSoft: ZuranoPremiumUiColors.softPurple,
                              ),
                            ),
                            _payrollGridCell(
                              _PayrollKpiMini(
                                label: l10n.payrollSummaryEarnings,
                                value: formatAppMoney(
                                  summary.totalEarnings,
                                  currencyCode,
                                  locale,
                                ),
                                trend: weeklyHub
                                    ? l10n.payrollDashboardKpiThisWeek
                                    : l10n.payrollDashboardKpiTrendLabel,
                                icon: AppIcons.trending_up_rounded,
                                iconColor: ZuranoPremiumUiColors.deepPurple,
                                iconSoft: ZuranoPremiumUiColors.softPurple,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            _payrollGridCell(
                              _PayrollKpiMini(
                                label: l10n.payrollSummaryDeductions,
                                value: formatAppMoney(
                                  summary.totalDeductions,
                                  currencyCode,
                                  locale,
                                ),
                                trend: weeklyHub
                                    ? l10n.payrollDashboardKpiThisWeek
                                    : l10n.payrollDashboardKpiTrendLabel,
                                icon: AppIcons.trending_down_rounded,
                                iconColor: ZuranoPremiumUiColors.danger,
                                iconSoft: ZuranoPremiumUiColors.dangerSoft,
                              ),
                            ),
                            _payrollGridCell(
                              _PayrollKpiMini(
                                label: l10n.payrollDashboardKpiRunsLabel,
                                value: '${summary.monthPayrollRunCount}',
                                trend: weeklyHub
                                    ? l10n.payrollDashboardKpiRunsHintWeek
                                    : l10n.payrollDashboardKpiRunsHint,
                                icon: AppIcons.event_note_rounded,
                                iconColor:
                                    ZuranoPremiumUiColors.primaryPurple,
                                iconSoft:
                                    ZuranoPremiumUiColors.softPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppEntranceMotion(
                  motionId: 'payroll-actions',
                  index: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 360;
                      final quickPay = FinanceQuickActionTile(
                        stackedLayout: true,
                        zuranoPremiumUi: true,
                        icon: AppIcons.flash_on_rounded,
                        title: l10n.payrollQuickPayTitle,
                        subtitle: l10n.payrollQuickPayShortcutSubtitle,
                        accent: ZuranoPremiumUiColors.deepPurple,
                        accentSoft: ZuranoPremiumUiColors.softPurple,
                        onTap: () => context.push(AppRoutes.ownerQuickPay),
                      );
                      final runReview = FinanceQuickActionTile(
                        stackedLayout: true,
                        zuranoPremiumUi: true,
                        icon: AppIcons.event_note_rounded,
                        title: l10n.payrollRunReviewTitle,
                        subtitle: l10n.payrollRunShortcutSubtitle,
                        accent: ZuranoPremiumUiColors.primaryPurple,
                        accentSoft: ZuranoPremiumUiColors.softPurple,
                        onTap: () =>
                            context.push(AppRoutes.ownerPayrollRunReview),
                      );
                      final reversal = FinanceQuickActionTile(
                        stackedLayout: true,
                        zuranoPremiumUi: true,
                        icon: AppIcons.undo_rounded,
                        title: l10n.payrollReversalTitle,
                        subtitle: l10n.payrollReversalShortcutSubtitle,
                        accent: ZuranoPremiumUiColors.danger,
                        accentSoft: ZuranoPremiumUiColors.dangerSoft,
                        onTap: () =>
                            GoRouter.of(context).push(AppRoutes.ownerPayrollReverse),
                      );
                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            quickPay,
                            const SizedBox(height: 12),
                            runReview,
                            const SizedBox(height: 12),
                            reversal,
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: quickPay),
                              const SizedBox(width: 12),
                              Expanded(child: runReview),
                            ],
                          ),
                          const SizedBox(height: 12),
                          reversal,
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AppEntranceMotion(
                  motionId: 'payroll-recent-runs-card',
                  index: 2,
                  child: PremiumFinanceCard(
                    zuranoPremiumStyle: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payrollRecentRunsTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ZuranoPremiumUiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weeklyHub
                              ? l10n.payrollRecentRunsSectionSubtitleWeek
                              : l10n.payrollRecentRunsSectionSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (summary.recentRuns.isEmpty)
                          Text(
                            l10n.payrollRecentRunsEmpty,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ZuranoPremiumUiColors.textSecondary,
                              height: 1.4,
                            ),
                          )
                        else
                          for (
                            var i = 0;
                            i < summary.recentRuns.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(height: 16),
                            AppEntranceMotion(
                              motionId:
                                  'payroll-run-row-${summary.recentRuns[i].year}-${summary.recentRuns[i].month}-$i',
                              index: i,
                              duration: const Duration(milliseconds: 220),
                              slideOffset: 8,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          summary.recentRuns[i].employeeName
                                                      ?.trim()
                                                      .isNotEmpty ==
                                                  true
                                              ? formatTeamMemberName(
                                                  summary.recentRuns[i]
                                                      .employeeName,
                                                )
                                              : l10n.payrollRunGroupLabel(
                                                  summary
                                                      .recentRuns[i]
                                                      .employeeCount,
                                                ),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                ZuranoPremiumUiColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat.yMMMM(
                                            locale.toString(),
                                          ).format(
                                            DateTime(
                                              summary.recentRuns[i].year,
                                              summary.recentRuns[i].month,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: ZuranoPremiumUiColors
                                                .textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      PayrollStatusChip(
                                        status: summary.recentRuns[i].status,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formatAppMoney(
                                          summary.recentRuns[i].netPay,
                                          currencyCode,
                                          locale,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              ZuranoPremiumUiColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppEntranceMotion(
                  motionId: 'payroll-missing-setup-card',
                  index: 3,
                  child: PremiumFinanceCard(
                    zuranoPremiumStyle: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payrollDashboardSetupCardTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ZuranoPremiumUiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (missingAsync.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child:
                                Center(child: AppLoadingIndicator(size: 32)),
                          )
                        else if (missing.isEmpty) ...[
                          Text(
                            l10n.payrollSetupEveryoneReadyHeading,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ZuranoPremiumUiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.payrollMissingSetupEmpty,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ZuranoPremiumUiColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ] else ...[
                          for (var i = 0; i < missing.length; i++) ...[
                            if (i > 0) const SizedBox(height: 16),
                            AppEntranceMotion(
                              motionId: 'payroll-missing-${missing[i].id}',
                              index: i,
                              duration: const Duration(milliseconds: 220),
                              slideOffset: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context.push(
                                      AppRoutes.ownerTeamMemberDetails(
                                        missing[i].id,
                                        tab: 'payroll',
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            missing[i].name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: ZuranoPremiumUiColors
                                                  .textPrimary,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: ZuranoPremiumUiColors
                                              .primaryPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
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

class _PayrollKpiMini extends StatelessWidget {
  const _PayrollKpiMini({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
    required this.iconSoft,
  });

  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;
  final Color iconSoft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
        ),
        Text(
          trend,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ZuranoPremiumUiColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
