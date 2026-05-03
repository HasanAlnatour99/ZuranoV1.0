import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/zurano/zurano_gradient_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart'
    show servicesStreamProvider;
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../data/models/service.dart';
import '../../data/service_category_helpers.dart';
import '../widgets/empty_services_state.dart';
import '../widgets/service_card.dart';
import '../widgets/service_category_chips.dart';
import '../widgets/service_form_sheet.dart';
import '../widgets/service_search_bar.dart';
import '../widgets/service_stats_row.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Owner-facing services catalog: search, category filters, stats, and actions.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchC = TextEditingController();
  String _query = '';
  OwnerServiceCategorySelection? _categoryFilter;

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  List<SalonService> _applyFilters(
    List<SalonService> all,
    AppLocalizations l10n,
  ) {
    var list = all;
    final filter = _categoryFilter;
    if (filter != null) {
      list = list.where(filter.matches).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return list;
    }
    return list.where((s) {
      final nameEn = (s.serviceName.isNotEmpty ? s.serviceName : s.name)
          .toLowerCase();
      final nameAr = s.nameAr.toLowerCase();
      final cat = displayCategoryLineForService(s, l10n)?.toLowerCase() ?? '';
      return nameEn.contains(q) || nameAr.contains(q) || cat.contains(q);
    }).toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    SalonService s,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.ownerServiceDeleteConfirmTitle),
        content: Text(l10n.ownerServiceDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.ownerServiceActionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.ownerServiceActionDelete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref
          .read(serviceRepositoryProvider)
          .deleteService(widget.salonId, s.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ownerServiceDeletedSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final servicesAsync = ref.watch(servicesStreamProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    const ctaHeight = 56.0;
    const ctaBottomMargin = 16.0;
    const ctaHorizontalPadding = 24.0;
    const ctaGapAboveContent = 20.0;
    final contentBottomPadding =
        bottomSafe + ctaHeight + ctaBottomMargin + ctaGapAboveContent;

    return servicesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: ZuranoTokens.background,
        body: Center(
          child: CircularProgressIndicator(color: ZuranoTokens.primary),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: ZuranoTokens.background,
        body: Center(
          child: Text(
            l10n.genericError,
            style: const TextStyle(color: ZuranoTokens.textDark),
          ),
        ),
      ),
      data: (all) {
        final filtered = _applyFilters(all, l10n);
        final total = all.length;
        final active = all.where((s) => s.isActive).length;
        final inactive = total - active;

        return Scaffold(
          backgroundColor: ZuranoTokens.background,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: AddBarberHeader(
                        title: l10n.ownerServicesTitle,
                        subtitle: l10n.ownerServicesSubtitle,
                        compact: true,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        16,
                        24,
                        contentBottomPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ServiceStatsRow(
                            total: total,
                            active: active,
                            inactive: inactive,
                          ),
                          const SizedBox(height: 18),
                          ServiceSearchBar(
                            controller: _searchC,
                            hintText: l10n.ownerServicesSearchPlaceholder,
                            onChanged: (v) => setState(() => _query = v),
                          ),
                          const SizedBox(height: 16),
                          ServiceCategoryChips(
                            services: all,
                            selection: _categoryFilter,
                            onSelected: (c) =>
                                setState(() => _categoryFilter = c),
                          ),
                          const SizedBox(height: 20),
                          if (all.isEmpty)
                            Builder(
                              builder: (context) {
                                final h = MediaQuery.sizeOf(context).height;
                                final minH = (h - 420).clamp(200.0, 420.0);
                                return ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: minH),
                                  child: const Center(
                                    child: EmptyServicesState(
                                      showPrimary: false,
                                    ),
                                  ),
                                );
                              },
                            )
                          else if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Column(
                                children: [
                                  Icon(
                                    AppIcons.filter_alt_off_outlined,
                                    size: 40,
                                    color: ZuranoTokens.textGray.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.ownerServicesNoMatches,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ZuranoTokens.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...filtered.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: ServiceCard(
                                  service: s,
                                  currencyCode: currencyCode,
                                  locale: locale,
                                  onEdit: () => showOwnerServiceEditorSheet(
                                    context,
                                    salonId: widget.salonId,
                                    existing: s,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(context, l10n, s),
                                  onToggleActive: () async {
                                    await ref
                                        .read(serviceRepositoryProvider)
                                        .setServiceActiveState(
                                          salonId: widget.salonId,
                                          serviceId: s.id,
                                          isActive: !s.isActive,
                                        );
                                  },
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      ctaHorizontalPadding,
                      0,
                      ctaHorizontalPadding,
                      bottomSafe + ctaBottomMargin,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SizedBox(
                        height: ctaHeight,
                        child: ZuranoGradientButton(
                          label: l10n.ownerAddService,
                          icon: AppIcons.add_rounded,
                          onPressed: () => showOwnerServiceEditorSheet(
                            context,
                            salonId: widget.salonId,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
