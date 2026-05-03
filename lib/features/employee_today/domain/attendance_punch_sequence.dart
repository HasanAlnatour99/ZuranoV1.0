import '../data/models/et_attendance_day.dart';
import '../data/models/et_attendance_punch.dart';

/// Prefer punch documents (sorted by time) over the denormalized day
/// `punchSequence`, which can lag or diverge after partial writes.
List<String> punchTypeSequenceForResolver({
  required EtAttendanceDay? day,
  required List<EtAttendancePunch> punches,
}) {
  if (punches.isNotEmpty) {
    final sorted = [...punches]
      ..sort((a, b) => a.punchTime.compareTo(b.punchTime));
    return sorted.map((p) => p.type.name).toList(growable: false);
  }
  return List<String>.from(day?.punchSequence ?? const <String>[]);
}
