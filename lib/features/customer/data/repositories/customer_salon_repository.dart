import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../models/salon_public_model.dart';

/// Local MVP search over already-public salon rows (name, area, gender, denormalized keywords).
///
/// TODO(Step 16+): When the public salon catalog grows past ~500 documents, add Algolia or
/// Typesense (or Firestore vector search) — local substring search will not scale.
List<SalonPublicModel> filterPublicSalonsByQuery(
  List<SalonPublicModel> items,
  String rawQuery,
) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) {
    return items;
  }
  bool tokenMatch(SalonPublicModel s) {
    final name = s.salonName.toLowerCase();
    final area = s.area.toLowerCase();
    if (name.contains(q) || area.contains(q)) {
      return true;
    }
    final gender = s.genderTarget ?? '';
    if (gender.isNotEmpty && gender.contains(q)) {
      return true;
    }
    for (final k in s.searchKeywords) {
      if (k.contains(q)) {
        return true;
      }
    }
    for (final k in s.areaKeywords) {
      if (k.contains(q)) {
        return true;
      }
    }
    for (final k in s.serviceKeywords) {
      if (k.contains(q)) {
        return true;
      }
    }
    return false;
  }

  return items.where(tokenMatch).toList(growable: false);
}

abstract class CustomerSalonRepository {
  /// Customer-facing mirror rows scoped by ISO country (see `publicSalons.countryCode`).
  Stream<List<SalonPublicModel>> watchPublicSalons({required String countryCode});

  /// Same backing stream as [watchPublicSalons], filtered in memory (MVP).
  Stream<List<SalonPublicModel>> searchPublicSalons({
    required String countryCode,
    required String query,
  });

  Future<SalonPublicModel?> getPublicSalonById(String salonId);
}

class FirestoreCustomerSalonRepository implements CustomerSalonRepository {
  FirestoreCustomerSalonRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Real salon documents at `salons/{salonId}` (mirrors may be missing).
  @override
  Stream<List<SalonPublicModel>> watchPublicSalons({required String countryCode}) {
    final cc = countryCode.trim().toUpperCase();
    return _firestore
        .collection(FirestorePaths.publicSalons)
        .where('countryCode', isEqualTo: cc)
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .limit(100)
        .snapshots()
        .map(
      (snap) {
        if (kDebugMode) {
          debugPrint(
            '[publicSalons/watch] country=$cc docs=${snap.docs.length}',
          );
        }
        final rows = snap.docs
            .map(SalonPublicModel.fromFirestore)
            .toList(growable: false);
        rows.sort((a, b) {
          final c = b.ratingAverage.compareTo(a.ratingAverage);
          if (c != 0) {
            return c;
          }
          return a.salonName.toLowerCase().compareTo(
            b.salonName.toLowerCase(),
          );
        });
        return rows;
      },
    );
  }

  @override
  Stream<List<SalonPublicModel>> searchPublicSalons({
    required String countryCode,
    required String query,
  }) {
    return watchPublicSalons(countryCode: countryCode).map(
      (list) => filterPublicSalonsByQuery(list, query),
    );
  }

  @override
  Future<SalonPublicModel?> getPublicSalonById(String salonId) async {
    final id = salonId.trim();
    if (id.isEmpty) {
      return null;
    }
    try {
      final publicDoc = await _firestore.doc(FirestorePaths.publicSalon(id)).get();
      if (publicDoc.exists) {
        return SalonPublicModel.fromFirestore(publicDoc);
      }
      final rootDoc = await _firestore
          .collection(FirestorePaths.salons)
          .doc(id)
          .get();
      if (rootDoc.exists) {
        return SalonPublicModel.fromSalonRootDocument(rootDoc);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }
}
