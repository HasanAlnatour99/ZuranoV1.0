import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/booking_repository.dart';
import '../data/models/booking.dart';

final bookingActionsProvider = Provider<BookingActions>((ref) {
  return BookingActions(ref);
});

/// Salon-scoped booking writes using [sessionUserProvider] for [AppUser.salonId].
class BookingActions {
  BookingActions(this._ref);

  final Ref _ref;

  /// Prevents duplicate cancel/reschedule calls while a request is in flight.
  final Map<String, Future<void>> _inFlight = {};

  BookingRepository get _repository => _ref.read(bookingRepositoryProvider);

  String _requireSalonId() {
    final salonId = _ref.read(sessionUserProvider).asData?.value?.salonId;
    if (salonId == null || salonId.isEmpty) {
      throw StateError('No salon for the current user.');
    }
    return salonId;
  }

  /// [slotStepMinutes] must be `15` or `30` (UTC grid). Persists via Firestore.
  Future<String> createBooking(
    Booking booking, {
    required int slotStepMinutes,
  }) {
    return _repository.createBooking(
      _requireSalonId(),
      booking,
      slotStepMinutes: slotStepMinutes,
    );
  }

  Future<void> updateBooking(Booking booking) {
    return _repository.updateBooking(_requireSalonId(), booking);
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime startAt,
    required DateTime endAt,
    required int slotStepMinutes,
  }) {
    final key = 'reschedule:$bookingId';
    return _dedupe(key, () {
      return _repository.rescheduleBooking(
        salonId: _requireSalonId(),
        bookingId: bookingId,
        startAt: startAt,
        endAt: endAt,
        slotStepMinutes: slotStepMinutes,
      );
    });
  }

  Future<void> cancelBooking(String bookingId) {
    final key = 'cancel:$bookingId';
    return _dedupe(key, () {
      return _repository.cancelBooking(
        salonId: _requireSalonId(),
        bookingId: bookingId,
      );
    });
  }

  Future<void> markBookingArrived(String bookingId) {
    return _repository.markBookingArrived(
      salonId: _requireSalonId(),
      bookingId: bookingId,
    );
  }

  Future<void> startBookingService(String bookingId) {
    return _repository.startBookingService(
      salonId: _requireSalonId(),
      bookingId: bookingId,
    );
  }

  Future<void> completeBookingService(String bookingId) {
    return _repository.completeBookingService(
      salonId: _requireSalonId(),
      bookingId: bookingId,
    );
  }

  Future<void> markBookingNoShow(String bookingId, {required String party}) {
    return _repository.markBookingNoShow(
      salonId: _requireSalonId(),
      bookingId: bookingId,
      party: party,
    );
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String nextStatus,
    String? reason,
  }) {
    return _repository.ownerUpdateBookingStatus(
      salonId: _requireSalonId(),
      bookingId: bookingId,
      nextStatus: nextStatus,
      reason: reason,
    );
  }

  Future<void> _dedupe(String key, Future<void> Function() run) {
    final pending = _inFlight[key];
    if (pending != null) {
      return pending;
    }
    final done = run().whenComplete(() {
      _inFlight.remove(key);
    });
    _inFlight[key] = done;
    return done;
  }
}
