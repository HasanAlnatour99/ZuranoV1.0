import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyScheduleAssignmentModel {
  const WeeklyScheduleAssignmentModel({
    required this.id,
    required this.salonId,
    required this.weekTemplateId,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.dayOfWeek,
    required this.shiftTemplateId,
    required this.shiftName,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.isOvernight,
    required this.durationMinutes,
    required this.breakMinutes,
    required this.colorHex,
    required this.updatedBy,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String weekTemplateId;
  final String employeeId;
  final String employeeName;
  final String date;
  final int dayOfWeek;
  final String? shiftTemplateId;
  final String shiftName;
  final String shiftType;
  final String? startTime;
  final String? endTime;
  final bool isOvernight;
  final int durationMinutes;
  final int breakMinutes;
  final String colorHex;
  final String updatedBy;
  final DateTime? updatedAt;

  factory WeeklyScheduleAssignmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return WeeklyScheduleAssignmentModel(
      id: doc.id,
      salonId: (data['salonId'] as String? ?? '').trim(),
      weekTemplateId: (data['weekTemplateId'] as String? ?? '').trim(),
      employeeId: (data['employeeId'] as String? ?? '').trim(),
      employeeName: (data['employeeName'] as String? ?? '').trim(),
      date: (data['date'] as String? ?? '').trim(),
      dayOfWeek: (data['dayOfWeek'] as num?)?.toInt() ?? 0,
      shiftTemplateId: (data['shiftTemplateId'] as String?)?.trim(),
      shiftName: (data['shiftName'] as String? ?? '').trim(),
      shiftType: (data['shiftType'] as String? ?? 'working').trim(),
      startTime: data['startTime'] as String?,
      endTime: data['endTime'] as String?,
      isOvernight: data['isOvernight'] == true,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (data['breakMinutes'] as num?)?.toInt() ?? 0,
      colorHex: (data['colorHex'] as String? ?? '#6D3CEB').trim(),
      updatedBy: (data['updatedBy'] as String? ?? '').trim(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'weekTemplateId': weekTemplateId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'dayOfWeek': dayOfWeek,
      'shiftTemplateId': shiftTemplateId,
      'shiftName': shiftName,
      'shiftType': shiftType,
      'startTime': startTime,
      'endTime': endTime,
      'isOvernight': isOvernight,
      'durationMinutes': durationMinutes,
      'breakMinutes': breakMinutes,
      'colorHex': colorHex,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
