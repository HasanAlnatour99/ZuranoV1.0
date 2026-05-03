// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalonService {

@JsonKey(fromJson: looseStringFromJson) String get id;@JsonKey(fromJson: looseStringFromJson) String get salonId;/// English catalogue name (sorting, staff POS, default customer LTR).
@JsonKey(fromJson: looseStringFromJson) String get name;@JsonKey(fromJson: looseStringFromJson) String get serviceName;/// Arabic display name (customer RTL; optional on legacy documents until edited).
@JsonKey(fromJson: looseStringFromJson) String get nameAr;@JsonKey(fromJson: looseIntFromJson) int get durationMinutes;@JsonKey(fromJson: looseDoubleFromJson) double get price;@JsonKey(fromJson: nullableLooseStringFromJson) String? get description;/// System category key, e.g. [ServiceCategoryKeys.hair], [ServiceCategoryKeys.other].
@JsonKey(fromJson: nullableLooseStringFromJson) String? get categoryKey;/// Display label at time of save (locale-specific).
@JsonKey(fromJson: nullableLooseStringFromJson) String? get categoryLabel;/// When [categoryKey] is [ServiceCategoryKeys.other], the owner-defined subgroup.
@JsonKey(fromJson: nullableLooseStringFromJson) String? get customCategoryName;/// Legacy display-only category (pre–categoryKey). Kept for backward compatibility.
@JsonKey(fromJson: nullableLooseStringFromJson) String? get category;/// Optional override key for service tile icon (same vocabulary as [categoryKey]).
@JsonKey(fromJson: nullableLooseStringFromJson) String? get iconKey;/// Optional marketing image URL (owner catalog / future customer UI).
@JsonKey(fromJson: nullableLooseStringFromJson) String? get imageUrl;/// Optional analytics: how many times sold or booked (when backend writes it).
@JsonKey(fromJson: nullableLooseIntFromJson) int? get timesUsed;/// Optional lifetime or period revenue attributed to this service.
@JsonKey(fromJson: nullableLooseDoubleFromJson) double? get totalRevenue;@JsonKey(fromJson: trueBoolFromJson) bool get isActive;@JsonKey(fromJson: trueBoolFromJson) bool get bookable;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get createdAt;@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? get updatedAt;
/// Create a copy of SalonService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalonServiceCopyWith<SalonService> get copyWith => _$SalonServiceCopyWithImpl<SalonService>(this as SalonService, _$identity);

  /// Serializes this SalonService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalonService&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.name, name) || other.name == name)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.categoryLabel, categoryLabel) || other.categoryLabel == categoryLabel)&&(identical(other.customCategoryName, customCategoryName) || other.customCategoryName == customCategoryName)&&(identical(other.category, category) || other.category == category)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.bookable, bookable) || other.bookable == bookable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,name,serviceName,nameAr,durationMinutes,price,description,categoryKey,categoryLabel,customCategoryName,category,iconKey,imageUrl,timesUsed,totalRevenue,isActive,bookable,createdAt,updatedAt]);

