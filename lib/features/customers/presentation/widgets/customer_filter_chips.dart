import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

const _primaryPurple = Color(0xFF7B2FF7);
const _textPrimary = Color(0xFF21143D);
const _textSecondary = Color(0xFF7A728C);

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
              child: _AnimatedFilterChip(
                label: e.$2,
                selected: selectedKey == e.$1,
                onTap: () => onSelected(e.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedFilterChip extends StatelessWidget {
  const _AnimatedFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected ? _primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? _primaryPurple
                  : _primaryPurple.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? _primaryPurple.withValues(alpha: 0.18)
                    : _textSecondary.withValues(alpha: 0.06),
                blurRadius: selected ? 18 : 12,
                offset: Offset(0, selected ? 10 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : _textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
