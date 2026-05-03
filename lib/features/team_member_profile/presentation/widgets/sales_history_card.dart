import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../sales/data/models/sale.dart';
import '../../../../l10n/app_localizations.dart';
import '../theme/team_member_profile_colors.dart';

class SalesHistoryCard extends StatelessWidget {
  const SalesHistoryCard({
    super.key,
    required this.sale,
    required this.currencyCode,
  });

  final Sale sale;
  final String currencyCode;

  static String? _trimmedReceiptUrl(Sale sale) {
    final u = sale.receiptPhotoUrl?.trim();
    if (u == null || u.isEmpty) return null;
    return u;
  }

  static String _paymentLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case SalePaymentMethods.cash:
        return l10n.paymentMethodCash;
      case SalePaymentMethods.card:
        return l10n.paymentMethodCard;
      case SalePaymentMethods.mixed:
        return l10n.paymentMethodMixed;
      case SalePaymentMethods.digitalWallet:
        return l10n.paymentMethodDigitalWallet;
      case SalePaymentMethods.other:
        return l10n.paymentMethodOther;
      default:
        return code.trim().isEmpty ? l10n.paymentMethodOther : code;
    }
  }

  static Widget _receiptIconPlaceholder() {
    return const Icon(
      Icons.receipt_long_rounded,
      color: TeamMemberProfileColors.primary,
    );
  }

  static void _openReceiptViewer(
    BuildContext context,
    AppLocalizations l10n,
    String imageUrl,
  ) {
    final media = MediaQuery.of(context);
    final maxH = media.size.height * 0.75;
    final maxW = media.size.width - 32;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  end: 4,
                  top: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.teamMemberSalesReceiptViewerTitle,
                        style: Theme.of(dialogContext).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(
                        dialogContext,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: maxW.clamp(0.0, media.size.width),
                height: maxH.clamp(200.0, media.size.height),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Center(
                    child: AppNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Theme.of(
                            dialogContext,
                          ).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final localeTag = locale.toString();
    final timeFormat = DateFormat('dd MMM yyyy • hh:mm a', localeTag);
    final customerLabel =
        (sale.customerName != null && sale.customerName!.trim().isNotEmpty)
        ? sale.customerName!.trim()
        : l10n.teamMemberSalesWalkInCustomer;
    final servicesSummary = sale.lineItems.isEmpty
        ? (sale.serviceNames.isEmpty
              ? l10n.teamMemberSalesServiceSummaryFallback
              : sale.serviceNames.join(', '))
        : sale.lineItems.map((e) => e.serviceName).join(', ');
    final payLabel = _paymentLabel(l10n, sale.paymentMethod);
    final receiptUrl = _trimmedReceiptUrl(sale);

    final lead = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.softPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: receiptUrl != null
          ? AppNetworkImage(
              imageUrl: receiptUrl,
              fit: BoxFit.cover,
              placeholder: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: Center(child: _receiptIconPlaceholder()),
            )
          : Center(child: _receiptIconPlaceholder()),
    );

    final leadWidget = receiptUrl != null
        ? Semantics(
            label: l10n.teamMemberSalesReceiptTapToEnlarge,
            button: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openReceiptViewer(context, l10n, receiptUrl),
                borderRadius: BorderRadius.circular(16),
                child: lead,
              ),
            ),
          )
        : lead;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TeamMemberProfileColors.border),
        boxShadow: [
          BoxShadow(
            color: TeamMemberProfileColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          leadWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: TeamMemberProfileColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  servicesSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeFormat.format(sale.soldAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(sale.total, currencyCode, locale),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: TeamMemberProfileColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: TeamMemberProfileColors.softPurple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  payLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TeamMemberProfileColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
