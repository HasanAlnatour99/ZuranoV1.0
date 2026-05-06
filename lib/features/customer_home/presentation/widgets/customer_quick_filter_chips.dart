import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customer/search/application/customer_search_controller.dart';

class CustomerQuickFilterChips extends ConsumerWidget {
  const CustomerQuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final search = ref.read(customerSearchControllerProvider.notifier);

    Widget chip(String label, Future<void> Function() onTap) {
      return ActionChip(
        backgroundColor: Colors.white.withValues(alpha: 0.22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        label: Text(label),
        onPressed: () async {
          HapticFeedback.selectionClick();
          await onTap();
          if (context.mounted) {
            context.push(AppRoutes.customerSearch);
          }
        },
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        chip(l10n.customerSearchFilterNearby, () => search.toggleNearbyOnly()),
        chip(l10n.customerSearchFilterOpenNow, () => search.toggleOpenNow()),
        chip(l10n.customerSearchFilterAvailableToday, () => search.toggleAvailableToday()),
        chip(l10n.customerSearchFilterOffers, () => search.toggleOffers()),
      ],
    );
  }
}

