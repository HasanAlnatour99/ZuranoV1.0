import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../data/models/customer.dart';
import '../../domain/customer_model.dart';
import '../../logic/customer_list_controller.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_empty_state.dart';
import '../widgets/customer_filter_chips.dart';
import '../widgets/customer_insight_empty_card.dart';
import '../widgets/customer_list_footer.dart';
import '../widgets/customer_premium_header.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/customers_section_header.dart';
import '../widgets/customers_filter_empty_state.dart';
import '../widgets/customers_search_empty_state.dart';
import '../widgets/golden_customers_card.dart';

const _customersPremiumBg = Color(0xFFFAF8FF);

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key, this.ownerShellHeroEmbedded = false});

  /// When true, rendered inside the owner shell without adding another Scaffold.
  final bool ownerShellHeroEmbedded;

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _selectedTag = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref
        .read(customerListControllerProvider.notifier)
        .updateSearch(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _applyFilters(List<Customer> customers) {
    final qRaw = _searchController.text.trim();
    final q = normalizeCustomerName(qRaw);
    final queryDigits = normalizeCustomerPhone(qRaw);
    return customers.where((c) {
      final searchOk = q.isEmpty ||
          c.normalizedFullName.contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          c.phone.toLowerCase().contains(q) ||
          (queryDigits != null &&
              queryDigits.isNotEmpty &&
              (c.normalizedPhoneNumber?.contains(queryDigits) ?? false));
      final seg = segmentForCustomer(c);
      final tagOk = switch (_selectedTag) {
        'All' => c.isActive,
        'New' => c.isActive && seg == CustomerSegment.newCustomer,
        'Regular' => c.isActive && seg == CustomerSegment.regular,
        'VIP' => c.isActive && seg == CustomerSegment.vip,
        'Inactive' => !c.isActive,
        _ => true,
      };
      return searchOk && tagOk;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedTag = 'All';
      _searchController.clear();
    });
  }

  void _clearSearchOnly() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final salon = salonAsync.asData?.value;
    final salonName = salon?.name ?? '';
    final showProBadge =
        (salon?.subscriptionPlan ?? '').trim().toLowerCase() == 'pro';
    final unreadNotifications = ref.watch(unreadNotificationCountProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final listAsync = ref.watch(customerListControllerProvider);

    final canCreate =
        user != null && (user.role == 'owner' || user.role == 'admin');
    final embedded = widget.ownerShellHeroEmbedded;

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final clearanceBelowContent = embedded
        ? bottomInset + 16
        : bottomInset + 24;

    Widget content() {
      final listState = listAsync.asData?.value ?? CustomerListState.initial();
      // Match team pattern: ignore transient [AsyncLoading] once we have data.
      // Otherwise brief notifier reloads full-screen block the whole tab.
      final blockingListLoad = listState.isLoadingInitial ||
          (listAsync.isLoading && !listAsync.hasValue);
      if (blockingListLoad) {
        return const Center(
          child: CircularProgressIndicator(
            color: FinanceDashboardColors.primaryPurple,
          ),
        );
      }

      if (listAsync.hasError || listState.errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.customersGenericLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FinanceDashboardColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      final customers = listState.customers;
      final filtered = _applyFilters(customers);
      final searchQuery = _searchController.text.trim();
      final filterEmpty =
          customers.isNotEmpty && filtered.isEmpty && salonId.isNotEmpty;
      final showListFooter =
          filtered.isNotEmpty && filtered.length < 5 && salonId.isNotEmpty;
      final showLoadMore =
          salonId.isNotEmpty && listState.hasMore && filtered.isNotEmpty;

      return CustomScrollView(
        slivers: [
          if (user != null)
            SliverToBoxAdapter(
              child: _CustomerHeaderStack(
                ownerName: user.name,
                salonName: salonName,
                showProBadge: showProBadge,
                unreadNotifications: unreadNotifications,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (salonId.isEmpty) ...[
                    Text(
                      l10n.ownerServicesWaitingForSalon,
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomersSectionHeader(
                    count: customers.length,
                    onFilterTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.customersScreenTitle)),
                      );
                    },
                  ),
                  if (salonId.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const CustomerInsightEmptyCard(),
                  ],
                  const SizedBox(height: 16),
                  CustomerSearchBar(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  CustomerFilterChips(
                    selectedKey: _selectedTag,
                    onSelected: (v) {
                      setState(() => _selectedTag = v);
                      ref
                          .read(customerListControllerProvider.notifier)
                          .updateFilter(
                            switch (v) {
                              'All' => 'All',
                              'New' => 'new',
                              'Regular' => 'regular',
                              'VIP' => 'vip',
                              'Inactive' => 'Inactive',
                              _ => 'All',
                            },
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (customers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: clearanceBelowContent),
                child: searchQuery.isNotEmpty
                    ? CustomersSearchEmptyState(
                        onClearSearch: _clearSearchOnly,
                      )
                    : CustomerEmptyState(
                        canCreate: canCreate,
                        onAddCustomer: canCreate
                            ? () => context.push(AppRoutes.customerNew)
                            : null,
                      ),
              ),
            )
          else if (filterEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: clearanceBelowContent),
                child: CustomersFilterEmptyState(
                  onClearFilters: _resetFilters,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                clearanceBelowContent + (embedded ? 120 : 8),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final extraCount =
                        (showListFooter ? 1 : 0) + (showLoadMore ? 1 : 0);
                    if (index >= filtered.length + extraCount) {
                      return null;
                    }
                    if (showListFooter && index == filtered.length) {
                      return const CustomerListFooter();
                    }
                    if (showLoadMore &&
                        index == filtered.length +
                            (showListFooter ? 1 : 0)) {
                      final isLoading = listState.isLoadingMore;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => ref
                                  .read(customerListControllerProvider.notifier)
                                  .loadMore(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: FinanceDashboardColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color:
                                        FinanceDashboardColors.primaryPurple,
                                  ),
                                )
                              : Text(l10n.customersLoadMore),
                        ),
                      );
                    }
                    final c = filtered[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == filtered.length - 1 && !showListFooter
                            ? 0
                            : 12,
                      ),
                      child: CustomerCard(
                        customer: c,
                        l10n: l10n,
                        localeName: localeName,
                        currencyCode: currencyCode,
                        listIndex: index,
                        onTap: () => context.push(
                          AppRoutes.ownerCustomerDetails(c.id),
                        ),
                        onOpenProfile: () => context.push(
                          AppRoutes.ownerCustomerDetails(c.id),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length +
                      (showListFooter ? 1 : 0) +
                      (showLoadMore ? 1 : 0),
                ),
              ),
            ),
        ],
      );
    }

    final bodyChild = content();

    if (embedded) {
      return ColoredBox(
        color: _customersPremiumBg,
        child: bodyChild,
      );
    }

    return Scaffold(
      backgroundColor: _customersPremiumBg,
      body: bodyChild,
    );
  }
}

class _CustomerHeaderStack extends StatelessWidget {
  const _CustomerHeaderStack({
    required this.ownerName,
    required this.salonName,
    required this.showProBadge,
    required this.unreadNotifications,
  });

  final String ownerName;
  final String salonName;
  final bool showProBadge;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 374,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomerPremiumHeader(
            ownerName: ownerName,
            salonName: salonName,
            showProBadge: showProBadge,
            unreadNotifications: unreadNotifications,
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            top: 246,
            child: GoldenCustomersCard(onTap: () {}),
          ),
        ],
      ),
    );
  }
}
