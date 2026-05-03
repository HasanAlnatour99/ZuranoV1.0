import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../employees/data/models/employee.dart';
import '../../../services/data/models/service.dart';
import '../../../users/data/models/app_user.dart';
import '../../data/models/salon_sales_settings.dart';
import '../../domain/add_sale_entry_mode.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/payment_method.dart';
import '../providers/add_sale_controller.dart';
import '../providers/salon_sales_settings_provider.dart';
import 'add_sale_payment_split_fields.dart';
import 'add_sale_receipt_section.dart';
import 'barber_selector_tile.dart';
import 'customer_selector_tile.dart';
import 'order_summary_card.dart';
import 'payment_method_selector.dart';
import 'service_selection_card.dart';

/// Classic cart-based add sale (services, barber, customer, payment, summary).
class ManualSaleForm extends ConsumerWidget {
  const ManualSaleForm({
    super.key,
    required this.user,
    required this.entryMode,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.activeServices,
    required this.activeEmployees,
    required this.onPickBarber,
    required this.onCustomerNameDialog,
    required this.onDiscountDialog,
    required this.canPickBarber,
    required this.showManageServicesLink,
    required this.allowedPayments,
  });

  final AppUser user;
  final AddSaleEntryMode entryMode;
  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;
  final List<SalonService> activeServices;
  final List<Employee> activeEmployees;
  final Future<void> Function(BuildContext, List<Employee>) onPickBarber;
  final Future<void> Function() onCustomerNameDialog;
  final Future<void> Function() onDiscountDialog;
  final bool canPickBarber;
  final bool showManageServicesLink;
  final Set<PosPaymentMethod> allowedPayments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addState = ref.watch(addSaleControllerProvider);
    final addNotifier = ref.read(addSaleControllerProvider.notifier);
    final settings =
        ref.watch(salonSalesSettingsStreamProvider).asData?.value ??
        SalonSalesSettings.defaults();
    final showDiscountEditor =
        entryMode != AddSaleEntryMode.employee ||
        settings.allowEmployeeDiscount;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: ServiceSelectionCard(
            l10n: l10n,
            locale: locale,
            currencyCode: currencyCode,
            services: activeServices,
            lines: addState.lines,
            searchQuery: addState.searchQuery,
            onSearchChanged: addNotifier.setSearchQuery,
            onServiceTap: addNotifier.addOrIncrementService,
            onRemoveLine: addNotifier.removeLine,
            showManageServicesLink: showManageServicesLink,
          ),
        ),
        if (entryMode != AddSaleEntryMode.employee)
          SliverToBoxAdapter(
            child: BarberSelectorTile(
              l10n: l10n,
              employees: activeEmployees,
              selectedId: addState.selectedBarberId,
              enabled: canPickBarber,
              onTap: () => onPickBarber(context, activeEmployees),
            ),
          ),
        SliverToBoxAdapter(
          child: CustomerSelectorTile(
            l10n: l10n,
            customerName: addState.customerName,
            onAddNameTap: onCustomerNameDialog,
          ),
        ),
        SliverToBoxAdapter(
          child: PaymentMethodSelector(
            selected: addState.paymentMethod,
            onChanged: addNotifier.setPaymentMethod,
            l10n: l10n,
            allowedMethods: allowedPayments,
          ),
        ),
        const SliverToBoxAdapter(child: AddSalePaymentSplitFields()),
        const SliverToBoxAdapter(child: AddSaleReceiptSection()),
        SliverToBoxAdapter(
          child: OrderSummaryCard(
            l10n: l10n,
            locale: locale,
            currencyCode: currencyCode,
            subtotal: addState.subtotal,
            discount: addState.totalDiscountAmount,
            total: addState.totalAmount,
            onDiscountTap: onDiscountDialog,
            showManualDiscountEditor: showDiscountEditor,
          ),
        ),
        if (addState.submitError != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                addState.submitError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
