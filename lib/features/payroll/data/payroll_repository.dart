import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/payroll_statuses.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_serializers.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/utils/month_key_utils.dart';
import '../../employees/data/models/employee.dart';
import '../../sales/data/models/sale.dart';
import '../domain/models/payroll_adjustment.dart';
import '../domain/models/payroll_record.dart' as domain;
import '../domain/models/payroll_status.dart';
import 'models/payroll_record.dart';

/// Keys stored on `payrollAdjustments` docs: legacy lowercase, or
/// lowercase with whitespace collapsed to `_` (Cloud Functions).
Set<String> _payrollReasonKeyQueryVariants(String normalizedReason) {
  final lower = normalizedReason.toLowerCase();
  return {lower, lower.replaceAll(RegExp(r'\s+'), '_')};
}

bool _payrollAdjustmentDocMatchesReason(
  Map<String, dynamic> data,
  String normalizedReason,
  Set<String> keyVariants,
) {
  final rk = (data['reasonKey'] as String?)?.trim();
  if (rk != null && rk.isNotEmpty && keyVariants.contains(rk)) {
    return true;
  }
  final r = (data['reason'] as String?)?.trim() ?? '';
  if (r.isEmpty) return false;
  if (r == normalizedReason) return true;
  final rl = r.toLowerCase();
  final target = normalizedReason.toLowerCase();
  return rl == target ||
      keyVariants.contains(rl) ||
      keyVariants.contains(rl.replaceAll(RegExp(r'\s+'), '_'));
}

