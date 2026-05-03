import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/booking/booking_slot_exception.dart';
import '../../../core/constants/booking_statuses.dart';
import '../../../core/booking/availability_schedule.dart';
import '../../bookings/data/booking_not_authenticated_exception.dart';
import '../../bookings/data/booking_time_overlap_exception.dart';
import '../../bookings/data/models/booking.dart';
import '../../employees/data/models/employee.dart';
import '../../services/data/models/service.dart';
import '../../../providers/app_settings_providers.dart';
import '../../../providers/customer_salon_streams_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../domain/customer_booking_validator.dart';
import 'customer_booking_state.dart';

final customerBookingControllerProvider = NotifierProvider.autoDispose
    .family<CustomerBookingNotifier, CustomerBookingState, String>(
      CustomerBookingNotifier.new,
    );

class CustomerBookingNotifier extends Notifier<CustomerBookingState> {
  CustomerBookingNotifier(this.salonId);

  final String salonId;

  @override
  CustomerBookingState build() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    ref.listen(customerSalonServicesStreamProvider(salonId), (prev, next) {
      if (next.hasValue) {
        _tryApplyRescheduleFromCatalog();
      }
    });
    ref.listen(customerSalonBarbersStreamProvider(salonId), (prev, next) {
      if (next.hasValue) {
        _tryApplyRescheduleFromCatalog();
      }
    });

    return CustomerBookingState(selectedDay: day);
  }

  void setRescheduleBooking(Booking? booking) {
    if (booking == null) {
      state = state.copyWith(rescheduleBooking: null, rescheduleApplied: false);
      return;
    }
    final note = booking.notes?.trim();
    state = state.copyWith(
      rescheduleBooking: booking,
      rescheduleApplied: false,
      notes: (note != null && note.isNotEmpty) ? note : state.notes,
    );
    _tryApplyRescheduleFromCatalog();
  }

  void _tryApplyRescheduleFromCatalog() {
    final booking = state.rescheduleBooking;
    if (booking == null || state.rescheduleApplied) {
      return;
    }
    final sAsync = ref.read(customerSalonServicesStreamProvider(salonId));
    final bAsync = ref.read(customerSalonBarbersStreamProvider(salonId));
    if (!sAsync.hasValue || !bAsync.hasValue) {
      return;
    }
    _applyRescheduleBooking(sAsync.requireValue, bAsync.requireValue);
  }

  void _applyRescheduleBooking(
    List<SalonService> services,
    List<Employee> barbers,
  ) {
    final r = state.rescheduleBooking;
    if (r == null || state.rescheduleApplied) {
      return;
    }
    SalonService? svc;
    for (final s in services) {
      if (s.id == r.serviceId) {
        svc = s;
        break;
      }
    }
    Employee? emp;
    for (final b in barbers) {
      if (b.id == r.barberId) {
        emp = b;
        break;
      }
    }
    final loc = r.startAt.toLocal();
    state = state.copyWith(
      service: svc,
      barber: emp,
      selectedDay: DateTime(loc.year, loc.month, loc.day),
      slotStartUtc: null,
      rescheduleApplied: true,
    );
  }

  void setSelectedDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDay: normalized,
      slotStartUtc: null,
      submissionErrorCode: null,
    );
  }

  void selectService(SalonService? service) {
    state = state.copyWith(
      service: service,
      barber: null,
      slotStartUtc: null,
      submissionErrorCode: null,
    );
  }

  void selectBarber(Employee? barber) {
    state = state.copyWith(
      barber: barber,
      slotStartUtc: null,
      submissionErrorCode: null,
    );
  }

  void selectSlotUtc(DateTime? slotUtc) {
    state = state.copyWith(slotStartUtc: slotUtc, submissionErrorCode: null);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value, submissionErrorCode: null);
  }

  void pickRecommendation({
    required Employee barber,
    required DateTime slotUtc,
  }) {
    state = state.copyWith(
      barber: barber,
      slotStartUtc: slotUtc,
      submissionErrorCode: null,
    );
  }

  /// Returns new booking id on success, or `null` on validation or failure.
  Future<String?> submitNewBooking() async {
    final notesErr = CustomerBookingValidator.notesErrorIfInvalid(state.notes);
    if (notesErr != null) {
      state = state.copyWith(submissionErrorCode: notesErr);
      return null;
    }

    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) {
      state = state.copyWith(submissionErrorCode: 'not_authenticated');
      return null;
    }

    final service = state.service;
    final barber = state.barber;
    final slot = state.slotStartUtc;
    if (state.selectedDay == null ||
        service == null ||
        barber == null ||
        slot == null) {
      state = state.copyWith(submissionErrorCode: 'incomplete');
      return null;
    }

    state = state.copyWith(isSubmitting: true, submissionErrorCode: null);

    final start = slot;
    final end = start.add(Duration(minutes: service.durationMinutes));
    final lang = ref.read(appLocalePreferenceProvider).languageCode;

    final booking = Booking(
      id: '',
      salonId: salonId,
      barberId: barber.id,
      customerId: user.uid,
      startAt: start,
      endAt: end,
      status: BookingStatuses.pending,
      barberName: barber.name,
      customerName: user.name,
      serviceId: service.id,
      serviceName: service.localizedTitleForLanguageCode(lang),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
    );

    try {
      final id = await ref
          .read(bookingRepositoryProvider)
          .createBooking(
            salonId,
            booking,
            slotStepMinutes: kCustomerSlotStepMinutes,
          );
      state = state.copyWith(isSubmitting: false);
      return id;
    } on BookingNotAuthenticatedException {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'not_authenticated',
      );
      return null;
    } on BookingSlotException {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'slot_invalid',
      );
      return null;
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'unknown',
      );
      return null;
    }
  }

  Future<bool> submitReschedule() async {
    final notesErr = CustomerBookingValidator.notesErrorIfInvalid(state.notes);
    if (notesErr != null) {
      state = state.copyWith(submissionErrorCode: notesErr);
      return false;
    }

    final reschedule = state.rescheduleBooking;
    final service = state.service;
    final barber = state.barber;
    final slot = state.slotStartUtc;
    if (reschedule == null ||
        service == null ||
        barber == null ||
        slot == null) {
      state = state.copyWith(submissionErrorCode: 'incomplete');
      return false;
    }

    state = state.copyWith(isSubmitting: true, submissionErrorCode: null);

    final start = slot;
    final end = start.add(Duration(minutes: service.durationMinutes));

    try {
      await ref
          .read(bookingRepositoryProvider)
          .rescheduleBooking(
            salonId: salonId,
            bookingId: reschedule.id,
            startAt: start,
            endAt: end,
            slotStepMinutes:
                reschedule.slotStepMinutes ?? kCustomerSlotStepMinutes,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } on BookingTimeOverlapException {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'time_overlap',
      );
      return false;
    } on BookingSlotException {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'slot_invalid',
      );
      return false;
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        submissionErrorCode: 'unknown',
      );
      return false;
    }
  }
}
