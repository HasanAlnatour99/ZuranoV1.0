import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/firestore/report_period.dart';
import 'models/expense.dart';

class ExpenseRepository {
  ExpenseRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expenses(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonExpenses(salonId));
  }

  /// Persists [expense] under `salons/{salonId}/expenses/{expenseId}`.
  Future<String> addExpense(String salonId, Expense expense) async {
    final collection = _expenses(salonId);
    final document = expense.id.isEmpty
        ? collection.doc()
        : collection.doc(expense.id);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...expense.toJson(),
      'id': document.id,
    });

    await document.set(payload);
    return document.id;
  }

  /// Alias for [addExpense] — matches naming used by other repositories.
  Future<String> createExpense(String salonId, Expense expense) {
    return addExpense(salonId, expense);
  }

  Future<void> updateExpense(String salonId, Expense expense) {
    return _expenses(salonId)
        .doc(expense.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(expense.toJson()),
          SetOptions(merge: true),
        );
  }

  /// One-time fetch of expenses, newest [incurredAt] first.
  Future<List<Expense>> getExpenses(
    String salonId, {
    String? category,
    DateTime? incurredFrom,
    DateTime? incurredTo,
    int limit = 100,
  }) async {
    final snapshot = await _expensesQuery(
      salonId,
      category: category,
      incurredFrom: incurredFrom,
      incurredTo: incurredTo,
      limit: limit,
    ).get();

    return _mapActive(snapshot.docs);
  }

  /// Expenses whose denormalized [Expense.reportYear] / [Expense.reportMonth]
  /// match the given calendar month (same convention as [Expense] defaults).
  Future<List<Expense>> getMonthlyExpenses(
    String salonId, {
    required int year,
    required int month,
    int limit = 500,
  }) async {
    final snapshot = await _expensesQuery(
      salonId,
      reportYear: year,
      reportMonth: month,
      limit: limit,
    ).get();

    return _mapActive(snapshot.docs);
  }

  /// Same as [getMonthlyExpenses] but accepts canonical [ReportPeriod.periodKey] (`YYYY-MM`).
  Future<List<Expense>> getMonthlyExpensesByPeriodKey(
    String salonId, {
    required String reportPeriodKey,
    int limit = 500,
  }) {
    final parsed = ReportPeriod.parsePeriodKey(reportPeriodKey);
    if (parsed == null) {
      throw ArgumentError.value(
        reportPeriodKey,
        'reportPeriodKey',
        'Expected YYYY-MM.',
      );
    }
    return getMonthlyExpenses(
      salonId,
      year: parsed.$1,
      month: parsed.$2,
      limit: limit,
    );
  }

  Stream<List<Expense>> watchExpenses(
    String salonId, {
    String? category,
    int? reportYear,
    int? reportMonth,
    DateTime? incurredFrom,
    DateTime? incurredTo,
    int limit = 100,
  }) {
    return _expensesQuery(
      salonId,
      category: category,
      reportYear: reportYear,
      reportMonth: reportMonth,
      incurredFrom: incurredFrom,
      incurredTo: incurredTo,
      limit: limit,
    ).snapshots().map((snapshot) => _mapActive(snapshot.docs));
  }

  List<Expense> _mapActive(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => Expense.fromJson(doc.data()))
        .where((e) => !e.isDeleted)
        .toList(growable: false);
  }

  /// Sets [Expense.isDeleted] to true (soft delete). Owner-only in rules.
  Future<void> deleteExpenseSoft(String salonId, String expenseId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _expenses(salonId).doc(expenseId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Query<Map<String, dynamic>> _expensesQuery(
    String salonId, {
    String? category,
    int? reportYear,
    int? reportMonth,
    DateTime? incurredFrom,
    DateTime? incurredTo,
    required int limit,
  }) {
    Query<Map<String, dynamic>> query = _expenses(salonId);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (reportYear != null && reportMonth != null) {
      query = query
          .where('reportYear', isEqualTo: reportYear)
          .where('reportMonth', isEqualTo: reportMonth);
    }

    if (incurredFrom != null) {
      query = query.where('incurredAt', isGreaterThanOrEqualTo: incurredFrom);
    }

    if (incurredTo != null) {
      query = query.where('incurredAt', isLessThanOrEqualTo: incurredTo);
    }

    return query.orderBy('incurredAt', descending: true).limit(limit);
  }
}
