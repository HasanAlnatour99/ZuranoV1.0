import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/payroll_statuses.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/payslip_model.dart';
import 'payslip_breakdown_section.dart';

class CurrentPayslipCard extends StatelessWidget {
  const CurrentPayslipCard({
    super.key,
    required this.payslip,
    required this.locale,
  });

  final PayslipModel payslip;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final earnings = payslip.lines.where((l) => l.isEarning).toList();
    final deductions = payslip.lines.where((l) => !l.isEarning).toList();
    final paid = payslip.status == PayrollStatuses.paid;
    final netLabel = formatAppMoney(payslip.netPay, payslip.currency, locale);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ZuranoPremiumUiColors.primaryPurple.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: payslip.employeePhotoUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeamMemberNameText(
                        payslip.employeeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.content_cut_rounded,
                            size: 16,
                            color: ZuranoPremiumUiColors.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              payslip.employeeRole,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ZuranoPremiumUiColors.textSecondary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            size: 16,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.employeePayrollPeriod(
                                DateFormat.MMMd(
                                  locale.toString(),
                                ).format(payslip.periodStart),
                                DateFormat.MMMd(
                                  locale.toString(),
                                ).format(payslip.periodEnd),
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ZuranoPremiumUiColors.textSecondary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paid
                                ? l10n.employeePayrollStatusPaid
                                : l10n.employeePayrollStatusApproved,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.employeePayrollNetPay,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ZuranoPremiumUiColors.textSecondary,
                      ),
                    ),
                    Text(
                      netLabel,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ZuranoPremiumUiColors.primaryPurple,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          PayslipBreakdownSection(
            title: l10n.employeePayrollEarnings,
            isEarning: true,
            lines: earnings,
            total: payslip.totalEarnings,
            currency: payslip.currency,
            totalLabel: l10n.employeePayrollTotalEarnings,
          ),
          PayslipBreakdownSection(
            title: l10n.employeePayrollDeductions,
            isEarning: false,
            lines: deductions,
            total: payslip.totalDeductions,
            currency: payslip.currency,
            totalLabel: l10n.employeePayrollTotalDeductions,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: ZuranoPremiumUiColors.primaryPurple.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.employeePayrollNetSalary.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: ZuranoPremiumUiColors.primaryPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${payslip.netPay.toStringAsFixed(2)} ${payslip.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: ZuranoPremiumUiColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u != null && u.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: u,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return CircleAvatar(
      radius: 26,
      backgroundColor: ZuranoPremiumUiColors.primaryPurple.withValues(
        alpha: 0.12,
      ),
      child: Icon(
        Icons.person_rounded,
        color: ZuranoPremiumUiColors.primaryPurple,
      ),
    );
  }
}
