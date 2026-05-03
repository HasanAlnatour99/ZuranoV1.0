import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/payroll_statuses.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../../core/constants/violation_types.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/text/team_member_name.dart';
import '../../employees/data/employee_repository.dart';
import '../../employees/data/models/employee.dart';
import '../../sales/data/sales_repository.dart';
import '../../violations/data/violation_repository.dart';
import 'models/payroll_deduction_line.dart';
import 'models/payroll_record.dart';
import 'payroll_repository.dart';

/// Salon-scoped payroll calculations and writes.
class PayrollService {
  PayrollService({
    required PayrollRepository payrollRepository,
    required SalesRepository salesRepository,
    required EmployeeRepository employeeRepository,
    required ViolationRepository violationRepository,
    required FirebaseFirestore firestore,
  }) : _payrollRepository = payrollRepository,
       _salesRepository = salesRepository,
       _employeeRepository = employeeRepository,
       _violationRepository = violationRepository,
       _firestore = firestore;

  final PayrollRepository _payrollRepository;
  final SalesRepository _salesRepository;
  final EmployeeRepository _employeeRepository;
  final ViolationRepository _violationRepository;
  final FirebaseFirestore _firestore;

  static DateTime periodStartUtc(int year, int month) =>
      DateTime.utc(year, month, 1);

  static DateTime periodEndInclusiveUtc(int year, int month) =>
      DateTime.utc(year, month + 1, 0, 23, 59, 59, 999);

  static double roundMoney(double value) =>
      double.parse(value.toStringAsFixed(2));

  static double commissionAmountFromSales(
    double totalSales,
    double commissionRatePercent,
  ) {
    return roundMoney(totalSales * commissionRatePercent / 100);
  }

  static double netFromParts({
    required double baseAmount,
    required double commissionAmount,
    required double bonusAmount,
    required double deductionAmount,
  }) {
    return roundMoney(
      baseAmount + commissionAmount + bonusAmount - deductionAmount,
    );
  }

