import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';
import '../utils/sale_customer_display.dart';

/// Receipt preview in a centered modal (matches Employee Sales light/purple UI).
void showEmployeeSaleReceiptPopup(BuildContext context, String imageUrl) {
  final l10n = AppLocalizations.of(context)!;
  final media = MediaQuery.of(context);
  final maxCardW = math.min(420.0, media.size.width - 40);
  final imageAreaH = math
      .min(media.size.height * 0.58, 420.0)
      .clamp(220.0, 520.0);

  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxCardW),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 8, 10),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4ECFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Color(0xFF7C3AED),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.teamMemberSalesReceiptViewerTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  letterSpacing: -0.2,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                              tooltip: MaterialLocalizations.of(
                                dialogContext,
                              ).closeButtonTooltip,
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  SizedBox(
                    height: imageAreaH,
                    width: double.infinity,
                    child: InteractiveViewer(
                      minScale: 0.75,
                      maxScale: 4,
                      boundaryMargin: const EdgeInsets.all(20),
                      child: Center(
                        child: AppNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          errorWidget: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade400,
                            size: 52,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Text(
                      l10n.teamMemberSalesReceiptTapToEnlarge,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

String? trimmedSaleReceiptUrl(Sale sale) {
  final u = sale.receiptPhotoUrl?.trim();
  if (u == null || u.isEmpty) return null;
  return u;
}

/// One row in the employee recent sales / sales history lists.
class EmployeeSaleListRow extends StatelessWidget {
  const EmployeeSaleListRow({
    super.key,
    required this.sale,
    required this.currencyCode,
    required this.locale,
    required this.timeFmt,
  });

  final Sale sale;
  final String currencyCode;
  final Locale locale;
  final DateFormat timeFmt;

  String _initials(Sale s) {
    final name = visibleSaleCustomerName(s);
    if (name.isEmpty) {
      final sn = s.serviceNames.isNotEmpty ? s.serviceNames.first : '?';
      return sn.isNotEmpty ? sn.substring(0, 1).toUpperCase() : '?';
    }
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
          .toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFF4ECFF),
      child: Text(
        _initials(sale),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF7C3AED),
        ),
      ),
    );
  }

  Widget _receiptThumbnail(BuildContext context) {
    final url = trimmedSaleReceiptUrl(sale);
    if (url == null) return _initialsAvatar();

    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.teamMemberSalesReceiptTapToEnlarge,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showEmployeeSaleReceiptPopup(context, url),
          child: SizedBox(
            width: 44,
            height: 44,
            child: ClipOval(
              child: AppNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
                errorWidget: _initialsAvatar(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = visibleSaleCustomerName(sale);
    final title = resolved == 'Guest'
        ? AppLocalizations.of(context)!.addSaleWalkInCustomer
        : resolved;
    final services = sale.serviceNames.join(' + ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _receiptThumbnail(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      services,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeFmt.format(sale.soldAt.toLocal()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatAppMoney(sale.total, currencyCode, locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
