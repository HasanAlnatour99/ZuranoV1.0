// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Employee {

@JsonKey(fromJson: looseStringFromJson) String get id;@JsonKey(fromJson: looseStringFromJson) String get salonId;@JsonKey(fromJson: looseStringFromJson) String get name;@JsonKey(fromJson: looseStringFromJson) String get email;@JsonKey(fromJson: nullableLooseStringFromJson) String? get username;@JsonKey(fromJson: nullableLooseStringFromJson) String? get usernameLower;@JsonKey(fromJson: looseStringFromJson) String get role;@JsonKey(fromJson: nullableLooseStringFromJson) String? get uid;@JsonKey(fromJson: nullableLooseStringFromJson) String? get phone;@JsonKey(fromJson: looseDoubleFromJson) double get commissionRate;@JsonKey(fromJson: looseDoubleFromJson) double get commissionValue;@JsonKey(fromJson: looseDoubleFromJson) double get commissionPercentage;@JsonKey(fromJson: looseDoubleFromJson) double get commissionFixedAmount;@JsonKey(fromJson: _commissionTypeFromJson) String get commissionType;@JsonKey(fromJson: looseDoubleFromJson) double get hourlyRate;@JsonKey(fromJson: looseDoubleFromJson) double get baseSalary;@JsonKey(fromJson: trueBoolFromJson) bool get isPayrollEnabled;@JsonKey(fromJson: nullableLooseStringFromJson) String? get payrollCurrency;@JsonKey(fromJson: looseStringFromJson) String get status;@JsonKey(fromJson: nullableLooseStringFromJson) String? get avatarUrl;@JsonKey(fromJson: trueBoolFromJson) bool get attendanceRequired;@JsonKey(fromJson: falseBoolFromJson) bool get isBookable;@JsonKey(fromJson: nullableLooseStringFromJson) String? get publicBio;@JsonKey(fromJson: looseIntFromJson) int get displayOrder;@JsonKey(fromJson: nullableLooseStringFromJson) String? get workingHoursProfileId;/// `monthly` | `weekly` — null inherits salon default payroll period.
@JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson) String? get payrollPeriodOverride;/// Calendar hire date (Firestore Timestamp); payroll prorates monthly base salary when set.
@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get hiredAt;@JsonKey(fromJson: stringListFromJson) List<String> get assignedServiceIds;@JsonKey(fromJson: trueBoolFromJson) bool get isActive;@JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson) WeeklyAvailability? get weeklyAvailability;@JsonKey(fromJson: _nullableBoolFromJson) bool? get mustChangePassword;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get createdAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get updatedAt;
/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeCopyWith<Employee> get copyWith => _$EmployeeCopyWithImpl<Employee>(this as Employee, _$identity);

  /// Serializes this Employee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.usernameLower, usernameLower) || other.usernameLower == usernameLower)&&(identical(other.role, role) || other.role == role)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.commissionValue, commissionValue) || other.commissionValue == commissionValue)&&(identical(other.commissionPercentage, commissionPercentage) || other.commissionPercentage == commissionPercentage)&&(identical(other.commissionFixedAmount, commissionFixedAmount) || other.commissionFixedAmount == commissionFixedAmount)&&(identical(other.commissionType, commissionType) || other.commissionType == commissionType)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.baseSalary, baseSalary) || other.baseSalary == baseSalary)&&(identical(other.isPayrollEnabled, isPayrollEnabled) || other.isPayrollEnabled == isPayrollEnabled)&&(identical(other.payrollCurrency, payrollCurrency) || other.payrollCurrency == payrollCurrency)&&(identical(other.status, status) || other.status == status)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.attendanceRequired, attendanceRequired) || other.attendanceRequired == attendanceRequired)&&(identical(other.isBookable, isBookable) || other.isBookable == isBookable)&&(identical(other.publicBio, publicBio) || other.publicBio == publicBio)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.workingHoursProfileId, workingHoursProfileId) || other.workingHoursProfileId == workingHoursProfileId)&&(identical(other.payrollPeriodOverride, payrollPeriodOverride) || other.payrollPeriodOverride == payrollPeriodOverride)&&(identical(other.hiredAt, hiredAt) || other.hiredAt == hiredAt)&&const DeepCollectionEquality().equals(other.assignedServiceIds, assignedServiceIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.weeklyAvailability, weeklyAvailability) || other.weeklyAvailability == weeklyAvailability)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,name,email,username,usernameLower,role,uid,phone,commissionRate,commissionValue,commissionPercentage,commissionFixedAmount,commissionType,hourlyRate,baseSalary,isPayrollEnabled,payrollCurrency,status,avatarUrl,attendanceRequired,isBookable,publicBio,displayOrder,workingHoursProfileId,payrollPeriodOverride,hiredAt,const DeepCollectionEquality().hash(assignedServiceIds),isActive,weeklyAvailability,mustChangePassword,createdAt,updatedAt]);

