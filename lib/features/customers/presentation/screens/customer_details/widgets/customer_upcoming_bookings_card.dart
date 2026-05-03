import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/booking_status_machine.dart';
import '../../../../../../core/constants/booking_statuses.dart';
import '../../../../../../core/text/team_member_name.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:barber_shop_app/features/bookings/data/models/booking.dart';

class CustomerUpcomingBookingsCard extends StatelessWidget {
  const CustomerUpcomingBookingsCard({
    super.key,
    required this.bookings,
    required this.l10n,
    required this.locale,
  });

  final List<Booking> bookings;
  final AppLocalizations l10n;
  final Locale locale;

  String _statusLabel(String raw) {
    final s = BookingStatusMachine.normalize(raw);
    return switch (s) {
      BookingStatuses.pending => l10n.bookingStatusPending,
      BookingStatuses.confirmed => l10n.bookingStatusConfirmed,
      BookingStatuses.completed => l10n.bookingStatusCompleted,
      BookingStatuses.cancelled => l10n.bookingStatusCancelled,
      BookingStatuses.rescheduled => l10n.bookingStatusRescheduled,
      BookingStatuses.noShow => l10n.bookingStatusNoShow,
      _ => raw,
    };
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = [...bookings]
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final next = upcoming.isEmpty ? null : upcoming.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0ECFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerUpcomingSectionTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: FinanceDashboardColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (next == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.customerUpcomingEmptyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(next.status),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: Color(0xFF6D28D9),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.yMMMd(
                          locale.toString(),
                        ).add_jm().format(next.startAt.toLocal()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    next.serviceName ??
                        next.serviceId ??
                        l10n.customerDetailsServiceFallback,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (next.barberName?.trim().isNotEmpty == true)
                        ? formatTeamMemberName(next.barberName)
                        : next.barberId,
                    style: const TextStyle(
                      color: FinanceDashboardColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
