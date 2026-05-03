import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/debug/agent_session_log.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import 'models/app_user.dart';

class UserRepository {
  UserRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  /// Doc id is always [FirebaseAuth.instance.currentUser.uid] when auth matches
  /// [AppUser.uid]. Blocks writes before auth is ready or when uids diverge.
  void _assertFirebaseAuthReadyForUserDoc(String payloadUid) {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null || authUid != payloadUid) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message:
            'Cannot write users/$payloadUid: FirebaseAuth not ready or uid '
            'mismatch (currentAuthUid=$authUid).',
      );
    }
  }

  /// First-time `users/{uid}` only: no-op if the doc already exists.
  ///
  /// Returns `true` if a new document was written, `false` if skipped (missing
  /// auth, uid mismatch, or doc already present). Uses [DocumentReference.set]
  /// with `merge: false` — never [DocumentReference.update] for creation.
  Future<bool> createUserIfNotExists(AppUser user) async {
    _assertFirebaseAuthReadyForUserDoc(user.uid);
    final authUid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = _users.doc(authUid);
    final existing = await docRef.get();
    if (existing.exists) {
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createUserIfNotExists: skip (doc exists) uid=$authUid',
        );
      }
      return false;
    }

    final fromJson = Map<String, dynamic>.from(user.toJson());
    fromJson.remove('createdAt');
    final payload = FirestoreWritePayload.withServerTimestampForUpdate(
      fromJson,
    );
    if (kDebugMode) {
      debugPrint(
        '[UserRepository] createUserIfNotExists BEFORE set uid=$authUid '
        'path=${docRef.path} payload=${_stringifyUserWritePayloadForDebug(payload)}',
      );
      // ignore: avoid_print
      print(
        '[UserRepository] createUserIfNotExists uid=$authUid '
        'payload=${_stringifyUserWritePayloadForDebug(payload)}',
      );
    }

    try {
      await docRef.set(payload);
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createUserIfNotExists success uid=$authUid '
          'path=${docRef.path}',
        );
      }
      return true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createUserIfNotExists denied: code=${e.code} '
          'message=${e.message} path=${docRef.path} payload='
          '${_stringifyUserWritePayloadForDebug(payload)}',
        );
      }
      rethrow;
    }
  }

  /// `users/{uid}` self-writes. Uses [FirebaseAuth.instance.currentUser.uid]
  /// as the document id after verifying it matches [user.uid].
  Future<void> createOrUpdateUser(AppUser user, {bool merge = true}) async {
    _assertFirebaseAuthReadyForUserDoc(user.uid);
    final authUid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = _users.doc(authUid);
    final fromJson = Map<String, dynamic>.from(user.toJson());
    fromJson.remove('createdAt');

    final payload = FirestoreWritePayload.withServerTimestampForUpdate(
      fromJson,
    );
    if (kDebugMode) {
      debugPrint(
        '[UserRepository] createOrUpdateUser BEFORE set uid=$authUid '
        'path=${docRef.path} merge=$merge '
        'payload=${_stringifyUserWritePayloadForDebug(payload)}',
      );
      // ignore: avoid_print
      print(
        '[UserRepository] createOrUpdateUser uid=$authUid merge=$merge '
        'payload=${_stringifyUserWritePayloadForDebug(payload)}',
      );
    }
    try {
      await docRef.set(payload, SetOptions(merge: merge));
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createOrUpdateUser success: uid=$authUid '
          'path=${docRef.path} merge=$merge',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createOrUpdateUser denied: code=${e.code} '
          'message=${e.message} path=${docRef.path} merge=$merge payload='
          '${_stringifyUserWritePayloadForDebug(payload)}',
        );
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[UserRepository] createOrUpdateUser failed: uid=$authUid '
          'path=${docRef.path} merge=$merge error=$e',
        );
      }
      rethrow;
    }
  }

  /// Shallow merge for fields not modeled on [AppUser] (e.g. guest metadata).
  Future<void> mergeProfileFields(Map<String, dynamic> fields) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid == null || authUid.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'Cannot merge users/*: not signed in.',
      );
    }
    final docRef = _users.doc(authUid);
    final payload = FirestoreWritePayload.withServerTimestampForUpdate(fields);
    await docRef.set(payload, SetOptions(merge: true));
  }

  /// Account recovery / first-time [users/{uid}] when the doc is missing.
  Future<void> createMinimalRecoveryUser(AppUser user) async {
    await createUserIfNotExists(user);
  }

  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return AppUser.fromJson(data);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }

      return AppUser.fromJson(data);
    });
  }

  Future<void> updateSalonMembership({
    required String uid,
    required String salonId,
    required String employeeId,
  }) async {
    _assertFirebaseAuthReadyForUserDoc(uid);
    final authUid = FirebaseAuth.instance.currentUser!.uid;
    final payload = FirestoreWritePayload.withServerTimestampForUpdate({
      'salonId': salonId,
      'employeeId': employeeId,
    });
    if (kDebugMode) {
      debugPrint(
        '[UserRepository] updateSalonMembership BEFORE set uid=$authUid '
        'path=${_users.doc(authUid).path} payload=$payload',
      );
      // ignore: avoid_print
      print(
        '[UserRepository] updateSalonMembership uid=$authUid payload=$payload',
      );
    }
    return _users.doc(authUid).set(payload, SetOptions(merge: true));
  }

  Future<void> setUserActiveState({
    required String uid,
    required bool isActive,
  }) async {
    _assertFirebaseAuthReadyForUserDoc(uid);
    final authUid = FirebaseAuth.instance.currentUser!.uid;
    final payload = FirestoreWritePayload.withServerTimestampForUpdate({
      'isActive': isActive,
    });
    if (kDebugMode) {
      debugPrint(
        '[UserRepository] setUserActiveState BEFORE set uid=$authUid '
        'path=${_users.doc(authUid).path} payload=$payload',
      );
      // ignore: avoid_print
      print(
        '[UserRepository] setUserActiveState uid=$authUid payload=$payload',
      );
    }
    return _users.doc(authUid).set(payload, SetOptions(merge: true));
  }

  Future<void> updateUserPhoto({
    required String uid,
    required String photoUrl,
  }) async {
    _assertFirebaseAuthReadyForUserDoc(uid);
    final authUid = FirebaseAuth.instance.currentUser!.uid;
    final payload = FirestoreWritePayload.withServerTimestampForUpdate({
      'photoUrl': photoUrl,
    });
    await _users.doc(authUid).set(payload, SetOptions(merge: true));
  }

  /// Clears `mustChangePassword` on `users/{uid}` and the linked employee row
  /// after the staff member rotates their Firebase password in-app.
  ///
  /// [employeeId] should match `employees/{employeeId}` (usually the same as
  /// [uid]); when null or empty, [uid] is used.
  Future<void> clearStaffMustChangePasswordAfterPasswordRotation({
    required String uid,
    required String salonId,
    String? employeeId,
    String? role,
  }) async {
    _assertFirebaseAuthReadyForUserDoc(uid);
    FirestoreWritePayload.assertSalonId(salonId);
    final eid = (employeeId != null && employeeId.trim().isNotEmpty)
        ? employeeId.trim()
        : uid.trim();
    if (kDebugMode) {
      agentSessionLog(
        hypothesisId: 'H-pwd',
        location:
            'user_repository.dart:clearStaffMustChangePasswordAfterPasswordRotation',
        message: 'clear_must_change_password_start',
        data: <String, Object?>{
          'uid': uid,
          'salonId': salonId,
          'employeeId': eid,
          'role': role ?? '',
        },
      );
    }
    final batch = _firestore.batch();
    final userRef = _users.doc(uid);
    final employeeRef = _firestore
        .collection(FirestorePaths.salons)
        .doc(salonId)
        .collection(FirestorePaths.employees)
        .doc(eid);
    final payload = FirestoreWritePayload.withServerTimestampForUpdate({
      'mustChangePassword': false,
    });
    batch.set(userRef, payload, SetOptions(merge: true));
    batch.set(employeeRef, payload, SetOptions(merge: true));
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        agentSessionLog(
          hypothesisId: 'H-pwd',
          location:
              'user_repository.dart:clearStaffMustChangePasswordAfterPasswordRotation',
          message: 'clear_must_change_password_failed',
          data: <String, Object?>{
            'uid': uid,
            'salonId': salonId,
            'employeeId': eid,
            'code': e.code,
          },
        );
      }
      rethrow;
    }
    if (kDebugMode) {
      agentSessionLog(
        hypothesisId: 'H-pwd',
        location:
            'user_repository.dart:clearStaffMustChangePasswordAfterPasswordRotation',
        message: 'clear_must_change_password_success',
        data: <String, Object?>{
          'uid': uid,
          'salonId': salonId,
          'employeeId': eid,
        },
      );
    }
  }
}

String _stringifyUserWritePayloadForDebug(Map<String, dynamic> payload) {
  return payload
      .map(
        (k, v) => MapEntry(
          k,
          v is FieldValue ? 'FieldValue(serverTimestamp or sentinel)' : v,
        ),
      )
      .toString();
}