@override
String toString() {
  return 'Employee(id: $id, salonId: $salonId, name: $name, email: $email, username: $username, usernameLower: $usernameLower, role: $role, uid: $uid, phone: $phone, commissionRate: $commissionRate, commissionValue: $commissionValue, commissionPercentage: $commissionPercentage, commissionFixedAmount: $commissionFixedAmount, commissionType: $commissionType, hourlyRate: $hourlyRate, baseSalary: $baseSalary, isPayrollEnabled: $isPayrollEnabled, payrollCurrency: $payrollCurrency, status: $status, avatarUrl: $avatarUrl, attendanceRequired: $attendanceRequired, isBookable: $isBookable, publicBio: $publicBio, displayOrder: $displayOrder, workingHoursProfileId: $workingHoursProfileId, payrollPeriodOverride: $payrollPeriodOverride, hiredAt: $hiredAt, assignedServiceIds: $assignedServiceIds, isActive: $isActive, weeklyAvailability: $weeklyAvailability, mustChangePassword: $mustChangePassword, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmployeeCopyWith<$Res>  {
  factory $EmployeeCopyWith(Employee value, $Res Function(Employee) _then) = _$EmployeeCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String name,@JsonKey(fromJson: looseStringFromJson) String email,@JsonKey(fromJson: nullableLooseStringFromJson) String? username,@JsonKey(fromJson: nullableLooseStringFromJson) String? usernameLower,@JsonKey(fromJson: looseStringFromJson) String role,@JsonKey(fromJson: nullableLooseStringFromJson) String? uid,@JsonKey(fromJson: nullableLooseStringFromJson) String? phone,@JsonKey(fromJson: looseDoubleFromJson) double commissionRate,@JsonKey(fromJson: looseDoubleFromJson) double commissionValue,@JsonKey(fromJson: looseDoubleFromJson) double commissionPercentage,@JsonKey(fromJson: looseDoubleFromJson) double commissionFixedAmount,@JsonKey(fromJson: _commissionTypeFromJson) String commissionType,@JsonKey(fromJson: looseDoubleFromJson) double hourlyRate,@JsonKey(fromJson: looseDoubleFromJson) double baseSalary,@JsonKey(fromJson: trueBoolFromJson) bool isPayrollEnabled,@JsonKey(fromJson: nullableLooseStringFromJson) String? payrollCurrency,@JsonKey(fromJson: looseStringFromJson) String status,@JsonKey(fromJson: nullableLooseStringFromJson) String? avatarUrl,@JsonKey(fromJson: trueBoolFromJson) bool attendanceRequired,@JsonKey(fromJson: falseBoolFromJson) bool isBookable,@JsonKey(fromJson: nullableLooseStringFromJson) String? publicBio,@JsonKey(fromJson: looseIntFromJson) int displayOrder,@JsonKey(fromJson: nullableLooseStringFromJson) String? workingHoursProfileId,@JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson) String? payrollPeriodOverride,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? hiredAt,@JsonKey(fromJson: stringListFromJson) List<String> assignedServiceIds,@JsonKey(fromJson: trueBoolFromJson) bool isActive,@JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson) WeeklyAvailability? weeklyAvailability,@JsonKey(fromJson: _nullableBoolFromJson) bool? mustChangePassword,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt
});




}
/// @nodoc
class _$EmployeeCopyWithImpl<$Res>
    implements $EmployeeCopyWith<$Res> {
  _$EmployeeCopyWithImpl(this._self, this._then);

  final Employee _self;
  final $Res Function(Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salonId = null,Object? name = null,Object? email = null,Object? username = freezed,Object? usernameLower = freezed,Object? role = null,Object? uid = freezed,Object? phone = freezed,Object? commissionRate = null,Object? commissionValue = null,Object? commissionPercentage = null,Object? commissionFixedAmount = null,Object? commissionType = null,Object? hourlyRate = null,Object? baseSalary = null,Object? isPayrollEnabled = null,Object? payrollCurrency = freezed,Object? status = null,Object? avatarUrl = freezed,Object? attendanceRequired = null,Object? isBookable = null,Object? publicBio = freezed,Object? displayOrder = null,Object? workingHoursProfileId = freezed,Object? payrollPeriodOverride = freezed,Object? hiredAt = freezed,Object? assignedServiceIds = null,Object? isActive = null,Object? weeklyAvailability = freezed,Object? mustChangePassword = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,usernameLower: freezed == usernameLower ? _self.usernameLower : usernameLower // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,commissionValue: null == commissionValue ? _self.commissionValue : commissionValue // ignore: cast_nullable_to_non_nullable
as double,commissionPercentage: null == commissionPercentage ? _self.commissionPercentage : commissionPercentage // ignore: cast_nullable_to_non_nullable
as double,commissionFixedAmount: null == commissionFixedAmount ? _self.commissionFixedAmount : commissionFixedAmount // ignore: cast_nullable_to_non_nullable
as double,commissionType: null == commissionType ? _self.commissionType : commissionType // ignore: cast_nullable_to_non_nullable
as String,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,baseSalary: null == baseSalary ? _self.baseSalary : baseSalary // ignore: cast_nullable_to_non_nullable
as double,isPayrollEnabled: null == isPayrollEnabled ? _self.isPayrollEnabled : isPayrollEnabled // ignore: cast_nullable_to_non_nullable
as bool,payrollCurrency: freezed == payrollCurrency ? _self.payrollCurrency : payrollCurrency // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,attendanceRequired: null == attendanceRequired ? _self.attendanceRequired : attendanceRequired // ignore: cast_nullable_to_non_nullable
as bool,isBookable: null == isBookable ? _self.isBookable : isBookable // ignore: cast_nullable_to_non_nullable
as bool,publicBio: freezed == publicBio ? _self.publicBio : publicBio // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,workingHoursProfileId: freezed == workingHoursProfileId ? _self.workingHoursProfileId : workingHoursProfileId // ignore: cast_nullable_to_non_nullable
as String?,payrollPeriodOverride: freezed == payrollPeriodOverride ? _self.payrollPeriodOverride : payrollPeriodOverride // ignore: cast_nullable_to_non_nullable
as String?,hiredAt: freezed == hiredAt ? _self.hiredAt : hiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedServiceIds: null == assignedServiceIds ? _self.assignedServiceIds : assignedServiceIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,weeklyAvailability: freezed == weeklyAvailability ? _self.weeklyAvailability : weeklyAvailability // ignore: cast_nullable_to_non_nullable
as WeeklyAvailability?,mustChangePassword: freezed == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Employee].
extension EmployeePatterns on Employee {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Employee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Employee value)  $default,){
final _that = this;
switch (_that) {
case _Employee():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Employee value)?  $default,){
final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String email, @JsonKey(fromJson: nullableLooseStringFromJson)  String? username, @JsonKey(fromJson: nullableLooseStringFromJson)  String? usernameLower, @JsonKey(fromJson: looseStringFromJson)  String role, @JsonKey(fromJson: nullableLooseStringFromJson)  String? uid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? phone, @JsonKey(fromJson: looseDoubleFromJson)  double commissionRate, @JsonKey(fromJson: looseDoubleFromJson)  double commissionValue, @JsonKey(fromJson: looseDoubleFromJson)  double commissionPercentage, @JsonKey(fromJson: looseDoubleFromJson)  double commissionFixedAmount, @JsonKey(fromJson: _commissionTypeFromJson)  String commissionType, @JsonKey(fromJson: looseDoubleFromJson)  double hourlyRate, @JsonKey(fromJson: looseDoubleFromJson)  double baseSalary, @JsonKey(fromJson: trueBoolFromJson)  bool isPayrollEnabled, @JsonKey(fromJson: nullableLooseStringFromJson)  String? payrollCurrency, @JsonKey(fromJson: looseStringFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? avatarUrl, @JsonKey(fromJson: trueBoolFromJson)  bool attendanceRequired, @JsonKey(fromJson: falseBoolFromJson)  bool isBookable, @JsonKey(fromJson: nullableLooseStringFromJson)  String? publicBio, @JsonKey(fromJson: looseIntFromJson)  int displayOrder, @JsonKey(fromJson: nullableLooseStringFromJson)  String? workingHoursProfileId, @JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson)  String? payrollPeriodOverride, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? hiredAt, @JsonKey(fromJson: stringListFromJson)  List<String> assignedServiceIds, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson)  WeeklyAvailability? weeklyAvailability, @JsonKey(fromJson: _nullableBoolFromJson)  bool? mustChangePassword, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.salonId,_that.name,_that.email,_that.username,_that.usernameLower,_that.role,_that.uid,_that.phone,_that.commissionRate,_that.commissionValue,_that.commissionPercentage,_that.commissionFixedAmount,_that.commissionType,_that.hourlyRate,_that.baseSalary,_that.isPayrollEnabled,_that.payrollCurrency,_that.status,_that.avatarUrl,_that.attendanceRequired,_that.isBookable,_that.publicBio,_that.displayOrder,_that.workingHoursProfileId,_that.payrollPeriodOverride,_that.hiredAt,_that.assignedServiceIds,_that.isActive,_that.weeklyAvailability,_that.mustChangePassword,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String email, @JsonKey(fromJson: nullableLooseStringFromJson)  String? username, @JsonKey(fromJson: nullableLooseStringFromJson)  String? usernameLower, @JsonKey(fromJson: looseStringFromJson)  String role, @JsonKey(fromJson: nullableLooseStringFromJson)  String? uid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? phone, @JsonKey(fromJson: looseDoubleFromJson)  double commissionRate, @JsonKey(fromJson: looseDoubleFromJson)  double commissionValue, @JsonKey(fromJson: looseDoubleFromJson)  double commissionPercentage, @JsonKey(fromJson: looseDoubleFromJson)  double commissionFixedAmount, @JsonKey(fromJson: _commissionTypeFromJson)  String commissionType, @JsonKey(fromJson: looseDoubleFromJson)  double hourlyRate, @JsonKey(fromJson: looseDoubleFromJson)  double baseSalary, @JsonKey(fromJson: trueBoolFromJson)  bool isPayrollEnabled, @JsonKey(fromJson: nullableLooseStringFromJson)  String? payrollCurrency, @JsonKey(fromJson: looseStringFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? avatarUrl, @JsonKey(fromJson: trueBoolFromJson)  bool attendanceRequired, @JsonKey(fromJson: falseBoolFromJson)  bool isBookable, @JsonKey(fromJson: nullableLooseStringFromJson)  String? publicBio, @JsonKey(fromJson: looseIntFromJson)  int displayOrder, @JsonKey(fromJson: nullableLooseStringFromJson)  String? workingHoursProfileId, @JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson)  String? payrollPeriodOverride, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? hiredAt, @JsonKey(fromJson: stringListFromJson)  List<String> assignedServiceIds, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson)  WeeklyAvailability? weeklyAvailability, @JsonKey(fromJson: _nullableBoolFromJson)  bool? mustChangePassword, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Employee():
return $default(_that.id,_that.salonId,_that.name,_that.email,_that.username,_that.usernameLower,_that.role,_that.uid,_that.phone,_that.commissionRate,_that.commissionValue,_that.commissionPercentage,_that.commissionFixedAmount,_that.commissionType,_that.hourlyRate,_that.baseSalary,_that.isPayrollEnabled,_that.payrollCurrency,_that.status,_that.avatarUrl,_that.attendanceRequired,_that.isBookable,_that.publicBio,_that.displayOrder,_that.workingHoursProfileId,_that.payrollPeriodOverride,_that.hiredAt,_that.assignedServiceIds,_that.isActive,_that.weeklyAvailability,_that.mustChangePassword,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String email, @JsonKey(fromJson: nullableLooseStringFromJson)  String? username, @JsonKey(fromJson: nullableLooseStringFromJson)  String? usernameLower, @JsonKey(fromJson: looseStringFromJson)  String role, @JsonKey(fromJson: nullableLooseStringFromJson)  String? uid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? phone, @JsonKey(fromJson: looseDoubleFromJson)  double commissionRate, @JsonKey(fromJson: looseDoubleFromJson)  double commissionValue, @JsonKey(fromJson: looseDoubleFromJson)  double commissionPercentage, @JsonKey(fromJson: looseDoubleFromJson)  double commissionFixedAmount, @JsonKey(fromJson: _commissionTypeFromJson)  String commissionType, @JsonKey(fromJson: looseDoubleFromJson)  double hourlyRate, @JsonKey(fromJson: looseDoubleFromJson)  double baseSalary, @JsonKey(fromJson: trueBoolFromJson)  bool isPayrollEnabled, @JsonKey(fromJson: nullableLooseStringFromJson)  String? payrollCurrency, @JsonKey(fromJson: looseStringFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? avatarUrl, @JsonKey(fromJson: trueBoolFromJson)  bool attendanceRequired, @JsonKey(fromJson: falseBoolFromJson)  bool isBookable, @JsonKey(fromJson: nullableLooseStringFromJson)  String? publicBio, @JsonKey(fromJson: looseIntFromJson)  int displayOrder, @JsonKey(fromJson: nullableLooseStringFromJson)  String? workingHoursProfileId, @JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson)  String? payrollPeriodOverride, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? hiredAt, @JsonKey(fromJson: stringListFromJson)  List<String> assignedServiceIds, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson)  WeeklyAvailability? weeklyAvailability, @JsonKey(fromJson: _nullableBoolFromJson)  bool? mustChangePassword, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Employee() when $default != null:
return $default(_that.id,_that.salonId,_that.name,_that.email,_that.username,_that.usernameLower,_that.role,_that.uid,_that.phone,_that.commissionRate,_that.commissionValue,_that.commissionPercentage,_that.commissionFixedAmount,_that.commissionType,_that.hourlyRate,_that.baseSalary,_that.isPayrollEnabled,_that.payrollCurrency,_that.status,_that.avatarUrl,_that.attendanceRequired,_that.isBookable,_that.publicBio,_that.displayOrder,_that.workingHoursProfileId,_that.payrollPeriodOverride,_that.hiredAt,_that.assignedServiceIds,_that.isActive,_that.weeklyAvailability,_that.mustChangePassword,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Employee extends Employee {
  const _Employee({@JsonKey(fromJson: looseStringFromJson) required this.id, @JsonKey(fromJson: looseStringFromJson) required this.salonId, @JsonKey(fromJson: looseStringFromJson) required this.name, @JsonKey(fromJson: looseStringFromJson) required this.email, @JsonKey(fromJson: nullableLooseStringFromJson) this.username, @JsonKey(fromJson: nullableLooseStringFromJson) this.usernameLower, @JsonKey(fromJson: looseStringFromJson) required this.role, @JsonKey(fromJson: nullableLooseStringFromJson) this.uid, @JsonKey(fromJson: nullableLooseStringFromJson) this.phone, @JsonKey(fromJson: looseDoubleFromJson) this.commissionRate = 0, @JsonKey(fromJson: looseDoubleFromJson) this.commissionValue = 0, @JsonKey(fromJson: looseDoubleFromJson) this.commissionPercentage = 0, @JsonKey(fromJson: looseDoubleFromJson) this.commissionFixedAmount = 0, @JsonKey(fromJson: _commissionTypeFromJson) this.commissionType = EmployeeCommissionTypes.percentage, @JsonKey(fromJson: looseDoubleFromJson) this.hourlyRate = 0, @JsonKey(fromJson: looseDoubleFromJson) this.baseSalary = 0, @JsonKey(fromJson: trueBoolFromJson) this.isPayrollEnabled = true, @JsonKey(fromJson: nullableLooseStringFromJson) this.payrollCurrency, @JsonKey(fromJson: looseStringFromJson) this.status = 'active', @JsonKey(fromJson: nullableLooseStringFromJson) this.avatarUrl, @JsonKey(fromJson: trueBoolFromJson) this.attendanceRequired = true, @JsonKey(fromJson: falseBoolFromJson) this.isBookable = false, @JsonKey(fromJson: nullableLooseStringFromJson) this.publicBio, @JsonKey(fromJson: looseIntFromJson) this.displayOrder = 0, @JsonKey(fromJson: nullableLooseStringFromJson) this.workingHoursProfileId, @JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson) this.payrollPeriodOverride = null, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.hiredAt, @JsonKey(fromJson: stringListFromJson) final  List<String> assignedServiceIds = const <String>[], @JsonKey(fromJson: trueBoolFromJson) this.isActive = true, @JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson) this.weeklyAvailability, @JsonKey(fromJson: _nullableBoolFromJson) this.mustChangePassword, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.updatedAt}): _assignedServiceIds = assignedServiceIds,super._();
  factory _Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);

