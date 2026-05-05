import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerSelectorTile extends StatelessWidget {
  const CustomerSelectorTile({
    super.key,
    required this.l10n,
    required this.customerName,
    required this.walkInPhone,
    required this.linkedCustomerId,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final String customerName;
  final String walkInPhone;
  final String? linkedCustomerId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasName = customerName.trim().isNotEmpty;
    final linked = linkedCustomerId?.trim().isNotEmpty ?? false;
    final phoneWalkIn = walkInPhone.trim();

    final primary = hasName
        ? customerName.trim()
        : l10n.addSaleWalkInCustomer;

    final String secondary;
    if (!hasName) {
      secondary = l10n.addSaleCustomerNoDetails;
    } else if (linked) {
      secondary = l10n.addSaleCustomerLinkedSubtitle;
    } else if (phoneWalkIn.isNotEmpty) {
      secondary = phoneWalkIn;
    } else {
      secondary = l10n.addSaleCustomerWalkInSubtitle;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: FinanceDashboardColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: FinanceDashboardColors.lightPurple.withValues(
                      alpha: 0.72,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: FinanceDashboardColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ownerAddSaleCustomerHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FinanceDashboardColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        primary,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: FinanceDashboardColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondary,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FinanceDashboardColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: FinanceDashboardColors.lightPurple.withValues(
                      alpha: 0.42,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasName ? Icons.edit_rounded : Icons.add_rounded,
                        size: 17,
                        color: FinanceDashboardColors.primaryPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.addSaleAddNameLink,
                        style: const TextStyle(
                          color: FinanceDashboardColors.deepPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
