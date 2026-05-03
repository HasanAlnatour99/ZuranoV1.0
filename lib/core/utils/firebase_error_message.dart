import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseErrorMessage {
  const FirebaseErrorMessage._();

  static String fromException(Object error) {
    if (error is FirebaseAuthException) {
      if (kDebugMode) {
        final message = error.message ?? 'Authentication failed.';
        return '[auth:${error.code}] $message';
      }
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'The email or password is incorrect.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not available. Ask your salon admin or try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'user-disabled':
          return 'This account has been disabled.';
      }

      return error.message ?? 'Authentication failed. Please try again.';
    }

    if (error is FirebaseException) {
      if (kDebugMode) {
        final message = error.message ?? 'Something went wrong.';
        return '[firebase:${error.code}] $message';
      }
      return error.message ?? 'Something went wrong. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