@override@JsonKey(fromJson: looseStringFromJson) final  String id;
@override@JsonKey(fromJson: looseStringFromJson) final  String salonId;
@override@JsonKey(fromJson: looseStringFromJson) final  String name;
@override@JsonKey(fromJson: looseStringFromJson) final  String email;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? username;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? usernameLower;
@override@JsonKey(fromJson: looseStringFromJson) final  String role;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? uid;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? phone;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double commissionRate;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double commissionValue;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double commissionPercentage;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double commissionFixedAmount;
@override@JsonKey(fromJson: _commissionTypeFromJson) final  String commissionType;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double hourlyRate;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double baseSalary;
@override@JsonKey(fromJson: trueBoolFromJson) final  bool isPayrollEnabled;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? payrollCurrency;
@override@JsonKey(fromJson: looseStringFromJson) final  String status;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? avatarUrl;
@override@JsonKey(fromJson: trueBoolFromJson) final  bool attendanceRequired;
@override@JsonKey(fromJson: falseBoolFromJson) final  bool isBookable;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? publicBio;
@override@JsonKey(fromJson: looseIntFromJson) final  int displayOrder;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? workingHoursProfileId;
/// `monthly` | `weekly` — null inherits salon default payroll period.
@override@JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson) final  String? payrollPeriodOverride;
/// Calendar hire date (Firestore Timestamp); payroll prorates monthly base salary when set.
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? hiredAt;
 final  List<String> _assignedServiceIds;
