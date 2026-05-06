import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/booking/availability_schedule.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/models/salon_public_model.dart';

/// Customer-facing one-line summary for today's opening hours on the salon profile.
String resolveSalonHoursText({
  required SalonPublicModel salon,
  required DateTime now,
  required AppLocalizations l10n,
  required Locale locale,
}) {
  final localNow = now.toLocal();

  final fromWh = _tryWorkingHoursLine(
    salon.workingHours,
    localNow,
    l10n,
    locale,
  );
  if (fromWh != null) {
    return fromWh;
  }

  final fromWeekly = _tryWeeklyAvailabilityLine(
    salon.weeklyAvailability,
    localNow.weekday,
    localNow,
    l10n,
    locale,
  );
  if (fromWeekly != null) {
    return fromWeekly;
  }

  return l10n.customerProfileWorkingHoursPlaceholder;
}

Map<String, dynamic>? _dayEntry(
  Map<String, dynamic>? workingHours,
  int weekday,
) {
  if (workingHours == null || workingHours.isEmpty) {
    return null;
  }
  final key = _weekdayFirestoreKey(weekday);
  for (final e in workingHours.entries) {
    if (e.key.toString().trim().toLowerCase() == key) {
      final v = e.value;
      if (v is Map) {
        return Map<String, dynamic>.from(Map<Object?, Object?>.from(v));
      }
      return null;
    }
  }
  return null;
}

String _weekdayFirestoreKey(int weekday) {
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

/// Reads `start` / `end`, or legacy string times `open` / `close` (only when string).
String? _startTimeStr(Map<String, dynamic> day) {
  for (final k in ['start']) {
    final v = day[k];
    if (v != null && v.toString().trim().isNotEmpty) {
      return v.toString().trim();
    }
  }
  final openVal = day['open'];
  if (openVal is String && openVal.contains(':')) {
    return openVal.trim();
  }
  return null;
}

String? _endTimeStr(Map<String, dynamic> day) {
  for (final k in ['end', 'close']) {
    final v = day[k];
    if (v != null && v.toString().trim().isNotEmpty) {
      return v.toString().trim();
    }
  }
  return null;
}

String? _tryWorkingHoursLine(
  Map<String, dynamic>? workingHours,
  DateTime localNow,
  AppLocalizations l10n,
  Locale locale,
) {
  final day = _dayEntry(workingHours, localNow.weekday);
  if (day == null) {
    return null;
  }

  if (day['isClosed'] == true) {
    return l10n.customerProfileHoursClosedToday;
  }
  if (day['open'] == false) {
    return l10n.customerProfileHoursClosedToday;
  }

  final startRaw = _startTimeStr(day);
  final endRaw = _endTimeStr(day);
  if (startRaw == null || endRaw == null) {
    return null;
  }

  final startDt = _parseTimeOnDay(localNow, startRaw);
  final endDt = _parseTimeOnDay(localNow, endRaw);
  if (startDt == null || endDt == null) {
    return null;
  }

  final fmtStart = _formatHm(startDt, locale);
  final fmtEnd = _formatHm(endDt, locale);

  if (localNow.isBefore(startDt)) {
    return l10n.customerProfileHoursClosedOpens(fmtStart);
  }
  if (localNow.isBefore(endDt)) {
    return l10n.customerProfileHoursOpenNowCloses(fmtEnd);
  }

  return l10n.customerProfileHoursClosedToday;
}

String? _tryWeeklyAvailabilityLine(
  WeeklyAvailability? weekly,
  int weekday,
  DateTime localNow,
  AppLocalizations l10n,
  Locale locale,
) {
  if (weekly == null) {
    return null;
  }
  final day = weekly.dayIfSet(weekday);
  if (day == null) {
    return null;
  }
  if (day.isDayOff) {
    return l10n.customerProfileHoursClosedToday;
  }

  final startDt = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
    day.openMinute ~/ 60,
    day.openMinute % 60,
  );
  final endDt = DateTime(
    localNow.year,
    localNow.month,
    localNow.day,
    day.closeMinute ~/ 60,
    day.closeMinute % 60,
  );

  final fmtStart = _formatHm(startDt, locale);
  final fmtEnd = _formatHm(endDt, locale);
  final minuteOfDay = localNow.hour * 60 + localNow.minute;

  if (minuteOfDay < day.openMinute) {
    return l10n.customerProfileHoursClosedOpens(fmtStart);
  }
  if (minuteOfDay < day.closeMinute) {
    for (final br in day.breaks) {
      if (minuteOfDay >= br.$1 && minuteOfDay < br.$2) {
        return l10n.customerProfileHoursClosedToday;
      }
    }
    return l10n.customerProfileHoursOpenNowCloses(fmtEnd);
  }

  return l10n.customerProfileHoursClosedToday;
}

DateTime? _parseTimeOnDay(DateTime base, String value) {
  final parts = value.split(':');
  if (parts.isEmpty) {
    return null;
  }
  final hour = int.tryParse(parts[0].trim()) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
  return DateTime(base.year, base.month, base.day, hour, minute);
}

String _formatHm(DateTime dt, Locale locale) {
  return DateFormat.jm(locale.toString()).format(dt);
}
