import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/result/app_result.dart';
import '../../../core/result/app_result_guard.dart';
import 'models/employee_element_entry_model.dart';
import 'payroll_constants.dart';

class EmployeeElementEntryRepository {
  EmployeeElementEntryRepository({
    required FirebaseFirestore firestore,
    required ConnectivityService connectivityService,
    required AppLogger logger,
  }) : _firestore = firestore,
       _connectivityService = connectivityService,
       _logger = logger;

  final FirebaseFirestore _firestore;
  final ConnectivityService _connectivityService;
  final AppLogger _logger;

  CollectionReference<Map<String, dynamic>> _entries(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(
      FirestorePaths.salonEmployeeElementEntries(salonId),
    );
  }

  Future<String> createEntry(
    String salonId,
    EmployeeElementEntryModel entry,
  ) async {
    final collection = _entries(salonId);
    final document = entry.id.isEmpty
        ? collection.doc()
        : collection.doc(entry.id);
    await document.set(
      FirestoreWritePayload.withServerTimestampsForCreate({
        ...entry.copyWith(id: document.id).toJson(),
        'id': document.id,
      }),
    );
    return document.id;
  }

  Future<AppResult<String>> createEntryResult(
    String salonId,
    EmployeeElementEntryModel entry,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'createEmployeeElementEntry',
      run: () => createEntry(salonId, entry),
    );
  }

  Future<void> updateEntry(String salonId, EmployeeElementEntryModel entry) {
    return _entries(salonId)
        .doc(entry.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(entry.toJson()),
          SetOptions(merge: true),
        );
  }

  Future<AppResult<Unit>> updateEntryResult(
    String salonId,
    EmployeeElementEntryModel entry,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'updateEmployeeElementEntry',
      run: () async {
        await updateEntry(salonId, entry);
        return unit;
      },
    );
  }

  Future<void> deleteEntry(String salonId, String entryId) {
    return _entries(salonId).doc(entryId).delete();
  }

  Future<AppResult<Unit>> deleteEntryResult(String salonId, String entryId) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'deleteEmployeeElementEntry',
      run: () async {
        await deleteEntry(salonId, entryId);
        return unit;
      },
    );
  }

  Future<EmployeeElementEntryModel?> getEntry(
    String salonId,
    String entryId,
  ) async {
    final snapshot = await _entries(salonId).doc(entryId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return EmployeeElementEntryModel.fromJson(data);
  }

  Future<AppResult<EmployeeElementEntryModel?>> getEntryResult(
    String salonId,
    String entryId,
  ) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getEmployeeElementEntry',
      run: () => getEntry(salonId, entryId),
    );
  }

  Future<List<EmployeeElementEntryModel>> getEntriesForEmployee(
    String salonId,
    String employeeId, {
    bool activeOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = _entries(salonId)
        .where('employeeId', isEqualTo: employeeId);
    if (activeOnly) {
      query = query.where('status', isEqualTo: PayrollEntryStatuses.active);
    }
    query = query.orderBy('updatedAt', descending: true);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => EmployeeElementEntryModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<AppResult<List<EmployeeElementEntryModel>>>
  getEntriesForEmployeeResult(
    String salonId,
    String employeeId, {
    bool activeOnly = false,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getEmployeeEntries',
      run: () =>
          getEntriesForEmployee(salonId, employeeId, activeOnly: activeOnly),
    );
  }

  Stream<List<EmployeeElementEntryModel>> watchEntriesForEmployee(
    String salonId,
    String employeeId, {
    bool activeOnly = false,
  }) {
    Query<Map<String, dynamic>> query = _entries(salonId)
        .where('employeeId', isEqualTo: employeeId);
    if (activeOnly) {
      query = query.where('status', isEqualTo: PayrollEntryStatuses.active);
    }
    query = query.orderBy('updatedAt', descending: true);
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => EmployeeElementEntryModel.fromJson(doc.data()))
          .toList(growable: false),
    );
  }

  Future<List<EmployeeElementEntryModel>> getActiveRecurringEntriesForPeriod(
    String salonId,
    String employeeId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final snapshot = await _entries(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: PayrollEntryStatuses.active)
        .where('recurrenceType', isEqualTo: PayrollRecurrenceTypes.recurring)
        .get();

    return snapshot.docs
        .map((doc) => EmployeeElementEntryModel.fromJson(doc.data()))
        .where(
          (entry) => entry.appliesToPeriod(
            periodStart: periodStart,
            periodEnd: periodEnd,
            year: periodStart.year,
            month: periodStart.month,
          ),
        )
        .toList(growable: false);
  }

  Future<AppResult<List<EmployeeElementEntryModel>>>
  getActiveRecurringEntriesForPeriodResult(
    String salonId,
    String employeeId, {
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getActiveRecurringEmployeeEntries',
      run: () => getActiveRecurringEntriesForPeriod(
        salonId,
        employeeId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
    );
  }

  Future<List<EmployeeElementEntryModel>> getCurrentPeriodNonRecurringEntries(
    String salonId,
    String employeeId, {
    required int year,
    required int month,
  }) async {
    final snapshot = await _entries(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: PayrollEntryStatuses.active)
        .where('recurrenceType', isEqualTo: PayrollRecurrenceTypes.nonrecurring)
        .where('payrollYear', isEqualTo: year)
        .where('payrollMonth', isEqualTo: month)
        .get();

    return snapshot.docs
        .map((doc) => EmployeeElementEntryModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<AppResult<List<EmployeeElementEntryModel>>>
  getCurrentPeriodNonRecurringEntriesResult(
    String salonId,
    String employeeId, {
    required int year,
    required int month,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'getCurrentPeriodNonRecurringEmployeeEntries',
      run: () => getCurrentPeriodNonRecurringEntries(
        salonId,
        employeeId,
        year: year,
        month: month,
      ),
    );
  }
}
