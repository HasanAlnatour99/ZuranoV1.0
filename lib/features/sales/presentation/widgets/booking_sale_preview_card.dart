import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/guest_booking_snapshot.dart';
import 'payment_status_chip.dart';

/// Read-only summary of a `guestBookings/{code}` row before POS conversion.
class BookingSalePreviewCard extends StatelessWidget {
  const BookingSalePreviewCard({
    super.key,
    required this.booking,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
  });

  final GuestBookingSnapshot booking;
  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final methodLabel = _paymentMethodLabel(l10n, booking.paymentMethod);
    final statusLabel = _paymentStatusLabel(l10n, booking.paymentStatus);
    final bookingStatusLabel = _bookingStatusLabel(l10n, booking.bookingStatus);
    final start = booking.appointmentStartAt;
    final end = booking.appointmentEndAt;
    final dateStr = DateFormat.yMMMd(locale.toString()).format(start);
    final timeStr =
        '${DateFormat.jm(locale.toString()).format(start)} – ${DateFormat.jm(locale.toString()).format(end)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FinanceDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.addSaleBookingFound,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: FinanceDashboardColors.textPrimary,
                  ),
                ),
              ),
              PaymentStatusChip(
                paymentMethodLabel: methodLabel,
                paymentStatusLabel: statusLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(l10n.addSaleBookingCodeLabel, booking.bookingCode),
          _row(l10n.addSaleBookingCustomer, booking.customerLabel),
          _row(
            l10n.addSaleBookingSalon,
            booking.salonName.trim().isEmpty ? '—' : booking.salonName,
          ),
          _row(
            l10n.addSaleBookingBarber,
            formatTeamMemberName(booking.barberName),
          ),
          _row(l10n.addSaleBookingStatus, bookingStatusLabel),
          const SizedBox(height: 12),
          Text(
            l10n.addSaleBookingSectionAppointment,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: FinanceDashboardColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateStr · $timeStr',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: FinanceDashboardColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.addSaleBookingSectionServices,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: FinanceDashboardColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in booking.serviceItems) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    line.name.trim().isEmpty ? '—' : line.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
                Text(
                  '${formatMoney(line.price, currencyCode, locale)} × ${line.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: FinanceDashboardColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          const Divider(height: 24),
          _moneyRow(
            l10n.addSaleBookingSubtotal,
            formatMoney(booking.subtotal, currencyCode, locale),
          ),
          _moneyRow(
            l10n.addSaleBookingDiscount,
            formatMoney(booking.discountAmount, currencyCode, locale),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.addSaleBookingTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                formatMoney(booking.totalAmount, currencyCode, locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: FinanceDashboardColors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.addSaleBookingSectionPayment,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: FinanceDashboardColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            methodLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: FinanceDashboardColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _moneyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: FinanceDashboardColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  static String _paymentMethodLabel(AppLocalizations l10n, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'cash':
        return l10n.paymentMethodCash;
      case 'card':
        return l10n.paymentMethodCard;
      case 'wallet':
        return l10n.addSalePaymentMethodWallet;
      default:
        return l10n.addSalePaymentMethodUnspecified;
    }
  }

  static String _paymentStatusLabel(AppLocalizations l10n, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return l10n.addSalePaymentStatusPending;
      case 'paid':
        return l10n.addSalePaymentStatusPaid;
      case 'failed':
        return l10n.addSalePaymentStatusFailed;
      case 'refunded':
        return l10n.addSalePaymentStatusRefunded;
      default:
        return raw.trim().isEmpty ? l10n.addSalePaymentStatusPending : raw;
    }
  }

  static String _bookingStatusLabel(AppLocalizations l10n, String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return l10n.bookingStatusPending;
      case 'confirmed':
        return l10n.bookingStatusConfirmed;
      case 'completed':
        return l10n.bookingStatusCompleted;
      case 'cancelled':
        return l10n.bookingStatusCancelled;
      case 'noshow':
      case 'no_show':
        return l10n.bookingStatusNoShow;
      default:
        return raw.trim().isEmpty ? '—' : raw;
    }
  }
}
