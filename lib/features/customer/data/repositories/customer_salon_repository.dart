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
  Stream<List<SalonPublicModel>> watchPublicSalons();

  /// Same backing stream as [watchPublicSalons], filtered in memory (MVP).
  Stream<List<SalonPublicModel>> searchPublicSalons(String query);

  Future<SalonPublicModel?> getPublicSalonById(String salonId);
}

class FirestoreCustomerSalonRepository implements CustomerSalonRepository {
  FirestoreCustomerSalonRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Real salon documents at `salons/{salonId}` (mirrors may be missing).
  Query<Map<String, dynamic>> _publishedSalonRootQuery() {
    return _firestore
        .collection(FirestorePaths.salons)
        .where('isPublished', isEqualTo: true)
        .limit(64);
  }

  @override
  Stream<List<SalonPublicModel>> watchPublicSalons() {
    return _publishedSalonRootQuery().snapshots().map(
      (snap) {
        if (kDebugMode) {
          debugPrint(
            '[publicSalons/watch] salons root docs=${snap.docs.length}',
          );
        }
        final rows = snap.docs
            .map(SalonPublicModel.fromSalonRootDocument)
            .where((s) => s.isActive && s.isPublic)
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
  Stream<List<SalonPublicModel>> searchPublicSalons(String query) {
    return watchPublicSalons().map(
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
