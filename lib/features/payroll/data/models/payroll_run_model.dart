import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../../core/firestore/report_period.dart';
import '../payroll_constants.dart';

part 'payroll_run_model.freezed.dart';
part 'payroll_run_model.g.dart';

@freezed
abstract class PayrollRunModel with _$PayrollRunModel {
  const PayrollRunModel._();

  const factory PayrollRunModel({
    @JsonKey(fromJson: looseStringFromJson) required String id,
    @JsonKey(fromJson: _runTypeFromJson) required String runType,
    @JsonKey(fromJson: looseStringFromJson) required String salonId,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? employeeId,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? employeeName,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int year,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int month,
    @Default(PayrollRunPeriodGranularities.monthly)
    @JsonKey(fromJson: _periodGranularityFromJson)
    String periodGranularity,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int isoWeekYear,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int isoWeekNumber,
    @Default(PayrollRunStatuses.draft)
    @JsonKey(fromJson: _statusFromJson)
    String status,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double totalEarnings,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double totalDeductions,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double netPay,
    @Default(<String>[])
    @JsonKey(fromJson: stringListFromJson)
    List<String> employeeIds,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int employeeCount,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? createdBy,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? createdAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? approvedAt,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? approvedBy,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? paidAt,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? paidBy,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? updatedAt,
    /// When set, weekly accrual used this inclusive UTC window (calendar days).
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? payrollWindowStartUtc,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? payrollWindowEndUtc,
  }) = _PayrollRunModel;

  String get reportPeriodKey {
    if (periodGranularity == PayrollRunPeriodGranularities.weekly &&
        payrollWindowStartUtc != null &&
        payrollWindowEndUtc != null) {
      final a = payrollWindowStartUtc!;
      final b = payrollWindowEndUtc!;
      return '${a.year.toString().padLeft(4, '0')}-${a.month.toString().padLeft(2, '0')}-${a.day.toString().padLeft(2, '0')}_${b.year.toString().padLeft(4, '0')}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';
    }
    if (periodGranularity == PayrollRunPeriodGranularities.weekly &&
        isoWeekYear > 0 &&
        isoWeekNumber > 0) {
      return '$isoWeekYear-W${isoWeekNumber.toString().padLeft(2, '0')}';
    }
    return ReportPeriod.periodKey(year, month);
  }

  bool get isQuickPay => runType == PayrollRunTypes.quickPay;

  factory PayrollRunModel.fromJson(Map<String, dynamic> json) =>
      _$PayrollRunModelFromJson(_normalizedPayrollRunJson(json));
}

Map<String, dynamic> _normalizedPayrollRunJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  var year = FirestoreSerializers.intValue(json['year']);
  var month = FirestoreSerializers.intValue(json['month']);
  if (year == 0 || month == 0) {
    final period = ReportPeriod.parsePeriodKey(
      FirestoreSerializers.string(json['reportPeriodKey']),
    );
    if (period != null) {
      year = period.$1;
      month = period.$2;
    }
  }
  final employeeIds = stringListFromJson(json['employeeIds']);
  normalized['year'] = year;
  normalized['month'] = month;
  normalized['employeeIds'] = employeeIds;
  normalized['employeeCount'] ??= employeeIds.length;
  return normalized;
}

String _runTypeFromJson(Object? value) =>
    nullableLooseStringFromJson(value) ?? PayrollRunTypes.payrollRun;

String _periodGranularityFromJson(Object? value) =>
    PayrollRunPeriodGranularities.normalize(
      nullableLooseStringFromJson(value),
    );

String _statusFromJson(Object? value) =>
    nullableLooseStringFromJson(value) ?? PayrollRunStatuses.draft;
