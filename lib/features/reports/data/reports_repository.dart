import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/core/firestore/firestore_write_payload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../domain/report_export_kind.dart';
import 'models/export_job_model.dart';

class ReportsFailure implements Exception {
  ReportsFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ReportsFailure($code): $message';
}

class ReportsRepository {
  ReportsRepository({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _jobsCol(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonExportJobs(salonId));
  }

  Stream<List<ExportJobModel>> watchExportJobs(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _jobsCol(salonId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (s) => s.docs.map(ExportJobModel.fromFirestore).toList(),
        );
  }

  Stream<ExportJobModel?> watchExportJob(String salonId, String exportJobId) {
    FirestoreWritePayload.assertSalonId(salonId);
    final id = exportJobId.trim();
    if (id.isEmpty) return Stream.value(null);
    return _jobsCol(salonId).doc(id).snapshots().map((d) {
      if (!d.exists) return null;
      return ExportJobModel.fromFirestore(d);
    });
  }

  Future<({String jobId, String status, String storagePath})> requestReportExport({
    required String salonId,
    required ReportCsvExportKind exportType,
    required String format,
    String? periodId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final callable = _functions.httpsCallable('requestReportExport');
      final result = await callable.call<Map<String, dynamic>>({
        'salonId': salonId,
        'exportType': exportType.wireValue,
        'format': format,
        if (periodId != null && periodId.trim().isNotEmpty) 'periodId': periodId.trim(),
        if (dateFrom != null && dateFrom.trim().isNotEmpty) 'dateFrom': dateFrom.trim(),
        if (dateTo != null && dateTo.trim().isNotEmpty) 'dateTo': dateTo.trim(),
      });
      final data = result.data;
      final jobId = data['jobId']?.toString() ?? '';
      final status = data['status']?.toString() ?? '';
      final storagePath = data['storagePath']?.toString() ?? '';
      if (jobId.isEmpty) {
        throw ReportsFailure('invalid-response', 'Missing job id.');
      }
      return (jobId: jobId, status: status, storagePath: storagePath);
    } on FirebaseFunctionsException catch (e) {
      throw ReportsFailure(
        e.code,
        e.message ?? 'Export failed.',
      );
    }
  }

  Future<({String jobId, String status, String storagePath})> generatePayslipPdf({
    required String salonId,
    required String periodId,
    required String employeeId,
  }) async {
    try {
      final callable = _functions.httpsCallable('generatePayslipPdf');
      final result = await callable.call<Map<String, dynamic>>({
        'salonId': salonId,
        'periodId': periodId.trim(),
        'employeeId': employeeId.trim(),
      });
      final data = result.data;
      final jobId = data['jobId']?.toString() ?? '';
      final status = data['status']?.toString() ?? '';
      final storagePath = data['storagePath']?.toString() ?? '';
      if (jobId.isEmpty) {
        throw ReportsFailure('invalid-response', 'Missing job id.');
      }
      return (jobId: jobId, status: status, storagePath: storagePath);
    } on FirebaseFunctionsException catch (e) {
      throw ReportsFailure(e.code, e.message ?? 'PDF export failed.');
    }
  }

  Future<({String downloadUrl, String storagePath, String fileName})>
      getExportDownloadUrl({
    required String salonId,
    required String exportJobId,
  }) async {
    try {
      final callable = _functions.httpsCallable('getExportDownloadUrl');
      final result = await callable.call<Map<String, dynamic>>({
        'salonId': salonId,
        'exportJobId': exportJobId.trim(),
      });
      final data = result.data;
      final downloadUrl = data['downloadUrl']?.toString() ?? '';
      final storagePath = data['storagePath']?.toString() ?? '';
      final fileName = data['fileName']?.toString() ?? '';
      if (downloadUrl.isEmpty) {
        throw ReportsFailure('invalid-response', 'Missing download URL.');
      }
      return (
        downloadUrl: downloadUrl,
        storagePath: storagePath,
        fileName: fileName,
      );
    } on FirebaseFunctionsException catch (e) {
      throw ReportsFailure(e.code, e.message ?? 'Could not get download link.');
    }
  }
}
