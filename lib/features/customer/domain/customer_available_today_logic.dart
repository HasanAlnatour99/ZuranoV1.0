import '../../../core/booking/availability_schedule.dart';
import '../discovery/utils/opening_hours_utils.dart';

/// “Available today” for discovery filters when Firestore may not yet expose the
/// slot-aggregation fields (`isAvailableToday`, `todayAvailableSlotsCount`).
///
/// **Preferred:** backend writes counts / flags on each salon (or `publicSalons`) doc.
/// **Fallback:** before closing time on a non–day-off weekday from [weeklyAvailability].
///
/// If [openingStatusUpdatedAt] is set and the backend reports no slots and not available,
/// we trust that over the weekly fallback.
bool salonPassesAvailableTodayDiscovery({
  required bool isClosedToday,
  required bool isAvailableToday,
  required int todayAvailableSlotsCount,
  DateTime? openingStatusUpdatedAt,
  WeeklyAvailability? weeklyAvailability,
}) {
  if (isClosedToday) {
    return false;
  }

  if (todayAvailableSlotsCount > 0) {
    return true;
  }

  final backendSaysNoAvailabilityToday = openingStatusUpdatedAt != null &&
      !isAvailableToday &&
      todayAvailableSlotsCount == 0;

  if (backendSaysNoAvailabilityToday) {
    return false;
  }

  return OpeningHoursUtils.hasBookableWindowRemainingToday(weeklyAvailability);
}
