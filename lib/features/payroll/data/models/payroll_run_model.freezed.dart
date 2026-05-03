// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll_run_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayrollRunModel {

@JsonKey(fromJson: looseStringFromJson) String get id;@JsonKey(fromJson: _runTypeFromJson) String get runType;@JsonKey(fromJson: looseStringFromJson) String get salonId;@JsonKey(fromJson: nullableLooseStringFromJson) String? get employeeId;@JsonKey(fromJson: nullableLooseStringFromJson) String? get employeeName;@JsonKey(fromJson: looseIntFromJson) int get year;@JsonKey(fromJson: looseIntFromJson) int get month;@JsonKey(fromJson: _periodGranularityFromJson) String get periodGranularity;@JsonKey(fromJson: looseIntFromJson) int get isoWeekYear;@JsonKey(fromJson: looseIntFromJson) int get isoWeekNumber;@JsonKey(fromJson: _statusFromJson) String get status;@JsonKey(fromJson: looseDoubleFromJson) double get totalEarnings;@JsonKey(fromJson: looseDoubleFromJson) double get totalDeductions;@JsonKey(fromJson: looseDoubleFromJson) double get netPay;@JsonKey(fromJson: stringListFromJson) List<String> get employeeIds;@JsonKey(fromJson: looseIntFromJson) int get employeeCount;@JsonKey(fromJson: nullableLooseStringFromJson) String? get createdBy;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get createdAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get approvedAt;@JsonKey(fromJson: nullableLooseStringFromJson) String? get approvedBy;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get paidAt;@JsonKey(fromJson: nullableLooseStringFromJson) String? get paidBy;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get updatedAt;/// When set, weekly accrual used this inclusive UTC window (calendar days).
@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get payrollWindowStartUtc;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get payrollWindowEndUtc;
/// Create a copy of PayrollRunModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayrollRunModelCopyWith<PayrollRunModel> get copyWith => _$PayrollRunModelCopyWithImpl<PayrollRunModel>(this as PayrollRunModel, _$identity);

  /// Serializes this PayrollRunModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayrollRunModel&&(identical(other.id, id) || other.id == id)&&(identical(other.runType, runType) || other.runType == runType)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.periodGranularity, periodGranularity) || other.periodGranularity == periodGranularity)&&(identical(other.isoWeekYear, isoWeekYear) || other.isoWeekYear == isoWeekYear)&&(identical(other.isoWeekNumber, isoWeekNumber) || other.isoWeekNumber == isoWeekNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.netPay, netPay) || other.netPay == netPay)&&const DeepCollectionEquality().equals(other.employeeIds, employeeIds)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.payrollWindowStartUtc, payrollWindowStartUtc) || other.payrollWindowStartUtc == payrollWindowStartUtc)&&(identical(other.payrollWindowEndUtc, payrollWindowEndUtc) || other.payrollWindowEndUtc == payrollWindowEndUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,runType,salonId,employeeId,employeeName,year,month,periodGranularity,isoWeekYear,isoWeekNumber,status,totalEarnings,totalDeductions,netPay,const DeepCollectionEquality().hash(employeeIds),employeeCount,createdBy,createdAt,approvedAt,approvedBy,paidAt,paidBy,updatedAt,payrollWindowStartUtc,payrollWindowEndUtc]);

@override
String toString() {
  return 'PayrollRunModel(id: $id, runType: $runType, salonId: $salonId, employeeId: $employeeId, employeeName: $employeeName, year: $year, month: $month, periodGranularity: $periodGranularity, isoWeekYear: $isoWeekYear, isoWeekNumber: $isoWeekNumber, status: $status, totalEarnings: $totalEarnings, totalDeductions: $totalDeductions, netPay: $netPay, employeeIds: $employeeIds, employeeCount: $employeeCount, createdBy: $createdBy, createdAt: $createdAt, approvedAt: $approvedAt, approvedBy: $approvedBy, paidAt: $paidAt, paidBy: $paidBy, updatedAt: $updatedAt, payrollWindowStartUtc: $payrollWindowStartUtc, payrollWindowEndUtc: $payrollWindowEndUtc)';
}


}

