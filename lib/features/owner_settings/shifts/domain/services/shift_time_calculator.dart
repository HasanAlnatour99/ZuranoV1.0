import 'package:flutter/material.dart';

class ShiftTimeCalculator {
  const ShiftTimeCalculator._();

  static int parseHHmmToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid HH:mm format');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return (hour * 60) + minute;
  }

  static String formatMinutesToHHmm(int minutes) {
    final h = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static int calculateDurationMinutes(String startTime, String endTime) {
    final start = parseHHmmToMinutes(startTime);
    final end = parseHHmmToMinutes(endTime);
    if (end > start) {
      return end - start;
    }
    return (24 * 60 - start) + end;
  }

  static bool isOvernight(String startTime, String endTime) {
    return parseHHmmToMinutes(endTime) <= parseHHmmToMinutes(startTime);
  }

  static ({DateTime startDateTime, DateTime endDateTime})
  buildStartEndDateTime({
    required DateTime scheduleDate,
    required String startTime,
    required String endTime,
    required bool isOvernight,
  }) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startDateTime = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    final endBaseDate = isOvernight
        ? scheduleDate.add(const Duration(days: 1))
        : scheduleDate;
    final endDateTime = DateTime(
      endBaseDate.year,
      endBaseDate.month,
      endBaseDate.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    return (startDateTime: startDateTime, endDateTime: endDateTime);
  }

  static String timeOfDayToHHmm(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
