import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/booking/availability_schedule.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../../core/utils/currency_for_country.dart';
import '../../../onboarding/domain/value_objects/user_address.dart';
import 'penalty_settings.dart';

class Salon {
  const Salon({
    required this.id,
    required this.salonId,
    required this.name,
    required this.phone,
    required this.address,
    required this.ownerUid,
    required this.ownerName,
    required this.ownerEmail,
    this.countryCode,
    this.countryName,
    this.city,
    this.currencyCode = 'USD',
    this.timeZone,
    this.isActive = true,
    this.category,
    this.businessType,
    this.contactPhone,
    this.addressDetails,
    this.location,
    this.weeklyAvailability,
    this.penaltySettings = const PenaltySettings(),
    this.defaultPayrollPeriod = SalonPayrollPeriods.monthly,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Mirrors the document id; stored for security rules and cross-doc consistency.
  final String salonId;
  final String name;

  /// Primary contact / display phone (salon line or owner).
  final String phone;
  final String address;
  final String ownerUid;
  final String ownerName;
  final String ownerEmail;

  /// Denormalized from [addressDetails] for queries / rules (ISO alpha-2).
  final String? countryCode;

  /// English display name for [countryCode].
  final String? countryName;

  /// Primary city or locality for the salon.
  final String? city;

  final String currencyCode;

  /// IANA timezone for salon-local reporting (e.g. `America/New_York`). Optional.
  final String? timeZone;

  final bool isActive;

  /// Optional browse filter (e.g. barbershop, spa).
  final String? category;

  /// `barber` | `women_salon` | `unisex`
  final String? businessType;

  /// Optional secondary / public salon phone.
  final String? contactPhone;

  /// Structured address when stored as a map under `address`.
  final UserAddress? addressDetails;

  final GeoPoint? location;

  /// Local weekly hours / breaks / day off per ISO weekday (1–7).
  final WeeklyAvailability? weeklyAvailability;

  final PenaltySettings penaltySettings;

  /// `monthly` (default) | `weekly` — default payroll cadence; staff may override on their profile.
  final String defaultPayrollPeriod;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Salon.fromJson(Map<String, dynamic> json) {
    final id = FirestoreSerializers.string(json['id']) ?? '';
    UserAddress? details;
    String addressLine;
    final rawAddress = json['address'];
    if (rawAddress is Map) {
      details = UserAddress.fromJson(Map<String, dynamic>.from(rawAddress));
      addressLine = details.formattedAddress;
    } else {
      addressLine = FirestoreSerializers.string(rawAddress) ?? '';
      details = null;
    }

    final settingsRaw = json['settings'];
    var currency = FirestoreSerializers.string(json['currencyCode'])?.trim();
    var tz = FirestoreSerializers.string(json['timeZone']);
    if (settingsRaw is Map) {
      final m = Map<String, dynamic>.from(settingsRaw);
      final ccy = FirestoreSerializers.string(m['currencyCode'])?.trim();
      if (ccy != null && ccy.isNotEmpty) {
        currency = ccy;
      }
      final tzFromSettings = FirestoreSerializers.string(m['timezone']);
      if (tzFromSettings != null && tzFromSettings.isNotEmpty) {
        tz = tzFromSettings;
      }
    }

    final countryIso =
        FirestoreSerializers.string(json['countryCode']) ??
        details?.countryCode;
    if (currency == null || currency.isEmpty) {
      currency = currencyCodeForCountryIso(countryIso ?? '');
    }

    GeoPoint? geo;
    final loc = json['location'];
    if (loc is GeoPoint) {
      geo = loc;
    }

    final ownerId = FirestoreSerializers.string(json['ownerId']);
    final ownerUid =
        FirestoreSerializers.string(json['ownerUid']) ?? ownerId ?? '';

    return Salon(
      id: id,
      salonId: FirestoreSerializers.string(json['salonId']) ?? id,
      name: FirestoreSerializers.string(json['name']) ?? '',
      phone: FirestoreSerializers.string(json['phone']) ?? '',
      address: addressLine,
      ownerUid: ownerUid,
      ownerName: FirestoreSerializers.string(json['ownerName']) ?? '',
      ownerEmail: FirestoreSerializers.string(json['ownerEmail']) ?? '',
      countryCode: countryIso,
      countryName:
          FirestoreSerializers.string(json['countryName']) ??
          details?.countryName,
      city: FirestoreSerializers.string(json['city']) ?? details?.city,
      currencyCode: currency,
      timeZone: tz,
      isActive: FirestoreSerializers.boolValue(
        json['isActive'],
        fallback: true,
      ),
      category: FirestoreSerializers.string(json['category']),
      businessType: FirestoreSerializers.string(json['businessType']),
      contactPhone: FirestoreSerializers.string(json['contactPhone']),
      addressDetails: details,
      location: geo,
      weeklyAvailability: WeeklyAvailability.maybeParse(
        json['weeklyAvailability'],
      ),
      penaltySettings: PenaltySettings.fromJson(json['penaltySettings']),
      defaultPayrollPeriod: SalonPayrollPeriods.normalize(
        FirestoreSerializers.string(json['defaultPayrollPeriod']),
      ),
      createdAt: FirestoreSerializers.dateTime(json['createdAt']),
      updatedAt: FirestoreSerializers.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'name': name,
      'phone': phone,
      'address': addressDetails?.toJson() ?? address,
      'ownerUid': ownerUid,
      'ownerId': ownerUid,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      if (countryCode != null && countryCode!.trim().isNotEmpty)
        'countryCode': countryCode!.trim().toUpperCase(),
      if (countryName != null && countryName!.trim().isNotEmpty)
        'countryName': countryName!.trim(),
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      'currencyCode': currencyCode,
      'settings': {
        'currencyCode': currencyCode,
        if (timeZone != null && timeZone!.isNotEmpty) 'timezone': timeZone,
      },
      if (timeZone != null && timeZone!.isNotEmpty) 'timeZone': timeZone,
      'isActive': isActive,
      if (category != null && category!.isNotEmpty) 'category': category,
      if (businessType != null && businessType!.isNotEmpty)
        'businessType': businessType,
      if (contactPhone != null && contactPhone!.isNotEmpty)
        'contactPhone': contactPhone,
      if (location != null) 'location': location,
      if (weeklyAvailability != null)
        'weeklyAvailability': {
          for (final e in weeklyAvailability!.byWeekday.entries)
            '${e.key}': {
              'closed': e.value.isDayOff,
              'openMinute': e.value.openMinute,
              'closeMinute': e.value.closeMinute,
              'breaks': [
                for (final b in e.value.breaks) {'start': b.$1, 'end': b.$2},
              ],
            },
        },
      'penaltySettings': penaltySettings.toJson(),
      'defaultPayrollPeriod': defaultPayrollPeriod,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Salon copyWith({
    String? id,
    String? salonId,
    String? name,
    String? phone,
    String? address,
    String? ownerUid,
    String? ownerName,
    String? ownerEmail,
    Object? countryCode = _sentinel,
    Object? countryName = _sentinel,
    Object? city = _sentinel,
    String? currencyCode,
    Object? timeZone = _sentinel,
    bool? isActive,
    Object? category = _sentinel,
    Object? businessType = _sentinel,
    Object? contactPhone = _sentinel,
    Object? addressDetails = _sentinel,
    Object? location = _sentinel,
    Object? weeklyAvailability = _sentinel,
    PenaltySettings? penaltySettings,
    String? defaultPayrollPeriod,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return Salon(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      ownerUid: ownerUid ?? this.ownerUid,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      countryCode: identical(countryCode, _sentinel)
          ? this.countryCode
          : countryCode as String?,
      countryName: identical(countryName, _sentinel)
          ? this.countryName
          : countryName as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
      currencyCode: currencyCode ?? this.currencyCode,
      timeZone: identical(timeZone, _sentinel)
          ? this.timeZone
          : timeZone as String?,
      isActive: isActive ?? this.isActive,
      category: identical(category, _sentinel)
          ? this.category
          : category as String?,
      businessType: identical(businessType, _sentinel)
          ? this.businessType
          : businessType as String?,
      contactPhone: identical(contactPhone, _sentinel)
          ? this.contactPhone
          : contactPhone as String?,
      addressDetails: identical(addressDetails, _sentinel)
          ? this.addressDetails
          : addressDetails as UserAddress?,
      location: identical(location, _sentinel)
          ? this.location
          : location as GeoPoint?,
      weeklyAvailability: identical(weeklyAvailability, _sentinel)
          ? this.weeklyAvailability
          : weeklyAvailability as WeeklyAvailability?,
      penaltySettings: penaltySettings ?? this.penaltySettings,
      defaultPayrollPeriod: defaultPayrollPeriod != null
          ? SalonPayrollPeriods.normalize(defaultPayrollPeriod)
          : this.defaultPayrollPeriod,
      createdAt: identical(createdAt, _sentinel)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _sentinel)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }
}

const Object _sentinel = Object();
