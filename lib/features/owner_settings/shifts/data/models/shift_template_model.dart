import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftTemplateModel {
  const ShiftTemplateModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.code,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.isOvernight,
    required this.durationMinutes,
    required this.breakMinutes,
    required this.colorHex,
    required this.iconKey,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String name;
  final String code;
  final String type;
  final String? startTime;
  final String? endTime;
  final bool isOvernight;
  final int durationMinutes;
  final int breakMinutes;
  final String colorHex;
  final String iconKey;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShiftTemplateModel copyWith({
    String? id,
    String? salonId,
    String? name,
    String? code,
    String? type,
    String? startTime,
    String? endTime,
    bool? isOvernight,
    int? durationMinutes,
    int? breakMinutes,
    String? colorHex,
    String? iconKey,
    bool? isActive,
    bool? isDefault,
    int? sortOrder,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShiftTemplateModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOvernight: isOvernight ?? this.isOvernight,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      colorHex: colorHex ?? this.colorHex,
      iconKey: iconKey ?? this.iconKey,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShiftTemplateModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data() ?? <String, dynamic>{};
    return ShiftTemplateModel(
      id: doc.id,
      salonId: (json['salonId'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      code: (json['code'] as String? ?? '').trim(),
      type: (json['type'] as String? ?? 'working').trim(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      isOvernight: json['isOvernight'] == true,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
      colorHex: (json['colorHex'] as String? ?? '#A78BFA').trim(),
      iconKey: (json['iconKey'] as String? ?? 'schedule').trim(),
      isActive: json['isActive'] != false,
      isDefault: json['isDefault'] == true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdBy: (json['createdBy'] as String? ?? '').trim(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'name': name,
      'code': code,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'isOvernight': isOvernight,
      'durationMinutes': durationMinutes,
      'breakMinutes': breakMinutes,
      'colorHex': colorHex,
      'iconKey': iconKey,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return <String, dynamic>{
      'name': name,
      'code': code,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'isOvernight': isOvernight,
      'durationMinutes': durationMinutes,
      'breakMinutes': breakMinutes,
      'colorHex': colorHex,
      'iconKey': iconKey,
      'isActive': isActive,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
