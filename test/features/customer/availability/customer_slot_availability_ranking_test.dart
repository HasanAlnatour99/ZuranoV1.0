import 'package:barber_shop_app/features/customer/application/customer_slot_availability_service.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_draft.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_service_public_model.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_settings.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_team_member_public_model.dart';
import 'package:barber_shop_app/features/customer/data/repositories/customer_booking_availability_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAvailabilityRepo implements CustomerBookingAvailabilityRepository {
  _FakeAvailabilityRepo({required this.bookings});

  final List<Map<String, dynamic>> bookings;

  @override
  Future<CustomerBookingSettings> getBookingSettings(String salonId) async {
    return const CustomerBookingSettings(
      enabled: true,
      bookingSlotIntervalMinutes: 30,
      minimumNoticeMinutes: 0,
      allowSameDayBooking: true,
      bufferMinutes: 0,
    );
  }

  @override
  Future<Map<String, dynamic>> getWorkingHours({
    required String salonId,
    required DateTime date,
  }) async {
    return <String, dynamic>{'open': true, 'start': '09:00', 'end': '11:00'};
  }

  @override
  Future<List<Map<String, dynamic>>> getBookingsForDate({
    required String salonId,
    required DateTime date,
    String? excludeBookingId,
  }) async {
    return bookings;
  }
}

CustomerTeamMemberPublicModel _member({
  required String id,
  required int sortOrder,
  bool isActive = true,
  bool isBookable = true,
  bool allowCustomerBooking = true,
}) {
  return CustomerTeamMemberPublicModel(
    id: id,
    salonId: 'salon-1',
    fullName: 'M $id',
    displayName: 'M $id',
    roleLabel: 'Barber',
    isActive: isActive,
    isBookable: isBookable,
    allowCustomerBooking: allowCustomerBooking,
    ratingAverage: 0,
    ratingCount: 0,
    sortOrder: sortOrder,
  );
}

void main() {
  test('Any available prefers fewer bookings on date', () async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    final repo = _FakeAvailabilityRepo(
      bookings: [
        {
          'employeeId': 'b',
          'startAt': DateTime(day.year, day.month, day.day, 10, 0),
          'endAt': DateTime(day.year, day.month, day.day, 10, 30),
        },
        {
          'employeeId': 'b',
          'startAt': DateTime(day.year, day.month, day.day, 10, 30),
          'endAt': DateTime(day.year, day.month, day.day, 11, 0),
        },
      ],
    );
    final service = CustomerSlotAvailabilityService(repo);

    const svc = CustomerServicePublicModel(
      id: 's1',
      salonId: 'salon-1',
      name: 'Haircut',
      displayName: 'Haircut',
      category: 'hair',
      categoryLabel: 'Hair',
      price: 10,
      durationMinutes: 30,
      isActive: true,
      isCustomerVisible: true,
      sortOrder: 1,
    );

    final slots = await service.generateSlots(
      salonId: 'salon-1',
      date: day,
      draft: const CustomerBookingDraft(
        salonId: 'salon-1',
        anyAvailableEmployee: true,
        selectedServices: [svc],
        durationMinutes: 30,
      ),
      teamMembers: [
        _member(id: 'a', sortOrder: 1),
        _member(id: 'b', sortOrder: 2),
      ],
    );

    final first = slots.firstWhere((s) => s.isAvailable);
    expect(first.employeeId, 'a');
  });
}

