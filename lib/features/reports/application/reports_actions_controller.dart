import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/session_provider.dart';
import '../data/reports_repository.dart';
import '../domain/report_export_kind.dart';
import 'reports_providers.dart';

final reportsActionsControllerProvider =
    NotifierProvider<ReportsActionsController, bool>(
  ReportsActionsController.new,
);

class ReportsActionsController extends Notifier<bool> {
  @override
  bool build() => false;

  ReportsRepository get _repo => ref.read(reportsRepositoryProvider);

  Future<String?> requestCsvExport({
    required ReportCsvExportKind kind,
    required String periodId,
  }) async {
    final salonId = ref.read(sessionUserProvider).asData?.value?.salonId?.trim();
    if (salonId == null || salonId.isEmpty) {
      return 'missing_salon';
    }
    state = true;
    try {
      await _repo.requestReportExport(
        salonId: salonId,
        exportType: kind,
        format: 'csv',
        periodId: periodId.trim(),
      );
      return null;
    } on ReportsFailure catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      state = false;
    }
  }

  Future<String?> generatePayslipPdf({
    required String periodId,
    required String employeeId,
  }) async {
    final salonId = ref.read(sessionUserProvider).asData?.value?.salonId?.trim();
    if (salonId == null || salonId.isEmpty) {
      return 'missing_salon';
    }
    state = true;
    try {
      await _repo.generatePayslipPdf(
        salonId: salonId,
        periodId: periodId.trim(),
        employeeId: employeeId.trim(),
      );
      return null;
    } on ReportsFailure catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      state = false;
    }
  }

  Future<({String downloadUrl, String fileName})?> openExportDownload({
    required String exportJobId,
  }) async {
    final salonId = ref.read(sessionUserProvider).asData?.value?.salonId?.trim();
    if (salonId == null || salonId.isEmpty) {
      return null;
    }
    state = true;
    try {
      final r = await _repo.getExportDownloadUrl(
        salonId: salonId,
        exportJobId: exportJobId,
      );
      return (downloadUrl: r.downloadUrl, fileName: r.fileName);
    } finally {
      state = false;
    }
  }
}
