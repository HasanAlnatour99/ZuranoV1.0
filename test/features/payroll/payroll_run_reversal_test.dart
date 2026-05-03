import 'package:barber_shop_app/features/payroll/data/models/payroll_result_model.dart';
import 'package:barber_shop_app/features/payroll/data/payroll_constants.dart';
import 'package:barber_shop_app/features/payroll/domain/payroll_run_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayrollRunStatuses.canRollback', () {
    test('allows draft, approved, and paid', () {
      expect(PayrollRunStatuses.canRollback(PayrollRunStatuses.draft), isTrue);
      expect(
        PayrollRunStatuses.canRollback(PayrollRunStatuses.approved),
        isTrue,
      );
      expect(PayrollRunStatuses.canRollback(PayrollRunStatuses.paid), isTrue);
    });

    test('disallows rolled_back', () {
      expect(
        PayrollRunStatuses.canRollback(PayrollRunStatuses.rolledBack),
        isFalse,
      );
    });
  });

  group('aggregatePayrollRunTotalsFromResults', () {
    test('sums earnings and deductions', () {
      final rows = [
        PayrollResultModel(
          id: '1',
          payrollRunId: 'run',
          employeeId: 'a',
          employeeName: 'A',
          elementCode: 'basic_salary',
          elementName: 'Salary',
          classification: PayrollElementClassifications.earning,
          recurrenceType: PayrollRecurrenceTypes.recurring,
          amount: 100,
          sourceType: PayrollResultSourceTypes.manual,
        ),
        PayrollResultModel(
          id: '2',
          payrollRunId: 'run',
          employeeId: 'a',
          employeeName: 'A',
          elementCode: 'tax',
          elementName: 'Tax',
          classification: PayrollElementClassifications.deduction,
          recurrenceType: PayrollRecurrenceTypes.nonrecurring,
          amount: 10,
          sourceType: PayrollResultSourceTypes.manual,
        ),
      ];
      final t = aggregatePayrollRunTotalsFromResults(rows);
      expect(t.totalEarnings, 100.0);
      expect(t.totalDeductions, 10.0);
      expect(t.netPay, 90.0);
    });
  });

  group('distinctEmployeeIdsForRun', () {
    test('preserves preferred order then sorts remainder', () {
      final rows = [
        PayrollResultModel(
          id: '1',
          payrollRunId: 'run',
          employeeId: 'c',
          employeeName: 'C',
          elementCode: 'x',
          elementName: 'X',
          classification: PayrollElementClassifications.earning,
          recurrenceType: PayrollRecurrenceTypes.recurring,
          amount: 1,
          sourceType: PayrollResultSourceTypes.manual,
        ),
        PayrollResultModel(
          id: '2',
          payrollRunId: 'run',
          employeeId: 'a',
          employeeName: 'A',
          elementCode: 'x',
          elementName: 'X',
          classification: PayrollElementClassifications.earning,
          recurrenceType: PayrollRecurrenceTypes.recurring,
          amount: 1,
          sourceType: PayrollResultSourceTypes.manual,
        ),
      ];
      final ids = distinctEmployeeIdsForRun(rows, ['b', 'a', 'c']);
      expect(ids, ['a', 'c']);
    });
  });
}
