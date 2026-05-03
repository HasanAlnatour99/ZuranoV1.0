import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../data/repositories/guest_profile_repository.dart';

final guestProfileRepositoryProvider = Provider<GuestProfileRepository>((ref) {
  return GuestProfileRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});
