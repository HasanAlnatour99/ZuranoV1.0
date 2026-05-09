import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/constants/app_routes.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../data/models/customer.dart';
import '../../../../logic/customer_permissions_provider.dart';
import '../../../providers/customer_details_providers.dart';

class CustomerActionGrid extends ConsumerWidget {
  const CustomerActionGrid({
    super.key,
    required this.customer,
    required this.l10n,
    required this.canManageBookings,
  });

  final Customer customer;
  final AppLocalizations l10n;
  final bool canManageBookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(customerDetailsControllerProvider.notifier);
    final perms = ref.watch(customerPermissionsProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: l10n.customerDetailsCall,
                icon: Icons.call_rounded,
                onTap: customer.phone.trim().isEmpty
                    ? null
                    : () async {
                        try {
                          await controller.callCustomer(customer.phone);
                        } on Object catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('$e')));
                          }
                        }
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: l10n.customerDetailsWhatsApp,
                icon: Icons.chat_rounded,
                onTap: customer.phone.trim().isEmpty
                    ? null
                    : () async {
                        try {
                          await controller.openWhatsApp(customer.phone);
                        } on Object catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('$e')));
                          }
                        }
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: l10n.customerDetailsEdit,
                icon: Icons.edit_rounded,
                onTap: perms.canEditCustomer
                    ? () =>
                          context.push(AppRoutes.ownerCustomerEdit(customer.id))
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: l10n.customerBookAppointment,
                icon: Icons.calendar_month_rounded,
                filled: true,
                onTap: canManageBookings && perms.canBookAppointment
                    ? () => context.push(
                        '${AppRoutes.bookingsNew}?customerId=${customer.id}',
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: l10n.customerDetailsAddService,
                icon: Icons.shopping_cart_rounded,
                filled: true,
                onTap: perms.canAddSaleForCustomer
                    ? () => context.push(
                        AppRoutes.addSalePrefill(customerId: customer.id),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
      ],
    );
    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: FinanceDashboardColors.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        side: BorderSide(color: FinanceDashboardColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: child,
    );
  }
}
