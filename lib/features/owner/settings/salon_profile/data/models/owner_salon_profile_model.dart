import 'package:cloud_firestore/cloud_firestore.dart';

/// Owner-editable public-facing salon profile fields stored on `salons/{salonId}`.
///
/// These fields are mirrored to `publicSalons/{salonId}` by Cloud Functions
/// (customer discovery uses `coverImageUrl`).
class OwnerSalonProfileModel {
  const OwnerSalonProfileModel({
    required this.salonId,
    required this.name,
    required this.ownerEmail,
    required this.photoUrls,
    this.coverImageUrl,
    this.countryCode,
    this.currencyCode,
  });

  final String salonId;
  final String name;
  final String ownerEmail;
  final List<String> photoUrls;
  final String? coverImageUrl;
  final String? countryCode;
  final String? currencyCode;

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => '$e'.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  factory OwnerSalonProfileModel.fromSalonDoc({
    required String salonId,
    required Map<String, dynamic> data,
  }) {
    final name = (data['name'] as String?)?.trim();
    final ownerEmail = (data['ownerEmail'] as String?)?.trim();
    final cover = (data['coverImageUrl'] as String?)?.trim();
    final countryCode = (data['countryCode'] as String?)?.trim();
    final currencyCode = (data['currencyCode'] as String?)?.trim();
    final photos = _stringList(data['photoUrls']);
    return OwnerSalonProfileModel(
      salonId: salonId,
      name: (name != null && name.isNotEmpty) ? name : 'Salon',
      ownerEmail: (ownerEmail != null && ownerEmail.isNotEmpty) ? ownerEmail : '',
      photoUrls: photos,
      coverImageUrl: (cover != null && cover.isNotEmpty) ? cover : null,
      countryCode: (countryCode != null && countryCode.isNotEmpty)
          ? countryCode.toUpperCase()
          : null,
      currencyCode:
          (currencyCode != null && currencyCode.isNotEmpty) ? currencyCode : null,
    );
  }

  factory OwnerSalonProfileModel.empty(String salonId) {
    return OwnerSalonProfileModel(
      salonId: salonId,
      name: 'Salon',
      ownerEmail: '',
      photoUrls: const [],
      coverImageUrl: null,
      countryCode: null,
      currencyCode: null,
    );
  }

  OwnerSalonProfileModel copyWith({
    String? name,
    String? ownerEmail,
    List<String>? photoUrls,
    Object? coverImageUrl = _sentinel,
    Object? countryCode = _sentinel,
    Object? currencyCode = _sentinel,
  }) {
    return OwnerSalonProfileModel(
      salonId: salonId,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      photoUrls: photoUrls ?? this.photoUrls,
      coverImageUrl: identical(coverImageUrl, _sentinel)
          ? this.coverImageUrl
          : coverImageUrl as String?,
      countryCode: identical(countryCode, _sentinel)
          ? this.countryCode
          : countryCode as String?,
      currencyCode: identical(currencyCode, _sentinel)
          ? this.currencyCode
          : currencyCode as String?,
    );
  }

  /// Keep Firestore payload shallow and merge-friendly.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name.trim(),
      if (ownerEmail.trim().isNotEmpty) 'ownerEmail': ownerEmail.trim(),
      'photoUrls': photoUrls,
      if (coverImageUrl != null && coverImageUrl!.trim().isNotEmpty)
        'coverImageUrl': coverImageUrl!.trim(),
      if (coverImageUrl == null) 'coverImageUrl': FieldValue.delete(),
    };
  }
}

const Object _sentinel = Object();

