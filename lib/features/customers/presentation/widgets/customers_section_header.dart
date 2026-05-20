import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

const _primaryPurple = Color(0xFF7B2FF7);
const _surfacePurple = Color(0xFFF0E7FF);
const _textPrimary = Color(0xFF21143D);
const _textSecondary = Color(0xFF7A728C);

class CustomersSectionHeader extends StatelessWidget {
  const CustomersSectionHeader({
    super.key,
    required this.count,
    required this.onFilterTap,
  });

  final int count;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.customersScreenTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _surfacePurple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.customersCountBadge(count),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: l10n.customersFilterTooltip,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _primaryPurple.withValues(alpha: 0.13),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _textSecondary.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: _primaryPurple,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