@override
String toString() {
  return 'SalonService(id: $id, salonId: $salonId, name: $name, serviceName: $serviceName, nameAr: $nameAr, durationMinutes: $durationMinutes, price: $price, description: $description, categoryKey: $categoryKey, categoryLabel: $categoryLabel, customCategoryName: $customCategoryName, category: $category, iconKey: $iconKey, imageUrl: $imageUrl, timesUsed: $timesUsed, totalRevenue: $totalRevenue, isActive: $isActive, bookable: $bookable, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SalonServiceCopyWith<$Res>  {
  factory $SalonServiceCopyWith(SalonService value, $Res Function(SalonService) _then) = _$SalonServiceCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String name,@JsonKey(fromJson: looseStringFromJson) String serviceName,@JsonKey(fromJson: looseStringFromJson) String nameAr,@JsonKey(fromJson: looseIntFromJson) int durationMinutes,@JsonKey(fromJson: looseDoubleFromJson) double price,@JsonKey(fromJson: nullableLooseStringFromJson) String? description,@JsonKey(fromJson: nullableLooseStringFromJson) String? categoryKey,@JsonKey(fromJson: nullableLooseStringFromJson) String? categoryLabel,@JsonKey(fromJson: nullableLooseStringFromJson) String? customCategoryName,@JsonKey(fromJson: nullableLooseStringFromJson) String? category,@JsonKey(fromJson: nullableLooseStringFromJson) String? iconKey,@JsonKey(fromJson: nullableLooseStringFromJson) String? imageUrl,@JsonKey(fromJson: nullableLooseIntFromJson) int? timesUsed,@JsonKey(fromJson: nullableLooseDoubleFromJson) double? totalRevenue,@JsonKey(fromJson: trueBoolFromJson) bool isActive,@JsonKey(fromJson: trueBoolFromJson) bool bookable,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt
});




}
/// @nodoc
class _$SalonServiceCopyWithImpl<$Res>
    implements $SalonServiceCopyWith<$Res> {
  _$SalonServiceCopyWithImpl(this._self, this._then);

  final SalonService _self;
  final $Res Function(SalonService) _then;

/// Create a copy of SalonService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salonId = null,Object? name = null,Object? serviceName = null,Object? nameAr = null,Object? durationMinutes = null,Object? price = null,Object? description = freezed,Object? categoryKey = freezed,Object? categoryLabel = freezed,Object? customCategoryName = freezed,Object? category = freezed,Object? iconKey = freezed,Object? imageUrl = freezed,Object? timesUsed = freezed,Object? totalRevenue = freezed,Object? isActive = null,Object? bookable = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryKey: freezed == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String?,categoryLabel: freezed == categoryLabel ? _self.categoryLabel : categoryLabel // ignore: cast_nullable_to_non_nullable
as String?,customCategoryName: freezed == customCategoryName ? _self.customCategoryName : customCategoryName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,timesUsed: freezed == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int?,totalRevenue: freezed == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,bookable: null == bookable ? _self.bookable : bookable // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalonService].
extension SalonServicePatterns on SalonService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalonService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalonService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalonService value)  $default,){
final _that = this;
switch (_that) {
case _SalonService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalonService value)?  $default,){
final _that = this;
switch (_that) {
case _SalonService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String serviceName, @JsonKey(fromJson: looseStringFromJson)  String nameAr, @JsonKey(fromJson: looseIntFromJson)  int durationMinutes, @JsonKey(fromJson: looseDoubleFromJson)  double price, @JsonKey(fromJson: nullableLooseStringFromJson)  String? description, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryLabel, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customCategoryName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? category, @JsonKey(fromJson: nullableLooseStringFromJson)  String? iconKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? imageUrl, @JsonKey(fromJson: nullableLooseIntFromJson)  int? timesUsed, @JsonKey(fromJson: nullableLooseDoubleFromJson)  double? totalRevenue, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: trueBoolFromJson)  bool bookable, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalonService() when $default != null:
return $default(_that.id,_that.salonId,_that.name,_that.serviceName,_that.nameAr,_that.durationMinutes,_that.price,_that.description,_that.categoryKey,_that.categoryLabel,_that.customCategoryName,_that.category,_that.iconKey,_that.imageUrl,_that.timesUsed,_that.totalRevenue,_that.isActive,_that.bookable,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String serviceName, @JsonKey(fromJson: looseStringFromJson)  String nameAr, @JsonKey(fromJson: looseIntFromJson)  int durationMinutes, @JsonKey(fromJson: looseDoubleFromJson)  double price, @JsonKey(fromJson: nullableLooseStringFromJson)  String? description, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryLabel, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customCategoryName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? category, @JsonKey(fromJson: nullableLooseStringFromJson)  String? iconKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? imageUrl, @JsonKey(fromJson: nullableLooseIntFromJson)  int? timesUsed, @JsonKey(fromJson: nullableLooseDoubleFromJson)  double? totalRevenue, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: trueBoolFromJson)  bool bookable, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SalonService():
return $default(_that.id,_that.salonId,_that.name,_that.serviceName,_that.nameAr,_that.durationMinutes,_that.price,_that.description,_that.categoryKey,_that.categoryLabel,_that.customCategoryName,_that.category,_that.iconKey,_that.imageUrl,_that.timesUsed,_that.totalRevenue,_that.isActive,_that.bookable,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: looseStringFromJson)  String id, @JsonKey(fromJson: looseStringFromJson)  String salonId, @JsonKey(fromJson: looseStringFromJson)  String name, @JsonKey(fromJson: looseStringFromJson)  String serviceName, @JsonKey(fromJson: looseStringFromJson)  String nameAr, @JsonKey(fromJson: looseIntFromJson)  int durationMinutes, @JsonKey(fromJson: looseDoubleFromJson)  double price, @JsonKey(fromJson: nullableLooseStringFromJson)  String? description, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? categoryLabel, @JsonKey(fromJson: nullableLooseStringFromJson)  String? customCategoryName, @JsonKey(fromJson: nullableLooseStringFromJson)  String? category, @JsonKey(fromJson: nullableLooseStringFromJson)  String? iconKey, @JsonKey(fromJson: nullableLooseStringFromJson)  String? imageUrl, @JsonKey(fromJson: nullableLooseIntFromJson)  int? timesUsed, @JsonKey(fromJson: nullableLooseDoubleFromJson)  double? totalRevenue, @JsonKey(fromJson: trueBoolFromJson)  bool isActive, @JsonKey(fromJson: trueBoolFromJson)  bool bookable, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson)  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SalonService() when $default != null:
return $default(_that.id,_that.salonId,_that.name,_that.serviceName,_that.nameAr,_that.durationMinutes,_that.price,_that.description,_that.categoryKey,_that.categoryLabel,_that.customCategoryName,_that.category,_that.iconKey,_that.imageUrl,_that.timesUsed,_that.totalRevenue,_that.isActive,_that.bookable,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalonService extends SalonService {
  const _SalonService({@JsonKey(fromJson: looseStringFromJson) required this.id, @JsonKey(fromJson: looseStringFromJson) required this.salonId, @JsonKey(fromJson: looseStringFromJson) required this.name, @JsonKey(fromJson: looseStringFromJson) this.serviceName = '', @JsonKey(fromJson: looseStringFromJson) this.nameAr = '', @JsonKey(fromJson: looseIntFromJson) required this.durationMinutes, @JsonKey(fromJson: looseDoubleFromJson) required this.price, @JsonKey(fromJson: nullableLooseStringFromJson) this.description, @JsonKey(fromJson: nullableLooseStringFromJson) this.categoryKey, @JsonKey(fromJson: nullableLooseStringFromJson) this.categoryLabel, @JsonKey(fromJson: nullableLooseStringFromJson) this.customCategoryName, @JsonKey(fromJson: nullableLooseStringFromJson) this.category, @JsonKey(fromJson: nullableLooseStringFromJson) this.iconKey, @JsonKey(fromJson: nullableLooseStringFromJson) this.imageUrl, @JsonKey(fromJson: nullableLooseIntFromJson) this.timesUsed, @JsonKey(fromJson: nullableLooseDoubleFromJson) this.totalRevenue, @JsonKey(fromJson: trueBoolFromJson) this.isActive = true, @JsonKey(fromJson: trueBoolFromJson) this.bookable = true, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.createdAt, @JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) this.updatedAt}): super._();
  factory _SalonService.fromJson(Map<String, dynamic> json) => _$SalonServiceFromJson(json);

@override@JsonKey(fromJson: looseStringFromJson) final  String id;
@override@JsonKey(fromJson: looseStringFromJson) final  String salonId;
/// English catalogue name (sorting, staff POS, default customer LTR).
@override@JsonKey(fromJson: looseStringFromJson) final  String name;
@override@JsonKey(fromJson: looseStringFromJson) final  String serviceName;
/// Arabic display name (customer RTL; optional on legacy documents until edited).
@override@JsonKey(fromJson: looseStringFromJson) final  String nameAr;
@override@JsonKey(fromJson: looseIntFromJson) final  int durationMinutes;
@override@JsonKey(fromJson: looseDoubleFromJson) final  double price;
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? description;
/// System category key, e.g. [ServiceCategoryKeys.hair], [ServiceCategoryKeys.other].
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? categoryKey;
/// Display label at time of save (locale-specific).
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? categoryLabel;
/// When [categoryKey] is [ServiceCategoryKeys.other], the owner-defined subgroup.
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? customCategoryName;
/// Legacy display-only category (pre–categoryKey). Kept for backward compatibility.
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? category;
/// Optional override key for service tile icon (same vocabulary as [categoryKey]).
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? iconKey;
/// Optional marketing image URL (owner catalog / future customer UI).
@override@JsonKey(fromJson: nullableLooseStringFromJson) final  String? imageUrl;
/// Optional analytics: how many times sold or booked (when backend writes it).
@override@JsonKey(fromJson: nullableLooseIntFromJson) final  int? timesUsed;
/// Optional lifetime or period revenue attributed to this service.
@override@JsonKey(fromJson: nullableLooseDoubleFromJson) final  double? totalRevenue;
@override@JsonKey(fromJson: trueBoolFromJson) final  bool isActive;
@override@JsonKey(fromJson: trueBoolFromJson) final  bool bookable;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) final  DateTime? updatedAt;

