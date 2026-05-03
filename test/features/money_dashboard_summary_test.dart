import 'package:barber_shop_app/core/constants/payroll_statuses.dart';
import 'package:barber_shop_app/core/constants/sale_reporting.dart';
import 'package:barber_shop_app/features/expenses/data/models/expense.dart';
import 'package:barber_shop_app/features/money/logic/money_dashboard_providers.dart';
import 'package:barber_shop_app/features/payroll/data/models/payslip_model.dart';
import 'package:barber_shop_app/features/payroll/data/models/payroll_record.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';
import 'package:flutter_test/flutter_test.dart';

PayslipModel _runPayslip({
  required String status,
  required double netPay,
  String payrollRunId = 'run1',
  DateTime? paidAt,
  int year = 2026,
  int month = 5,
}) {
  return PayslipModel(
    id: 'ps1',
    salonId: 'salon',
    employeeId: 'e1',
    employeeName: 'A',
    employeeRole: 'barber',
    year: year,
    month: month,
    periodStart: DateTime.utc(year, month, 1),
    periodEnd: DateTime.utc(year, month + 1, 0),
    currency: 'USD',
    status: status,
    employeeVisible: false,
    baseSalary: 0,
    serviceRevenue: 0,
    commissionPercent: 0,
    commissionAmount: 0,
    totalEarnings: netPay,
    totalDeductions: 0,
    netPay: netPay,
    servicesCount: 0,
    attendanceDaysPresent: 0,
    attendanceRequiredDays: 0,
    lateCount: 0,
    absenceCount: 0,
    missingCheckoutCount: 0,
    lines: const [],
    paidAt: paidAt,
    payrollRunId: payrollRunId,
  );
}

PayrollRecord _legacyPayroll({
  required String status,
  required double netAmount,
  DateTime? paidAt,
  int year = 2026,
  int month = 5,
}) {
  return PayrollRecord(
    id: 'p1',
    salonId: 'salon',
    employeeId: 'e1',
    employeeName: 'A',
    periodStart: DateTime.utc(year, month, 1),
    periodEnd: DateTime.utc(year, month + 1, 0),
    baseAmount: 0,
    commissionAmount: 0,
    bonusAmount: 0,
    deductionAmount: 0,
    netAmount: netAmount,
    status: status,
    month: month,
    year: year,
    paidAt: paidAt,
  );
}

Sale _sale({
  required String id,
  required double total,
  required DateTime soldAt,
  required int reportYear,
  required int reportMonth,
}) {
  return Sale(
    id: id,
    salonId: 'salon',
    employeeId: 'e1',
    employeeName: 'A',
    lineItems: const [],
    serviceNames: const ['Cut'],
    subtotal: total,
    tax: 0,
    discount: 0,
    total: total,
    paymentMethod: SalePaymentMethods.cash,
    status: SaleStatuses.completed,
    soldAt: soldAt,
    createdByUid: 'u',
    createdByName: 'n',
    reportYear: reportYear,
    reportMonth: reportMonth,
  );
}

