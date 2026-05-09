import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../providers/customer_map_providers.dart';

class SearchThisAreaButton extends ConsumerWidget {
  const SearchThisAreaButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(mapSearchThisAreaVisibleProvider);
    if (!visible) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      color: AppBrandColors.primary,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, color: AppBrandColors.onPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.customerMapSearchThisArea,
                style: const TextStyle(
                  color: AppBrandColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
