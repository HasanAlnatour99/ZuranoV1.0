import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/payroll_constants.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../widgets/payroll_result_line_tile.dart';
import '../widgets/payroll_section_card.dart';
import '../widgets/payroll_status_chip.dart';
import '../widgets/payroll_summary_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../providers/money_currency_providers.dart';

class PayslipScreen extends ConsumerWidget {
  const PayslipScreen({
    super.key,
    required this.runId,
    required this.employeeId,
    this.employeeName,
  });

  final String runId;
  final String employeeId;
  final String? employeeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final payslipAsync = ref.watch(
      payslipDataProvider((runId: runId, employeeId: employeeId)),
    );

    return Scaffold(
      appBar: AppPageHeader(title: Text(l10n.payrollPayslipTitle)),
      body: payslipAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.payrollPayslipTitle,
              message: l10n.payrollGenericError,
              icon: AppIcons.receipt_long_outlined,
              centerContent: true,
            ),
          ),
        ),
        data: (data) {
          final run = data.run;
          final results = data.results;
          final earnings = results
              .where(
                (result) =>
                    result.classification ==
                    PayrollElementClassifications.earning,
              )
              .toList(growable: false);
          final deductions = results
              .where(
                (result) =>
                    result.classification ==
                    PayrollElementClassifications.deduction,
              )
              .toList(growable: false);
          final information = results
              .where(
                (result) =>
                    result.classification ==
                    PayrollElementClassifications.information,
              )
              .toList(growable: false);
          final earningsTotal = earnings.fold<double>(
            0,
            (sum, result) => sum + result.amount,
          );
          final deductionsTotal = deductions.fold<double>(
            0,
            (sum, result) => sum + result.amount,
          );
          final netPay = earningsTotal - deductionsTotal;

          if (run == null || results.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: AppEmptyState(
                title: l10n.payrollPayslipEmptyTitle,
                message: l10n.payrollPayslipEmptySubtitle,
                icon: AppIcons.payments_outlined,
                centerContent: true,
              ),
            );
          }

          final name = employeeName?.trim().isNotEmpty == true
              ? formatTeamMemberName(employeeName)
              : formatTeamMemberName(results.first.employeeName);

          return AppMotionPlayback(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.small / 2),
                Text(
                  DateFormat.yMMMM(
                    locale.toString(),
                  ).format(DateTime(run.year, run.month)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    PayrollStatusChip(status: run.status),
                    Text(
                      formatAppMoney(netPay, currencyCode, locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                Row(
                  children: [
                    Expanded(
                      child: AppEntranceMotion(
                        motionId: 'payslip-earnings-summary',
                        child: PayrollSummaryCard(
                          label: l10n.payrollSummaryEarnings,
                          value: earningsTotal,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: AppEntranceMotion(
                        motionId: 'payslip-deductions-summary',
                        index: 1,
                        child: PayrollSummaryCard(
                          label: l10n.payrollSummaryDeductions,
                          value: deductionsTotal,
                          currencyCode: currencyCode,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                AppEntranceMotion(
                  motionId: 'payslip-net-summary',
                  index: 2,
                  child: PayrollSummaryCard(
                    label: l10n.payrollSummaryNetPay,
                    value: netPay,
                    currencyCode: currencyCode,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppEntranceMotion(
                  motionId: 'payslip-earnings-section',
                  index: 3,
                  child: PayrollSectionCard(
                    title: l10n.payrollSectionEarnings,
                    expandable: true,
                    child: Column(
                      children: [
                        for (final result in earnings)
                          PayrollResultLineTile(
                            result: result,
                            currencyCode: currencyCode,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                AppEntranceMotion(
                  motionId: 'payslip-deductions-section',
                  index: 4,
                  child: PayrollSectionCard(
                    title: l10n.payrollSectionDeductions,
                    expandable: true,
                    child: deductions.isEmpty
                        ? Text(l10n.payrollSectionEmpty)
                        : Column(
                            children: [
                              for (final result in deductions)
                                PayrollResultLineTile(
                                  result: result,
                                  currencyCode: currencyCode,
                                ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                AppEntranceMotion(
                  motionId: 'payslip-information-section',
                  index: 5,
                  child: PayrollSectionCard(
                    title: l10n.payrollSectionInformation,
                    expandable: true,
                    child: information.isEmpty
                        ? Text(l10n.payrollSectionEmpty)
                        : Column(
                            children: [
                              for (final result in information)
                                PayrollResultLineTile(
                                  result: result,
                                  currencyCode: currencyCode,
                                  showMeta: false,
                                ),
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
