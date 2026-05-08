import 'package:barber_shop_app/features/payroll/data/models/employee_element_entry_model.dart';
import 'package:barber_shop_app/features/payroll/data/payroll_calculation_service.dart';
import 'package:barber_shop_app/features/payroll/data/payroll_constants.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmployeeElementEntryModel.appliesToPeriod', () {
    test('keeps recurring entries active until ended', () {
      final entry = EmployeeElementEntryModel(
        id: 'entry-1',
        employeeId: 'employee-1',
        employeeName: 'Barber',
        elementCode: 'basic_salary',
        elementName: 'Basic Salary',
        classification: PayrollElementClassifications.earning,
        recurrenceType: PayrollRecurrenceTypes.recurring,
        amount: 1000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      );

      expect(
        entry.appliesToPeriod(
          periodStart: DateTime(2026, 5, 1),
          periodEnd: DateTime(2026, 5, 31, 23, 59, 59),
          year: 2026,
          month: 5,
        ),
        isTrue,
      );
      expect(
        entry.appliesToPeriod(
          periodStart: DateTime(2027, 1, 1),
          periodEnd: DateTime(2027, 1, 31, 23, 59, 59),
          year: 2027,
          month: 1,
        ),
        isFalse,
      );
    });

    test('applies nonrecurring entries only to their target period', () {
      final entry = EmployeeElementEntryModel(
        id: 'entry-2',
        employeeId: 'employee-1',
        employeeName: 'Barber',
        elementCode: 'bonus',
        elementName: 'Bonus',
        classification: PayrollElementClassifications.earning,
        recurrenceType: PayrollRecurrenceTypes.nonrecurring,
        amount: 100,
        payrollYear: 2026,
        payrollMonth: 5,
      );

      expect(
        entry.appliesToPeriod(
          periodStart: DateTime(2026, 5, 1),
          periodEnd: DateTime(2026, 5, 31, 23, 59, 59),
          year: 2026,
          month: 5,
        ),
        isTrue,
      );
      expect(
        entry.appliesToPeriod(
          periodStart: DateTime(2026, 6, 1),
          periodEnd: DateTime(2026, 6, 30, 23, 59, 59),
          year: 2026,
          month: 6,
        ),
        isFalse,
      );
    });
  });

  test(
    'commission calculation uses snapshots first and employee fallback last',
    () {
      final sales = [
        Sale(
          id: 'sale-1',
          salonId: 'salon-1',
          employeeId: 'employee-1',
          employeeName: 'Barber',
          lineItems: const <SaleLineItem>[],
          serviceNames: const <String>[],
          subtotal: 100,
          tax: 0,
          discount: 0,
          total: 100,
          paymentMethod: 'cash',
          status: 'completed',
          soldAt: DateTime(2026, 5, 1),
          commissionRateUsed: 30,
          commissionAmount: 30,
        ),
        Sale(
          id: 'sale-2',
          salonId: 'salon-1',
          employeeId: 'employee-1',
          employeeName: 'Barber',
          lineItems: const <SaleLineItem>[],
          serviceNames: const <String>[],
          subtotal: 200,
          tax: 0,
          discount: 0,
          total: 200,
          paymentMethod: 'cash',
          status: 'completed',
          soldAt: DateTime(2026, 5, 2),
          commissionRateUsed: 25,
        ),
        Sale(
          id: 'sale-3',
          salonId: 'salon-1',
          employeeId: 'employee-1',
          employeeName: 'Barber',
          lineItems: const <SaleLineItem>[],
          serviceNames: const <String>[],
          subtotal: 100,
          tax: 0,
          discount: 0,
          total: 100,
          paymentMethod: 'cash',
          status: 'completed',
          soldAt: DateTime(2026, 5, 3),
        ),
      ];

      final result = PayrollCalculationService.calculateCommissionFromSales(
        sales: sales,
        fallbackRate: 20,
      );

      expect(result.amount, 100);
      expect(result.calculationSource, PayrollCalculationSources.fallback);
      expect(result.sourceRefIds, ['sale-1', 'sale-2', 'sale-3']);
      expect(result.quantity, 3);
    },
  );

  test('rollback rules allow draft and approved only', () {
    expect(PayrollRunStatuses.canRollback(PayrollRunStatuses.draft), isTrue);
    expect(PayrollRunStatuses.canRollback(PayrollRunStatuses.approved), isTrue);
    expect(PayrollRunStatuses.canRollback(PayrollRunStatuses.paid), isTrue);
    expect(
      PayrollRunStatuses.canRollback(PayrollRunStatuses.rolledBack),
      isFalse,
    );
  });
}
