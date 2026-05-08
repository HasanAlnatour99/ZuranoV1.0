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
  static const _placeholderGray = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    final hint = l10n.customerHomeSearchPlaceholder;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        onTap: _openSearch,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: ZuranoCustomerColors.primary,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: _placeholderGray,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openFilters,
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ZuranoCustomerColors.primary,
                          Color(0xFFA855F7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

