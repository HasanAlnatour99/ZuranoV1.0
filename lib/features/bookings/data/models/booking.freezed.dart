// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

@JsonKey(fromJson: looseStringFromJson) String get id;@JsonKey(fromJson: looseStringFromJson) String get salonId;@JsonKey(fromJson: looseStringFromJson) String get barberId;@JsonKey(fromJson: looseStringFromJson) String get customerId;@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime get startAt;@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime get endAt;@JsonKey(fromJson: _statusFromJson) String get status;@JsonKey(fromJson: nullableLooseStringFromJson) String? get barberName;@JsonKey(fromJson: nullableLooseStringFromJson) String? get customerName;@JsonKey(fromJson: nullableLooseStringFromJson) String? get serviceId;@JsonKey(fromJson: nullableLooseStringFromJson) String? get serviceName;@JsonKey(fromJson: nullableLooseStringFromJson) String? get notes;@JsonKey(fromJson: looseIntFromJson) int get reportYear;@JsonKey(fromJson: looseIntFromJson) int get reportMonth;@JsonKey(fromJson: _slotStepFromJson) int? get slotStepMinutes;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get createdAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get updatedAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get cancelledAt;@JsonKey(fromJson: nullableLooseStringFromJson) String? get cancelledByRole;@JsonKey(fromJson: nullableLooseStringFromJson) String? get cancelledByUserId;@JsonKey(fromJson: nullableLooseStringFromJson) String? get rescheduledFromBookingId;@JsonKey(fromJson: nullableLooseStringFromJson) String? get rescheduledToBookingId;@JsonKey(fromJson: _operationalStateFromJson) String get operationalState;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get customerArrivedAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get serviceStartedAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get serviceCompletedAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get noShowMarkedAt;@JsonKey(fromJson: nullableLooseStringFromJson) String? get noShowParty;@JsonKey(fromJson: nullableLooseStringFromJson) String? get operationalMarkedByUid;@JsonKey(fromJson: nullableLooseStringFromJson) String? get operationalMarkedByRole;/// Set when the customer submits post-visit feedback via [submitCustomerFeedback].
@JsonKey(name: 'feedbackSubmitted') bool get feedbackSubmitted;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.barberName, barberName) || other.barberName == barberName)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reportYear, reportYear) || other.reportYear == reportYear)&&(identical(other.reportMonth, reportMonth) || other.reportMonth == reportMonth)&&(identical(other.slotStepMinutes, slotStepMinutes) || other.slotStepMinutes == slotStepMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledByRole, cancelledByRole) || other.cancelledByRole == cancelledByRole)&&(identical(other.cancelledByUserId, cancelledByUserId) || other.cancelledByUserId == cancelledByUserId)&&(identical(other.rescheduledFromBookingId, rescheduledFromBookingId) || other.rescheduledFromBookingId == rescheduledFromBookingId)&&(identical(other.rescheduledToBookingId, rescheduledToBookingId) || other.rescheduledToBookingId == rescheduledToBookingId)&&(identical(other.operationalState, operationalState) || other.operationalState == operationalState)&&(identical(other.customerArrivedAt, customerArrivedAt) || other.customerArrivedAt == customerArrivedAt)&&(identical(other.serviceStartedAt, serviceStartedAt) || other.serviceStartedAt == serviceStartedAt)&&(identical(other.serviceCompletedAt, serviceCompletedAt) || other.serviceCompletedAt == serviceCompletedAt)&&(identical(other.noShowMarkedAt, noShowMarkedAt) || other.noShowMarkedAt == noShowMarkedAt)&&(identical(other.noShowParty, noShowParty) || other.noShowParty == noShowParty)&&(identical(other.operationalMarkedByUid, operationalMarkedByUid) || other.operationalMarkedByUid == operationalMarkedByUid)&&(identical(other.operationalMarkedByRole, operationalMarkedByRole) || other.operationalMarkedByRole == operationalMarkedByRole)&&(identical(other.feedbackSubmitted, feedbackSubmitted) || other.feedbackSubmitted == feedbackSubmitted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,barberId,customerId,startAt,endAt,status,barberName,customerName,serviceId,serviceName,notes,reportYear,reportMonth,slotStepMinutes,createdAt,updatedAt,cancelledAt,cancelledByRole,cancelledByUserId,rescheduledFromBookingId,rescheduledToBookingId,operationalState,customerArrivedAt,serviceStartedAt,serviceCompletedAt,noShowMarkedAt,noShowParty,operationalMarkedByUid,operationalMarkedByRole,feedbackSubmitted]);

