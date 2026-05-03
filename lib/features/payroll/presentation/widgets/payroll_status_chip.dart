import 'package:flutter/material.dart';

import '../../../../core/formatting/payroll_status_localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/payroll_constants.dart';

class PayrollStatusChip extends StatelessWidget {
  const PayrollStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final colors = switch (status) {
      PayrollRunStatuses.paid => (
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      PayrollRunStatuses.approved => (
        background: isDark
            ? AppColorsDark.payrollApprovedBadgeBackground
            : AppColorsLight.payrollApprovedBadgeBackground,
        foreground: isDark
            ? AppColorsDark.onPayrollApprovedBadge
            : AppColorsLight.onPayrollApprovedBadge,
      ),
      PayrollRunStatuses.rolledBack => (
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      ),
      _ => (
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          localizedPayrollStatus(l10n, status),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
