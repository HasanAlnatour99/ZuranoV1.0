import '../../../core/constants/booking_status_machine.dart';
import '../../../core/constants/booking_statuses.dart';
import '../data/models/customer_booking_details_model.dart';
import '../data/models/customer_booking_settings.dart';

/// Mirrors [cancelCustomerBooking] in `functions/src/customer/customerPortalCallables.ts`.
CustomerOnlineCancelEligibility resolveCustomerOnlineCancelEligibility({
  required CustomerBookingDetailsModel details,
  required CustomerBookingSettings settings,
}) {
  final normalized = BookingStatusMachine.normalize(details.status.trim());
  if (normalized != BookingStatuses.pending &&
      normalized != BookingStatuses.confirmed) {
    return CustomerOnlineCancelEligibility.ineligibleWrongStatus;
  }

  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final endMs = details.endAt.millisecondsSinceEpoch;
  if (endMs <= nowMs) {
    return CustomerOnlineCancelEligibility.ineligibleEnded;
  }

  if (!settings.allowCustomerCancellation) {
    return CustomerOnlineCancelEligibility.ineligibleNotAllowed;
  }

  final cutoffMs =
      (settings.cancellationCutoffMinutes.clamp(0, 525600)) * 60 * 1000;
  final startMs = details.startAt.millisecondsSinceEpoch;
  if (nowMs > startMs - cutoffMs) {
    return CustomerOnlineCancelEligibility.ineligibleTooClose;
  }

  return CustomerOnlineCancelEligibility.eligible;
}

enum CustomerOnlineCancelEligibility {
  eligible,
  ineligibleNotAllowed,
  ineligibleTooClose,
  ineligibleWrongStatus,
  ineligibleEnded,
}