@override
String toString() {
  return 'Booking(id: $id, salonId: $salonId, barberId: $barberId, customerId: $customerId, startAt: $startAt, endAt: $endAt, status: $status, barberName: $barberName, customerName: $customerName, serviceId: $serviceId, serviceName: $serviceName, notes: $notes, reportYear: $reportYear, reportMonth: $reportMonth, slotStepMinutes: $slotStepMinutes, createdAt: $createdAt, updatedAt: $updatedAt, cancelledAt: $cancelledAt, cancelledByRole: $cancelledByRole, cancelledByUserId: $cancelledByUserId, rescheduledFromBookingId: $rescheduledFromBookingId, rescheduledToBookingId: $rescheduledToBookingId, operationalState: $operationalState, customerArrivedAt: $customerArrivedAt, serviceStartedAt: $serviceStartedAt, serviceCompletedAt: $serviceCompletedAt, noShowMarkedAt: $noShowMarkedAt, noShowParty: $noShowParty, operationalMarkedByUid: $operationalMarkedByUid, operationalMarkedByRole: $operationalMarkedByRole, feedbackSubmitted: $feedbackSubmitted)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String barberId,@JsonKey(fromJson: looseStringFromJson) String customerId,@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime startAt,@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime endAt,@JsonKey(fromJson: _statusFromJson) String status,@JsonKey(fromJson: nullableLooseStringFromJson) String? barberName,@JsonKey(fromJson: nullableLooseStringFromJson) String? customerName,@JsonKey(fromJson: nullableLooseStringFromJson) String? serviceId,@JsonKey(fromJson: nullableLooseStringFromJson) String? serviceName,@JsonKey(fromJson: nullableLooseStringFromJson) String? notes,@JsonKey(fromJson: looseIntFromJson) int reportYear,@JsonKey(fromJson: looseIntFromJson) int reportMonth,@JsonKey(fromJson: _slotStepFromJson) int? slotStepMinutes,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? cancelledAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByRole,@JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByUserId,@JsonKey(fromJson: nullableLooseStringFromJson) String? rescheduledFromBookingId,@JsonKey(fromJson: nullableLooseStringFromJson) String? rescheduledToBookingId,@JsonKey(fromJson: _operationalStateFromJson) String operationalState,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? customerArrivedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? serviceStartedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? serviceCompletedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? noShowMarkedAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? noShowParty,@JsonKey(fromJson: nullableLooseStringFromJson) String? operationalMarkedByUid,@JsonKey(fromJson: nullableLooseStringFromJson) String? operationalMarkedByRole,@JsonKey(name: 'feedbackSubmitted') bool feedbackSubmitted
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salonId = null,Object? barberId = null,Object? customerId = null,Object? startAt = null,Object? endAt = null,Object? status = null,Object? barberName = freezed,Object? customerName = freezed,Object? serviceId = freezed,Object? serviceName = freezed,Object? notes = freezed,Object? reportYear = null,Object? reportMonth = null,Object? slotStepMinutes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? cancelledAt = freezed,Object? cancelledByRole = freezed,Object? cancelledByUserId = freezed,Object? rescheduledFromBookingId = freezed,Object? rescheduledToBookingId = freezed,Object? operationalState = null,Object? customerArrivedAt = freezed,Object? serviceStartedAt = freezed,Object? serviceCompletedAt = freezed,Object? noShowMarkedAt = freezed,Object? noShowParty = freezed,Object? operationalMarkedByUid = freezed,Object? operationalMarkedByRole = freezed,Object? feedbackSubmitted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,barberName: freezed == barberName ? _self.barberName : barberName // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reportYear: null == reportYear ? _self.reportYear : reportYear // ignore: cast_nullable_to_non_nullable
as int,reportMonth: null == reportMonth ? _self.reportMonth : reportMonth // ignore: cast_nullable_to_non_nullable
as int,slotStepMinutes: freezed == slotStepMinutes ? _self.slotStepMinutes : slotStepMinutes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledByRole: freezed == cancelledByRole ? _self.cancelledByRole : cancelledByRole // ignore: cast_nullable_to_non_nullable
as String?,cancelledByUserId: freezed == cancelledByUserId ? _self.cancelledByUserId : cancelledByUserId // ignore: cast_nullable_to_non_nullable
as String?,rescheduledFromBookingId: freezed == rescheduledFromBookingId ? _self.rescheduledFromBookingId : rescheduledFromBookingId // ignore: cast_nullable_to_non_nullable
as String?,rescheduledToBookingId: freezed == rescheduledToBookingId ? _self.rescheduledToBookingId : rescheduledToBookingId // ignore: cast_nullable_to_non_nullable
as String?,operationalState: null == operationalState ? _self.operationalState : operationalState // ignore: cast_nullable_to_non_nullable
as String,customerArrivedAt: freezed == customerArrivedAt ? _self.customerArrivedAt : customerArrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceStartedAt: freezed == serviceStartedAt ? _self.serviceStartedAt : serviceStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceCompletedAt: freezed == serviceCompletedAt ? _self.serviceCompletedAt : serviceCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,noShowMarkedAt: freezed == noShowMarkedAt ? _self.noShowMarkedAt : noShowMarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,noShowParty: freezed == noShowParty ? _self.noShowParty : noShowParty // ignore: cast_nullable_to_non_nullable
as String?,operationalMarkedByUid: freezed == operationalMarkedByUid ? _self.operationalMarkedByUid : operationalMarkedByUid // ignore: cast_nullable_to_non_nullable
as String?,operationalMarkedByRole: freezed == operationalMarkedByRole ? _self.operationalMarkedByRole : operationalMarkedByRole // ignore: cast_nullable_to_non_nullable
as String?,feedbackSubmitted: null == feedbackSubmitted ? _self.feedbackSubmitted : feedbackSubmitted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String barberId, @JsonKey(fromJson: looseStringFromJson)  String customerId, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime startAt, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime endAt, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? barberName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customerName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? notes, @JsonKey(fromJson: looseIntFromJson)  int reportYear, @JsonKey(fromJson: looseIntFromJson)  int reportMonth, @JsonKey(fromJson: _slotStepFromJson)  int? slotStepMinutes, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? cancelledAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByRole, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByUserId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledFromBookingId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledToBookingId, @JsonKey(fromJson: _operationalStateFromJson)  String operationalState, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? customerArrivedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceStartedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceCompletedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? noShowMarkedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? noShowParty, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByUid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByRole, @JsonKey(name: 'feedbackSubmitted')  bool feedbackSubmitted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.salonId,_that.barberId,_that.customerId,_that.startAt,_that.endAt,_that.status,_that.barberName,_that.customerName,_that.serviceId,_that.serviceName,_that.notes,_that.reportYear,_that.reportMonth,_that.slotStepMinutes,_that.createdAt,_that.updatedAt,_that.cancelledAt,_that.cancelledByRole,_that.cancelledByUserId,_that.rescheduledFromBookingId,_that.rescheduledToBookingId,_that.operationalState,_that.customerArrivedAt,_that.serviceStartedAt,_that.serviceCompletedAt,_that.noShowMarkedAt,_that.noShowParty,_that.operationalMarkedByUid,_that.operationalMarkedByRole,_that.feedbackSubmitted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String barberId, @JsonKey(fromJson: looseStringFromJson)  String customerId, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime startAt, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime endAt, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? barberName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customerName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? notes, @JsonKey(fromJson: looseIntFromJson)  int reportYear, @JsonKey(fromJson: looseIntFromJson)  int reportMonth, @JsonKey(fromJson: _slotStepFromJson)  int? slotStepMinutes, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? cancelledAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByRole, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByUserId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledFromBookingId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledToBookingId, @JsonKey(fromJson: _operationalStateFromJson)  String operationalState, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? customerArrivedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceStartedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceCompletedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? noShowMarkedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? noShowParty, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByUid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByRole, @JsonKey(name: 'feedbackSubmitted')  bool feedbackSubmitted)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.salonId,_that.barberId,_that.customerId,_that.startAt,_that.endAt,_that.status,_that.barberName,_that.customerName,_that.serviceId,_that.serviceName,_that.notes,_that.reportYear,_that.reportMonth,_that.slotStepMinutes,_that.createdAt,_that.updatedAt,_that.cancelledAt,_that.cancelledByRole,_that.cancelledByUserId,_that.rescheduledFromBookingId,_that.rescheduledToBookingId,_that.operationalState,_that.customerArrivedAt,_that.serviceStartedAt,_that.serviceCompletedAt,_that.noShowMarkedAt,_that.noShowParty,_that.operationalMarkedByUid,_that.operationalMarkedByRole,_that.feedbackSubmitted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String barberId, @JsonKey(fromJson: looseStringFromJson)  String customerId, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime startAt, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson)  DateTime endAt, @JsonKey(fromJson: _statusFromJson)  String status, @JsonKey(fromJson: nullableLooseStringFromJson)  String? barberName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customerName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? serviceName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? notes, @JsonKey(fromJson: looseIntFromJson)  int reportYear, @JsonKey(fromJson: looseIntFromJson)  int reportMonth, @JsonKey(fromJson: _slotStepFromJson)  int? slotStepMinutes, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? cancelledAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByRole, @JsonKey(fromJson: nullableLooseStringFromJson)  String? cancelledByUserId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledFromBookingId, @JsonKey(fromJson: nullableLooseStringFromJson)  String? rescheduledToBookingId, @JsonKey(fromJson: _operationalStateFromJson)  String operationalState, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? customerArrivedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceStartedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? serviceCompletedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? noShowMarkedAt, @JsonKey(fromJson: nullableLooseStringFromJson)  String? noShowParty, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByUid, @JsonKey(fromJson: nullableLooseStringFromJson)  String? operationalMarkedByRole, @JsonKey(name: 'feedbackSubmitted')  bool feedbackSubmitted)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.salonId,_that.barberId,_that.customerId,_that.startAt,_that.endAt,_that.status,_that.barberName,_that.customerName,_that.serviceId,_that.serviceName,_that.notes,_that.reportYear,_that.reportMonth,_that.slotStepMinutes,_that.createdAt,_that.updatedAt,_that.cancelledAt,_that.cancelledByRole,_that.cancelledByUserId,_that.rescheduledFromBookingId,_that.rescheduledToBookingId,_that.operationalState,_that.customerArrivedAt,_that.serviceStartedAt,_that.serviceCompletedAt,_that.noShowMarkedAt,_that.noShowParty,_that.operationalMarkedByUid,_that.operationalMarkedByRole,_that.feedbackSubmitted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking extends Booking {
  const _Booking({@JsonKey(fromJson: looseStringFromJson) required this.id, @JsonKey(fromJson: looseStringFromJson) required this.salonId, @JsonKey(fromJson: looseStringFromJson) required this.barberId, @JsonKey(fromJson: looseStringFromJson) required this.customerId, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) required this.startAt, @JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) required this.endAt, @JsonKey(fromJson: _statusFromJson) required this.status, @JsonKey(fromJson: nullableLooseStringFromJson) this.barberName, @JsonKey(fromJson: nullableLooseStringFromJson) this.customerName, @JsonKey(fromJson: nullableLooseStringFromJson) this.serviceId, @JsonKey(fromJson: nullableLooseStringFromJson) this.serviceName, @JsonKey(fromJson: nullableLooseStringFromJson) this.notes, @JsonKey(fromJson: looseIntFromJson) this.reportYear = 0, @JsonKey(fromJson: looseIntFromJson) this.reportMonth = 0, @JsonKey(fromJson: _slotStepFromJson) this.slotStepMinutes, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.updatedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.cancelledAt, @JsonKey(fromJson: nullableLooseStringFromJson) this.cancelledByRole, @JsonKey(fromJson: nullableLooseStringFromJson) this.cancelledByUserId, @JsonKey(fromJson: nullableLooseStringFromJson) this.rescheduledFromBookingId, @JsonKey(fromJson: nullableLooseStringFromJson) this.rescheduledToBookingId, @JsonKey(fromJson: _operationalStateFromJson) this.operationalState = BookingOperationalStates.waiting, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.customerArrivedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.serviceStartedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.serviceCompletedAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.noShowMarkedAt, @JsonKey(fromJson: nullableLooseStringFromJson) this.noShowParty, @JsonKey(fromJson: nullableLooseStringFromJson) this.operationalMarkedByUid, @JsonKey(fromJson: nullableLooseStringFromJson) this.operationalMarkedByRole, @JsonKey(name: 'feedbackSubmitted') this.feedbackSubmitted = false}): super._();
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override@JsonKey(fromJson: looseStringFromJson) final  String id;
@override@JsonKey(fromJson: looseStringFromJson) final  String salonId;
@override@JsonKey(fromJson: looseStringFromJson) final  String barberId;
@override@JsonKey(fromJson: looseStringFromJson) final  String customerId;
@override@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) final  DateTime startAt;
@override@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) final  DateTime endAt;
@override@JsonKey(fromJson: _statusFromJson) final  String status;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? barberName;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? customerName;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? serviceId;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? serviceName;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? notes;
@override@JsonKey(fromJson: looseIntFromJson) final  int reportYear;
@override@JsonKey(fromJson: looseIntFromJson) final  int reportMonth;
@override@JsonKey(fromJson: _slotStepFromJson) final  int? slotStepMinutes;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? updatedAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? cancelledAt;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? cancelledByRole;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? cancelledByUserId;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? rescheduledFromBookingId;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? rescheduledToBookingId;
@override@JsonKey(fromJson: _operationalStateFromJson) final  String operationalState;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? customerArrivedAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? serviceStartedAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? serviceCompletedAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? noShowMarkedAt;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? noShowParty;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? operationalMarkedByUid;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? operationalMarkedByRole;
/// Set when the customer submits post-visit feedback via [submitCustomerFeedback].
@override@JsonKey(name: 'feedbackSubmitted') final  bool feedbackSubmitted;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.barberName, barberName) || other.barberName == barberName)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reportYear, reportYear) || other.reportYear == reportYear)&&(identical(other.reportMonth, reportMonth) || other.reportMonth == reportMonth)&&(identical(other.slotStepMinutes, slotStepMinutes) || other.slotStepMinutes == slotStepMinutes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancelledByRole, cancelledByRole) || other.cancelledByRole == cancelledByRole)&&(identical(other.cancelledByUserId, cancelledByUserId) || other.cancelledByUserId == cancelledByUserId)&&(identical(other.rescheduledFromBookingId, rescheduledFromBookingId) || other.rescheduledFromBookingId == rescheduledFromBookingId)&&(identical(other.rescheduledToBookingId, rescheduledToBookingId) || other.rescheduledToBookingId == rescheduledToBookingId)&&(identical(other.operationalState, operationalState) || other.operationalState == operationalState)&&(identical(other.customerArrivedAt, customerArrivedAt) || other.customerArrivedAt == customerArrivedAt)&&(identical(other.serviceStartedAt, serviceStartedAt) || other.serviceStartedAt == serviceStartedAt)&&(identical(other.serviceCompletedAt, serviceCompletedAt) || other.serviceCompletedAt == serviceCompletedAt)&&(identical(other.noShowMarkedAt, noShowMarkedAt) || other.noShowMarkedAt == noShowMarkedAt)&&(identical(other.noShowParty, noShowParty) || other.noShowParty == noShowParty)&&(identical(other.operationalMarkedByUid, operationalMarkedByUid) || other.operationalMarkedByUid == operationalMarkedByUid)&&(identical(other.operationalMarkedByRole, operationalMarkedByRole) || other.operationalMarkedByRole == operationalMarkedByRole)&&(identical(other.feedbackSubmitted, feedbackSubmitted) || other.feedbackSubmitted == feedbackSubmitted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,barberId,customerId,startAt,endAt,status,barberName,customerName,serviceId,serviceName,notes,reportYear,reportMonth,slotStepMinutes,createdAt,updatedAt,cancelledAt,cancelledByRole,cancelledByUserId,rescheduledFromBookingId,rescheduledToBookingId,operationalState,customerArrivedAt,serviceStartedAt,serviceCompletedAt,noShowMarkedAt,noShowParty,operationalMarkedByUid,operationalMarkedByRole,feedbackSubmitted]);