  PayrollRecord _mergeViolationsIntoPayroll({
    required PayrollRecord draft,
    required List<PayrollDeductionLine> violationLines,
    required double violationSum,
    required double manualDeductionAmount,
    required String id,
    required String status,
    String? notes,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final deductionAmount = roundMoney(violationSum + manualDeductionAmount);
    final netAmount = netFromParts(
      baseAmount: draft.baseAmount,
      commissionAmount: draft.commissionAmount,
      bonusAmount: draft.bonusAmount,
      deductionAmount: deductionAmount,
    );
    return PayrollRecord(
      id: id,
      salonId: draft.salonId,
      employeeId: draft.employeeId,
      employeeName: draft.employeeName,
      periodStart: draft.periodStart,
      periodEnd: draft.periodEnd,
      baseAmount: draft.baseAmount,
      commissionAmount: draft.commissionAmount,
      totalSales: draft.totalSales,
      commissionRate: draft.commissionRate,
      bonusAmount: draft.bonusAmount,
      deductionAmount: deductionAmount,
      manualDeductionAmount: manualDeductionAmount,
      deductionLines: violationLines,
      netAmount: netAmount,
      status: status,
      month: draft.month,
      year: draft.year,
      notes: notes,
      paidAt: paidAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Future<({List<PayrollDeductionLine> lines, double sum})>
  _violationLinesForDraft(
    PayrollRecord draft,
    String salonId,
    int year,
    int month,
  ) async {
    final violations = await _violationRepository
        .getApprovedUnappliedForEmployeeMonth(
          salonId,
          draft.employeeId,
          year,
          month,
        );
    final grossBefore =
        draft.baseAmount + draft.commissionAmount + draft.bonusAmount;
    final lines = <PayrollDeductionLine>[];
    var sum = 0.0;
    for (final v in violations) {
      var amt = v.amount;
      if (amt == 0 && v.percent != null && v.percent! > 0) {
        amt = roundMoney(grossBefore * v.percent! / 100);
      }
      sum += amt;
      final label = v.violationType == ViolationTypes.exceededBreakTime &&
              (v.minutesLate ?? 0) > 0
          ? '${ViolationTypes.exceededBreakTime} · ${v.minutesLate}m'
          : v.violationType;
      lines.add(
        PayrollDeductionLine(
          kind: 'violation',
          amount: amt,
          violationId: v.id,
          bookingId: v.bookingId,
          label: label,
        ),
      );
    }
    return (lines: lines, sum: roundMoney(sum));
  }

  List<String> _violationIdsFromLines(List<PayrollDeductionLine> lines) {
    return lines
        .map((e) => e.violationId)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _commitPayrollAndAppliedViolations({
    required String salonId,
    required PayrollRecord payroll,
    required List<String> violationIds,
  }) async {
    if (payroll.id.isEmpty) {
      throw StateError('Payroll id required to apply violations.');
    }
    final batch = _firestore.batch();
    final payRef = _firestore.doc(
      FirestorePaths.salonPayrollRecord(salonId, payroll.id),
    );
    batch.set(
      payRef,
      FirestoreWritePayload.withServerTimestampForUpdate(payroll.toJson()),
      SetOptions(merge: true),
    );
    for (final vid in violationIds) {
      final vRef = _firestore.doc(FirestorePaths.salonViolation(salonId, vid));
      batch.update(vRef, {
        'status': ViolationStatuses.applied,
        'payrollRunId': payroll.id,
        'appliedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Draft payroll for one employee (not persisted). [month] is 1–12; period is UTC.
  Future<PayrollRecord> calculatePayroll({
    required String salonId,
    required String employeeId,
    required int year,
    required int month,
  }) async {
    _assertCalendarMonth(year, month);

    final employee = await _employeeRepository.getEmployee(salonId, employeeId);
    if (employee == null) {
      throw ArgumentError.value(
        employeeId,
        'employeeId',
        'Employee not found for salon.',
      );
    }

    final sales = await _salesRepository.getSalesByEmployee(
      salonId,
      employeeId,
      reportYear: year,
      reportMonth: month,
      limit: 2000,
    );

    final totalSales = roundMoney(
      sales
          .where((s) => s.status == SaleStatuses.completed)
          .fold<double>(0, (running, s) => running + s.total),
    );

    final rate = employee.salesCommissionPercentFallback;
    var commissionAmount = commissionAmountFromSales(totalSales, rate);
    if (employee.commissionType == EmployeeCommissionTypes.fixed) {
      commissionAmount = roundMoney(employee.resolvedCommissionFixedAmount);
    } else if (employee.commissionType ==
        EmployeeCommissionTypes.percentagePlusFixed) {
      commissionAmount = roundMoney(
        commissionAmount + employee.resolvedCommissionFixedAmount,
      );
    }

    const baseAmount = 0.0;
    const bonusAmount = 0.0;
    const deductionAmount = 0.0;

    final netAmount = netFromParts(
      baseAmount: baseAmount,
      commissionAmount: commissionAmount,
      bonusAmount: bonusAmount,
      deductionAmount: deductionAmount,
    );

    final periodStart = periodStartUtc(year, month);
    final periodEnd = periodEndInclusiveUtc(year, month);

    return PayrollRecord(
      id: '',
      salonId: salonId,
      employeeId: employee.id,
      employeeName: formatTeamMemberName(employee.name),
      periodStart: periodStart,
      periodEnd: periodEnd,
      baseAmount: baseAmount,
      commissionAmount: commissionAmount,
      totalSales: totalSales,
      commissionRate: rate,
      bonusAmount: bonusAmount,
      deductionAmount: deductionAmount,
      manualDeductionAmount: 0,
      deductionLines: const [],
      netAmount: netAmount,
      status: PayrollStatuses.draft,
    );
  }

  /// Persists calculated payroll for [year]-[month].
  Future<List<String>> generatePayroll({
    required String salonId,
    required int year,
    required int month,
    Iterable<String>? employeeIds,
  }) async {
    _assertCalendarMonth(year, month);

    final idSet = employeeIds
        ?.map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    var employees = await _employeeRepository.getEmployees(
      salonId,
      onlyActive: true,
    );
    if (idSet != null) {
      employees = employees.where((e) => idSet.contains(e.id)).toList();
    }

    final createdOrUpdated = <String>[];

    for (final employee in employees) {
      final draft = await calculatePayroll(
        salonId: salonId,
        employeeId: employee.id,
        year: year,
        month: month,
      );

      final existing = await _payrollRepository.findOpenPayrollForEmployeeMonth(
        salonId,
        employee.id,
        year,
        month,
      );

      if (existing != null && existing.status == PayrollStatuses.paid) {
        continue;
      }

      final manual = existing?.manualDeductionAmount ?? 0.0;
      final viol = await _violationLinesForDraft(draft, salonId, year, month);
      final vIds = _violationIdsFromLines(viol.lines);

      if (existing != null) {
        final merged = _mergeViolationsIntoPayroll(
          draft: draft,
          violationLines: viol.lines,
          violationSum: viol.sum,
          manualDeductionAmount: manual,
          id: existing.id,
          status: existing.status,
          notes: existing.notes,
          paidAt: existing.paidAt,
          createdAt: existing.createdAt,
          updatedAt: existing.updatedAt,
        );
        await _commitPayrollAndAppliedViolations(
          salonId: salonId,
          payroll: merged,
          violationIds: vIds,
        );
        createdOrUpdated.add(existing.id);
      } else {
        final docRef = _firestore
            .collection(FirestorePaths.salonPayroll(salonId))
            .doc();
        final newId = docRef.id;
        final merged = _mergeViolationsIntoPayroll(
          draft: draft,
          violationLines: viol.lines,
          violationSum: viol.sum,
          manualDeductionAmount: manual,
          id: newId,
          status: PayrollStatuses.draft,
          notes: null,
          paidAt: null,
          createdAt: null,
          updatedAt: null,
        );
        final batch = _firestore.batch();
        batch.set(
          docRef,
          FirestoreWritePayload.withServerTimestampsForCreate({
            ...merged.toJson(),
            'id': newId,
          }),
        );
        for (final vid in vIds) {
          final vRef = _firestore.doc(
            FirestorePaths.salonViolation(salonId, vid),
          );
          batch.update(vRef, {
            'status': ViolationStatuses.applied,
            'payrollRunId': newId,
            'appliedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        createdOrUpdated.add(newId);
      }
    }

    return createdOrUpdated;
  }

  Future<void> markAsPaid({
    required String salonId,
    required String payrollId,
  }) async {
    final record = await _payrollRepository.getPayrollRecord(
      salonId,
      payrollId,
    );
    if (record == null) {
      throw ArgumentError.value(payrollId, 'payrollId', 'Payroll not found.');
    }
    if (record.status == PayrollStatuses.voided) {
      throw StateError('Cannot mark a voided payroll as paid.');
    }
    if (record.status == PayrollStatuses.paid) {
      return;
    }
    await _payrollRepository.markPayrollAsPaid(salonId, payrollId);
  }

  void _assertCalendarMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12.',
      );
    }
    if (year < 1970 || year > 2100) {
      throw ArgumentError.value(year, 'year', 'Year is out of range.');
    }
  }
}
