import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/payroll_statuses.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import 'payslip_line_model.dart';

/// `salons/{salonId}/payslips/{payslipId}` — monthly payslip for one employee.
class PayslipModel {
  const PayslipModel({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeRole,
    this.employeePhotoUrl,
    required this.year,
    required this.month,
    required this.periodStart,
    required this.periodEnd,
    required this.currency,
    required this.status,
    required this.employeeVisible,
    required this.baseSalary,
    this.baseSalaryNominal,
    this.baseSalaryProrationRatio,
    required this.serviceRevenue,
    required this.commissionPercent,
    required this.commissionAmount,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netPay,
    required this.servicesCount,
    required this.attendanceDaysPresent,
    required this.attendanceRequiredDays,
    required this.lateCount,
    required this.absenceCount,
    required this.missingCheckoutCount,
    required this.lines,
    this.generatedBy,
    this.approvedBy,
    this.paidBy,
    this.generatedAt,
    this.approvedAt,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
    this.payrollRunId,
  });

  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String employeeRole;
  final String? employeePhotoUrl;
  final int year;
  final int month;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currency;
  final String status;
  final bool employeeVisible;
  final double baseSalary;
  final double? baseSalaryNominal;
  final double? baseSalaryProrationRatio;
  final double serviceRevenue;
  final double commissionPercent;
  final double commissionAmount;
  final double totalEarnings;
  final double totalDeductions;
  final double netPay;
  final int servicesCount;
  final int attendanceDaysPresent;
  final int attendanceRequiredDays;
  final int lateCount;
  final int absenceCount;
  final int missingCheckoutCount;
  final List<PayslipLineModel> lines;
  final String? generatedBy;
  final String? approvedBy;
  final String? paidBy;
  final DateTime? generatedAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Set when this payslip was generated from the payroll-run pipeline (`payroll_runs`).
  final String? payrollRunId;

  bool get isPaid => status == PayrollStatuses.paid;
  bool get isApproved => status == PayrollStatuses.approved;

  factory PayslipModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<PayslipLineModel> lines,
  ) {
    final d = doc.data() ?? {};
    return PayslipModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      employeeId: looseStringFromJson(d['employeeId']),
      employeeName: looseStringFromJson(d['employeeName']),
      employeeRole: looseStringFromJson(d['employeeRole']),
      employeePhotoUrl: nullableLooseStringFromJson(d['employeePhotoUrl']),
      year: looseIntFromJson(d['year']),
      month: looseIntFromJson(d['month']),
      periodStart: firestoreDateTimeFromJson(d['periodStart']),
      periodEnd: firestoreDateTimeFromJson(d['periodEnd']),
      currency: looseStringFromJson(d['currency']),
      status: looseStringFromJson(d['status']),
      employeeVisible: trueBoolFromJson(d['employeeVisible']),
      baseSalary: looseDoubleFromJson(d['baseSalary']),
      baseSalaryNominal: nullableLooseDoubleFromJson(d['baseSalaryNominal']),
      baseSalaryProrationRatio: nullableLooseDoubleFromJson(
        d['baseSalaryProrationRatio'],
      ),
      serviceRevenue: looseDoubleFromJson(d['serviceRevenue']),
      commissionPercent: looseDoubleFromJson(d['commissionPercent']),
      commissionAmount: looseDoubleFromJson(d['commissionAmount']),
      totalEarnings: looseDoubleFromJson(d['totalEarnings']),
      totalDeductions: looseDoubleFromJson(d['totalDeductions']),
      netPay: looseDoubleFromJson(d['netPay']),
      servicesCount: looseIntFromJson(d['servicesCount']),
      attendanceDaysPresent: looseIntFromJson(d['attendanceDaysPresent']),
      attendanceRequiredDays: looseIntFromJson(d['attendanceRequiredDays']),
      lateCount: looseIntFromJson(d['lateCount']),
      absenceCount: looseIntFromJson(d['absenceCount']),
      missingCheckoutCount: looseIntFromJson(d['missingCheckoutCount']),
      lines: lines,
      generatedBy: nullableLooseStringFromJson(d['generatedBy']),
      approvedBy: nullableLooseStringFromJson(d['approvedBy']),
      paidBy: nullableLooseStringFromJson(d['paidBy']),
      generatedAt: nullableFirestoreDateTimeFromJson(d['generatedAt']),
      approvedAt: nullableFirestoreDateTimeFromJson(d['approvedAt']),
      paidAt: nullableFirestoreDateTimeFromJson(d['paidAt']),
      createdAt: nullableFirestoreDateTimeFromJson(d['createdAt']),
      updatedAt: nullableFirestoreDateTimeFromJson(d['updatedAt']),
      payrollRunId: nullableLooseStringFromJson(d['payrollRunId']),
    );
  }
}
