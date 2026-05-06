import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../theme/zurano_customer_colors.dart';
import 'customer_discovery_search_bar.dart';
import 'customer_location_pill.dart';
import 'customer_quick_filter_chips.dart';

class CustomerHomeSearchHeader extends ConsumerWidget {
  const CustomerHomeSearchHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ZuranoCustomerColors.primary,
            ZuranoCustomerColors.headerGradientMid,
            ZuranoCustomerColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ZuranoCustomerColors.primary.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomerLocationPill(),
          const SizedBox(height: 18),
          Text(
            l10n.customerHomeSearchHeadline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.customerHomeSearchSubtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          const CustomerDiscoverySearchBar(),
          const SizedBox(height: 14),
          const CustomerQuickFilterChips(),
        ],
      ),
    );
  }
}

