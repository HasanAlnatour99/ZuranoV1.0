import 'package:cloud_firestore/cloud_firestore.dart';

/// Owner/admin team attendance view model (supports legacy + new Firestore shapes).
class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.attendanceDate,
    required this.dateKey,
    required this.weekKey,
    required this.monthKey,
    required this.checkInAt,
    required this.checkOutAt,
    required this.status,
    required this.source,
    required this.lateMinutes,
    required this.earlyExitMinutes,
    required this.missingCheckout,
    required this.manualEdited,
    required this.notes,
  });

  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String attendanceDate;
  final int dateKey;
  final String weekKey;
  final String monthKey;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String status;
  final String source;
  final int lateMinutes;
  final int earlyExitMinutes;
  final bool missingCheckout;
  final bool manualEdited;
  final String notes;

  factory AttendanceRecordModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime? readTimestamp(String key) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      return null;
    }

    final workDate = readTimestamp('workDate');
    final attendanceDateStr = data['attendanceDate'] is String
        ? data['attendanceDate'] as String
        : _isoDateFromWorkDate(workDate);

    final dateKeyRaw = data['dateKey'];
    final int dateKeyParsed = switch (dateKeyRaw) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.replaceAll('-', '')) ?? 0,
      _ => _dateKeyFromIso(attendanceDateStr),
    };

    final lateMinutes = switch (data['lateMinutes']) {
      int v => v,
      num v => v.toInt(),
      _ => switch (data['minutesLate']) {
        int v => v,
        num v => v.toInt(),
        _ => 0,
      },
    };

    final missingCheckout =
        data['missingCheckout'] == true || data['needsCorrection'] == true;

    return AttendanceRecordModel(
      id: doc.id,
      salonId: data['salonId']?.toString() ?? '',
      employeeId: data['employeeId']?.toString() ?? '',
      employeeName: data['employeeName']?.toString() ?? '',
      attendanceDate: attendanceDateStr,
      dateKey: dateKeyParsed,
      weekKey: data['weekKey']?.toString() ?? '',
      monthKey:
          data['monthKey']?.toString() ?? _monthKeyFromIso(attendanceDateStr),
      checkInAt: readTimestamp('checkInAt') ?? readTimestamp('punchInAt'),
      checkOutAt: readTimestamp('checkOutAt') ?? readTimestamp('punchOutAt'),
      status: data['status']?.toString().trim().isNotEmpty == true
          ? data['status'] as String
          : 'incomplete',
      source: data['source']?.toString().trim().isNotEmpty == true
          ? data['source'] as String
          : 'employee_app',
      lateMinutes: lateMinutes,
      earlyExitMinutes: data['earlyExitMinutes'] is int
          ? data['earlyExitMinutes'] as int
          : (data['earlyExitMinutes'] is num
                ? (data['earlyExitMinutes'] as num).toInt()
                : 0),
      missingCheckout: missingCheckout,
      manualEdited: data['manualEdited'] == true,
      notes: data['notes']?.toString() ?? '',
    );
  }

  static String _isoDateFromWorkDate(DateTime? workDate) {
    if (workDate == null) return '';
    final d = DateTime(workDate.year, workDate.month, workDate.day);
    return d.toIso8601String().substring(0, 10);
  }

  static int _dateKeyFromIso(String iso) {
    if (iso.length < 10) return 0;
    return int.tryParse(iso.substring(0, 10).replaceAll('-', '')) ?? 0;
  }

  static String _monthKeyFromIso(String iso) {
    if (iso.length < 7) return '';
    return iso.substring(0, 7);
  }

  /// Keys consumed by attendance adjustment parsers / Cloud Function payloads.
  Map<String, dynamic> toAttendanceAdjustmentPrefillPayload() {
    final m = <String, dynamic>{
      'status': status,
      if (notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final ci = checkInAt;
    if (ci != null) {
      m['checkInAt'] = Timestamp.fromDate(ci);
    }
    final co = checkOutAt;
    if (co != null) {
      m['checkOutAt'] = Timestamp.fromDate(co);
    }
    return m;
  }

  /// Calendar day for this row (team history / adjustments).
  DateTime? attendanceCalendarDay() {
    final iso = DateTime.tryParse(attendanceDate);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }
    if (dateKey > 0) {
      final padded = dateKey.toString().padLeft(8, '0');
      if (padded.length == 8) {
        final y = int.tryParse(padded.substring(0, 4));
        final mo = int.tryParse(padded.substring(4, 6));
        final d = int.tryParse(padded.substring(6, 8));
        if (y != null && mo != null && d != null) {
          return DateTime(y, mo, d);
        }
      }
    }
    return null;
  }
}
