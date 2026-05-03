import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class PayrollEmptyState extends StatelessWidget {
  const PayrollEmptyState({
    super.key,
    required this.onGenerateFirstPayslip,
    this.titleStyle,
    this.subtitleStyle,
  });

  final VoidCallback? onGenerateFirstPayslip;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.noPayrollRecordsYet,
            textAlign: TextAlign.center,
            style:
                titleStyle ??
                const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.generatedPayslipsWillAppearHere,
            textAlign: TextAlign.center,
            style: subtitleStyle ?? theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (onGenerateFirstPayslip != null)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: onGenerateFirstPayslip,
                child: Text(l10n.generateFirstPayslip),
              ),
            ),
        ],
      ),
    );
  }
}
