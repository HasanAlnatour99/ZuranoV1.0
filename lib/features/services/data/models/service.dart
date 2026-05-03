import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../service_category_catalog.dart';

part 'service.freezed.dart';
part 'service.g.dart';

@freezed
abstract class SalonService with _$SalonService {
  const SalonService._();

  const factory SalonService({
    @JsonKey(fromJson: looseStringFromJson) required String id,
    @JsonKey(fromJson: looseStringFromJson) required String salonId,

    /// English catalogue name (sorting, staff POS, default customer LTR).
    @JsonKey(fromJson: looseStringFromJson) required String name,
    @Default('') @JsonKey(fromJson: looseStringFromJson) String serviceName,

    /// Arabic display name (customer RTL; optional on legacy documents until edited).
    @Default('') @JsonKey(fromJson: looseStringFromJson) String nameAr,
    @JsonKey(fromJson: looseIntFromJson) required int durationMinutes,
    @JsonKey(fromJson: looseDoubleFromJson) required double price,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? description,

    /// System category key, e.g. [ServiceCategoryKeys.hair], [ServiceCategoryKeys.other].
    @JsonKey(fromJson: nullableLooseStringFromJson) String? categoryKey,

    /// Display label at time of save (locale-specific).
    @JsonKey(fromJson: nullableLooseStringFromJson) String? categoryLabel,

    /// When [categoryKey] is [ServiceCategoryKeys.other], the owner-defined subgroup.
    @JsonKey(fromJson: nullableLooseStringFromJson) String? customCategoryName,

    /// Legacy display-only category (pre–categoryKey). Kept for backward compatibility.
    @JsonKey(fromJson: nullableLooseStringFromJson) String? category,

    /// Optional override key for service tile icon (same vocabulary as [categoryKey]).
    @JsonKey(fromJson: nullableLooseStringFromJson) String? iconKey,

    /// Optional marketing image URL (owner catalog / future customer UI).
    @JsonKey(fromJson: nullableLooseStringFromJson) String? imageUrl,

    /// Optional analytics: how many times sold or booked (when backend writes it).
    @JsonKey(fromJson: nullableLooseIntFromJson) int? timesUsed,

    /// Optional lifetime or period revenue attributed to this service.
    @JsonKey(fromJson: nullableLooseDoubleFromJson) double? totalRevenue,
    @Default(true) @JsonKey(fromJson: trueBoolFromJson) bool isActive,
    @Default(true) @JsonKey(fromJson: trueBoolFromJson) bool bookable,
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
  }) = _SalonService;

  factory SalonService.fromJson(Map<String, dynamic> json) =>
      _$SalonServiceFromJson(_normalizedSalonServiceJson(json));

  /// Pass `Localizations.localeOf(context).languageCode` (e.g. `ar`, `en`).
  String localizedTitleForLanguageCode(String languageCode) {
    if (languageCode == 'ar') {
      final ar = nameAr.trim();
      if (ar.isNotEmpty) return ar;
    }
    final en = serviceName.trim().isNotEmpty ? serviceName.trim() : name;
    return en;
  }
}

Map<String, dynamic> _normalizedSalonServiceJson(Map<String, dynamic> json) {
  final name = (FirestoreSerializers.string(json['name']) ?? '').trim();
  final normalized = Map<String, dynamic>.from(json);
  normalized['name'] = name;
  normalized['serviceName'] =
      FirestoreSerializers.string(json['serviceName'])?.trim().isNotEmpty ==
          true
      ? FirestoreSerializers.string(json['serviceName'])!.trim()
      : name;

  normalized['nameAr'] = (FirestoreSerializers.string(json['nameAr']) ?? '')
      .trim();

  var categoryKey = FirestoreSerializers.string(json['categoryKey'])?.trim();
  var categoryLabel = FirestoreSerializers.string(
    json['categoryLabel'],
  )?.trim();
  var customCategoryName = FirestoreSerializers.string(
    json['customCategoryName'],
  )?.trim();
  final legacyCategory = FirestoreSerializers.string(json['category'])?.trim();

  if (categoryKey == null || categoryKey.isEmpty) {
    final migrated = ServiceCategoryKeys.migrateLegacyCategoryLabelToKey(
      legacyCategory,
    );
    if (migrated != null) {
      categoryKey = migrated;
      categoryLabel ??= ServiceCategoryKeys.defaultEnglishLabelForKey(migrated);
    } else if (legacyCategory != null && legacyCategory.isNotEmpty) {
      categoryKey = ServiceCategoryKeys.other;
      customCategoryName ??= legacyCategory.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      categoryLabel ??= 'Other';
    }
  }

  if (categoryKey != null && categoryKey.isNotEmpty) {
    normalized['categoryKey'] = categoryKey;
  }
  if (categoryLabel != null && categoryLabel.isNotEmpty) {
    normalized['categoryLabel'] = categoryLabel;
  }
  if (customCategoryName != null && customCategoryName.isNotEmpty) {
    normalized['customCategoryName'] = customCategoryName;
  }

  final displayLine = _displayCategoryForLegacyField(
    categoryKey: categoryKey,
    categoryLabel: categoryLabel,
    customCategoryName: customCategoryName,
    legacyCategory: legacyCategory,
  );
  if (displayLine != null && displayLine.isNotEmpty) {
    normalized['category'] = displayLine;
  }

  final iconKey = FirestoreSerializers.string(json['iconKey'])?.trim();
  if (iconKey != null && iconKey.isNotEmpty) {
    normalized['iconKey'] = iconKey;
  }

  return normalized;
}

String? _displayCategoryForLegacyField({
  required String? categoryKey,
  required String? categoryLabel,
  required String? customCategoryName,
  required String? legacyCategory,
}) {
  final key = categoryKey?.trim();
  if (key == null || key.isEmpty) {
    return legacyCategory;
  }
  if (key == ServiceCategoryKeys.other) {
    final custom = customCategoryName?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return categoryLabel?.trim().isNotEmpty == true
        ? categoryLabel!.trim()
        : 'Other';
  }
  if (categoryLabel != null && categoryLabel.isNotEmpty) {
    return categoryLabel;
  }
  return legacyCategory;
}
