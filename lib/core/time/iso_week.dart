/// ISO 8601 week-year and week number for the week containing [utcDay] (date-only UTC).
({int weekYear, int weekNumber}) isoWeekSpecForUtcDate(DateTime utcDay) {
  final d = DateTime.utc(utcDay.year, utcDay.month, utcDay.day);
  // Thursday of this calendar week (Dart: Mon=1 … Sun=7).
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final weekYear = thursday.year;
  final jan4 = DateTime.utc(weekYear, 1, 4);
  final firstWeekThursday = jan4.add(Duration(days: 4 - jan4.weekday));
  final weekNumber = 1 + thursday.difference(firstWeekThursday).inDays ~/ 7;
  return (weekYear: weekYear, weekNumber: weekNumber);
}

/// Monday 00:00:00.000 UTC of ISO week ([weekYear], [weekNumber]).
DateTime isoWeekMondayUtc(int weekYear, int weekNumber) {
  final jan4 = DateTime.utc(weekYear, 1, 4);
  final mondayWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  return mondayWeek1.add(Duration(days: (weekNumber - 1) * 7));
}

/// Inclusive UTC bounds for the ISO week (Mon 00:00 … Sun 23:59:59.999).
(DateTime startUtc, DateTime endUtc) isoWeekUtcBounds(int weekYear, int weekNumber) {
  final startUtc = isoWeekMondayUtc(weekYear, weekNumber);
  final endUtc = startUtc.add(
    const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999),
  );
  return (startUtc, endUtc);
}
