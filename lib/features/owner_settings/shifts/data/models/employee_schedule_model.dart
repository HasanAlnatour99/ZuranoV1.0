import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeScheduleModel {
  const EmployeeScheduleModel({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.scheduleDate,
    required this.dayOfWeek,
    required this.shiftTemplateId,
    required this.shiftName,
    required this.shiftType,
    required this.startDateTime,
    required this.endDateTime,
    required this.isOvernight,
    required this.startTime,
    required this.endTime,
    required this.scheduledMinutes,
    required this.breakMinutes,
    required this.source,
    required this.weekTemplateId,
    required this.attendanceStatus,
    required this.payrollStatus,
    required this.isLocked,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String scheduleDate;
  final int dayOfWeek;
  final String? shiftTemplateId;
  final String shiftName;
  final String shiftType;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final bool isOvernight;
  final String? startTime;
  final String? endTime;
  final int scheduledMinutes;
  final int breakMinutes;
  final String source;
  final String weekTemplateId;
  final String attendanceStatus;
  final String payrollStatus;
  final bool isLocked;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EmployeeScheduleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return EmployeeScheduleModel(
      id: (data['id'] as String? ?? doc.id).trim(),
      salonId: (data['salonId'] as String? ?? '').trim(),
      employeeId: (data['employeeId'] as String? ?? '').trim(),
      employeeName: (data['employeeName'] as String? ?? '').trim(),
      scheduleDate: (data['scheduleDate'] as String? ?? '').trim(),
      dayOfWeek: (data['dayOfWeek'] as num?)?.toInt() ?? 0,
      shiftTemplateId: (data['shiftTemplateId'] as String?)?.trim(),
      shiftName: (data['shiftName'] as String? ?? '').trim(),
      shiftType: (data['shiftType'] as String? ?? 'working').trim(),
      startDateTime: (data['startDateTime'] as Timestamp?)?.toDate(),
      endDateTime: (data['endDateTime'] as Timestamp?)?.toDate(),
      isOvernight: data['isOvernight'] == true,
      startTime: (data['startTime'] as String?)?.trim(),
      endTime: (data['endTime'] as String?)?.trim(),
      scheduledMinutes: (data['scheduledMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (data['breakMinutes'] as num?)?.toInt() ?? 0,
      source: (data['source'] as String? ?? '').trim(),
      weekTemplateId: (data['weekTemplateId'] as String? ?? '').trim(),
      attendanceStatus: (data['attendanceStatus'] as String? ?? '').trim(),
      payrollStatus: (data['payrollStatus'] as String? ?? '').trim(),
      isLocked: data['isLocked'] == true,
      createdBy: (data['createdBy'] as String? ?? '').trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'scheduleDate': scheduleDate,
      'dayOfWeek': dayOfWeek,
      'shiftTemplateId': shiftTemplateId,
      'shiftName': shiftName,
      'shiftType': shiftType,
      'startDateTime': startDateTime == null
          ? null
          : Timestamp.fromDate(startDateTime!),
      'endDateTime': endDateTime == null
          ? null
          : Timestamp.fromDate(endDateTime!),
      'isOvernight': isOvernight,
      'startTime': startTime,
      'endTime': endTime,
      'scheduledMinutes': scheduledMinutes,
      'breakMinutes': breakMinutes,
      'source': source,
      'weekTemplateId': weekTemplateId,
      'attendanceStatus': attendanceStatus,
      'payrollStatus': payrollStatus,
      'isLocked': isLocked,
      'createdBy': createdBy,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
