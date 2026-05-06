import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../bookings/data/booking_repository.dart';
import '../../../bookings/data/models/booking.dart';
import '../models/customer_booking_settings.dart';

abstract class CustomerBookingAvailabilityRepository {
  Future<CustomerBookingSettings> getBookingSettings(String salonId);

  Future<List<Map<String, dynamic>>> getBookingsForDate({
    required String salonId,
    required DateTime date,
    String? excludeBookingId,
  });

  Future<Map<String, dynamic>> getWorkingHours({
    required String salonId,
    required DateTime date,
  });
}

class FirestoreCustomerBookingAvailabilityRepository
    implements CustomerBookingAvailabilityRepository {
  FirestoreCustomerBookingAvailabilityRepository(
    this._firestore,
    this._bookings,
  );

  final FirebaseFirestore _firestore;
  final BookingRepository _bookings;

  static const _blockingStatuses = {
    'pending',
    'confirmed',
    'checkedIn',
    'checked_in',
  };

  @override
  Future<CustomerBookingSettings> getBookingSettings(String salonId) async {
    final doc = await _firestore.doc(FirestorePaths.publicSalon(salonId)).get();
    final data = doc.data();
    final raw = data?['customerBookingSettings'];
    return CustomerBookingSettings.fromMap(
      raw is Map<String, dynamic> ? raw : null,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getBookingsForDate({
    required String salonId,
    required DateTime date,
    String? excludeBookingId,
  }) async {
    final startLocal = DateTime(date.year, date.month, date.day);
    final endLocal = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final List<Booking> masks;
    try {
      masks = await _bookings.fetchDayBusyMask(
        salonId: salonId,
        startFromUtc: startLocal.toUtc(),
        startToUtc: endLocal.toUtc(),
      );
    } on Object {
      return const [];
    }

    return masks
        .where((b) {
          if (excludeBookingId != null &&
              excludeBookingId.isNotEmpty &&
              b.id == excludeBookingId) {
            return false;
          }
          return _blockingStatuses.contains(b.status.trim());
        })
        .map((b) {
          return <String, dynamic>{
            'employeeId': b.barberId,
            'employeeName': b.barberName,
            'startAt': b.startAt,
            'endAt': b.endAt,
            'status': b.status,
          };
        })
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> getWorkingHours({
    required String salonId,
    required DateTime date,
  }) async {
    final doc = await _firestore.doc(FirestorePaths.publicSalon(salonId)).get();
    final data = doc.data();
    final workingHours = data?['workingHours'];
    final key = _weekdayKey(date.weekday);
    if (workingHours is Map<String, dynamic>) {
      final day = workingHours[key];
      if (day is Map<String, dynamic>) {
        return day;
      }
    }
    return const {'open': true, 'start': '09:00', 'end': '21:00'};
  }

  static String _weekdayKey(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'monday',
      DateTime.tuesday => 'tuesday',
      DateTime.wednesday => 'wednesday',
      DateTime.thursday => 'thursday',
      DateTime.friday => 'friday',
      DateTime.saturday => 'saturday',
      DateTime.sunday => 'sunday',
      _ => 'monday',
    };
  }
}
