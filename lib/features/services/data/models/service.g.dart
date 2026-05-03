// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalonService _$SalonServiceFromJson(Map<String, dynamic> json) =>
    _SalonService(
      id: looseStringFromJson(json['id']),
      salonId: looseStringFromJson(json['salonId']),
      name: looseStringFromJson(json['name']),
      serviceName: json['serviceName'] == null
          ? ''
          : looseStringFromJson(json['serviceName']),
      nameAr: json['nameAr'] == null ? '' : looseStringFromJson(json['nameAr']),
      durationMinutes: looseIntFromJson(json['durationMinutes']),
      price: looseDoubleFromJson(json['price']),
      description: nullableLooseStringFromJson(json['description']),
      categoryKey: nullableLooseStringFromJson(json['categoryKey']),
      categoryLabel: nullableLooseStringFromJson(json['categoryLabel']),
      customCategoryName: nullableLooseStringFromJson(
        json['customCategoryName'],
      ),
      category: nullableLooseStringFromJson(json['category']),
      iconKey: nullableLooseStringFromJson(json['iconKey']),
      imageUrl: nullableLooseStringFromJson(json['imageUrl']),
      timesUsed: nullableLooseIntFromJson(json['timesUsed']),
      totalRevenue: nullableLooseDoubleFromJson(json['totalRevenue']),
      isActive: json['isActive'] == null
          ? true
          : trueBoolFromJson(json['isActive']),
      bookable: json['bookable'] == null
          ? true
          : trueBoolFromJson(json['bookable']),
      createdAt: nullableFirestoreDateTimeFromJson(json['createdAt']),
      updatedAt: nullableFirestoreDateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$SalonServiceToJson(_SalonService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'salonId': instance.salonId,
      'name': instance.name,
      'serviceName': instance.serviceName,
      'nameAr': instance.nameAr,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'description': instance.description,
      'categoryKey': instance.categoryKey,
      'categoryLabel': instance.categoryLabel,
      'customCategoryName': instance.customCategoryName,
      'category': instance.category,
      'iconKey': instance.iconKey,
      'imageUrl': instance.imageUrl,
      'timesUsed': instance.timesUsed,
      'totalRevenue': instance.totalRevenue,
      'isActive': instance.isActive,
      'bookable': instance.bookable,
      'createdAt': nullableFirestoreDateTimeToJson(instance.createdAt),
      'updatedAt': nullableFirestoreDateTimeToJson(instance.updatedAt),
    };
