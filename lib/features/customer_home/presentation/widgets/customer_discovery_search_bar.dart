import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customer/search/presentation/widgets/search_filter_bottom_sheet.dart';
import '../theme/zurano_customer_colors.dart';

class CustomerDiscoverySearchBar extends ConsumerStatefulWidget {
  const CustomerDiscoverySearchBar({super.key});

  @override
  ConsumerState<CustomerDiscoverySearchBar> createState() =>
      _CustomerDiscoverySearchBarState();
}

class _CustomerDiscoverySearchBarState
    extends ConsumerState<CustomerDiscoverySearchBar> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % 5);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openSearch() {
    HapticFeedback.selectionClick();
    context.push(AppRoutes.customerSearch);
  }

  void _openFilters() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hint = _hintForIndex(l10n, _index);

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _openSearch,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 58,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: ZuranoCustomerColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    hint,
                    key: ValueKey(hint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ZuranoCustomerColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openFilters,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ZuranoCustomerColors.primary,
                        ZuranoCustomerColors.headerGradientMid,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hintForIndex(AppLocalizations l10n, int index) {
    // Localized hints (no hardcoded UI strings).
    final localized = <String>[
      l10n.customerHomeSearchHintHaircut,
      l10n.customerHomeSearchHintBeard,
      l10n.customerHomeSearchHintSalonsNearby,
      l10n.customerHomeSearchHintSpecialists,
      l10n.customerHomeSearchHintSpaNails,
    ];
    if (localized.isEmpty) return l10n.customerSearchHint;
    return localized[index % localized.length];
  }
}

