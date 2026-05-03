import '../../../attendance/data/models/attendance_record.dart';
import '../../../employees/data/models/employee.dart';
import '../../../payroll/data/models/employee_element_entry_model.dart';
import '../../../payroll/data/models/payroll_element_model.dart';
import '../../../payroll/data/models/payroll_result_model.dart';
import '../../../payroll/data/payroll_calculation_service.dart';

class PayrollSetupWorkspaceData {
  const PayrollSetupWorkspaceData({
    required this.employees,
    required this.elements,
    required this.entries,
    required this.selectedPeriod,
    required this.missingSetupCount,
    this.selectedEmployee,
  });

  final List<Employee> employees;
  final List<PayrollElementModel> elements;
  final List<EmployeeElementEntryModel> entries;
  final DateTime selectedPeriod;
  final int missingSetupCount;
  final Employee? selectedEmployee;
}

class PayrollExplanationWorkspaceData {
  const PayrollExplanationWorkspaceData({
    required this.selectedPeriod,
    required this.employees,
    required this.bundle,
    required this.statement,
    required this.currencyCode,
    this.selectedEmployee,
  });

  final DateTime selectedPeriod;
  final List<Employee> employees;
  final PayrollCalculationBundle bundle;
  final PayrollEmployeeStatement statement;
  final String currencyCode;
  final Employee? selectedEmployee;

  List<PayrollResultModel> get earnings => statement.results
      .where((item) => item.classification == 'earning')
      .toList(growable: false);

  List<PayrollResultModel> get deductions => statement.results
      .where((item) => item.classification == 'deduction')
      .toList(growable: false);
}

class AnalyticsWorkspaceData {
  const AnalyticsWorkspaceData({
    required this.currencyCode,
    required this.rangeLabel,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalPayroll,
    required this.netAfterExpensesAndPayroll,
    required this.transactionCount,
    required this.draftPayrollRuns,
    required this.chartPoints,
  });

  final String currencyCode;
  final String rangeLabel;
  final double totalRevenue;
  final double totalExpenses;
  final double totalPayroll;
  final double netAfterExpensesAndPayroll;
  final int transactionCount;
  final int draftPayrollRuns;
  final List<({String label, double revenue, double expenses})> chartPoints;
}

class AttendanceCorrectionWorkspaceData {
  const AttendanceCorrectionWorkspaceData({
    required this.employees,
    required this.records,
    required this.startDate,
    required this.endDate,
    required this.pendingCount,
    required this.needsCorrectionCount,
    this.selectedEmployee,
    this.selectedRecord,
  });

  final List<Employee> employees;
  final List<AttendanceRecord> records;
  final DateTime startDate;
  final DateTime endDate;
  final int pendingCount;
  final int needsCorrectionCount;
  final Employee? selectedEmployee;
  final AttendanceRecord? selectedRecord;
}

class PayrollElementProposal {
  const PayrollElementProposal({
    required this.name,
    required this.classification,
    required this.recurrenceType,
    required this.calculationMethod,
    required this.defaultAmount,
  });

  final String name;
  final String classification;
  final String recurrenceType;
  final String calculationMethod;
  final double defaultAmount;
}

class AttendanceCorrectionProposal {
  const AttendanceCorrectionProposal({
    required this.recordId,
    required this.approvedByUid,
    this.approvedByName,
    this.status,
    this.checkInTime,
    this.checkOutTime,
    this.note,
  });

  final String recordId;
  final String approvedByUid;
  final String? approvedByName;
  final String? status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? note;
}

abstract class SmartWorkspaceRepository {
  Future<PayrollSetupWorkspaceData> getPayrollSetupData({
    required String salonId,
    required DateTime period,
    String? employeeQuery,
    String? employeeId,
  });

  Future<PayrollExplanationWorkspaceData> getPayrollExplanationData({
    required String salonId,
    required DateTime period,
    required String createdBy,
    String? employeeQuery,
    String? employeeId,
  });

  Future<AnalyticsWorkspaceData> getAnalyticsData({
    required String salonId,
    required DateTime period,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<AttendanceCorrectionWorkspaceData> getAttendanceCorrectionData({
    required String salonId,
    required DateTime startDate,
    required DateTime endDate,
    String? employeeQuery,
    String? employeeId,
    String? recordId,
  });

  Future<void> createPayrollElement({
    required String salonId,
    required PayrollElementProposal proposal,
  });

  Future<void> applyAttendanceCorrection({
    required String salonId,
    required AttendanceCorrectionProposal proposal,
  });
}
