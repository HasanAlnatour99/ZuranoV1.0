import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/sale.dart';
import '../utils/sale_customer_display.dart';

class EmployeeRecentSalesList extends StatelessWidget {
  const EmployeeRecentSalesList({
    super.key,
    required this.sales,
    required this.currencyCode,
    required this.locale,
  });

  final List<Sale> sales;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFmt = DateFormat.jm(locale.toString());
    final show = sales.take(5).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.employeeSalesRecentTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: Color(0xFF111827),
            ),
          ),
          if (show.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    l10n.salesRecentEmptyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.employeeSalesEmptyCta,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            )
          else
            ...show.map(
              (s) => _SaleRow(
                sale: s,
                currencyCode: currencyCode,
                locale: locale,
                timeFmt: timeFmt,
              ),
            ),
          if (show.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.employeeSalesShowingLatest(show.length),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _openSaleReceiptFullScreen(BuildContext context, String imageUrl) {
  final l10n = AppLocalizations.of(context)!;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(l10n.teamMemberSalesReceiptViewerTitle),
          ),
          body: SafeArea(
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 56,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

String? _trimmedReceiptUrl(Sale sale) {
  final u = sale.receiptPhotoUrl?.trim();
  if (u == null || u.isEmpty) return null;
  return u;
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({
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
    final url = _trimmedReceiptUrl(sale);
    if (url == null) return _initialsAvatar();

    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.teamMemberSalesReceiptTapToEnlarge,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openSaleReceiptFullScreen(context, url),
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
