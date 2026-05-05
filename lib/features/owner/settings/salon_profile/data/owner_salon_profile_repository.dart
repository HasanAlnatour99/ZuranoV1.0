import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../../../../../core/firestore/firestore_write_payload.dart';
import '../../../../../core/utils/currency_for_country.dart';
import 'models/owner_salon_profile_model.dart';

class OwnerSalonProfileRepository {
  OwnerSalonProfileRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _salonRef(String salonId) =>
      _firestore.doc(FirestorePaths.salon(salonId));

  Stream<OwnerSalonProfileModel> watchProfile(String salonId) {
    final id = salonId.trim();
    FirestoreWritePayload.assertSalonId(id);
    return _salonRef(id).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) {
        return OwnerSalonProfileModel.empty(id);
      }
      return OwnerSalonProfileModel.fromSalonDoc(salonId: id, data: data);
    });
  }

  Future<void> mergeSalonFields({
    required String salonId,
    required Map<String, dynamic> fields,
  }) async {
    final id = salonId.trim();
    FirestoreWritePayload.assertSalonId(id);
    final payload = FirestoreWritePayload.withServerTimestampForUpdate(fields);
    await _salonRef(id).set(payload, SetOptions(merge: true));
  }

  Future<void> updateSalonName({
    required String salonId,
    required String name,
  }) async {
    await mergeSalonFields(salonId: salonId, fields: {'name': name.trim()});
  }

  Future<void> updateCountryAndCurrency({
    required String salonId,
    required String countryCode,
    required String countryName,
  }) async {
    final iso = countryCode.trim().toUpperCase();
    final name = countryName.trim();
    if (iso.isEmpty || iso.length != 2) {
      throw ArgumentError.value(countryCode, 'countryCode', 'Invalid country.');
    }
    final currency = currencyCodeForCountryIso(iso);
    await mergeSalonFields(
      salonId: salonId,
      fields: {
        'countryCode': iso,
        if (name.isNotEmpty) 'countryName': name,
        // Ensure salon money displays match the selected country.
        'currencyCode': currency,
      },
    );
  }

  Future<void> updateOwnerEmailOnSalon({
    required String salonId,
    required String ownerEmail,
  }) async {
    await mergeSalonFields(
      salonId: salonId,
      fields: {'ownerEmail': ownerEmail.trim().toLowerCase()},
    );
  }

  Future<void> updatePhotos({
    required String salonId,
    required List<String> photoUrls,
    required String? coverImageUrl,
  }) async {
    final clean = photoUrls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    await mergeSalonFields(
      salonId: salonId,
      fields: {
        'photoUrls': clean,
        if (coverImageUrl != null && coverImageUrl.trim().isNotEmpty)
          'coverImageUrl': coverImageUrl.trim(),
        if (coverImageUrl == null) 'coverImageUrl': FieldValue.delete(),
      },
    );
  }
}

