// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_run_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayrollRunModel _$PayrollRunModelFromJson(Map<String, dynamic> json) =>
    _PayrollRunModel(
      id: looseStringFromJson(json['id']),
      runType: _runTypeFromJson(json['runType']),
      salonId: looseStringFromJson(json['salonId']),
      employeeId: nullableLooseStringFromJson(json['employeeId']),
      employeeName: nullableLooseStringFromJson(json['employeeName']),
      year: json['year'] == null ? 0 : looseIntFromJson(json['year']),
      month: json['month'] == null ? 0 : looseIntFromJson(json['month']),
      periodGranularity: json['periodGranularity'] == null
          ? PayrollRunPeriodGranularities.monthly
          : _periodGranularityFromJson(json['periodGranularity']),
      isoWeekYear: json['isoWeekYear'] == null
          ? 0
          : looseIntFromJson(json['isoWeekYear']),
      isoWeekNumber: json['isoWeekNumber'] == null
          ? 0
          : looseIntFromJson(json['isoWeekNumber']),
      status: json['status'] == null
          ? PayrollRunStatuses.draft
          : _statusFromJson(json['status']),
      totalEarnings: json['totalEarnings'] == null
          ? 0
          : looseDoubleFromJson(json['totalEarnings']),
      totalDeductions: json['totalDeductions'] == null
          ? 0
          : looseDoubleFromJson(json['totalDeductions']),
      netPay: json['netPay'] == null ? 0 : looseDoubleFromJson(json['netPay']),
      employeeIds: json['employeeIds'] == null
          ? const <String>[]
          : stringListFromJson(json['employeeIds']),
      employeeCount: json['employeeCount'] == null
          ? 0
          : looseIntFromJson(json['employeeCount']),
      createdBy: nullableLooseStringFromJson(json['createdBy']),
      createdAt: nullableFirestoreDateTimeFromJson(json['createdAt']),
      approvedAt: nullableFirestoreDateTimeFromJson(json['approvedAt']),
      approvedBy: nullableLooseStringFromJson(json['approvedBy']),
      paidAt: nullableFirestoreDateTimeFromJson(json['paidAt']),
      paidBy: nullableLooseStringFromJson(json['paidBy']),
      updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
      payrollWindowStartUtc: nullableFirestoreDateTimeFromJson(
        json['payrollWindowStartUtc'],
      ),
      payrollWindowEndUtc: nullableFirestoreDateTimeFromJson(
        json['payrollWindowEndUtc'],
      ),
    );

Map<String, dynamic> _$PayrollRunModelToJson(_PayrollRunModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runType': instance.runType,
      'salonId': instance.salonId,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'year': instance.year,
      'month': instance.month,
      'periodGranularity': instance.periodGranularity,
      'isoWeekYear': instance.isoWeekYear,
      'isoWeekNumber': instance.isoWeekNumber,
      'status': instance.status,
      'totalEarnings': instance.totalEarnings,
      'totalDeductions': instance.totalDeductions,
      'netPay': instance.netPay,
      'employeeIds': instance.employeeIds,
      'employeeCount': instance.employeeCount,
      'createdBy': instance.createdBy,
      'createdAt': nullableFirestoreDateTimeToJson(instance.createdAt),
      'approvedAt': nullableFirestoreDateTimeToJson(instance.approvedAt),
      'approvedBy': instance.approvedBy,
      'paidAt': nullableFirestoreDateTimeToJson(instance.paidAt),
      'paidBy': instance.paidBy,
      'updatedAt': nullableFirestoreDateTimeToJson(instance.updatedAt),
      'payrollWindowStartUtc': nullableFirestoreDateTimeToJson(
        instance.payrollWindowStartUtc,
      ),
      'payrollWindowEndUtc': nullableFirestoreDateTimeToJson(
        instance.payrollWindowEndUtc,
      ),
    };
