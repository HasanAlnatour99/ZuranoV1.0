import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/utils/phone_normalizer.dart';
import '../../employees/data/models/employee.dart';
import '../../onboarding/domain/value_objects/salon_business_type.dart';
import '../../onboarding/domain/value_objects/user_address.dart';
import '../../users/data/models/app_user.dart';
import 'models/salon.dart';

class SalonRepository {
  SalonRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _salons =>
      _firestore.collection(FirestorePaths.salons);

  /// Creates salon + links owner, or returns existing linkage if [salonId]
  /// is already set (idempotent). User doc is always [SetOptions.merge].
  Future<({String salonId, String employeeId})> createSalonForOwner({
    required AppUser owner,
    required String salonName,
    required SalonBusinessType businessType,
    required UserAddress address,
    String? contactPhone,
    String currencyCode = 'USD',
    String? timeZone,
  }) async {
    if (owner.uid.isEmpty) {
      throw ArgumentError.value(
        owner.uid,
        'owner.uid',
        'Owner ID is required.',
      );
    }

    final primaryPhone =
        (contactPhone != null && contactPhone.trim().isNotEmpty)
        ? PhoneNormalizer.normalizeForStorage(contactPhone)
        : (owner.phoneE164OrEmpty ?? '');

    final userRef = _firestore.doc(FirestorePaths.user(owner.uid));

    final outcome = await _firestore.runTransaction((
      Transaction transaction,
    ) async {
      final userSnap = await transaction.get(userRef);
      final existingRaw = userSnap.data()?['salonId'];
      final existingSalonId = existingRaw is String ? existingRaw.trim() : '';
      if (existingSalonId.isNotEmpty) {
        return (
          salonId: existingSalonId,
          employeeId: owner.uid,
          createdNewSalon: false,
        );
      }

      final salonDoc = _salons.doc();
      final employeeId = owner.uid;
      final salon = Salon(
        id: salonDoc.id,
        salonId: salonDoc.id,
        name: salonName.trim(),
        phone: primaryPhone,
        address: address.formattedAddress,
        addressDetails: address,
        countryCode: address.countryCode,
        countryName: address.countryName,
        city: address.city,
        businessType: businessType.firestoreValue,
        contactPhone: contactPhone != null && contactPhone.trim().isNotEmpty
            ? PhoneNormalizer.normalizeForStorage(contactPhone)
            : null,
        ownerUid: owner.uid,
        ownerName: owner.name.trim(),
        ownerEmail: owner.email.trim(),
        currencyCode: currencyCode,
        timeZone: timeZone,
      );

      transaction.set(
        userRef,
        FirestoreWritePayload.withServerTimestampForUpdate({
          'role': UserRoles.owner,
          'salonId': salonDoc.id,
          'employeeId': employeeId,
          'onboardingStatus': 'completed',
          'salonCreationCompleted': true,
          'countryCode': address.countryCode,
          'countryName': address.countryName,
          'city': address.city,
          'profileCompleted': true,
          'profileCompletedAt': FieldValue.serverTimestamp(),
        }),
        SetOptions(merge: true),
      );
      transaction.set(
        salonDoc,
        FirestoreWritePayload.withServerTimestampsForCreate(salon.toJson()),
      );

      return (
        salonId: salonDoc.id,
        employeeId: employeeId,
        createdNewSalon: true,
      );
    });

    if (!outcome.createdNewSalon) {
      return (salonId: outcome.salonId, employeeId: outcome.employeeId);
    }

    final salonDoc = _salons.doc(outcome.salonId);
    final employeeDoc = salonDoc
        .collection(FirestorePaths.employees)
        .doc(outcome.employeeId);
    final nowUtc = DateTime.now().toUtc();
    final employee = Employee(
      id: outcome.employeeId,
      salonId: outcome.salonId,
      uid: owner.uid,
      name: owner.name.trim(),
      email: owner.email.trim(),
      role: UserRoles.owner,
      phone: owner.phoneE164OrEmpty,
      hiredAt: DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day),
    );

    try {
      final employeeBatch = _firestore.batch();
      employeeBatch.set(
        employeeDoc,
        FirestoreWritePayload.withServerTimestampsForCreate(employee.toJson()),
      );
      await employeeBatch.commit();
    } on FirebaseException {
      await _rollbackSalonBootstrap(userRef: userRef, salonRef: salonDoc);
      rethrow;
    } catch (_) {
      await _rollbackSalonBootstrap(userRef: userRef, salonRef: salonDoc);
      rethrow;
    }

    return (salonId: outcome.salonId, employeeId: outcome.employeeId);
  }

  Future<void> _rollbackSalonBootstrap({
    required DocumentReference<Map<String, dynamic>> userRef,
    required DocumentReference<Map<String, dynamic>> salonRef,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        userRef,
        FirestoreWritePayload.withServerTimestampForUpdate({
          'salonId': FieldValue.delete(),
          'employeeId': FieldValue.delete(),
          'onboardingStatus': FieldValue.delete(),
          'salonCreationCompleted': false,
        }),
        SetOptions(merge: true),
      );
      batch.delete(salonRef);
      await batch.commit();
    } catch (_) {
      // Original error from employee commit remains more actionable.
    }
  }

  Future<Salon?> getSalon(String salonId) async {
    final snapshot = await _salons.doc(salonId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }

    return Salon.fromJson(data);
  }

  Stream<Salon?> watchSalon(String salonId) {
    return _salons.doc(salonId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      return Salon.fromJson(data);
    });
  }

  /// Discoverable salons for customers (active only). Sort is client-side by name.
  Stream<List<Salon>> watchActiveSalons({int limit = 80}) {
    return _salons
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Salon.fromJson(doc.data()))
              .toList(growable: false);
          list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return list;
        });
  }

  Future<void> updateSalon(Salon salon) {
    return _salons
        .doc(salon.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(
            salon.copyWith(salonId: salon.id).toJson(),
          ),
          SetOptions(merge: true),
        );
  }
}
