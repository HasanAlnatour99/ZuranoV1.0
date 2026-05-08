import 'dart:math';

import '../../../core/storage/secure_storage_service.dart';

class GuestIdentityRepository {
  GuestIdentityRepository(this._storage);

  final SecureStorageService _storage;

  static const guestProfileIdKey = 'zurano_guest_profile_id';

  Future<String> getOrCreateGuestProfileId() async {
    final existing = (await _storage.read(guestProfileIdKey))?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final rnd = Random.secure();
    final suffix = _randomSuffix(rnd, 10);
    final ms = DateTime.now().millisecondsSinceEpoch;
    final id = 'guest_${ms}_$suffix';
    await _storage.write(guestProfileIdKey, id);
    return id;
  }

  Future<String?> getGuestProfileId() async {
    final v = (await _storage.read(guestProfileIdKey))?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  static String _randomSuffix(Random rnd, int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final out = StringBuffer();
    for (var i = 0; i < length; i++) {
      out.write(chars[rnd.nextInt(chars.length)]);
    }
    return out.toString();
  }
}

