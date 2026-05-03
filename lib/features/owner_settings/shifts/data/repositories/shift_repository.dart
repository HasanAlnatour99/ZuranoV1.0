import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../models/shift_template_model.dart';

class ShiftRepository {
  ShiftRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _templates(String salonId) {
    return _firestore.collection(FirestorePaths.salonShiftTemplates(salonId));
  }

  Stream<List<ShiftTemplateModel>> streamShiftTemplates(String salonId) {
    return _templates(salonId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ShiftTemplateModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<ShiftTemplateModel?> getShiftTemplate({
    required String salonId,
    required String shiftId,
  }) async {
    final doc = await _templates(salonId).doc(shiftId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ShiftTemplateModel.fromFirestore(doc);
  }

  Future<void> createShiftTemplate({
    required String salonId,
    required ShiftTemplateModel model,
  }) async {
    final collection = _templates(salonId);
    final activeSnapshot = await collection
        .where('isActive', isEqualTo: true)
        .get();
    final activeDocRefs = activeSnapshot.docs
        .map((doc) => collection.doc(doc.id))
        .toList(growable: false);
    await _firestore.runTransaction((tx) async {
      final docRef = model.id.trim().isEmpty
          ? collection.doc()
          : collection.doc(model.id);
      var hasExistingDefault = false;
      for (final activeDocRef in activeDocRefs) {
        final activeDoc = await tx.get(activeDocRef);
        if (activeDoc.data()?['isDefault'] == true) {
          hasExistingDefault = true;
        }
      }
      final shouldBeDefault = model.isDefault || !hasExistingDefault;
      if (shouldBeDefault) {
        for (final activeDocRef in activeDocRefs) {
          if (activeDocRef.id == docRef.id) {
            continue;
          }
          tx.update(activeDocRef, <String, dynamic>{
            'isDefault': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      final payload = model
          .copyWith(id: docRef.id, salonId: salonId, isDefault: shouldBeDefault)
          .toCreateMap();
      tx.set(docRef, payload);
    });
  }

  Future<void> updateShiftTemplate({
    required String salonId,
    required ShiftTemplateModel model,
  }) async {
    final collection = _templates(salonId);
    final activeSnapshot = await collection
        .where('isActive', isEqualTo: true)
        .get();
    final activeDocRefs = activeSnapshot.docs
        .map((doc) => collection.doc(doc.id))
        .toList(growable: false);
    await _firestore.runTransaction((tx) async {
      final activeDocs = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final activeDocRef in activeDocRefs) {
        activeDocs.add(await tx.get(activeDocRef));
      }
      if (!model.isDefault) {
        final hasOtherDefault = activeDocs.any((doc) {
          if (doc.id == model.id) {
            return false;
          }
          return doc.data()?['isDefault'] == true;
        });
        if (!hasOtherDefault) {
          throw StateError('At least one default shift is required.');
        }
      }
      if (model.isDefault) {
        for (final activeDoc in activeDocs) {
          if (activeDoc.id == model.id) {
            continue;
          }
          tx.update(activeDoc.reference, <String, dynamic>{
            'isDefault': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      tx.update(collection.doc(model.id), model.toUpdateMap());
    });
  }

  Future<void> deactivateShiftTemplate({
    required String salonId,
    required String shiftId,
  }) async {
    final collection = _templates(salonId);
    final activeSnapshot = await collection
        .where('isActive', isEqualTo: true)
        .get();
    final activeDocRefs = activeSnapshot.docs
        .map((doc) => collection.doc(doc.id))
        .toList(growable: false);
    await _firestore.runTransaction((tx) async {
      final activeDocs = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final activeDocRef in activeDocRefs) {
        activeDocs.add(await tx.get(activeDocRef));
      }
      final targetDoc = activeDocs.where((doc) => doc.id == shiftId);
      if (targetDoc.isEmpty) {
        return;
      }
      final isDefault = targetDoc.first.data()?['isDefault'] == true;
      final activeOthers = activeDocs
          .where((doc) => doc.id != shiftId)
          .toList(growable: false);
      if (isDefault && activeOthers.isEmpty) {
        throw StateError('At least one default shift is required.');
      }
      tx.update(collection.doc(shiftId), <String, dynamic>{
        'isActive': false,
        'isDefault': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (isDefault) {
        final fallbackDefault = activeOthers.first;
        tx.update(fallbackDefault.reference, <String, dynamic>{
          'isDefault': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> reorderShiftTemplates({
    required String salonId,
    required List<String> orderedTemplateIds,
  }) async {
    final batch = _firestore.batch();
    final collection = _templates(salonId);
    for (var index = 0; index < orderedTemplateIds.length; index++) {
      final templateId = orderedTemplateIds[index];
      batch.update(collection.doc(templateId), <String, dynamic>{
        'sortOrder': index,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