/// @nodoc
abstract mixin class $PayrollRunModelCopyWith<$Res>  {
  factory $PayrollRunModelCopyWith(PayrollRunModel value, $Res Function(PayrollRunModel) _then) = _$PayrollRunModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: _runTypeFromJson) String runType,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: nullableLooseStringFromJson) String? employeeId,@JsonKey(fromJson: nullableLooseStringFromJson) String? employeeName,@JsonKey(fromJson: looseIntFromJson) int year,@JsonKey(fromJson: looseIntFromJson) int month,@JsonKey(fromJson: _periodGranularityFromJson) String periodGranularity,@JsonKey(fromJson: looseIntFromJson) int isoWeekYear,@JsonKey(fromJson: looseIntFromJson) int isoWeekNumber,@JsonKey(fromJson: _statusFromJson) String status,@JsonKey(fromJson: looseDoubleFromJson) double totalEarnings,@JsonKey(fromJson: looseDoubleFromJson) double totalDeductions,@JsonKey(fromJson: looseDoubleFromJson) double netPay,@JsonKey(fromJson: stringListFromJson) List<String> employeeIds,@JsonKey(fromJson: looseIntFromJson) int employeeCount,@JsonKey(fromJson: nullableLooseStringFromJson) String? createdBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? approvedAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? approvedBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? paidAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? paidBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? payrollWindowStartUtc,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? payrollWindowEndUtc
});




}
/// @nodoc
class _$PayrollRunModelCopyWithImpl<$Res>
    implements $PayrollRunModelCopyWith<$Res> {
  _$PayrollRunModelCopyWithImpl(this._self, this._then);

  final PayrollRunModel _self;
  final $Res Function(PayrollRunModel) _then;

/// Create a copy of PayrollRunModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? runType = null,Object? salonId = null,Object? employeeId = freezed,Object? employeeName = freezed,Object? year = null,Object? month = null,Object? periodGranularity = null,Object? isoWeekYear = null,Object? isoWeekNumber = null,Object? status = null,Object? totalEarnings = null,Object? totalDeductions = null,Object? netPay = null,Object? employeeIds = null,Object? employeeCount = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? paidAt = freezed,Object? paidBy = freezed,Object? updatedAt = freezed,Object? payrollWindowStartUtc = freezed,Object? payrollWindowEndUtc = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runType: null == runType ? _self.runType : runType // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,employeeName: freezed == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,periodGranularity: null == periodGranularity ? _self.periodGranularity : periodGranularity // ignore: cast_nullable_to_non_nullable
as String,isoWeekYear: null == isoWeekYear ? _self.isoWeekYear : isoWeekYear // ignore: cast_nullable_to_non_nullable
as int,isoWeekNumber: null == isoWeekNumber ? _self.isoWeekNumber : isoWeekNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,netPay: null == netPay ? _self.netPay : netPay // ignore: cast_nullable_to_non_nullable
as double,employeeIds: null == employeeIds ? _self.employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payrollWindowStartUtc: freezed == payrollWindowStartUtc ? _self.payrollWindowStartUtc : payrollWindowStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,payrollWindowEndUtc: freezed == payrollWindowEndUtc ? _self.payrollWindowEndUtc : payrollWindowEndUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PayrollRunModel].
extension PayrollRunModelPatterns on PayrollRunModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayrollRunModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayrollRunModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayrollRunModel value)  $default,){
final _that = this;
switch (_that) {
case _PayrollRunModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayrollRunModel value)?  $default,){
final _that = this;
switch (_that) {
case _PayrollRunModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: _runTypeFromJson)  String runType, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeName, @JsonKey(fromJson: looseIntFromJson)  int year, @JsonKey(fromJson: looseIntFromJson)  int month, @JsonKey(fromJson: _periodGranularityFromJson)  String periodGranularity, @JsonKey(fromJson: looseIntFromJson)  int isoWeekYear, @JsonKey(fromJson: looseIntFromJson)  int isoWeekNumber, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: looseDoubleFromJson)  double totalEarnings, @JsonKey(fromJson: looseDoubleFromJson)  double totalDeductions, @JsonKey(fromJson: looseDoubleFromJson)  double netPay, @JsonKey(fromJson: stringListFromJson)  List<String> employeeIds, @JsonKey(fromJson: looseIntFromJson)  int employeeCount, @JsonKey(fromJson: nullableLooseStringFromJson)  String? createdBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? approvedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? approvedBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? paidAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? paidBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowStartUtc, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowEndUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayrollRunModel() when $default != null:
return $default(_that.id,_that.runType,_that.salonId,_that.employeeId,_that.employeeName,_that.year,_that.month,_that.periodGranularity,_that.isoWeekYear,_that.isoWeekNumber,_that.status,_that.totalEarnings,_that.totalDeductions,_that.netPay,_that.employeeIds,_that.employeeCount,_that.createdBy,_that.createdAt,_that.approvedAt,_that.approvedBy,_that.paidAt,_that.paidBy,_that.updatedAt,_that.payrollWindowStartUtc,_that.payrollWindowEndUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: _runTypeFromJson)  String runType, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeName, @JsonKey(fromJson: looseIntFromJson)  int year, @JsonKey(fromJson: looseIntFromJson)  int month, @JsonKey(fromJson: _periodGranularityFromJson)  String periodGranularity, @JsonKey(fromJson: looseIntFromJson)  int isoWeekYear, @JsonKey(fromJson: looseIntFromJson)  int isoWeekNumber, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: looseDoubleFromJson)  double totalEarnings, @JsonKey(fromJson: looseDoubleFromJson)  double totalDeductions, @JsonKey(fromJson: looseDoubleFromJson)  double netPay, @JsonKey(fromJson: stringListFromJson)  List<String> employeeIds, @JsonKey(fromJson: looseIntFromJson)  int employeeCount, @JsonKey(fromJson: nullableLooseStringFromJson)  String? createdBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? approvedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? approvedBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? paidAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? paidBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowStartUtc, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowEndUtc)  $default,) {final _that = this;
switch (_that) {
case _PayrollRunModel():
return $default(_that.id,_that.runType,_that.salonId,_that.employeeId,_that.employeeName,_that.year,_that.month,_that.periodGranularity,_that.isoWeekYear,_that.isoWeekNumber,_that.status,_that.totalEarnings,_that.totalDeductions,_that.netPay,_that.employeeIds,_that.employeeCount,_that.createdBy,_that.createdAt,_that.approvedAt,_that.approvedBy,_that.paidAt,_that.paidBy,_that.updatedAt,_that.payrollWindowStartUtc,_that.payrollWindowEndUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: _runTypeFromJson)  String runType, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? employeeName, @JsonKey(fromJson: looseIntFromJson)  int year, @JsonKey(fromJson: looseIntFromJson)  int month, @JsonKey(fromJson: _periodGranularityFromJson)  String periodGranularity, @JsonKey(fromJson: looseIntFromJson)  int isoWeekYear, @JsonKey(fromJson: looseIntFromJson)  int isoWeekNumber, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: looseDoubleFromJson)  double totalEarnings, @JsonKey(fromJson: looseDoubleFromJson)  double totalDeductions, @JsonKey(fromJson: looseDoubleFromJson)  double netPay, @JsonKey(fromJson: stringListFromJson)  List<String> employeeIds, @JsonKey(fromJson: looseIntFromJson)  int employeeCount, @JsonKey(fromJson: nullableLooseStringFromJson)  String? createdBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? approvedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? approvedBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? paidAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? paidBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowStartUtc, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? payrollWindowEndUtc)?  $default,) {final _that = this;
switch (_that) {
case _PayrollRunModel() when $default != null:
return $default(_that.id,_that.runType,_that.salonId,_that.employeeId,_that.employeeName,_that.year,_that.month,_that.periodGranularity,_that.isoWeekYear,_that.isoWeekNumber,_that.status,_that.totalEarnings,_that.totalDeductions,_that.netPay,_that.employeeIds,_that.employeeCount,_that.createdBy,_that.createdAt,_that.approvedAt,_that.approvedBy,_that.paidAt,_that.paidBy,_that.updatedAt,_that.payrollWindowStartUtc,_that.payrollWindowEndUtc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayrollRunModel extends PayrollRunModel {
  const _PayrollRunModel({@JsonKey(fromJson: looseStringFromJson) required this.id, @JsonKey(fromJson: _runTypeFromJson) required this.runType, @JsonKey(fromJson: looseStringFromJson) required this.salonId, @JsonKey(fromJson: nullableLooseStringFromJson) this.employeeId, @JsonKey(fromJson: nullableLooseStringFromJson) this.employeeName, @JsonKey(fromJson: looseIntFromJson) this.year = 0, @JsonKey(fromJson: looseIntFromJson) this.month = 0, @JsonKey(fromJson: _periodGranularityFromJson) this.periodGranularity = PayrollRunPeriodGranularities.monthly, @JsonKey(fromJson: looseIntFromJson) this.isoWeekYear = 0, @JsonKey(fromJson: looseIntFromJson) this.isoWeekNumber = 0, @JsonKey(fromJson: _statusFromJson) this.status = PayrollRunStatuses.draft, @JsonKey(fromJson: looseDoubleFromJson) this.totalEarnings = 0, @JsonKey(fromJson: looseDoubleFromJson) this.totalDeductions = 0, @JsonKey(fromJson: looseDoubleFromJson) this.netPay = 0, @JsonKey(fromJson: stringListFromJson) final  List<String> employeeIds = const <String>[], @JsonKey(fromJson: looseIntFromJson) this.employeeCount = 0, @JsonKey(fromJson: nullableLooseStringFromJson) this.createdBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.approvedAt, @JsonKey(fromJson: nullableLooseStringFromJson) this.approvedBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.paidAt, @JsonKey(fromJson: nullableLooseStringFromJson) this.paidBy, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.payrollWindowStartUtc, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.payrollWindowEndUtc}): _employeeIds = employeeIds,super._();
  factory _PayrollRunModel.fromJson(Map<String, dynamic> json) => _$PayrollRunModelFromJson(json);

@override@JsonKey(fromJson: looseStringFromJson) final  String id;
@override@JsonKey(fromJson: _runTypeFromJson) final  String runType;
@override@JsonKey(fromJson: looseStringFromJson) final  String salonId;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? employeeId;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? employeeName;
@override@JsonKey(fromJson: looseIntFromJson) final  int year;
@override@JsonKey(fromJson: looseIntFromJson) final  int month;
@override@JsonKey(fromJson: _periodGranularityFromJson) final  String periodGranularity;
@override@JsonKey(fromJson: looseIntFromJson) final  int isoWeekYear;
@override@JsonKey(fromJson: looseIntFromJson) final  int isoWeekNumber;
@override@JsonKey(fromJson: _statusFromJson) final  String status;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double totalEarnings;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double totalDeductions;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double netPay;
 final  List<String> _employeeIds;
@override@JsonKey(fromJson: stringListFromJson) List<String> get employeeIds {
  if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_employeeIds);
}

@override@JsonKey(fromJson: looseIntFromJson) final  int employeeCount;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? createdBy;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? approvedAt;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? approvedBy;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? paidAt;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? paidBy;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? updatedAt;
/// When set, weekly accrual used this inclusive UTC window (calendar days).
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? payrollWindowStartUtc;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? payrollWindowEndUtc;

/// Create a copy of PayrollRunModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayrollRunModelCopyWith<_PayrollRunModel> get copyWith => __$PayrollRunModelCopyWithImpl<_PayrollRunModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayrollRunModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayrollRunModel&&(identical(other.id, id) || other.id == id)&&(identical(other.runType, runType) || other.runType == runType)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.periodGranularity, periodGranularity) || other.periodGranularity == periodGranularity)&&(identical(other.isoWeekYear, isoWeekYear) || other.isoWeekYear == isoWeekYear)&&(identical(other.isoWeekNumber, isoWeekNumber) || other.isoWeekNumber == isoWeekNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.netPay, netPay) || other.netPay == netPay)&&const DeepCollectionEquality().equals(other._employeeIds, _employeeIds)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.payrollWindowStartUtc, payrollWindowStartUtc) || other.payrollWindowStartUtc == payrollWindowStartUtc)&&(identical(other.payrollWindowEndUtc, payrollWindowEndUtc) || other.payrollWindowEndUtc == payrollWindowEndUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,runType,salonId,employeeId,employeeName,year,month,periodGranularity,isoWeekYear,isoWeekNumber,status,totalEarnings,totalDeductions,netPay,const DeepCollectionEquality().hash(_employeeIds),employeeCount,createdBy,createdAt,approvedAt,approvedBy,paidAt,paidBy,updatedAt,payrollWindowStartUtc,payrollWindowEndUtc]);

@override
String toString() {
  return 'PayrollRunModel(id: $id, runType: $runType, salonId: $salonId, employeeId: $employeeId, employeeName: $employeeName, year: $year, month: $month, periodGranularity: $periodGranularity, isoWeekYear: $isoWeekYear, isoWeekNumber: $isoWeekNumber, status: $status, totalEarnings: $totalEarnings, totalDeductions: $totalDeductions, netPay: $netPay, employeeIds: $employeeIds, employeeCount: $employeeCount, createdBy: $createdBy, createdAt: $createdAt, approvedAt: $approvedAt, approvedBy: $approvedBy, paidAt: $paidAt, paidBy: $paidBy, updatedAt: $updatedAt, payrollWindowStartUtc: $payrollWindowStartUtc, payrollWindowEndUtc: $payrollWindowEndUtc)';
}


}

/// @nodoc
abstract mixin class _$PayrollRunModelCopyWith<$Res> implements $PayrollRunModelCopyWith<$Res> {
  factory _$PayrollRunModelCopyWith(_PayrollRunModel value, $Res Function(_PayrollRunModel) _then) = __$PayrollRunModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: _runTypeFromJson) String runType,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: nullableLooseStringFromJson) String? employeeId,@JsonKey(fromJson: nullableLooseStringFromJson) String? employeeName,@JsonKey(fromJson: looseIntFromJson) int year,@JsonKey(fromJson: looseIntFromJson) int month,@JsonKey(fromJson: _periodGranularityFromJson) String periodGranularity,@JsonKey(fromJson: looseIntFromJson) int isoWeekYear,@JsonKey(fromJson: looseIntFromJson) int isoWeekNumber,@JsonKey(fromJson: _statusFromJson) String status,@JsonKey(fromJson: looseDoubleFromJson) double totalEarnings,@JsonKey(fromJson: looseDoubleFromJson) double totalDeductions,@JsonKey(fromJson: looseDoubleFromJson) double netPay,@JsonKey(fromJson: stringListFromJson) List<String> employeeIds,@JsonKey(fromJson: looseIntFromJson) int employeeCount,@JsonKey(fromJson: nullableLooseStringFromJson) String? createdBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? approvedAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? approvedBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? paidAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? paidBy,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? payrollWindowStartUtc,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? payrollWindowEndUtc
});




}
/// @nodoc
class __$PayrollRunModelCopyWithImpl<$Res>
    implements _$PayrollRunModelCopyWith<$Res> {
  __$PayrollRunModelCopyWithImpl(this._self, this._then);

  final _PayrollRunModel _self;
  final $Res Function(_PayrollRunModel) _then;

/// Create a copy of PayrollRunModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? runType = null,Object? salonId = null,Object? employeeId = freezed,Object? employeeName = freezed,Object? year = null,Object? month = null,Object? periodGranularity = null,Object? isoWeekYear = null,Object? isoWeekNumber = null,Object? status = null,Object? totalEarnings = null,Object? totalDeductions = null,Object? netPay = null,Object? employeeIds = null,Object? employeeCount = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? approvedAt = freezed,Object? approvedBy = freezed,Object? paidAt = freezed,Object? paidBy = freezed,Object? updatedAt = freezed,Object? payrollWindowStartUtc = freezed,Object? payrollWindowEndUtc = freezed,}) {
  return _then(_PayrollRunModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runType: null == runType ? _self.runType : runType // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,employeeName: freezed == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,periodGranularity: null == periodGranularity ? _self.periodGranularity : periodGranularity // ignore: cast_nullable_to_non_nullable
as String,isoWeekYear: null == isoWeekYear ? _self.isoWeekYear : isoWeekYear // ignore: cast_nullable_to_non_nullable
as int,isoWeekNumber: null == isoWeekNumber ? _self.isoWeekNumber : isoWeekNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,netPay: null == netPay ? _self.netPay : netPay // ignore: cast_nullable_to_non_nullable
as double,employeeIds: null == employeeIds ? _self._employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paidBy: freezed == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,payrollWindowStartUtc: freezed == payrollWindowStartUtc ? _self.payrollWindowStartUtc : payrollWindowStartUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,payrollWindowEndUtc: freezed == payrollWindowEndUtc ? _self.payrollWindowEndUtc : payrollWindowEndUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