@override@JsonKey(fromJson: stringListFromJson) List<String> get assignedServiceIds {
  if (_assignedServiceIds is EqualUnmodifiableListView) return _assignedServiceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedServiceIds);
}

@override@JsonKey(fromJson: trueBoolFromJson) final  bool isActive;
@override@JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson) final  WeeklyAvailability? weeklyAvailability;
@override@JsonKey(fromJson: _nullableBoolFromJson) final  bool? mustChangePassword;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? updatedAt;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeCopyWith<_Employee> get copyWith => __$EmployeeCopyWithImpl<_Employee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmployeeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Employee&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.usernameLower, usernameLower) || other.usernameLower == usernameLower)&&(identical(other.role, role) || other.role == role)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.commissionValue, commissionValue) || other.commissionValue == commissionValue)&&(identical(other.commissionPercentage, commissionPercentage) || other.commissionPercentage == commissionPercentage)&&(identical(other.commissionFixedAmount, commissionFixedAmount) || other.commissionFixedAmount == commissionFixedAmount)&&(identical(other.commissionType, commissionType) || other.commissionType == commissionType)&&(identical(other.hourlyRate, hourlyRate) || other.hourlyRate == hourlyRate)&&(identical(other.baseSalary, baseSalary) || other.baseSalary == baseSalary)&&(identical(other.isPayrollEnabled, isPayrollEnabled) || other.isPayrollEnabled == isPayrollEnabled)&&(identical(other.payrollCurrency, payrollCurrency) || other.payrollCurrency == payrollCurrency)&&(identical(other.status, status) || other.status == status)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.attendanceRequired, attendanceRequired) || other.attendanceRequired == attendanceRequired)&&(identical(other.isBookable, isBookable) || other.isBookable == isBookable)&&(identical(other.publicBio, publicBio) || other.publicBio == publicBio)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.workingHoursProfileId, workingHoursProfileId) || other.workingHoursProfileId == workingHoursProfileId)&&(identical(other.payrollPeriodOverride, payrollPeriodOverride) || other.payrollPeriodOverride == payrollPeriodOverride)&&(identical(other.hiredAt, hiredAt) || other.hiredAt == hiredAt)&&const DeepCollectionEquality().equals(other._assignedServiceIds, _assignedServiceIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.weeklyAvailability, weeklyAvailability) || other.weeklyAvailability == weeklyAvailability)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,name,email,username,usernameLower,role,uid,phone,commissionRate,commissionValue,commissionPercentage,commissionFixedAmount,commissionType,hourlyRate,baseSalary,isPayrollEnabled,payrollCurrency,status,avatarUrl,attendanceRequired,isBookable,publicBio,displayOrder,workingHoursProfileId,payrollPeriodOverride,hiredAt,const DeepCollectionEquality().hash(_assignedServiceIds),isActive,weeklyAvailability,mustChangePassword,createdAt,updatedAt]);