@override
String toString() {
  return 'Booking(id: $id, salonId: $salonId, barberId: $barberId, customerId: $customerId, startAt: $startAt, endAt: $endAt, status: $status, barberName: $barberName, customerName: $customerName, serviceId: $serviceId, serviceName: $serviceName, notes: $notes, reportYear: $reportYear, reportMonth: $reportMonth, slotStepMinutes: $slotStepMinutes, createdAt: $createdAt, updatedAt: $updatedAt, cancelledAt: $cancelledAt, cancelledByRole: $cancelledByRole, cancelledByUserId: $cancelledByUserId, rescheduledFromBookingId: $rescheduledFromBookingId, rescheduledToBookingId: $rescheduledToBookingId, operationalState: $operationalState, customerArrivedAt: $customerArrivedAt, serviceStartedAt: $serviceStartedAt, serviceCompletedAt: $serviceCompletedAt, noShowMarkedAt: $noShowMarkedAt, noShowParty: $noShowParty, operationalMarkedByUid: $operationalMarkedByUid, operationalMarkedByRole: $operationalMarkedByRole, feedbackSubmitted: $feedbackSubmitted)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String barberId,@JsonKey(fromJson: looseStringFromJson) String customerId,@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime startAt,@JsonKey(fromJson: firestoreDateTimeFromJson, toJson: firestoreDateTimeToJson) DateTime endAt,@JsonKey(fromJson: _statusFromJson) String status,@JsonKey(fromJson: nullableLooseStringFromJson) String? barberName,@JsonKey(fromJson: nullableLooseStringFromJson) String? customerName,@JsonKey(fromJson: nullableLooseStringFromJson) String? serviceId,@JsonKey(fromJson: nullableLooseStringFromJson) String? serviceName,@JsonKey(fromJson: nullableLooseStringFromJson) String? notes,@JsonKey(fromJson: looseIntFromJson) int reportYear,@JsonKey(fromJson: looseIntFromJson) int reportMonth,@JsonKey(fromJson: _slotStepFromJson) int? slotStepMinutes,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? cancelledAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByRole,@JsonKey(fromJson: nullableLooseStringFromJson) String? cancelledByUserId,@JsonKey(fromJson: nullableLooseStringFromJson) String? rescheduledFromBookingId,@JsonKey(fromJson: nullableLooseStringFromJson) String? rescheduledToBookingId,@JsonKey(fromJson: _operationalStateFromJson) String operationalState,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? customerArrivedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? serviceStartedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? serviceCompletedAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? noShowMarkedAt,@JsonKey(fromJson: nullableLooseStringFromJson) String? noShowParty,@JsonKey(fromJson: nullableLooseStringFromJson) String? operationalMarkedByUid,@JsonKey(fromJson: nullableLooseStringFromJson) String? operationalMarkedByRole,@JsonKey(name: 'feedbackSubmitted') bool feedbackSubmitted
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salonId = null,Object? barberId = null,Object? customerId = null,Object? startAt = null,Object? endAt = null,Object? status = null,Object? barberName = freezed,Object? customerName = freezed,Object? serviceId = freezed,Object? serviceName = freezed,Object? notes = freezed,Object? reportYear = null,Object? reportMonth = null,Object? slotStepMinutes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? cancelledAt = freezed,Object? cancelledByRole = freezed,Object? cancelledByUserId = freezed,Object? rescheduledFromBookingId = freezed,Object? rescheduledToBookingId = freezed,Object? operationalState = null,Object? customerArrivedAt = freezed,Object? serviceStartedAt = freezed,Object? serviceCompletedAt = freezed,Object? noShowMarkedAt = freezed,Object? noShowParty = freezed,Object? operationalMarkedByUid = freezed,Object? operationalMarkedByRole = freezed,Object? feedbackSubmitted = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,barberName: freezed == barberName ? _self.barberName : barberName // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,serviceName: freezed == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reportYear: null == reportYear ? _self.reportYear : reportYear // ignore: cast_nullable_to_non_nullable
as int,reportMonth: null == reportMonth ? _self.reportMonth : reportMonth // ignore: cast_nullable_to_non_nullable
as int,slotStepMinutes: freezed == slotStepMinutes ? _self.slotStepMinutes : slotStepMinutes // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledByRole: freezed == cancelledByRole ? _self.cancelledByRole : cancelledByRole // ignore: cast_nullable_to_non_nullable
as String?,cancelledByUserId: freezed == cancelledByUserId ? _self.cancelledByUserId : cancelledByUserId // ignore: cast_nullable_to_non_nullable
as String?,rescheduledFromBookingId: freezed == rescheduledFromBookingId ? _self.rescheduledFromBookingId : rescheduledFromBookingId // ignore: cast_nullable_to_non_nullable
as String?,rescheduledToBookingId: freezed == rescheduledToBookingId ? _self.rescheduledToBookingId : rescheduledToBookingId // ignore: cast_nullable_to_non_nullable
as String?,operationalState: null == operationalState ? _self.operationalState : operationalState // ignore: cast_nullable_to_non_nullable
as String,customerArrivedAt: freezed == customerArrivedAt ? _self.customerArrivedAt : customerArrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceStartedAt: freezed == serviceStartedAt ? _self.serviceStartedAt : serviceStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceCompletedAt: freezed == serviceCompletedAt ? _self.serviceCompletedAt : serviceCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,noShowMarkedAt: freezed == noShowMarkedAt ? _self.noShowMarkedAt : noShowMarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,noShowParty: freezed == noShowParty ? _self.noShowParty : noShowParty // ignore: cast_nullable_to_non_nullable
as String?,operationalMarkedByUid: freezed == operationalMarkedByUid ? _self.operationalMarkedByUid : operationalMarkedByUid // ignore: cast_nullable_to_non_nullable
as String?,operationalMarkedByRole: freezed == operationalMarkedByRole ? _self.operationalMarkedByRole : operationalMarkedByRole // ignore: cast_nullable_to_non_nullable
as String?,feedbackSubmitted: null == feedbackSubmitted ? _self.feedbackSubmitted : feedbackSubmitted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
