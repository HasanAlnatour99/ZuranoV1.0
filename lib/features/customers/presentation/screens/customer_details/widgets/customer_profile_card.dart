import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/session_provider.dart';
import '../../../../data/models/customer.dart';
import '../../../../domain/customer_type_resolver.dart';
import 'customer_discount_sheet.dart';
import 'customer_insights_card.dart';
import 'customer_type_chips.dart';

class CustomerProfileCard extends ConsumerWidget {
  const CustomerProfileCard({
    super.key,
    required this.customer,
    required this.resolvedType,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
  });

  final Customer customer;
  final CustomerType resolvedType;
  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    return ('$a$b').toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEditDiscount = ref.watch(sessionUserProvider).asData?.value;
    final showDiscountEdit =
        canEditDiscount != null &&
        (canEditDiscount.role == 'owner' || canEditDiscount.role == 'admin');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1233).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0ECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFEDE9FE),
                    child: Text(
                      _initials(customer.visibleDisplayName),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                  if (customer.isVip)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFE6B95C),
                        size: 22,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.visibleDisplayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: FinanceDashboardColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 16,
                          color: FinanceDashboardColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.phone.isEmpty ? '—' : customer.phone,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFFF7F2FF),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: showDiscountEdit
                      ? () => showEditCustomerDiscountSheet(
                          context: context,
                          ref: ref,
                          customer: customer,
                        )
                      : null,
                  child: Container(
                    width: 88,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE9D8FD)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.customerDiscountBoxTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: FinanceDashboardColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${customer.discountPercentage.toStringAsFixed(customer.discountPercentage == customer.discountPercentage.roundToDouble() ? 0 : 1)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF6D28D9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.customerDiscountBoxSubtitle,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 9,
                            height: 1.2,
                            color: FinanceDashboardColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          CustomerTypeChips(
            customer: customer,
            resolvedType: resolvedType,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          CustomerInsightsCard(
            customer: customer,
            resolvedType: resolvedType,
            l10n: l10n,
            locale: locale,
            currencyCode: currencyCode,
          ),
        ],
      ),
    );
  }
}