@override
String toString() {
  return 'Employee(id: $id, salonId: $salonId, name: $name, email: $email, username: $username, usernameLower: $usernameLower, role: $role, uid: $uid, phone: $phone, commissionRate: $commissionRate, commissionValue: $commissionValue, commissionPercentage: $commissionPercentage, commissionFixedAmount: $commissionFixedAmount, commissionType: $commissionType, hourlyRate: $hourlyRate, baseSalary: $baseSalary, isPayrollEnabled: $isPayrollEnabled, payrollCurrency: $payrollCurrency, status: $status, avatarUrl: $avatarUrl, attendanceRequired: $attendanceRequired, isBookable: $isBookable, publicBio: $publicBio, displayOrder: $displayOrder, workingHoursProfileId: $workingHoursProfileId, payrollPeriodOverride: $payrollPeriodOverride, hiredAt: $hiredAt, assignedServiceIds: $assignedServiceIds, isActive: $isActive, weeklyAvailability: $weeklyAvailability, mustChangePassword: $mustChangePassword, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmployeeCopyWith<$Res> implements $EmployeeCopyWith<$Res> {
  factory _$EmployeeCopyWith(_Employee value, $Res Function(_Employee) _then) = __$EmployeeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String name,@JsonKey(fromJson: looseStringFromJson) String email,@JsonKey(fromJson: nullableLooseStringFromJson) String? username,@JsonKey(fromJson: nullableLooseStringFromJson) String? usernameLower,@JsonKey(fromJson: looseStringFromJson) String role,@JsonKey(fromJson: nullableLooseStringFromJson) String? uid,@JsonKey(fromJson: nullableLooseStringFromJson) String? phone,@JsonKey(fromJson: looseDoubleFromJson) double commissionRate,@JsonKey(fromJson: looseDoubleFromJson) double commissionValue,@JsonKey(fromJson: looseDoubleFromJson) double commissionPercentage,@JsonKey(fromJson: looseDoubleFromJson) double commissionFixedAmount,@JsonKey(fromJson: _commissionTypeFromJson) String commissionType,@JsonKey(fromJson: looseDoubleFromJson) double hourlyRate,@JsonKey(fromJson: looseDoubleFromJson) double baseSalary,@JsonKey(fromJson: trueBoolFromJson) bool isPayrollEnabled,@JsonKey(fromJson: nullableLooseStringFromJson) String? payrollCurrency,@JsonKey(fromJson: looseStringFromJson) String status,@JsonKey(fromJson: nullableLooseStringFromJson) String? avatarUrl,@JsonKey(fromJson: trueBoolFromJson) bool attendanceRequired,@JsonKey(fromJson: falseBoolFromJson) bool isBookable,@JsonKey(fromJson: nullableLooseStringFromJson) String? publicBio,@JsonKey(fromJson: looseIntFromJson) int displayOrder,@JsonKey(fromJson: nullableLooseStringFromJson) String? workingHoursProfileId,@JsonKey(fromJson: _payrollPeriodOverrideFromJson, toJson: _payrollPeriodOverrideToJson) String? payrollPeriodOverride,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? hiredAt,@JsonKey(fromJson: stringListFromJson) List<String> assignedServiceIds,@JsonKey(fromJson: trueBoolFromJson) bool isActive,@JsonKey(fromJson: _weeklyAvailabilityFromJson, toJson: _weeklyAvailabilityToJson) WeeklyAvailability? weeklyAvailability,@JsonKey(fromJson: _nullableBoolFromJson) bool? mustChangePassword,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt
});




}
/// @nodoc
class __$EmployeeCopyWithImpl<$Res>
    implements _$EmployeeCopyWith<$Res> {
  __$EmployeeCopyWithImpl(this._self, this._then);

  final _Employee _self;
  final $Res Function(_Employee) _then;

/// Create a copy of Employee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salonId = null,Object? name = null,Object? email = null,Object? username = freezed,Object? usernameLower = freezed,Object? role = null,Object? uid = freezed,Object? phone = freezed,Object? commissionRate = null,Object? commissionValue = null,Object? commissionPercentage = null,Object? commissionFixedAmount = null,Object? commissionType = null,Object? hourlyRate = null,Object? baseSalary = null,Object? isPayrollEnabled = null,Object? payrollCurrency = freezed,Object? status = null,Object? avatarUrl = freezed,Object? attendanceRequired = null,Object? isBookable = null,Object? publicBio = freezed,Object? displayOrder = null,Object? workingHoursProfileId = freezed,Object? payrollPeriodOverride = freezed,Object? hiredAt = freezed,Object? assignedServiceIds = null,Object? isActive = null,Object? weeklyAvailability = freezed,Object? mustChangePassword = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Employee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,usernameLower: freezed == usernameLower ? _self.usernameLower : usernameLower // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,commissionValue: null == commissionValue ? _self.commissionValue : commissionValue // ignore: cast_nullable_to_non_nullable
as double,commissionPercentage: null == commissionPercentage ? _self.commissionPercentage : commissionPercentage // ignore: cast_nullable_to_non_nullable
as double,commissionFixedAmount: null == commissionFixedAmount ? _self.commissionFixedAmount : commissionFixedAmount // ignore: cast_nullable_to_non_nullable
as double,commissionType: null == commissionType ? _self.commissionType : commissionType // ignore: cast_nullable_to_non_nullable
as String,hourlyRate: null == hourlyRate ? _self.hourlyRate : hourlyRate // ignore: cast_nullable_to_non_nullable
as double,baseSalary: null == baseSalary ? _self.baseSalary : baseSalary // ignore: cast_nullable_to_non_nullable
as double,isPayrollEnabled: null == isPayrollEnabled ? _self.isPayrollEnabled : isPayrollEnabled // ignore: cast_nullable_to_non_nullable
as bool,payrollCurrency: freezed == payrollCurrency ? _self.payrollCurrency : payrollCurrency // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,attendanceRequired: null == attendanceRequired ? _self.attendanceRequired : attendanceRequired // ignore: cast_nullable_to_non_nullable
as bool,isBookable: null == isBookable ? _self.isBookable : isBookable // ignore: cast_nullable_to_non_nullable
as bool,publicBio: freezed == publicBio ? _self.publicBio : publicBio // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,workingHoursProfileId: freezed == workingHoursProfileId ? _self.workingHoursProfileId : workingHoursProfileId // ignore: cast_nullable_to_non_nullable
as String?,payrollPeriodOverride: freezed == payrollPeriodOverride ? _self.payrollPeriodOverride : payrollPeriodOverride // ignore: cast_nullable_to_non_nullable
as String?,hiredAt: freezed == hiredAt ? _self.hiredAt : hiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,assignedServiceIds: null == assignedServiceIds ? _self._assignedServiceIds : assignedServiceIds // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,weeklyAvailability: freezed == weeklyAvailability ? _self.weeklyAvailability : weeklyAvailability // ignore: cast_nullable_to_non_nullable
as WeeklyAvailability?,mustChangePassword: freezed == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
