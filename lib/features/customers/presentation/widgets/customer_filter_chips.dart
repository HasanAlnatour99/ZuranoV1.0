import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Horizontal filter chips for the customer list.
class CustomerFilterChips extends StatelessWidget {
  const CustomerFilterChips({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  /// One of: `All`, `New`, `Regular`, `VIP`, `Inactive`.
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(String, String)>[
      ('All', l10n.customersTagAll),
      ('New', l10n.customersTagNew),
      ('Regular', l10n.customersTagRegular),
      ('VIP', l10n.customersTagVip),
      ('Inactive', l10n.customersTagInactive),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 32, 0),
      child: Row(
        children: [
          for (final e in items)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: ChoiceChip(
                showCheckmark: e.$1 == 'All',
                selected: selectedKey == e.$1,
                onSelected: (_) => onSelected(e.$1),
                label: Text(e.$2),
                selectedColor: FinanceDashboardColors.primaryPurple,
                backgroundColor: FinanceDashboardColors.surface,
                labelStyle: TextStyle(
                  color: selectedKey == e.$1
                      ? Colors.white
                      : FinanceDashboardColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: selectedKey == e.$1
                        ? FinanceDashboardColors.primaryPurple
                        : FinanceDashboardColors.border,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
