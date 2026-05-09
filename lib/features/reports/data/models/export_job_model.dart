import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';

/// `salons/{salonId}/exportJobs/{exportJobId}`
class ExportJobModel {
  const ExportJobModel({
    required this.id,
    required this.salonId,
    required this.exportType,
    required this.format,
    required this.periodId,
    required this.dateFrom,
    required this.dateTo,
    required this.employeeId,
    required this.status,
    required this.fileName,
    required this.storagePath,
    required this.downloadUrl,
    required this.requestedBy,
    required this.requestedByName,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
    required this.failedAt,
    required this.errorCode,
  });

  final String id;
  final String salonId;
  final String exportType;
  final String format;
  final String? periodId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? employeeId;
  final String status;
  final String fileName;
  final String storagePath;
  final String? downloadUrl;
  final String requestedBy;
  final String requestedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? errorCode;

  factory ExportJobModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ExportJobModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      exportType: looseStringFromJson(d['exportType']),
      format: looseStringFromJson(d['format']),
      periodId: nullableLooseStringFromJson(d['periodId']),
      dateFrom: FirestoreSerializers.dateTime(d['dateFrom']),
      dateTo: FirestoreSerializers.dateTime(d['dateTo']),
      employeeId: nullableLooseStringFromJson(d['employeeId']),
      status: looseStringFromJson(d['status']),
      fileName: looseStringFromJson(d['fileName']),
      storagePath: looseStringFromJson(d['storagePath']),
      downloadUrl: nullableLooseStringFromJson(d['downloadUrl']),
      requestedBy: looseStringFromJson(d['requestedBy']),
      requestedByName: looseStringFromJson(d['requestedByName']),
      createdAt: FirestoreSerializers.dateTime(d['createdAt']),
      updatedAt: FirestoreSerializers.dateTime(d['updatedAt']),
      completedAt: FirestoreSerializers.dateTime(d['completedAt']),
      failedAt: FirestoreSerializers.dateTime(d['failedAt']),
      errorCode: nullableLooseStringFromJson(d['errorCode']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing =>
      status == 'processing' || status == 'queued';
}
