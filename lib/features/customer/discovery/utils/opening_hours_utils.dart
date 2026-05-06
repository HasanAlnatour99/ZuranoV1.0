import '../../../../core/booking/availability_schedule.dart';

/// Parses `openingHours` maps shaped like `{ monday: { open, close, isClosed } }`.
///
/// Also supports owner-configured [WeeklyAvailability] on `salons/{salonId}` when
/// `openingHours` / `isOpenNow` are absent.
class OpeningHoursUtils {
  OpeningHoursUtils._();

  /// Returns `true` when the salon is **closed right now** using [WeeklyAvailability]
  /// (local device time vs open/close minutes for today's weekday).
  ///
  /// Missing weekday entry, day off, outside window, or inside a break ⇒ closed.
  static bool isClosedNowFromWeeklyAvailability(WeeklyAvailability weekly) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final day = weekly.dayIfSet(weekday);
    if (day == null) {
      return true;
    }
    if (day.isDayOff) {
      return true;
    }
    final minuteOfDay = now.hour * 60 + now.minute;
    if (minuteOfDay < day.openMinute || minuteOfDay >= day.closeMinute) {
      return true;
    }
    for (final br in day.breaks) {
      if (minuteOfDay >= br.$1 && minuteOfDay < br.$2) {
        return true;
      }
    }
    return false;
  }

  /// True when today’s [WeeklyAvailability] still has time **before [closeMinute]**
  /// (salon not day-off today). Used when slot-count fields are not on Firestore yet.
  ///
  /// Includes “opens later today” (before [openMinute]) and currently open.
  static bool hasBookableWindowRemainingToday(WeeklyAvailability? weekly) {
    if (weekly == null) {
      return false;
    }
    final now = DateTime.now();
    final day = weekly.dayIfSet(now.weekday);
    if (day == null || day.isDayOff) {
      return false;
    }
    final minuteOfDay = now.hour * 60 + now.minute;
    return minuteOfDay < day.closeMinute;
  }

  /// Returns `true` when the venue should be treated as **closed right now**
  /// (missing data → closed).
  static bool isClosedNow(Map<String, dynamic>? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return true;
    }

    final now = DateTime.now();
    final dayKey = _dayKey(now.weekday);
    final today = openingHours[dayKey];

    if (today is! Map) {
      return true;
    }
    if (today['isClosed'] == true) {
      return true;
    }

    final open = today['open']?.toString();
    final close = today['close']?.toString();

    if (open == null || close == null) {
      return true;
    }

    final openTime = _parseTime(now, open);
    final closeTime = _parseTime(now, close);

    return now.isBefore(openTime) || now.isAfter(closeTime);
  }

  static DateTime _parseTime(DateTime base, String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  static String _dayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }
}
