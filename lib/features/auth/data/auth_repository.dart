import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/boot/app_boot_log.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/debug/agent_session_log.dart';
import '../../onboarding/domain/value_objects/user_address.dart';
import '../../onboarding/domain/value_objects/user_phone.dart';
import '../../users/data/models/app_user.dart';
import '../../users/data/user_repository.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuth auth,
    required UserRepository userRepository,
  }) : _auth = auth,
       _userRepository = userRepository;

  final FirebaseAuth _auth;
  final UserRepository _userRepository;
  String? _lastCredentialUid;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const <String>['email', 'profile'],
  );

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  /// Customer email/password signup with optional structured phone + address
  /// (city, country) written in the initial `users/{uid}` document.
  Future<String> registerCustomerWithEmail({
    required String fullName,
    required String email,
    required String password,
    UserPhone? phone,
    UserAddress? address,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _debugLogSignupSession(
      credential: credential,
      flow: 'registerCustomerWithEmail',
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Failed to create account.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    await _writeUserProfileWithLogging(
      flow: 'registerCustomerWithEmail',
      user: AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: fullName.trim(),
        role: UserRoles.customer,
        isActive: true,
        salonId: null,
        employeeId: null,
        onboardingCompleted: true,
        profileCompletedAt: DateTime.now(),
        phone: phone,
        address: address,
      ),
      merge: false,
    );
    _lastCredentialUid = user.uid;
    return user.uid;
  }

  Future<String> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _debugLogSignupSession(credential: credential, flow: 'registerWithEmail');

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Failed to create account.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    await _writeUserProfileWithLogging(
      flow: 'registerWithEmail',
      user: AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: fullName.trim(),
        role: UserRoles.owner,
        isActive: true,
        salonId: null,
        employeeId: null,
        onboardingCompleted: true,
      ),
      merge: false,
    );
    _lastCredentialUid = user.uid;
    return user.uid;
  }

  Future<void> registerCustomerWithProfile({
    required String fullName,
    required String email,
    required String password,
    required UserPhone phone,
    required UserAddress address,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Failed to create account.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    await _writeUserProfileWithLogging(
      flow: 'registerCustomerWithProfile',
      user: AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: fullName.trim(),
        role: UserRoles.customer,
        isActive: true,
        salonId: null,
        employeeId: null,
        onboardingCompleted: true,
        phone: phone,
        address: address,
      ),
      merge: false,
    );
  }

  Future<String> registerSalonOwnerAccount({
    required String fullName,
    required String email,
    required String password,
    required UserPhone phone,
    required UserAddress ownerCountryAddress,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    _debugLogSignupSession(
      credential: credential,
      flow: 'registerSalonOwnerAccount',
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Failed to create account.',
      );
    }

    await user.updateDisplayName(fullName.trim());

    await _writeUserProfileWithLogging(
      flow: 'registerSalonOwnerAccount',
      user: AppUser(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: fullName.trim(),
        role: UserRoles.owner,
        isActive: true,
        salonId: null,
        employeeId: null,
        onboardingCompleted: true,
        phone: phone,
        address: ownerCountryAddress,
      ),
      merge: false,
    );
    _lastCredentialUid = user.uid;
    return user.uid;
  }

  void _debugLogSignupSession({
    required UserCredential credential,
    required String flow,
  }) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[$flow] SIGNUP auth uid = ${credential.user?.uid}');
    debugPrint('[$flow] SIGNUP currentUser uid = ${_auth.currentUser?.uid}');
    debugPrint(
      '[$flow] SIGNUP currentUser email = ${_auth.currentUser?.email}',
    );
  }

  /// Re-authenticates the current email/password user (no password change).
  Future<void> reauthenticateWithCurrentEmailPassword(
    String currentPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'No signed-in user.',
      );
    }
    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Account has no email for password confirmation.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Updates password for the already re-authenticated current user.
  Future<void> updateCurrentUserPassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'No signed-in user.',
      );
    }
    await user.updatePassword(newPassword);
  }

  /// Re-authenticates the signed-in email/password user and sets a new password.
  /// Call only after the user entered their current (temporary) password correctly.
  Future<void> reauthenticateWithEmailPasswordAndUpdatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await reauthenticateWithCurrentEmailPassword(currentPassword);
    await updateCurrentUserPassword(newPassword);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: normalizedPassword,
    );
    final uid = credential.user?.uid ?? _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'No authenticated user found after login.',
      );
    }
    _lastCredentialUid = uid;
    return uid;
  }

  String? get lastCredentialUid => _lastCredentialUid;

  /// After email/password sign-in, creates `users/{uid}` only when missing and
  /// when [preferredRole] is customer or owner (matches the selected app flow).
  ///
  /// Does **not** overwrite an existing profile. If [preferredRole] is invalid,
  /// does nothing — the app router then sends the user to account profile bootstrap.
  Future<void> ensureMinimalUserDocumentIfMissing({
    required String preferredRole,
  }) async {
    if (preferredRole != UserRoles.owner &&
        preferredRole != UserRoles.customer) {
      if (kDebugMode) {
        AppBootLog.session('skip_minimal_profile_invalid_intent', {
          'preferredRole': preferredRole,
        });
      }
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final existing = await _userRepository.getUser(user.uid);
    if (existing != null) {
      if (kDebugMode) {
        AppBootLog.session('credential_login_profile_exists', {
          'authUid': user.uid,
          'userDocExists': true,
          'role': existing.role,
          'salonId': existing.salonId,
          'employeeId': existing.employeeId,
        });
      }
      return;
    }
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'User');
    if (kDebugMode) {
      AppBootLog.session('credential_login_create_minimal_profile', {
        'authUid': user.uid,
        'userDocExists': false,
        'role': preferredRole,
        'salonId': null,
        'employeeId': null,
      });
    }
    final minimalUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
      role: preferredRole,
      isActive: true,
      salonId: null,
      employeeId: null,
      onboardingCompleted: true,
      authProvider: 'password',
    );
    await _userRepository.createUserIfNotExists(minimalUser);
    final persisted = await _userRepository.getUser(user.uid);
    if (persisted == null) {
      throw FirebaseAuthException(
        code: 'profile-create-failed',
        message: 'Could not create user profile.',
      );
    }
    if (kDebugMode) {
      debugPrint(
        '[ensureMinimalUserDocumentIfMissing] Firestore user uid=${user.uid} '
        'role=$preferredRole userDocExists=true',
      );
    }
    AppBootLog.session(
      'ensureMinimalUserDocumentIfMissing_user_write_success',
      {
        'authUid': user.uid,
        'role': preferredRole,
        'salonId': persisted.salonId,
        'userDocExists': true,
      },
    );
  }

  Future<void> signInWithGoogle({required String newUserRole}) async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(provider);
      final user = credential.user;
      if (user != null) {
        _lastCredentialUid = user.uid;
        await _ensureFirestoreProfileAfterSignIn(
          user,
          newUserRole: newUserRole,
        );
      }
      return;
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final oauthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(oauthCredential);

    final user = _auth.currentUser;
    if (user != null) {
      _lastCredentialUid = user.uid;
      await _ensureFirestoreProfileAfterSignIn(user, newUserRole: newUserRole);
    }
  }

  Future<void> signInWithApple({required String newUserRole}) async {
    if (kIsWeb) {
      throw FirebaseAuthException(
        code: 'unsupported-platform',
        message: 'Apple sign-in is not enabled for web in this build.',
      );
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (appleCredential.identityToken == null) {
      throw FirebaseAuthException(
        code: 'apple-missing-token',
        message: 'Apple did not return an identity token.',
      );
    }

    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken);

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user;
    if (user == null) return;
    _lastCredentialUid = user.uid;

    var name = user.displayName ?? '';
    if (name.isEmpty &&
        (appleCredential.givenName != null ||
            appleCredential.familyName != null)) {
      name =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }
    }

    await _ensureFirestoreProfileAfterSignIn(
      _auth.currentUser ?? user,
      newUserRole: newUserRole,
    );
  }

  Future<void> signInWithFacebook({required String newUserRole}) async {
    if (kIsWeb) {
      throw FirebaseAuthException(
        code: 'unsupported-platform',
        message: 'Facebook sign-in is not enabled for web in this build.',
      );
    }

    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status != LoginStatus.success ||
        result.accessToken?.tokenString == null) {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'Facebook sign-in did not complete.',
      );
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    await _auth.signInWithCredential(credential);

    final user = _auth.currentUser;
    if (user != null) {
      _lastCredentialUid = user.uid;
      await _ensureFirestoreProfileAfterSignIn(user, newUserRole: newUserRole);
    }
  }

  Future<void> _ensureFirestoreProfileAfterSignIn(
    User user, {
    required String newUserRole,
  }) async {
    final existing = await _userRepository.getUser(user.uid);
    if (existing != null) {
      if (kDebugMode) {
        AppBootLog.session('oauth_existing_profile', {
          'authUid': user.uid,
          'userDocExists': true,
          'role': existing.role,
          'salonId': existing.salonId,
          'employeeId': existing.employeeId,
        });
      }
      return;
    }

    if (newUserRole != UserRoles.owner && newUserRole != UserRoles.customer) {
      if (kDebugMode) {
        AppBootLog.session('oauth_invalid_new_role', {
          'authUid': user.uid,
          'newUserRole': newUserRole,
        });
      }
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'OAuth signup role must be customer or owner.',
      );
    }

    if (kDebugMode) {
      AppBootLog.session('oauth_create_minimal_profile', {
        'authUid': user.uid,
        'userDocExists': false,
        'role': newUserRole,
        'salonId': null,
        'employeeId': null,
      });
    }
    final oauthUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : (user.email ?? 'User'),
      role: newUserRole,
      isActive: true,
      salonId: null,
      employeeId: null,
      onboardingCompleted: true,
      authProvider: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : null,
    );
    await _userRepository.createUserIfNotExists(oauthUser);
    final persisted = await _userRepository.getUser(user.uid);
    if (persisted == null) {
      throw FirebaseAuthException(
        code: 'profile-create-failed',
        message: 'Could not create user profile.',
      );
    }
    if (kDebugMode) {
      debugPrint(
        '[_ensureFirestoreProfileAfterSignIn] Firestore user uid=${user.uid} '
        'role=$newUserRole userDocExists=true',
      );
    }
    AppBootLog.session('oauthSignup_user_write_success', {
      'authUid': user.uid,
      'role': newUserRole,
      'salonId': persisted.salonId,
      'userDocExists': true,
    });
  }

  Future<void> _writeUserProfileWithLogging({
    required String flow,
    required AppUser user,
    bool merge = false,
  }) async {
    if (user.role == UserRoles.employee &&
        (user.salonId == null || user.salonId!.trim().isEmpty)) {
      throw FirebaseAuthException(
        code: 'invalid-user-state',
        message: 'Employee profile requires a valid salonId.',
      );
    }

    try {
      await _userRepository.createOrUpdateUser(user, merge: merge);
      final persisted = await _userRepository.getUser(user.uid);
      if (kDebugMode) {
        debugPrint(
          '[$flow] Firestore user write success uid=${user.uid} role=${user.role} '
          'salonId=${user.salonId ?? "(null)"}',
        );
        debugPrint(
          '[$flow] userDoc existence after signup: ${persisted != null}',
        );
      }
      AppBootLog.session('${flow}_user_write_success', {
        'authUid': user.uid,
        'role': user.role,
        'salonId': user.salonId,
        'userDocExists': persisted != null,
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[$flow] Firestore user write failure uid=${user.uid}: $error',
        );
      }
      AppBootLog.session('${flow}_user_write_failure', {
        'authUid': user.uid,
        'role': user.role,
        'salonId': user.salonId,
        'error': error.toString(),
      });
      rethrow;
    }
  }

  /// Anonymous Firebase Auth + `users/{uid}` customer guest row (upgradeable via link).
  Future<void> signInAsAnonymousGuestCustomer() async {
    if (kDebugMode) {
      debugPrint(
        '[GUEST_AUTH] before_signInAnonymously '
        'currentUid=${_auth.currentUser?.uid ?? "(none)"} '
        'isAnonymous=${_auth.currentUser?.isAnonymous}',
      );
    }

    final credential = await _auth.signInAnonymously();
    final user = credential.user;

    if (kDebugMode) {
      debugPrint(
        '[GUEST_AUTH] after_signInAnonymously '
        'uid=${user?.uid ?? "(null)"} isAnonymous=${user?.isAnonymous}',
      );
    }

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'Unable to start guest session.',
      );
    }

    final guestUser = AppUser(
      uid: user.uid,
      email: '',
      name: 'Guest',
      role: UserRoles.customer,
      isActive: true,
      salonId: null,
      employeeId: null,
      onboardingCompleted: true,
      authProvider: 'anonymous',
    );

    if (kDebugMode) {
      debugPrint(
        '[GUEST_AUTH] before_user_profile_merge path=users/${user.uid}',
      );
    }

    await _userRepository.createOrUpdateUser(guestUser, merge: true);
    await _userRepository.mergeProfileFields({
      'accountType': 'guest',
      'isAnonymous': true,
      'guestStatus': 'active',
    });

    if (kDebugMode) {
      debugPrint(
        '[GUEST_AUTH] after_user_profile_merge path=users/${user.uid}',
      );
    }

    AppBootLog.session('anonymous_guest_sign_in', {'authUid': user.uid});
    _lastCredentialUid = user.uid;
  }

  Future<void> logout() async {
    // #region agent log
    agentSessionLog(
      hypothesisId: 'H2',
      location: 'auth_repository.dart:logout',
      message: 'before_firebase_signOut',
      runId: 'logout-debug',
      data: <String, Object?>{'uid': _auth.currentUser?.uid ?? '(none)'},
    );
    // #endregion
    await FirebaseAuth.instance.signOut();
    _lastCredentialUid = null;
    // #region agent log
    agentSessionLog(
      hypothesisId: 'H2',
      location: 'auth_repository.dart:logout',
      message: 'after_firebase_signOut',
      runId: 'logout-debug',
      data: <String, Object?>{'uid': _auth.currentUser?.uid ?? '(none)'},
    );
    // #endregion
    if (!kIsWeb) {
      unawaited(_bestEffortSocialSignOut());
    }
  }

  /// Clears native Google / Facebook sessions without blocking app sign-out.
  /// [GoogleSignIn.signOut] can hang when called before Firebase sign-out on
  /// some devices; Firebase is the source of truth for session + routing.
  Future<void> _bestEffortSocialSignOut() async {
    try {
      await _googleSignIn.signOut().timeout(const Duration(seconds: 5));
    } catch (_) {}
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }
}