/// Create a copy of SalonService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalonServiceCopyWith<_SalonService> get copyWith => __$SalonServiceCopyWithImpl<_SalonService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalonServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalonService&&(identical(other.id, id) || other.id == id)&&(identical(other.salonId, salonId) || other.salonId == salonId)&&(identical(other.name, name) || other.name == name)&&(identical(other.serviceName, serviceName) || other.serviceName == serviceName)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.categoryLabel, categoryLabel) || other.categoryLabel == categoryLabel)&&(identical(other.customCategoryName, customCategoryName) || other.customCategoryName == customCategoryName)&&(identical(other.category, category) || other.category == category)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.timesUsed, timesUsed) || other.timesUsed == timesUsed)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.bookable, bookable) || other.bookable == bookable)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,salonId,name,serviceName,nameAr,durationMinutes,price,description,categoryKey,categoryLabel,customCategoryName,category,iconKey,imageUrl,timesUsed,totalRevenue,isActive,bookable,createdAt,updatedAt]);

@override
String toString() {
  return 'SalonService(id: $id, salonId: $salonId, name: $name, serviceName: $serviceName, nameAr: $nameAr, durationMinutes: $durationMinutes, price: $price, description: $description, categoryKey: $categoryKey, categoryLabel: $categoryLabel, customCategoryName: $customCategoryName, category: $category, iconKey: $iconKey, imageUrl: $imageUrl, timesUsed: $timesUsed, totalRevenue: $totalRevenue, isActive: $isActive, bookable: $bookable, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SalonServiceCopyWith<$Res> implements $SalonServiceCopyWith<$Res> {
  factory _$SalonServiceCopyWith(_SalonService value, $Res Function(_SalonService) _then) = __$SalonServiceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: looseStringFromJson) String id,@JsonKey(fromJson: looseStringFromJson) String salonId,@JsonKey(fromJson: looseStringFromJson) String name,@JsonKey(fromJson: looseStringFromJson) String serviceName,@JsonKey(fromJson: looseStringFromJson) String nameAr,@JsonKey(fromJson: looseIntFromJson) int durationMinutes,@JsonKey(fromJson: looseDoubleFromJson) double price,@JsonKey(fromJson: nullableLooseStringFromJson) String? description,@JsonKey(fromJson: nullableLooseStringFromJson) String? categoryKey,@JsonKey(fromJson: nullableLooseStringFromJson) String? categoryLabel,@JsonKey(fromJson: nullableLooseStringFromJson) String? customCategoryName,@JsonKey(fromJson: nullableLooseStringFromJson) String? category,@JsonKey(fromJson: nullableLooseStringFromJson) String? iconKey,@JsonKey(fromJson: nullableLooseStringFromJson) String? imageUrl,@JsonKey(fromJson: nullableLooseIntFromJson) int? timesUsed,@JsonKey(fromJson: nullableLooseDoubleFromJson) double? totalRevenue,@JsonKey(fromJson: trueBoolFromJson) bool isActive,@JsonKey(fromJson: trueBoolFromJson) bool bookable,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? createdAt,@JsonKey(fromJson: nullableFirestoreDateTimeFromJson, toJson: nullableFirestoreDateTimeToJson) DateTime? updatedAt
});




}
/// @nodoc
class __$SalonServiceCopyWithImpl<$Res>
    implements _$SalonServiceCopyWith<$Res> {
  __$SalonServiceCopyWithImpl(this._self, this._then);

  final _SalonService _self;
  final $Res Function(_SalonService) _then;

/// Create a copy of SalonService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salonId = null,Object? name = null,Object? serviceName = null,Object? nameAr = null,Object? durationMinutes = null,Object? price = null,Object? description = freezed,Object? categoryKey = freezed,Object? categoryLabel = freezed,Object? customCategoryName = freezed,Object? category = freezed,Object? iconKey = freezed,Object? imageUrl = freezed,Object? timesUsed = freezed,Object? totalRevenue = freezed,Object? isActive = null,Object? bookable = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SalonService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,salonId: null == salonId ? _self.salonId : salonId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,serviceName: null == serviceName ? _self.serviceName : serviceName // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryKey: freezed == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String?,categoryLabel: freezed == categoryLabel ? _self.categoryLabel : categoryLabel // ignore: cast_nullable_to_non_nullable
as String?,customCategoryName: freezed == customCategoryName ? _self.customCategoryName : customCategoryName // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,timesUsed: freezed == timesUsed ? _self.timesUsed : timesUsed // ignore: cast_nullable_to_non_nullable
as int?,totalRevenue: freezed == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,bookable: null == bookable ? _self.bookable : bookable // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
