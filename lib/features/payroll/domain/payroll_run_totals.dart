import '../data/models/payroll_result_model.dart';
import '../data/payroll_calculation_service.dart';
import '../data/payroll_constants.dart';

/// Aggregates run-level totals from payroll result rows (same rules as calculation).
({double totalEarnings, double totalDeductions, double netPay})
aggregatePayrollRunTotalsFromResults(Iterable<PayrollResultModel> results) {
  var earnings = 0.0;
  var deductions = 0.0;
  for (final r in results) {
    if (r.classification == PayrollElementClassifications.earning) {
      earnings += r.amount;
    } else if (r.classification == PayrollElementClassifications.deduction) {
      deductions += r.amount;
    }
  }
  final te = PayrollCalculationService.roundMoney(earnings);
  final td = PayrollCalculationService.roundMoney(deductions);
  final net = PayrollCalculationService.roundMoney(te - td);
  return (totalEarnings: te, totalDeductions: td, netPay: net);
}

/// Stable employee id list: [preferredOrder] first, then any others sorted.
List<String> distinctEmployeeIdsForRun(
  Iterable<PayrollResultModel> results,
  List<String> preferredOrder,
) {
  final fromResults = results
      .map((r) => r.employeeId.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  final out = <String>[];
  for (final id in preferredOrder) {
    final t = id.trim();
    if (t.isEmpty || !fromResults.contains(t)) continue;
    out.add(t);
    fromResults.remove(t);
  }
  final rest = fromResults.toList()..sort();
  out.addAll(rest);
  return out;
}

String? primaryEmployeeNameFromResults(
  Iterable<PayrollResultModel> results,
  String employeeId,
) {
  final target = employeeId.trim();
  if (target.isEmpty) return null;
  for (final r in results) {
    if (r.employeeId.trim() == target) {
      final n = r.employeeName.trim();
      if (n.isNotEmpty) return n;
    }
  }
  return null;
}
