import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/booking/availability_schedule.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../domain/commission_type.dart';
import '../../domain/employee_role.dart';

export '../../domain/commission_type.dart' show EmployeeCommissionTypes;

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
abstract class Employee with _$Employee {
  const Employee._();

  const factory Employee({
    @JsonKey(fromJson: looseStringFromJson) required String id,
    @JsonKey(fromJson: looseStringFromJson) required String salonId,
    @JsonKey(fromJson: looseStringFromJson) required String name,
    @JsonKey(fromJson: looseStringFromJson) required String email,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? username,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? usernameLower,
    @JsonKey(fromJson: looseStringFromJson) required String role,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? uid,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? phone,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double commissionRate,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double commissionValue,
    @Default(0)
    @JsonKey(fromJson: looseDoubleFromJson)
    double commissionPercentage,
    @Default(0)
    @JsonKey(fromJson: looseDoubleFromJson)
    double commissionFixedAmount,
    @Default(EmployeeCommissionTypes.percentage)
    @JsonKey(fromJson: _commissionTypeFromJson)
    String commissionType,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double hourlyRate,
    @Default(0) @JsonKey(fromJson: looseDoubleFromJson) double baseSalary,
    @Default(true) @JsonKey(fromJson: trueBoolFromJson) bool isPayrollEnabled,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? payrollCurrency,
    @Default('active') @JsonKey(fromJson: looseStringFromJson) String status,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? avatarUrl,
    @Default(true) @JsonKey(fromJson: trueBoolFromJson) bool attendanceRequired,
    @Default(false) @JsonKey(fromJson: falseBoolFromJson) bool isBookable,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? publicBio,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int displayOrder,
    @JsonKey(fromJson: nullableLooseStringFromJson)
    String? workingHoursProfileId,
    /// `monthly` | `weekly` — null inherits salon default payroll period.
    @Default(null)
    @JsonKey(
      fromJson: _payrollPeriodOverrideFromJson,
      toJson: _payrollPeriodOverrideToJson,
    )
    String? payrollPeriodOverride,
    /// Calendar hire date (Firestore Timestamp); payroll prorates monthly base salary when set.
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? hiredAt,
    @Default(<String>[])
    @JsonKey(fromJson: stringListFromJson)
    List<String> assignedServiceIds,
    @Default(true) @JsonKey(fromJson: trueBoolFromJson) bool isActive,
    @JsonKey(
      fromJson: _weeklyAvailabilityFromJson,
      toJson: _weeklyAvailabilityToJson,
    )
    WeeklyAvailability? weeklyAvailability,
    @JsonKey(fromJson: _nullableBoolFromJson) bool? mustChangePassword,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? createdAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? updatedAt,
  }) = _Employee;

  /// Customer booking UI: stub from `publicSalons/{salonId}/team/{id}` (no HR; slot planner falls back to salon hours).
  factory Employee.customerBookingFromPublicMirror({
    required String id,
    required String salonId,
    required String displayName,
    String? profileImageUrl,
  }) {
    return Employee(
      id: id,
      salonId: salonId,
      name: displayName,
      email: '',
      role: employeeRoleToFirestoreString(EmployeeRole.barber),
      avatarUrl: profileImageUrl,
      isBookable: true,
      isActive: true,
      weeklyAvailability: null,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(_normalizedEmployeeJson(json));

  /// Percent value as stored in Firestore (e.g. 2 for 2%), for payroll fallbacks.
  double get resolvedCommissionPercentage {
    if (commissionPercentage > 0) {
      return commissionPercentage;
    }
    if (commissionType == EmployeeCommissionTypes.percentage ||
        commissionType == EmployeeCommissionTypes.percentagePlusFixed) {
      return commissionValue > 0 ? commissionValue : commissionRate;
    }
    return 0;
  }

  /// Fixed currency component per pay period (salon ISO currency), when applicable.
  double get resolvedCommissionFixedAmount {
    if (commissionFixedAmount > 0) {
      return commissionFixedAmount;
    }
    if (commissionType == EmployeeCommissionTypes.fixed) {
      return commissionValue;
    }
    return 0;
  }

  /// Fallback rate passed to per-sale commission math (percent 0–100, not decimal).
  double get salesCommissionPercentFallback {
    return switch (commissionType) {
      EmployeeCommissionTypes.percentage ||
      EmployeeCommissionTypes.percentagePlusFixed =>
        resolvedCommissionPercentage,
      _ => 0,
    };
  }

  double? get effectiveCommissionRate =>
      commissionType == EmployeeCommissionTypes.percentage
      ? resolvedCommissionPercentage
      : null;

  static String _resolvedStatus(String? status, bool isActive) {
    final trimmed = status?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return isActive ? 'active' : 'inactive';
  }
}

Map<String, dynamic> _normalizedEmployeeJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['commissionValue'] ??= json['commissionRate'];

  final type =
      FirestoreSerializers.string(json['commissionType']) ??
      EmployeeCommissionTypes.percentage;

  var pct = FirestoreSerializers.doubleValue(json['commissionPercentage']);
  var fixedAmt = FirestoreSerializers.doubleValue(
    json['commissionFixedAmount'],
  );

  if (pct == 0 && fixedAmt == 0) {
    final legacy = FirestoreSerializers.doubleValue(json['commissionValue']);
    if (legacy != 0) {
      if (type == EmployeeCommissionTypes.fixed) {
        fixedAmt = legacy;
      } else {
        pct = legacy;
      }
    }
  }

  normalized['commissionPercentage'] = pct;
  normalized['commissionFixedAmount'] = fixedAmt;
  normalized['commissionType'] = type;
  try {
    final parsedRole = employeeRoleFromString(
      FirestoreSerializers.string(json['role']),
    );
    normalized['role'] = employeeRoleToFirestoreString(parsedRole);
  } catch (_) {
    normalized['role'] = EmployeeRole.barber.value;
  }

  normalized['status'] = Employee._resolvedStatus(
    FirestoreSerializers.string(json['status']),
    FirestoreSerializers.boolValue(json['isActive'], fallback: true),
  );
  return normalized;
}

String? _payrollPeriodOverrideFromJson(Object? value) {
  final s = nullableLooseStringFromJson(value)?.trim();
  if (s == null || s.isEmpty) {
    return null;
  }
  return SalonPayrollPeriods.isValid(s)
      ? SalonPayrollPeriods.normalize(s)
      : null;
}

Object? _payrollPeriodOverrideToJson(String? value) => value;

String _commissionTypeFromJson(Object? value) {
  final raw = FirestoreSerializers.string(value)?.trim();
  if (raw == EmployeeCommissionTypes.fixed ||
      raw == EmployeeCommissionTypes.percentagePlusFixed) {
    return raw!;
  }
  return EmployeeCommissionTypes.percentage;
}

bool? _nullableBoolFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return FirestoreSerializers.boolValue(value);
}

WeeklyAvailability? _weeklyAvailabilityFromJson(Object? value) {
  return WeeklyAvailability.maybeParse(value);
}

Map<String, dynamic>? _weeklyAvailabilityToJson(WeeklyAvailability? value) {
  if (value == null) {
    return null;
  }

  return {
    for (final entry in value.byWeekday.entries)
      '${entry.key}': {
        'closed': entry.value.isDayOff,
        'openMinute': entry.value.openMinute,
        'closeMinute': entry.value.closeMinute,
        'breaks': [
          for (final breakWindow in entry.value.breaks)
            {'start': breakWindow.$1, 'end': breakWindow.$2},
        ],
      },
  };
}
