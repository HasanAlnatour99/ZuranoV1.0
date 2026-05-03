import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../data/models/customer.dart';
import '../../domain/customer_model.dart';
import '../../logic/customer_providers.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_empty_state.dart';
import '../widgets/customer_filter_chips.dart';
import '../widgets/customer_info_banner.dart';
import '../widgets/customer_insight_card.dart';
import '../widgets/customer_list_footer.dart';
import '../widgets/customer_permission_error.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/customers_filter_empty_state.dart';
import '../widgets/customers_header.dart';
import '../widgets/customers_search_empty_state.dart';
import '../widgets/customers_premium_header.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key, this.ownerShellHeroEmbedded = false});

  /// When true, shown under [OwnerDashboardHeroTabScaffold] (shared hero + light canvas).
  final bool ownerShellHeroEmbedded;

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _selectedTag = 'All';

  @override
  void dispose() {
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
    final salonName = salonAsync.asData?.value?.name ?? '';
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    // Always stream the salon list; filter locally as the user types so we do
    // not swap to [customerSearchProvider] per keystroke (that re-ran a Future
    // and showed a full-screen loading spinner on every character).
    final rawAsync = ref.watch(customersListProvider(salonId));

    final canCreate =
        user != null && (user.role == 'owner' || user.role == 'admin');
    final embedded = widget.ownerShellHeroEmbedded;

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final clearanceBelowContent = embedded
        ? bottomInset + 16
        : bottomInset + 24;

    Widget content(AsyncValue<List<Customer>> async) {
      return async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: FinanceDashboardColors.primaryPurple,
          ),
        ),
        error: (error, _) {
          if (isCustomerPermissionDenied(error)) {
            return const CustomerPermissionError();
          }
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
        },
        data: (customers) {
          final filtered = _applyFilters(customers);
          final searchQuery = _searchController.text.trim();
          final filterEmpty =
              customers.isNotEmpty && filtered.isEmpty && salonId.isNotEmpty;
          final showListFooter =
              filtered.isNotEmpty && filtered.length < 5 && salonId.isNotEmpty;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, embedded ? 36 : 0, 20, 0),
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
                      ] else ...[
                        const CustomerInfoBanner(),
                        const SizedBox(height: 16),
                      ],
                      CustomersHeader(
                        count: filtered.length,
                        onFilterTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.customersScreenTitle)),
                          );
                        },
                      ),
                      if (salonId.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        CustomerInsightCard(salonId: salonId),
                      ],
                      const SizedBox(height: 16),
                      CustomerSearchBar(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      CustomerFilterChips(
                        selectedKey: _selectedTag,
                        onSelected: (v) => setState(() => _selectedTag = v),
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
                        if (index >= filtered.length + (showListFooter ? 1 : 0)) {
                          return null;
                        }
                        if (showListFooter && index == filtered.length) {
                          return const CustomerListFooter();
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
                      childCount:
                          filtered.length + (showListFooter ? 1 : 0),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    final bodyChild = salonId.isEmpty
        ? content(const AsyncData<List<Customer>>(<Customer>[]))
        : content(rawAsync);

    if (embedded) {
      return ColoredBox(
        color: FinanceDashboardColors.background,
        child: bodyChild,
      );
    }

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null)
            CustomersPremiumHeader(
              user: user,
              salonName: salonName,
              leading: context.canPop()
                  ? IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  : null,
            ),
          const SizedBox(height: 14),
          Expanded(child: bodyChild),
        ],
      ),
    );
  }
}
