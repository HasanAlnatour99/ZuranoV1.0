import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyScheduleTemplateModel {
  const WeeklyScheduleTemplateModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.status,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String name;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final String status;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WeeklyScheduleTemplateModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return WeeklyScheduleTemplateModel(
      id: doc.id,
      salonId: (data['salonId'] as String? ?? '').trim(),
      name: (data['name'] as String? ?? '').trim(),
      weekStartDate: _parseDateOnly(data['weekStartDate'] as String?),
      weekEndDate: _parseDateOnly(data['weekEndDate'] as String?),
      status: (data['status'] as String? ?? 'draft').trim(),
      createdBy: (data['createdBy'] as String? ?? '').trim(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'name': name,
      'weekStartDate': _formatDateOnly(weekStartDate),
      'weekEndDate': _formatDateOnly(weekEndDate),
      'status': status,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime _parseDateOnly(String? raw) {
    if (raw == null || raw.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    final parts = raw.split('-');
    if (parts.length != 3) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
