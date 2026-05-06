import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../application/customer_popular_searches_provider.dart';
import '../../application/customer_recent_searches_controller.dart';
import '../../application/customer_search_controller.dart';
import '../../application/customer_search_view_state.dart';
import '../../domain/models/customer_search_filter.dart';
import '../../domain/models/customer_search_result.dart';
import '../../../../customer_home/presentation/theme/zurano_customer_colors.dart';
import '../widgets/popular_searches_section.dart';
import '../widgets/recent_searches_section.dart';
import '../widgets/search_filter_bottom_sheet.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_quick_filter_strip.dart';
import '../widgets/search_suggestion_section.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({
    super.key,
    this.initialQuickFilter,
    this.initialSort,
  });

  final String? initialQuickFilter;
  final String? initialSort;

  @override
  ConsumerState<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final controller = TextEditingController();
  Timer? debounce;
  bool _initialFilterApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialFilterApplied) {
        return;
      }
      final qf = widget.initialQuickFilter?.trim();
      final s = widget.initialSort?.trim();
      if ((qf == null || qf.isEmpty) && (s == null || s.isEmpty)) {
        return;
      }
      _initialFilterApplied = true;
      ref.read(customerSearchControllerProvider.notifier).applyInitialQuickFilter(
            quickFilter: qf,
            sort: s,
          );
    });
  }

  void _onChanged(String value) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(customerSearchControllerProvider.notifier).updateQuery(value);
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _openFilters() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Theme(
        data: ZuranoCustomerColors.discoveryShellTheme(Theme.of(context)),
        child: const SearchFilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(customerSearchControllerProvider);
    final searchFilter = ref.read(customerSearchControllerProvider.notifier).filter;
    final recent = ref.watch(customerRecentSearchesControllerProvider);
    final popularAsync = ref.watch(customerPopularSearchesProvider);

    return Theme(
      data: ZuranoCustomerColors.discoveryShellTheme(Theme.of(context)),
      child: Scaffold(
      backgroundColor: ZuranoCustomerColors.searchBackground,
      body: SafeArea(
        child: Column(
          children: [
            _SearchTopInput(
              controller: controller,
              hintText: l10n.customerSearchHint,
              onChanged: _onChanged,
              onOpenFilters: _openFilters,
            ),
            const SearchQuickFilterStrip(),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollUpdateNotification) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                  return false;
                },
                child: resultsAsync.when(
                  data: (CustomerSearchViewState viewState) {
                    final items = viewState.results;
                    final q = controller.text.trim();
                    final showDiscoveryLanding =
                        q.isEmpty &&
                        searchFilter.sort == CustomerSearchSort.recommended &&
                        !searchFilter.nearbyOnly &&
                        !searchFilter.openNowOnly &&
                        !searchFilter.offersOnly &&
                        !searchFilter.availableTodayOnly &&
                        searchFilter.audience == null;
                    if (showDiscoveryLanding) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        children: [
                          if (viewState.indexPermissionDenied)
                            _SearchIndexUnavailableNotice(
                              message: l10n.customerSearchIndexUnavailable,
                            ),
                          RecentSearchesSection(
                            title: l10n.customerSearchRecentTitle,
                            items: recent,
                            clearAllLabel: l10n.customerSearchClearAll,
                            onTapItem: (q) {
                              controller.text = q;
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                              ref
                                  .read(customerRecentSearchesControllerProvider.notifier)
                                  .add(q);
                              ref.read(customerSearchControllerProvider.notifier).updateQuery(q);
                            },
                            onClearAll: () => ref
                                .read(customerRecentSearchesControllerProvider.notifier)
                                .clear(),
                          ),
                          const SizedBox(height: 16),
                          PopularSearchesSection(
                            title: l10n.customerSearchPopularTitle,
                            itemsAsync: popularAsync,
                            onTapItem: (label) {
                              controller.text = label;
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                              ref
                                  .read(customerRecentSearchesControllerProvider.notifier)
                                  .add(label);
                              ref
                                  .read(customerSearchControllerProvider.notifier)
                                  .updateQuery(label);
                            },
                          ),
                          const SizedBox(height: 16),
                          SearchSuggestionSection(
                            title: l10n.customerSearchTryTitle,
                            suggestions: [
                              l10n.customerSearchTryHaircut,
                              l10n.customerSearchTryBeard,
                              l10n.customerSearchTrySalonNearYou,
                              l10n.customerSearchTrySpecialist,
                            ],
                            onTapSuggestion: (label) {
                              controller.text = label;
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                              ref
                                  .read(customerRecentSearchesControllerProvider.notifier)
                                  .add(label);
                              ref
                                  .read(customerSearchControllerProvider.notifier)
                                  .updateQuery(label);
                            },
                          ),
                        ],
                      );
                    }

                    if (items.isEmpty) {
                      if (viewState.indexPermissionDenied) {
                        return _SearchMessageView(
                          title: l10n.customerSearchErrorTitle,
                          message: l10n.customerSearchIndexUnavailable,
                        );
                      }
                      return _SearchMessageView(
                        title: l10n.customerSearchNoResultsTitle,
                        message: l10n.customerSearchNoResultsMessage,
                      );
                    }

                    final grouped = _group(items);
                    final tiles = <Widget>[];
                    void addGroup(CustomerSearchResultType type, String title) {
                      final list = grouped[type] ?? const <CustomerSearchResult>[];
                      if (list.isEmpty) return;
                      tiles.add(Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8, top: 10),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ));
                      for (final r in list) {
                        tiles.add(SearchResultTile(result: r));
                      }
                    }

                    addGroup(CustomerSearchResultType.service, l10n.customerSearchGroupServices);
                    addGroup(CustomerSearchResultType.specialist, l10n.customerSearchGroupSpecialists);
                    addGroup(CustomerSearchResultType.salon, l10n.customerSearchGroupPlaces);

                    return ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      children: [
                        if (viewState.showLocationHintForNearby)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LocationHintBanner(
                              message: l10n.customerSearchEnableLocationForNearby,
                            ),
                          ),
                        if (viewState.indexPermissionDenied)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SearchIndexUnavailableNotice(
                              message: l10n.customerSearchIndexUnavailable,
                            ),
                          ),
                        ...tiles,
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _SearchMessageView(
                    title: l10n.customerSearchErrorTitle,
                    message: e.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Map<CustomerSearchResultType, List<CustomerSearchResult>> _group(
    List<CustomerSearchResult> items,
  ) {
    final out = <CustomerSearchResultType, List<CustomerSearchResult>>{};
    for (final r in items) {
      (out[r.type] ??= <CustomerSearchResult>[]).add(r);
    }
    return out;
  }
}

class _SearchTopInput extends StatelessWidget {
  const _SearchTopInput({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onOpenFilters,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return Material(
                  elevation: 6,
                  shadowColor: ZuranoCustomerColors.primary.withValues(alpha: 0.12),
                  borderRadius: radius,
                  color: Colors.white,
                  child: TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  cursorColor: ZuranoCustomerColors.primary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ZuranoCustomerColors.textStrong,
                        fontWeight: FontWeight.w600,
                      ),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ZuranoCustomerColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide(
                        color: ZuranoCustomerColors.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: const BorderSide(
                        color: ZuranoCustomerColors.primary,
                        width: 1.5,
                      ),
                    ),
                    border: OutlineInputBorder(borderRadius: radius),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ZuranoCustomerColors.primary.withValues(alpha: 0.85),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasText)
                          IconButton(
                            tooltip:
                                MaterialLocalizations.of(context).deleteButtonTooltip,
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: ZuranoCustomerColors.textMuted,
                            ),
                          ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                          onPressed: onOpenFilters,
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: ZuranoCustomerColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationHintBanner extends StatelessWidget {
  const _LocationHintBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZuranoCustomerColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZuranoCustomerColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_off_rounded, color: ZuranoCustomerColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ZuranoCustomerColors.textStrong,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchIndexUnavailableNotice extends StatelessWidget {
  const _SearchIndexUnavailableNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.schedule_rounded, size: 20, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMessageView extends StatelessWidget {
  const _SearchMessageView({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

