import 'package:firebase_auth/firebase_auth.dart';

/// Thrown when [FirebaseAuth.currentUser] is null before a protected operation.
class AuthRequiredException implements Exception {
  @override
  String toString() => 'AuthRequiredException';
}

/// Ensures a signed-in user and a fresh ID token (needed for HTTPS callables).
Future<User> requireFirebaseUser(FirebaseAuth auth) async {
  final user = auth.currentUser;
  if (user == null) {
    throw AuthRequiredException();
  }
  await user.getIdToken(true);
  return user;
}
