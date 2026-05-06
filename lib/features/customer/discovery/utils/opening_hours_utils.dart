/// Parses `openingHours` maps shaped like `{ monday: { open, close, isClosed } }`.
class OpeningHoursUtils {
  OpeningHoursUtils._();

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