class PayrollRepository {
  PayrollRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _payroll(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonPayroll(salonId));
  }

  Future<String> createPayrollRecord(
    String salonId,
    PayrollRecord payrollRecord,
  ) async {
    final collection = _payroll(salonId);
    final document = payrollRecord.id.isEmpty
        ? collection.doc()
        : collection.doc(payrollRecord.id);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...payrollRecord.toJson(),
      'id': document.id,
    });

    await document.set(payload);
    return document.id;
  }

  Future<void> updatePayrollRecord(
    String salonId,
    PayrollRecord payrollRecord,
  ) {
    return _payroll(salonId)
        .doc(payrollRecord.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(
            payrollRecord.toJson(),
          ),
          SetOptions(merge: true),
        );
  }

  Future<PayrollRecord?> getPayrollRecord(
    String salonId,
    String payrollId,
  ) async {
    if (payrollId.isEmpty) {
      throw ArgumentError.value(
        payrollId,
        'payrollId',
        'Payroll ID is required.',
      );
    }
    final snapshot = await _payroll(salonId).doc(payrollId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return PayrollRecord.fromJson(data);
  }

  /// Non-voided payroll for the employee and calendar month, if any (latest by [periodStart]).
  Future<PayrollRecord?> findOpenPayrollForEmployeeMonth(
    String salonId,
    String employeeId,
    int year,
    int month,
  ) async {
    if (employeeId.isEmpty) {
      throw ArgumentError.value(
        employeeId,
        'employeeId',
        'Employee ID is required.',
      );
    }
    final snapshot = await _payroll(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final records = snapshot.docs
        .map((doc) => PayrollRecord.fromJson(doc.data()))
        .where((r) => r.status != PayrollStatuses.voided)
        .toList(growable: false);

    if (records.isEmpty) {
      return null;
    }

    records.sort((a, b) => b.periodStart.compareTo(a.periodStart));
    return records.first;
  }

  Future<void> markPayrollAsPaid(String salonId, String payrollId) async {
    if (payrollId.isEmpty) {
      throw ArgumentError.value(
        payrollId,
        'payrollId',
        'Payroll ID is required.',
      );
    }
    await _payroll(salonId).doc(payrollId).set({
      'status': PayrollStatuses.paid,
      'paidAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<PayrollRecord>> watchPayroll(
    String salonId, {
    String? employeeId,
    String? status,
    int? year,
    int? month,
    int limit = 36,
  }) {
    Query<Map<String, dynamic>> query = _payroll(salonId);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    if (year != null && month != null) {
      query = query
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month);
    }

    query = query.orderBy('periodStart', descending: true).limit(limit);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => PayrollRecord.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<String> fetchSalonCurrencyCode(String salonId) async {
    final snapshot = await _firestore.doc(FirestorePaths.salon(salonId)).get();
    final data = snapshot.data();
    if (data == null) {
      return 'USD';
    }
    final direct = (data['currencyCode'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty) {
      return direct.toUpperCase();
    }
    final settings = data['settings'];
    if (settings is Map<String, dynamic>) {
      final nested = (settings['currencyCode'] as String?)?.trim();
      if (nested != null && nested.isNotEmpty) {
        return nested.toUpperCase();
      }
    }
    return 'USD';
  }

  Future<Employee?> getEmployee(String salonId, String employeeId) async {
    final snapshot = await _firestore
        .doc(FirestorePaths.salonEmployee(salonId, employeeId))
        .get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return Employee.fromJson({...data, 'id': employeeId});
  }

  Future<List<Sale>> getEmployeeSalesByRange({
    required String salonId,
    required String employeeId,
    required DateTime start,
    required DateTime endExclusive,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.salonSales(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'completed')
        .where('soldAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('soldAt', isLessThan: Timestamp.fromDate(endExclusive))
        .get();
    return query.docs
        .map((doc) => Sale.fromJson({...doc.data(), 'id': doc.id}))
        .toList(growable: false);
  }

  Future<List<PayrollAdjustment>> getPayrollAdjustments({
    required String salonId,
    required String employeeId,
    required String monthKey,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.salonPayrollAdjustmentsV2(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'active')
        .get();
    final all = query.docs
        .map((doc) {
          final data = doc.data();
          return PayrollAdjustment(
            id: doc.id,
            salonId: data['salonId'] as String? ?? salonId,
            employeeId: data['employeeId'] as String? ?? employeeId,
            monthKey: data['monthKey'] as String? ?? monthKey,
            type: (data['type'] as String?) == 'deduction'
                ? PayrollAdjustmentType.deduction
                : PayrollAdjustmentType.bonus,
            amount: FirestoreSerializers.doubleValue(data['amount']),
            reason: data['reason'] as String? ?? '',
            note: data['note'] as String?,
            status: data['status'] as String? ?? 'active',
            isRecurring: data['isRecurring'] as bool? ?? false,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            createdBy: data['createdBy'] as String?,
          );
        })
        .toList(growable: false);
    final visible = all.where((item) {
      if (item.isRecurring) {
        return item.monthKey.compareTo(monthKey) <= 0;
      }
      return item.monthKey == monthKey;
    }).toList(growable: false);
    final latestRecurringByKey = <String, PayrollAdjustment>{};
    final oneTime = <PayrollAdjustment>[];
    for (final item in visible) {
      if (!item.isRecurring) {
        oneTime.add(item);
        continue;
      }
      final key = '${item.type.value}:${item.reason.trim().toLowerCase()}';
      final existing = latestRecurringByKey[key];
      if (existing == null || existing.monthKey.compareTo(item.monthKey) < 0) {
        latestRecurringByKey[key] = item;
      }
    }
    return <PayrollAdjustment>[
      ...oneTime,
      ...latestRecurringByKey.values,
    ];
  }

  Future<domain.PayrollRecord?> getTeamMemberPayrollRecord({
    required String salonId,
    required String employeeId,
    required String monthKey,
  }) async {
    final docId = '${employeeId}_$monthKey';
    final snapshot = await _firestore
        .doc(FirestorePaths.salonPayrollRecord(salonId, docId))
        .get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return _domainRecordFromMap(docId, data);
  }

  Future<List<domain.PayrollRecord>> getTeamMemberPayrollHistory({
    required String salonId,
    required String employeeId,
    int limit = 12,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.salonPayroll(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('monthKey', descending: true)
        .limit(limit)
        .get();
    return query.docs
        .map((doc) => _domainRecordFromMap(doc.id, doc.data()))
        .toList(growable: false);
  }

  Future<void> addPayrollAdjustment({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required double amount,
    required String reason,
    required bool isRecurring,
    required String? note,
    required String userId,
  }) async {
    final normalizedReason = reason.trim();
    final normalizedReasonKey = normalizedReason.toLowerCase();
    final noteValue = note?.trim();
    final collection = _firestore.collection(
      FirestorePaths.salonPayrollAdjustmentsV2(salonId),
    );
    final existingQuery = await collection
        .where('employeeId', isEqualTo: employeeId)
        .where('monthKey', isEqualTo: monthKey)
        .where('type', isEqualTo: type.value)
        .where('reasonKey', isEqualTo: normalizedReasonKey)
        .where('isRecurring', isEqualTo: isRecurring)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    final fallbackQuery = existingQuery.docs.isNotEmpty
        ? null
        : await collection
              .where('employeeId', isEqualTo: employeeId)
              .where('monthKey', isEqualTo: monthKey)
              .where('type', isEqualTo: type.value)
              .where('reason', isEqualTo: normalizedReason)
              .where('isRecurring', isEqualTo: isRecurring)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

    if (existingQuery.docs.isNotEmpty || (fallbackQuery?.docs.isNotEmpty ?? false)) {
      final existing = existingQuery.docs.isNotEmpty
          ? existingQuery.docs.first
          : fallbackQuery!.docs.first;
      final existingAmount = (existing.data()['amount'] as num?)?.toDouble() ?? 0;
      await existing.reference.set({
        'amount': existingAmount + amount,
        'reasonKey': normalizedReasonKey,
        if (noteValue != null && noteValue.isNotEmpty) 'note': noteValue,
        'updatedBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final ref = collection.doc();
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      'id': ref.id,
      'salonId': salonId,
      'employeeId': employeeId,
      'monthKey': monthKey,
      'type': type.value,
      'amount': amount,
      'reason': normalizedReason,
      'reasonKey': normalizedReasonKey,
      if (noteValue != null && noteValue.isNotEmpty) 'note': noteValue,
      'status': 'active',
      'isRecurring': isRecurring,
      'createdBy': userId,
      'updatedBy': userId,
    });
    await ref.set(payload);
  }

  /// Returns how many adjustment documents were soft-removed.
  Future<int> removePayrollAdjustmentElement({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required String reason,
    required String userId,
  }) async {
    final normalizedReason = reason.trim();
    final keyVariants = _payrollReasonKeyQueryVariants(normalizedReason);
    final collection = _firestore.collection(
      FirestorePaths.salonPayrollAdjustmentsV2(salonId),
    );

    final removedPayload = {
      'status': 'removed',
      'removedAt': FieldValue.serverTimestamp(),
      'removedBy': userId,
      'updatedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final processedIds = <String>{};

    Future<void> softRemove(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
      if (!processedIds.add(doc.id)) return;
      await doc.reference.set(removedPayload, SetOptions(merge: true));
    }

    for (final rk in keyVariants) {
      final recurringByKey = await collection
          .where('employeeId', isEqualTo: employeeId)
          .where('type', isEqualTo: type.value)
          .where('reasonKey', isEqualTo: rk)
          .where('isRecurring', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .get();
      for (final doc in recurringByKey.docs) {
        await softRemove(doc);
      }

      final oneTimeByKey = await collection
          .where('employeeId', isEqualTo: employeeId)
          .where('monthKey', isEqualTo: monthKey)
          .where('type', isEqualTo: type.value)
          .where('reasonKey', isEqualTo: rk)
          .where('status', isEqualTo: 'active')
          .get();
      for (final doc in oneTimeByKey.docs) {
        await softRemove(doc);
      }
    }

    final recurringByReason = await collection
        .where('employeeId', isEqualTo: employeeId)
        .where('type', isEqualTo: type.value)
        .where('isRecurring', isEqualTo: true)
        .where('reason', isEqualTo: normalizedReason)
        .where('status', isEqualTo: 'active')
        .get();
    for (final doc in recurringByReason.docs) {
      await softRemove(doc);
    }

    final oneTimeByReason = await collection
        .where('employeeId', isEqualTo: employeeId)
        .where('monthKey', isEqualTo: monthKey)
        .where('type', isEqualTo: type.value)
        .where('reason', isEqualTo: normalizedReason)
        .where('status', isEqualTo: 'active')
        .get();
    for (final doc in oneTimeByReason.docs) {
      await softRemove(doc);
    }

    final monthSweep = await collection
        .where('employeeId', isEqualTo: employeeId)
        .where('monthKey', isEqualTo: monthKey)
        .where('status', isEqualTo: 'active')
        .get();
    for (final doc in monthSweep.docs) {
      final data = doc.data();
      if (data['type'] != type.value) continue;
      if (data['isRecurring'] == true) continue;
      if (!_payrollAdjustmentDocMatchesReason(data, normalizedReason, keyVariants)) {
        continue;
      }
      await softRemove(doc);
    }

    final recurringSweep = await collection
        .where('employeeId', isEqualTo: employeeId)
        .where('type', isEqualTo: type.value)
        .where('isRecurring', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .get();
    for (final doc in recurringSweep.docs) {
      final data = doc.data();
      if (!_payrollAdjustmentDocMatchesReason(data, normalizedReason, keyVariants)) {
        continue;
      }
      await softRemove(doc);
    }

    return processedIds.length;
  }

  Future<void> generateTeamMemberPayroll({
    required String salonId,
    required String employeeId,
    required String employeeName,
    required String monthKey,
    required String currencyCode,
    required double servicesRevenue,
    required double commissionPercentage,
    required double commissionAmount,
    required double bonusesTotal,
    required double deductionsTotal,
    required double netPayout,
    required int salesCount,
    required List<String> adjustmentIds,
    required String userId,
  }) async {
    final docId = '${employeeId}_$monthKey';
    final ref = _firestore.doc(
      FirestorePaths.salonPayrollRecord(salonId, docId),
    );
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      final data = existing.data();
      if (data != null &&
          PayrollStatusX.fromString(data['status'] as String?) ==
              PayrollStatus.paid) {
        throw StateError('Cannot regenerate a paid payroll record.');
      }
      final payload = <String, dynamic>{
        'id': docId,
        'salonId': salonId,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'monthKey': monthKey,
        'currencyCode': currencyCode,
        'servicesRevenue': servicesRevenue,
        'commissionPercentage': commissionPercentage,
        'commissionAmount': commissionAmount,
        'bonusesTotal': bonusesTotal,
        'deductionsTotal': deductionsTotal,
        'netPayout': netPayout,
        'status': PayrollStatus.ready.value,
        'salesCount': salesCount,
        'adjustmentIds': adjustmentIds,
        'generatedBy': userId,
        'generatedAt': FieldValue.serverTimestamp(),
        'createdAt': existing.exists
            ? (data?['createdAt'] ?? FieldValue.serverTimestamp())
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      tx.set(ref, payload, SetOptions(merge: true));
    });
  }

  Future<void> reverseLatestTeamMemberPayrollMonth({
    required String salonId,
    required String employeeId,
    required String userId,
  }) async {
    final latestQuery = await _firestore
        .collection(FirestorePaths.salonPayroll(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('monthKey', descending: true)
        .limit(1)
        .get();

    if (latestQuery.docs.isEmpty) {
      throw StateError('No payroll month found to reverse.');
    }

    final latestDoc = latestQuery.docs.first;
    final latestData = latestDoc.data();
    final status = PayrollStatusX.fromString(latestData['status'] as String?);
    if (status == PayrollStatus.cancelled) {
      throw StateError('Latest payroll month is already reversed.');
    }

    await latestDoc.reference.set({
      'status': PayrollStatus.cancelled.value,
      'reversedAt': FieldValue.serverTimestamp(),
      'reversedBy': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  domain.PayrollRecord _domainRecordFromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final monthKeyRaw =
        FirestoreSerializers.string(data['monthKey'])?.trim();
    final reportKeyRaw =
        FirestoreSerializers.string(data['reportPeriodKey'])?.trim();
    final resolvedMonthKey =
        (monthKeyRaw != null && monthKeyRaw.isNotEmpty)
            ? monthKeyRaw
            : (reportKeyRaw != null && reportKeyRaw.isNotEmpty)
                ? reportKeyRaw
                : MonthKeyUtils.fromDate(DateTime.now());

    return domain.PayrollRecord(
      id: id,
      salonId: data['salonId'] as String? ?? '',
      employeeId: data['employeeId'] as String? ?? '',
      employeeName: data['employeeName'] as String? ?? '',
      monthKey: resolvedMonthKey,
      currencyCode: data['currencyCode'] as String? ?? 'USD',
      servicesRevenue: FirestoreSerializers.doubleValue(
        data['servicesRevenue'] ?? data['totalSales'] ?? data['baseAmount'],
      ),
      commissionPercentage: FirestoreSerializers.doubleValue(
        data['commissionPercentage'],
      ),
      commissionAmount: FirestoreSerializers.doubleValue(
        data['commissionAmount'],
      ),
      bonusesTotal: FirestoreSerializers.doubleValue(
        data['bonusesTotal'] ?? data['bonusAmount'],
      ),
      deductionsTotal: FirestoreSerializers.doubleValue(
        data['deductionsTotal'] ?? data['deductionAmount'],
      ),
      netPayout: FirestoreSerializers.doubleValue(
        data['netPayout'] ?? data['netAmount'],
      ),
      status: PayrollStatusX.fromString(
        FirestoreSerializers.string(data['status']),
      ),
      salesCount: FirestoreSerializers.intValue(data['salesCount']),
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate(),
      generatedBy: data['generatedBy'] as String?,
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      paidBy: data['paidBy'] as String?,
    );
  }
}
