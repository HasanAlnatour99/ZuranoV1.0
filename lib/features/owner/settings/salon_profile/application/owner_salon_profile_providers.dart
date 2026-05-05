import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../providers/firebase_providers.dart';
import '../../../../../providers/repository_providers.dart';
import '../data/owner_salon_profile_repository.dart';
import '../data/salon_profile_image_storage.dart';
import '../data/models/owner_salon_profile_model.dart';

final ownerSalonProfileRepositoryProvider =
    Provider<OwnerSalonProfileRepository>((ref) {
      return OwnerSalonProfileRepository(firestore: ref.watch(firestoreProvider));
    });

final salonProfileImageStorageProvider = Provider<SalonProfileImageStorage>((ref) {
  return SalonProfileImageStorage(storage: ref.watch(firebaseStorageProvider));
});

final ownerSalonProfileProvider =
    StreamProvider.family<OwnerSalonProfileModel, String>((ref, salonId) {
      return ref.watch(ownerSalonProfileRepositoryProvider).watchProfile(salonId);
    });

final ownerSalonNameControllerProvider =
    AsyncNotifierProvider<OwnerSalonNameController, void>(
      OwnerSalonNameController.new,
    );

class OwnerSalonNameController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateSalonName({
    required String salonId,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(ownerSalonProfileRepositoryProvider)
          .updateSalonName(salonId: salonId, name: name),
    );
    return !state.hasError;
  }

  Future<bool> updateCountry({
    required String salonId,
    required String countryCode,
    required String countryName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(ownerSalonProfileRepositoryProvider).updateCountryAndCurrency(
            salonId: salonId,
            countryCode: countryCode,
            countryName: countryName,
          ),
    );
    return !state.hasError;
  }
}

final ownerSalonPhotosControllerProvider =
    AsyncNotifierProvider<OwnerSalonPhotosController, void>(
      OwnerSalonPhotosController.new,
    );

class OwnerSalonPhotosController extends AsyncNotifier<void> {
  static const maxPhotos = 5;

  @override
  Future<void> build() async {}

  Future<bool> addPhoto({
    required String salonId,
    required OwnerSalonProfileModel current,
    required XFile image,
  }) async {
    if (current.photoUrls.length >= maxPhotos) {
      return false;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bytes = await image.readAsBytes();
      final ext = image.name.toLowerCase();
      final contentType = ext.endsWith('.png')
          ? 'image/png'
          : ext.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';

      final url =
          await ref.read(salonProfileImageStorageProvider).uploadSalonPhoto(
                salonId: salonId,
                bytes: bytes,
                contentType: contentType,
              );

      final updated = [...current.photoUrls, url];
      final cover =
          (current.coverImageUrl == null || current.coverImageUrl!.isEmpty)
              ? url
              : current.coverImageUrl;
      await ref.read(ownerSalonProfileRepositoryProvider).updatePhotos(
            salonId: salonId,
            photoUrls: updated,
            coverImageUrl: cover,
          );
    });
    return !state.hasError;
  }

  Future<bool> removePhoto({
    required String salonId,
    required OwnerSalonProfileModel current,
    required String url,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated =
          current.photoUrls.where((e) => e != url).toList(growable: false);
      final cover = current.coverImageUrl == url
          ? (updated.isNotEmpty ? updated.first : null)
          : current.coverImageUrl;
      await ref.read(ownerSalonProfileRepositoryProvider).updatePhotos(
            salonId: salonId,
            photoUrls: updated,
            coverImageUrl: cover,
          );
    });
    return !state.hasError;
  }

  Future<bool> setCover({
    required String salonId,
    required OwnerSalonProfileModel current,
    required String url,
  }) async {
    if (!current.photoUrls.contains(url)) {
      return false;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(ownerSalonProfileRepositoryProvider).updatePhotos(
            salonId: salonId,
            photoUrls: current.photoUrls,
            coverImageUrl: url,
          ),
    );
    return !state.hasError;
  }
}

final ownerSalonAccountControllerProvider =
    AsyncNotifierProvider<OwnerSalonAccountController, void>(
      OwnerSalonAccountController.new,
    );

class OwnerSalonAccountController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateAccountEmail({
    required String uid,
    required String salonId,
    required String newEmail,
    required String currentPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateEmailWithPassword(
            newEmail: newEmail,
            currentPassword: currentPassword,
          );
      await ref
          .read(userRepositoryProvider)
          .mergeProfileFields({'email': newEmail.trim().toLowerCase()});
      await ref.read(ownerSalonProfileRepositoryProvider).updateOwnerEmailOnSalon(
            salonId: salonId,
            ownerEmail: newEmail,
          );
    });
    return !state.hasError;
  }

  Future<bool> updateAccountPassword({
    required String newPassword,
    required String currentPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updatePasswordWithPassword(
            newPassword: newPassword,
            currentPassword: currentPassword,
          ),
    );
    return !state.hasError;
  }
}

