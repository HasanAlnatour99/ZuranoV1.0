import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import 'payroll_action_tile.dart';

class PayrollQuickActionsRow extends StatelessWidget {
  const PayrollQuickActionsRow({
    super.key,
    required this.editingEnabled,
    required this.reverseEnabled,
    required this.onAddBonus,
    required this.onAddDeduction,
    required this.onGeneratePayslip,
    required this.onReverseLastPayrollMonth,
  });

  /// Add bonus, add deduction, and generate payslip.
  final bool editingEnabled;

  /// Reverse latest payroll month (allowed even when [editingEnabled] is false).
  final bool reverseEnabled;
  final VoidCallback onAddBonus;
  final VoidCallback onAddDeduction;
  final VoidCallback onGeneratePayslip;
  final VoidCallback onReverseLastPayrollMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[
      PayrollActionTile(
        icon: Icons.add,
        label: l10n.addBonus,
        onTap: editingEnabled ? onAddBonus : null,
      ),
      PayrollActionTile(
        icon: Icons.remove,
        label: l10n.addDeduction,
        onTap: editingEnabled ? onAddDeduction : null,
      ),
      PayrollActionTile(
        icon: Icons.receipt_long,
        label: l10n.generatePayslip,
        onTap: editingEnabled ? onGeneratePayslip : null,
      ),
      PayrollActionTile(
        icon: Icons.undo_rounded,
        label: l10n.reverseLastPayrollMonth,
        onTap: reverseEnabled ? onReverseLastPayrollMonth : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        if (isCompact) {
          return Column(
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                SizedBox(width: double.infinity, child: actions[index]),
                if (index < actions.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              Expanded(child: actions[index]),
              if (index < actions.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}