void main() {
  final month = DateTime(2026, 5);

  test(
    'payroll total excludes approved run payslips until status is paid',
    () {
      final approved = _runPayslip(
        status: PayrollStatuses.approved,
        netPay: 6078.50,
      );
      final summary = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: [approved],
        month: month,
      );
      expect(summary.payrollTotal, 0);
    },
  );

  test('payroll total includes paid run payslips', () {
    final paid = _runPayslip(
      status: PayrollStatuses.paid,
      netPay: 100,
    );
    final summary = buildMoneyDashboardSummaryForMonth(
      sales: const <Sale>[],
      expenses: const <Expense>[],
      payroll: const <PayrollRecord>[],
      runPayslips: [paid],
      month: month,
    );
    expect(summary.payrollTotal, 100);
  });

  test('payroll total excludes legacy records until paid', () {
    final draft = _legacyPayroll(
      status: PayrollStatuses.approved,
      netAmount: 500,
    );
    final summary = buildMoneyDashboardSummaryForMonth(
      sales: const <Sale>[],
      expenses: const <Expense>[],
      payroll: [draft],
      runPayslips: const <PayslipModel>[],
      month: month,
    );
    expect(summary.payrollTotal, 0);

    final paidSummary = buildMoneyDashboardSummaryForMonth(
      sales: const <Sale>[],
      expenses: const <Expense>[],
      payroll: [
        _legacyPayroll(status: PayrollStatuses.paid, netAmount: 500),
      ],
      runPayslips: const <PayslipModel>[],
      month: month,
    );
    expect(paidSummary.payrollTotal, 500);
  });

  test('non-run payslips (no payrollRunId) never count toward payroll total', () {
    final manual = PayslipModel(
      id: 'ps_manual',
      salonId: 'salon',
      employeeId: 'e1',
      employeeName: 'A',
      employeeRole: 'barber',
      year: 2026,
      month: 5,
      periodStart: DateTime.utc(2026, 5, 1),
      periodEnd: DateTime.utc(2026, 5, 31),
      currency: 'USD',
      status: PayrollStatuses.paid,
      employeeVisible: true,
      baseSalary: 0,
      serviceRevenue: 0,
      commissionPercent: 0,
      commissionAmount: 0,
      totalEarnings: 999,
      totalDeductions: 0,
      netPay: 999,
      servicesCount: 0,
      attendanceDaysPresent: 0,
      attendanceRequiredDays: 0,
      lateCount: 0,
      absenceCount: 0,
      missingCheckoutCount: 0,
      lines: const [],
      payrollRunId: null,
    );
    final summary = buildMoneyDashboardSummaryForMonth(
      sales: const <Sale>[],
      expenses: const <Expense>[],
      payroll: const <PayrollRecord>[],
      runPayslips: [manual],
      month: month,
    );
    expect(summary.payrollTotal, 0);
  });

  group('inclusiveEndDay (MTD)', () {
    test('sales include only soldAt on or before end day in month', () {
      final may = DateTime(2026, 5);
      final sales = [
        _sale(
          id: 's_early',
          total: 10,
          soldAt: DateTime(2026, 5, 2, 10),
          reportYear: 2026,
          reportMonth: 5,
        ),
        _sale(
          id: 's_late',
          total: 50,
          soldAt: DateTime(2026, 5, 20, 10),
          reportYear: 2026,
          reportMonth: 5,
        ),
      ];
      final full = buildMoneyDashboardSummaryForMonth(
        sales: sales,
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: const <PayslipModel>[],
        month: may,
      );
      expect(full.salesTotal, 60);

      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: sales,
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: const <PayslipModel>[],
        month: may,
        inclusiveEndDay: 3,
      );
      expect(mtd.salesTotal, 10);
    });

    test('February leap day excluded when inclusiveEndDay is 28', () {
      final feb2024 = DateTime(2024, 2);
      final sales = [
        _sale(
          id: 's27',
          total: 7,
          soldAt: DateTime(2024, 2, 27),
          reportYear: 2024,
          reportMonth: 2,
        ),
        _sale(
          id: 's29',
          total: 29,
          soldAt: DateTime(2024, 2, 29),
          reportYear: 2024,
          reportMonth: 2,
        ),
      ];
      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: sales,
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: const <PayslipModel>[],
        month: feb2024,
        inclusiveEndDay: 28,
      );
      expect(mtd.salesTotal, 7);
    });

    test('expenses respect incurredAt day cap', () {
      final may = DateTime(2026, 5);
      final expenses = [
        Expense(
          id: 'e1',
          salonId: 'salon',
          title: 'A',
          category: 'other',
          amount: 5,
          incurredAt: DateTime(2026, 5, 2),
          createdByUid: 'u',
          createdByName: 'n',
          reportYear: 2026,
          reportMonth: 5,
        ),
        Expense(
          id: 'e2',
          salonId: 'salon',
          title: 'B',
          category: 'other',
          amount: 40,
          incurredAt: DateTime(2026, 5, 10),
          createdByUid: 'u',
          createdByName: 'n',
          reportYear: 2026,
          reportMonth: 5,
        ),
      ];
      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: expenses,
        payroll: const <PayrollRecord>[],
        runPayslips: const <PayslipModel>[],
        month: may,
        inclusiveEndDay: 3,
      );
      expect(mtd.expensesTotal, 5);
    });

    test('paid run payslip counts only when paidAt within MTD window', () {
      final may = DateTime(2026, 5);
      final early = _runPayslip(
        status: PayrollStatuses.paid,
        netPay: 100,
        paidAt: DateTime(2026, 5, 2, 12),
      );
      final late = PayslipModel(
        id: 'ps2',
        salonId: 'salon',
        employeeId: 'e2',
        employeeName: 'B',
        employeeRole: 'barber',
        year: 2026,
        month: 5,
        periodStart: DateTime.utc(2026, 5, 1),
        periodEnd: DateTime.utc(2026, 5, 31),
        currency: 'USD',
        status: PayrollStatuses.paid,
        employeeVisible: false,
        baseSalary: 0,
        serviceRevenue: 0,
        commissionPercent: 0,
        commissionAmount: 0,
        totalEarnings: 200,
        totalDeductions: 0,
        netPay: 200,
        servicesCount: 0,
        attendanceDaysPresent: 0,
        attendanceRequiredDays: 0,
        lateCount: 0,
        absenceCount: 0,
        missingCheckoutCount: 0,
        lines: const [],
        payrollRunId: 'run2',
        paidAt: DateTime(2026, 5, 15),
      );
      final full = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: [early, late],
        month: may,
      );
      expect(full.payrollTotal, 300);

      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: const <Expense>[],
        payroll: const <PayrollRecord>[],
        runPayslips: [early, late],
        month: may,
        inclusiveEndDay: 3,
      );
      expect(mtd.payrollTotal, 100);
    });

    test('legacy paid payroll excluded in MTD when paidAt is null', () {
      final may = DateTime(2026, 5);
      final paidNoDate = _legacyPayroll(
        status: PayrollStatuses.paid,
        netAmount: 400,
        paidAt: null,
      );
      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: const <Expense>[],
        payroll: [paidNoDate],
        runPayslips: const <PayslipModel>[],
        month: may,
        inclusiveEndDay: 10,
      );
      expect(mtd.payrollTotal, 0);
    });

    test('legacy paid payroll included in MTD when paidAt in window', () {
      final may = DateTime(2026, 5);
      final paid = _legacyPayroll(
        status: PayrollStatuses.paid,
        netAmount: 400,
        paidAt: DateTime(2026, 5, 3, 9),
      );
      final mtd = buildMoneyDashboardSummaryForMonth(
        sales: const <Sale>[],
        expenses: const <Expense>[],
        payroll: [paid],
        runPayslips: const <PayslipModel>[],
        month: may,
        inclusiveEndDay: 5,
      );
      expect(mtd.payrollTotal, 400);
    });
  });
}
