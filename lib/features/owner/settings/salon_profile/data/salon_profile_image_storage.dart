import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Uploads salon profile photos to Firebase Storage under
/// `salons/{salonId}/profile/photos/`.
class SalonProfileImageStorage {
  SalonProfileImageStorage({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const int maxBytes = 6 * 1024 * 1024;

  Reference _objectRef(String salonId, String fileName) {
    return _storage
        .ref()
        .child('salons')
        .child(salonId)
        .child('profile')
        .child('photos')
        .child(fileName);
  }

  Future<String> uploadSalonPhoto({
    required String salonId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('Image data is empty.');
    }
    if (bytes.length > maxBytes) {
      throw ArgumentError('Image exceeds maximum size.');
    }
    final ct = contentType.toLowerCase();
    final ext = ct.contains('png')
        ? 'png'
        : ct.contains('webp')
        ? 'webp'
        : 'jpg';
    final name = 'salon_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _objectRef(salonId, name);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}

