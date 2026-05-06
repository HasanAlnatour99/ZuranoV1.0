import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employee_today/presentation/employee_today_theme.dart';
import '../../data/models/booking.dart';

/// Horizontal preview of upcoming bookings (Zurano / owner premium styling).
///
/// Hidden when [bookings] is empty. Shows at most [maxVisible] cards; use a
/// horizontal [ListView] so additional items scroll off-screen.
class BookingsPreviewContainer extends StatelessWidget {
  const BookingsPreviewContainer({
    super.key,
    required this.title,
    required this.bookings,
    required this.l10n,
    required this.localeName,
    this.maxVisible = 3,
    this.onViewAll,
    this.onTapBooking,
    this.useEmployeePalette = false,
  });

  final String title;
  final List<Booking> bookings;
  final AppLocalizations l10n;
  final String localeName;
  final int maxVisible;
  final VoidCallback? onViewAll;
  final void Function(Booking booking)? onTapBooking;
  final bool useEmployeePalette;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = bookings.take(maxVisible).toList(growable: false);
    final dateFmt = DateFormat.yMMMd(localeName);
    final timeFmt = DateFormat.jm(localeName);

    final border = useEmployeePalette
        ? EmployeeTodayColors.cardBorder
        : const Color(0xFFF0ECFF);
    final titleColor = useEmployeePalette
        ? EmployeeTodayColors.deepText
        : FinanceDashboardColors.textPrimary;
    final subtitleColor = useEmployeePalette
        ? EmployeeTodayColors.mutedText
        : FinanceDashboardColors.textSecondary;
    final accent = useEmployeePalette
        ? EmployeeTodayColors.primaryPurple
        : FinanceDashboardColors.primaryPurple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(l10n.bookingsPreviewViewAll),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final b = visible[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTapBooking == null ? null : () => onTapBooking!(b),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.customerName?.trim().isNotEmpty == true
                                    ? b.customerName!.trim()
                                    : l10n.bookingsPreviewGuestLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                localizedBookingStatus(l10n, b.status),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dateFmt.format(b.startAt.toLocal())} · ${timeFmt.format(b.startAt.toLocal())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.serviceName?.trim().isNotEmpty == true
                              ? b.serviceName!.trim()
                              : (b.barberName?.trim().isNotEmpty == true
                                    ? formatTeamMemberName(b.barberName)
                                    : b.barberId),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Active upcoming = pending or confirmed, and appointment not yet ended.
List<Booking> filterUpcomingBookings(Iterable<Booking> all) {
  final now = DateTime.now();
  final out = all.where((b) {
    final s = b.status;
    if (s != BookingStatuses.pending && s != BookingStatuses.confirmed) {
      return false;
    }
    return b.endAt.isAfter(now);
  }).toList();
  out.sort((a, b) => a.startAt.compareTo(b.startAt));
  return out;
}

/// Keeps bookings with [startAt] before [endExclusive] (typically now + 7 days).
List<Booking> filterBookingsStartingBefore(
  List<Booking> bookings,
  DateTime endExclusive,
) {
  return bookings
      .where((b) => b.startAt.isBefore(endExclusive))
      .toList(growable: false);
}
