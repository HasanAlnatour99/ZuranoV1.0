// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Employee _$EmployeeFromJson(Map<String, dynamic> json) => _Employee(
  id: looseStringFromJson(json['id']),
  salonId: looseStringFromJson(json['salonId']),
  name: looseStringFromJson(json['name']),
  email: looseStringFromJson(json['email']),
  username: nullableLooseStringFromJson(json['username']),
  usernameLower: nullableLooseStringFromJson(json['usernameLower']),
  role: looseStringFromJson(json['role']),
  uid: nullableLooseStringFromJson(json['uid']),
  phone: nullableLooseStringFromJson(json['phone']),
  commissionRate: json['commissionRate'] == null
      ? 0
      : looseDoubleFromJson(json['commissionRate']),
  commissionValue: json['commissionValue'] == null
      ? 0
      : looseDoubleFromJson(json['commissionValue']),
  commissionPercentage: json['commissionPercentage'] == null
      ? 0
      : looseDoubleFromJson(json['commissionPercentage']),
  commissionFixedAmount: json['commissionFixedAmount'] == null
      ? 0
      : looseDoubleFromJson(json['commissionFixedAmount']),
  commissionType: json['commissionType'] == null
      ? EmployeeCommissionTypes.percentage
      : _commissionTypeFromJson(json['commissionType']),
  hourlyRate: json['hourlyRate'] == null
      ? 0
      : looseDoubleFromJson(json['hourlyRate']),
  baseSalary: json['baseSalary'] == null
      ? 0
      : looseDoubleFromJson(json['baseSalary']),
  isPayrollEnabled: json['isPayrollEnabled'] == null
      ? true
      : trueBoolFromJson(json['isPayrollEnabled']),
  payrollCurrency: nullableLooseStringFromJson(json['payrollCurrency']),
  status: json['status'] == null
      ? 'active'
      : looseStringFromJson(json['status']),
  avatarUrl: nullableLooseStringFromJson(json['avatarUrl']),
  attendanceRequired: json['attendanceRequired'] == null
      ? true
      : trueBoolFromJson(json['attendanceRequired']),
  isBookable: json['isBookable'] == null
      ? false
      : falseBoolFromJson(json['isBookable']),
  publicBio: nullableLooseStringFromJson(json['publicBio']),
  displayOrder: json['displayOrder'] == null
      ? 0
      : looseIntFromJson(json['displayOrder']),
  workingHoursProfileId: nullableLooseStringFromJson(
    json['workingHoursProfileId'],
  ),
  payrollPeriodOverride: json['payrollPeriodOverride'] == null
      ? null
      : _payrollPeriodOverrideFromJson(json['payrollPeriodOverride']),
  hiredAt: nullableFirestoreDateTimeFromJson(json['hiredAt']),
  assignedServiceIds: json['assignedServiceIds'] == null
      ? const <String>[]
      : stringListFromJson(json['assignedServiceIds']),
  isActive: json['isActive'] == null
      ? true
      : trueBoolFromJson(json['isActive']),
  weeklyAvailability: _weeklyAvailabilityFromJson(json['weeklyAvailability']),
  mustChangePassword: _nullableBoolFromJson(json['mustChangePassword']),
  createdAt: nullableFirestoreDateTimeFromJson(json['createdAt']),
  updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$EmployeeToJson(_Employee instance) => <String, dynamic>{
  'id': instance.id,
  'salonId': instance.salonId,
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'usernameLower': instance.usernameLower,
  'role': instance.role,
  'uid': instance.uid,
  'phone': instance.phone,
  'commissionRate': instance.commissionRate,
  'commissionValue': instance.commissionValue,
  'commissionPercentage': instance.commissionPercentage,
  'commissionFixedAmount': instance.commissionFixedAmount,
  'commissionType': instance.commissionType,
  'hourlyRate': instance.hourlyRate,
  'baseSalary': instance.baseSalary,
  'isPayrollEnabled': instance.isPayrollEnabled,
  'payrollCurrency': instance.payrollCurrency,
  'status': instance.status,
  'avatarUrl': instance.avatarUrl,
  'attendanceRequired': instance.attendanceRequired,
  'isBookable': instance.isBookable,
  'publicBio': instance.publicBio,
  'displayOrder': instance.displayOrder,
  'workingHoursProfileId': instance.workingHoursProfileId,
  'payrollPeriodOverride': _payrollPeriodOverrideToJson(
    instance.payrollPeriodOverride,
  ),
  'hiredAt': nullableFirestoreDateTimeToJson(instance.hiredAt),
  'assignedServiceIds': instance.assignedServiceIds,
  'isActive': instance.isActive,
  'weeklyAvailability': _weeklyAvailabilityToJson(instance.weeklyAvailability),
  'mustChangePassword': instance.mustChangePassword,
  'createdAt': nullableFirestoreDateTimeToJson(instance.createdAt),
  'updatedAt': nullableFirestoreDateTimeToJson(instance.updatedAt),
};
