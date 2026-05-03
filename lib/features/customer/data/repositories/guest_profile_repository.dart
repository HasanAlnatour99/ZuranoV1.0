import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firestore/firestore_paths.dart';

class GuestNicknameException implements Exception {
  GuestNicknameException(this.code);

  final String code;
}

/// Reserves `guestProfiles/{nicknameKey}` for the signed-in anonymous customer.
class GuestProfileRepository {
  GuestProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static final RegExp allowedNicknameBasePattern = RegExp(
    r'^[a-zA-Z0-9\u0600-\u06FF]{2,24}$',
  );

  /// Returns lowercase [nicknameKey] and display [guestDisplayName] (e.g. Hasan-ZR7K2P).
  Future<({String nicknameKey, String guestDisplayName})>
  reserveUniqueGuestProfile({required String rawBase}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw GuestNicknameException('not_signed_in');
    }
    final base = _sanitizeBase(rawBase);
    if (base.length < 2) {
      throw GuestNicknameException('too_short');
    }
    if (!allowedNicknameBasePattern.hasMatch(base)) {
      throw GuestNicknameException('invalid');
    }

    final baseDisplay = _toDisplayFragment(base);
    final rnd = Random.secure();

    for (var attempt = 0; attempt < 16; attempt++) {
      final suffix = _randomSuffix(rnd);
      final guestDisplayName = '$baseDisplay-$suffix';
      final nicknameKey = guestDisplayName.toLowerCase();
      final ref = _firestore.doc(FirestorePaths.guestProfile(nicknameKey));

      try {
        await _firestore.runTransaction((tx) async {
          final snap = await tx.get(ref);
          if (snap.exists) {
            throw StateError('collision');
          }
          final now = FieldValue.serverTimestamp();
          tx.set(ref, <String, dynamic>{
            'nicknameKey': nicknameKey,
            'guestDisplayName': guestDisplayName,
            'authUid': uid,
            'reservedAt': now,
            'createdAt': now,
            'updatedAt': now,
          });
        });
        return (nicknameKey: nicknameKey, guestDisplayName: guestDisplayName);
      } on StateError {
        continue;
      }
    }
    throw GuestNicknameException('reserve_failed');
  }

  String _sanitizeBase(String raw) {
    var s = raw.trim().replaceAll(RegExp(r'[\s\-_]+'), '');
    if (s.length > 24) {
      s = s.substring(0, 24);
    }
    return s;
  }

  String _toDisplayFragment(String base) {
    if (base.isEmpty) {
      return 'Guest';
    }
    return base[0].toUpperCase() + base.substring(1).toLowerCase();
  }

  String _randomSuffix(Random rnd) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buf = StringBuffer('ZR');
    for (var i = 0; i < 4; i++) {
      buf.write(chars[rnd.nextInt(chars.length)]);
    }
    return buf.toString();
  }
}
