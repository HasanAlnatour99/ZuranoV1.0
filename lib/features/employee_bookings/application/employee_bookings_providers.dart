import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/data/models/booking.dart';
import '../../bookings/presentation/widgets/bookings_preview_container.dart';
import '../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../providers/repository_providers.dart';

/// Upcoming (pending/confirmed, not ended) bookings for the signed-in employee,
/// limited to [startAt] within the next 7 days (inclusive window from now).
final employeeBookingsNext7DaysProvider =
    StreamProvider.autoDispose<List<Booking>>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream.value(const <Booking>[]);
      }
      final eid = scope.employeeId.trim();
      final sid = scope.salonId.trim();
      if (eid.isEmpty || sid.isEmpty) {
        return Stream.value(const <Booking>[]);
      }
      final repo = ref.watch(bookingRepositoryProvider);
      final now = DateTime.now();
      final horizon = now.add(const Duration(days: 7));
      // Include in-progress appointments from earlier today; cap query window.
      final startFrom = now.subtract(const Duration(hours: 36));
      return repo
          .watchBookingsBySalon(
            sid,
            barberId: eid,
            startFrom: startFrom,
            startTo: horizon,
            limit: 120,
          )
          .map(filterUpcomingBookings);
    });
