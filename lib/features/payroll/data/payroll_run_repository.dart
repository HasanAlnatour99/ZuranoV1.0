import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/result/app_result.dart';
import '../../../core/result/app_result_guard.dart';
import 'models/payroll_result_model.dart';
import 'models/payroll_run_model.dart';
import 'payroll_constants.dart';

class PayrollRunRepository {
  PayrollRunRepository({
    required FirebaseFirestore firestore,
    required ConnectivityService connectivityService,
    required AppLogger logger,
  }) : _firestore = firestore,
       _connectivityService = connectivityService,
       _logger = logger;

  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivityService;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _runs(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonPayrollRuns(salonId));
  }

  CollectionReference<Map<String, dynamic>> _results(
    String salonId,
    String runId,
  ) {
    FirestoreWritePayload.assertSalonId(salonId);
    if (runId.isEmpty) {
      throw ArgumentError.value(runId, 'runId', 'Payroll run ID is required.');
    }
    return _firestore.collection(
      FirestorePaths.salonPayrollRunResults(salonId, runId),
    );
  }

  Future<String> createRun(String salonId, PayrollRunModel run) async {
    final collection = _runs(salonId);
    final document = run.id.isEmpty ? collection.doc() : collection.doc(run.id);
    await document.set(
      FirestoreWritePayload.withServerTimestampsForCreate({
        ...run.copyWith(id: document.id).toJson(),
        'id': document.id,
        'reportPeriodKey': run.reportPeriodKey,
      }),
    );
    return document.id;
  }

  Future<AppResult<String>> createRunResult(
    String salonId,
    PayrollRunModel run,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'createPayrollRun',
      run: () => createRun(salonId, run),
    );
  }

  Future<void> updateRun(String salonId, PayrollRunModel run) {
    return _runs(salonId)
        .doc(run.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate({
            ...run.toJson(),
            'reportPeriodKey': run.reportPeriodKey,
          }),
          SetOptions(merge: true),
        );
  }

  Future<AppResult<Unit>> updateRunResult(String salonId, PayrollRunModel run) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'updatePayrollRun',
      run: () async {
        await updateRun(salonId, run);
        return unit;
      },
    );
  }

  Future<PayrollRunModel?> getRun(String salonId, String runId) async {
    final snapshot = await _runs(salonId).doc(runId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return PayrollRunModel.fromJson(data);
  }

  Future<AppResult<PayrollRunModel?>> getRunResult(
    String salonId,
    String runId,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getPayrollRun',
      run: () => getRun(salonId, runId),
    );
  }

  /// Employee ids that already appear on a **paid** [PayrollRunModel] whose
  /// [PayrollRunModel.reportPeriodKey] matches [reportPeriodKey].
  ///
  /// Scans up to [scanLimit] most recent paid runs (unordered) and filters in
  /// memory by period key. Excludes [excludeRunId] when recalculating a draft.
  Future<Set<String>> employeeIdsWithPaidRunForReportPeriod(
    String salonId, {
    required String reportPeriodKey,
    String? excludeRunId,
    int scanLimit = 300,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final key = reportPeriodKey.trim();
    if (key.isEmpty) {
      return const <String>{};
    }
    final exclude = excludeRunId?.trim();
    final snapshot = await _runs(salonId)
        .where('status', isEqualTo: PayrollRunStatuses.paid)
        .limit(scanLimit)
        .get();

    final out = <String>{};
    for (final doc in snapshot.docs) {
      if (exclude != null && exclude.isNotEmpty && doc.id == exclude) {
        continue;
      }
      final run = PayrollRunModel.fromJson(doc.data());
      if (run.reportPeriodKey != key) {
        continue;
      }
      for (final id in run.employeeIds) {
        final t = id.trim();
        if (t.isNotEmpty) {
          out.add(t);
        }
      }
      final single = run.employeeId?.trim();
      if (single != null && single.isNotEmpty) {
        out.add(single);
      }
    }
    return out;
  }

  Future<List<PayrollRunModel>> getRuns(
    String salonId, {
    String? status,
    int? year,
    int? month,
    int limit = 36,
  }) async {
    final snapshot = await _runsQuery(
      salonId,
      status: status,
      year: year,
      month: month,
      limit: limit,
    ).get();
    return snapshot.docs
        .map((doc) => PayrollRunModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<AppResult<List<PayrollRunModel>>> getRunsResult(
    String salonId, {
    String? status,
    int? year,
    int? month,
    int limit = 36,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getPayrollRuns',
      run: () => getRuns(
        salonId,
        status: status,
        year: year,
        month: month,
        limit: limit,
      ),
    );
  }

  Stream<List<PayrollRunModel>> watchRuns(
    String salonId, {
    String? status,
    int? year,
    int? month,
    int limit = 36,
  }) {
    return _runsQuery(
      salonId,
      status: status,
      year: year,
      month: month,
      limit: limit,
    ).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => PayrollRunModel.fromJson(doc.data()))
          .toList(growable: false),
    );
  }

  Stream<List<PayrollRunModel>> watchRunsForEmployee(
    String salonId,
    String employeeId, {
    int limit = 60,
  }) {
    return _runs(salonId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PayrollRunModel.fromJson(doc.data()))
              .where(
                (run) =>
                    run.employeeId == employeeId ||
                    run.employeeIds.contains(employeeId),
              )
              .toList(growable: false),
        );
  }

  Future<void> replaceResults(
    String salonId,
    String runId,
    List<PayrollResultModel> results,
  ) async {
    final collection = _results(salonId, runId);
    final existing = await collection.get();
    final batch = _firestore.batch();

    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final result in results) {
      final docRef = result.id.isEmpty
          ? collection.doc()
          : collection.doc(result.id);
      batch.set(
        docRef,
        FirestoreWritePayload.withServerTimestampsForCreate({
          ...result.copyWith(id: docRef.id, payrollRunId: runId).toJson(),
          'id': docRef.id,
          'payrollRunId': runId,
        }),
      );
    }

    await batch.commit();
  }

  Future<AppResult<Unit>> replaceResultsResult(
    String salonId,
    String runId,
    List<PayrollResultModel> results,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'replacePayrollResults',
      run: () async {
        await replaceResults(salonId, runId, results);
        return unit;
      },
    );
  }

  Future<List<PayrollResultModel>> getResults(
    String salonId,
    String runId, {
    String? employeeId,
  }) async {
    Query<Map<String, dynamic>> query = _results(
      salonId,
      runId,
    ).orderBy('displayOrder').orderBy('createdAt');
    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PayrollResultModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<AppResult<List<PayrollResultModel>>> getResultsResult(
    String salonId,
    String runId, {
    String? employeeId,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getPayrollResults',
      run: () => getResults(salonId, runId, employeeId: employeeId),
    );
  }

  Stream<List<PayrollResultModel>> watchResults(
    String salonId,
    String runId, {
    String? employeeId,
  }) {
    Query<Map<String, dynamic>> query = _results(
      salonId,
      runId,
    ).orderBy('displayOrder').orderBy('createdAt');
    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => PayrollResultModel.fromJson(doc.data()))
          .toList(growable: false),
    );
  }

  Query<Map<String, dynamic>> _runsQuery(
    String salonId, {
    String? status,
    int? year,
    int? month,
    required int limit,
  }) {
    Query<Map<String, dynamic>> query = _runs(
      salonId,
    ).orderBy('createdAt', descending: true);

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    if (year != null && month != null) {
      query = query
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month);
    }

    return query.limit(limit);
  }
}
