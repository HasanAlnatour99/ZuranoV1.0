import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceCorrectionRequestModel {
  const AttendanceCorrectionRequestModel({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.attendanceId,
    required this.attendanceDayId,
    required this.attendanceDate,
    required this.dateKey,
    required this.requestType,
    required this.requestedPunchType,
    required this.requestedPunchTime,
    required this.requestedCheckInAt,
    required this.requestedCheckOutAt,
    required this.reason,
    required this.status,
    required this.reviewNote,
  });

  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;

  /// Legacy `salons/.../attendance/{id}` doc id when present.
  final String attendanceId;

  /// Employee day id (`{dateKey}_{employeeId}`) for punch-based corrections.
  final String attendanceDayId;

  final String attendanceDate;
  final int dateKey;
  final String requestType;

  /// `AttendancePunchType.name` from employee correction requests.
  final String requestedPunchType;
  final DateTime? requestedPunchTime;

  final DateTime? requestedCheckInAt;
  final DateTime? requestedCheckOutAt;
  final String reason;
  final String status;
  final String reviewNote;

  factory AttendanceCorrectionRequestModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime? readTimestamp(String key) {
      final value = data[key];
      if (value is Timestamp) return value.toDate();
      return null;
    }

    final dateKeyRaw = data['dateKey'];
    final int dateKeyParsed = switch (dateKeyRaw) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      _ => 0,
    };

    final attendanceDayId = data['attendanceDayId']?.toString() ?? '';
    final requestedPunchType = data['requestedPunchType']?.toString() ?? '';
    final requestedPunchTime = readTimestamp('requestedPunchTime');

    var attendanceDate = data['attendanceDate']?.toString() ?? '';
    if (attendanceDate.isEmpty &&
        dateKeyRaw is String &&
        dateKeyRaw.length == 8 &&
        RegExp(r'^\d{8}$').hasMatch(dateKeyRaw)) {
      attendanceDate =
          '${dateKeyRaw.substring(0, 4)}-${dateKeyRaw.substring(4, 6)}-${dateKeyRaw.substring(6, 8)}';
    }
    if (attendanceDate.isEmpty && dateKeyParsed > 0) {
      final s = dateKeyParsed.toString().padLeft(8, '0');
      if (s.length == 8) {
        attendanceDate =
            '${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6, 8)}';
      }
    }

    return AttendanceCorrectionRequestModel(
      id: doc.id,
      salonId: data['salonId']?.toString() ?? '',
      employeeId: data['employeeId']?.toString() ?? '',
      employeeName: data['employeeName']?.toString() ?? '',
      attendanceId: data['attendanceId']?.toString() ?? '',
      attendanceDayId: attendanceDayId,
      attendanceDate: attendanceDate,
      dateKey: dateKeyParsed,
      requestType: data['requestType']?.toString() ?? '',
      requestedPunchType: requestedPunchType,
      requestedPunchTime: requestedPunchTime,
      requestedCheckInAt: readTimestamp('requestedCheckInAt'),
      requestedCheckOutAt: readTimestamp('requestedCheckOutAt'),
      reason: data['reason']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      reviewNote: data['reviewNote']?.toString() ?? '',
    );
  }
}
