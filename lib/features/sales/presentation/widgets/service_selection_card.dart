import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../services/data/models/service.dart';
import '../providers/add_sale_controller.dart';
import 'service_quick_card.dart';
import 'selected_service_tile.dart';

class ServiceSelectionCard extends StatefulWidget {
  const ServiceSelectionCard({
    super.key,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.services,
    required this.lines,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onServiceTap,
    required this.onRemoveLine,
    this.showManageServicesLink = true,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;
  final List<SalonService> services;
  final List<CartLine> lines;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SalonService> onServiceTap;
  final ValueChanged<String> onRemoveLine;

  /// When false, the link to salon service management is hidden (e.g. employee role).
  final bool showManageServicesLink;

  @override
  State<ServiceSelectionCard> createState() => _ServiceSelectionCardState();
}

class _ServiceSelectionCardState extends State<ServiceSelectionCard> {
  late final TextEditingController _searchController;

  /// Nullable + lazy getters so hot reload (which does not rerun [initState] on
  /// preserved [State]) still creates controllers on first [build].
  ScrollController? _selectedLinesScrollController;
  ScrollController? _servicesListScrollController;

  ScrollController get _effectiveSelectedLinesScroll =>
      _selectedLinesScrollController ??= ScrollController();

  ScrollController get _effectiveServicesListScroll =>
      _servicesListScrollController ??= ScrollController();

  static const double _servicesListMaxHeight = 280;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(ServiceSelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectedLinesScrollController?.dispose();
    _servicesListScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final q = widget.searchQuery.trim().toLowerCase();
    final filtered = widget.services.where((s) {
      if (q.isEmpty) return true;
      final nameEn = (s.serviceName.trim().isNotEmpty ? s.serviceName : s.name)
          .toLowerCase();
      final nameAr = s.nameAr.toLowerCase();
      return nameEn.contains(q) || nameAr.contains(q);
    }).toList();

    final selectedMaxHeight = (widget.lines.length * 56.0).clamp(0.0, 156.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: FinanceDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: FinanceDashboardColors.lightPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  color: FinanceDashboardColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.addSaleSelectServicesTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: FinanceDashboardColors.textPrimary,
                  ),
                ),
              ),
              if (widget.showManageServicesLink)
                TextButton(
                  onPressed: () => context.push(AppRoutes.ownerServices),
                  style: TextButton.styleFrom(
                    foregroundColor: FinanceDashboardColors.deepPurple,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: Text(l10n.addSaleManageServices),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: FinanceDashboardColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FinanceDashboardColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: FinanceDashboardColors.textSecondary.withValues(
                    alpha: 0.76,
                  ),
                ),
                suffixIcon: widget.searchQuery.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.addSaleClearSearchTooltip,
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: FinanceDashboardColors.textSecondary
                              .withValues(alpha: 0.74),
                        ),
                      ),
                hintText: l10n.addSaleSearchServicesHint,
                hintStyle: const TextStyle(
                  color: FinanceDashboardColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
          ),
          if (widget.lines.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.addSaleSelectedServicesTitle(widget.lines.length),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: FinanceDashboardColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FinanceDashboardColors.background.withValues(
                  alpha: 0.72,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FinanceDashboardColors.border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: selectedMaxHeight),
                child: Scrollbar(
                  controller: _effectiveSelectedLinesScroll,
                  thumbVisibility: widget.lines.length > 2,
                  child: ListView(
                    controller: _effectiveSelectedLinesScroll,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: widget.lines.length > 2
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    children: [
                      for (final line in widget.lines)
                        SelectedServiceTile(
                          dense: true,
                          title: '${line.serviceName} × ${line.quantity}',
                          subtitle: l10n.addSaleSelectedServiceLineSubtitle,
                          priceLabel: formatAppMoney(
                            line.lineTotal,
                            widget.currencyCode,
                            widget.locale,
                          ),
                          categoryKey: line.categoryKey,
                          iconKey: line.iconKey,
                          onRemove: () => widget.onRemoveLine(line.serviceId),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.addSaleAllServicesSectionTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: FinanceDashboardColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: _servicesListMaxHeight,
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.services.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.addSaleNoActiveServicesYet,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: FinanceDashboardColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.addSaleCreateServicesFirst,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: FinanceDashboardColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              l10n.customerNoServicesListed,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: FinanceDashboardColors.textSecondary,
                              ),
                            ),
                    ),
                  )
                : Scrollbar(
                    controller: _effectiveServicesListScroll,
                    thumbVisibility: filtered.length > 4,
                    child: ListView.separated(
                      controller: _effectiveServicesListScroll,
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final name = s.localizedTitleForLanguageCode(
                          widget.locale.languageCode,
                        );
                        final selected = widget.lines.any(
                          (e) => e.serviceId == s.id,
                        );
                        return ServiceQuickCard(
                          compact: true,
                          title: name,
                          priceLabel: formatAppMoney(
                            s.price,
                            widget.currencyCode,
                            widget.locale,
                          ),
                          categoryKey: s.categoryKey,
                          iconKey: s.iconKey,
                          isSelected: selected,
                          onTap: () => widget.onServiceTap(s),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
