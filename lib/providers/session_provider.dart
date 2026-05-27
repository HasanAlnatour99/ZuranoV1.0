import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/boot/app_boot_log.dart';
import '../core/constants/user_roles.dart';
import '../core/firestore/firestore_paths.dart';
import '../core/session/app_entry_session.dart';
import '../core/session/app_session_status.dart';
import '../core/session/app_user_session_validation.dart';
import '../features/salon/data/models/salon.dart';
import '../features/salon/data/salon_repository.dart';
import '../features/users/data/models/app_user.dart';
import '../features/users/data/user_repository.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';

const Duration _startupUserReadTimeout = Duration(seconds: 10);
const Duration _startupSalonReadTimeout = Duration(seconds: 10);

// -----------------------------------------------------------------------------
// Startup flow (Auth + Firestore users/{uid})
// -----------------------------------------------------------------------------
//
// 1) **Signed out** — `authStateChanges` emits null → [AppEntrySessionSignedOut].
// 2) **Signed in, profile missing (race or true gap)** — first `getUser` may be
//    null right after signup; we watch `users/{uid}` until it exists or time out,
//    then [AppEntrySessionReady] / bootstrap only if still missing.
// 3) **Signed in, valid profile** — `getUser` succeeds → watch `users/{uid}` →
//    [AppEntrySessionReady] or [AppEntrySessionStaffLinkageIncomplete].
// 4) **Staff without salonId/employeeId** — incomplete linkage → recovery route
//    (no dashboard, no create-salon).
// 5) **Customers / admins / barbers** — routed only from [AppEntrySessionReady]
//    using role + validation; customers never hit create-salon.
// -----------------------------------------------------------------------------

AppEntrySession _mapLoadedUserToSession(AppUser u) {
  if (classifyStaffLinkage(u) == ProfileIntegrityIssue.staffMissingLinkage) {
    return AppEntrySessionStaffLinkageIncomplete(u);
  }
  return AppEntrySessionReady(u);
}

Future<void> _debugLogAfterUserLoad({
  required Ref ref,
  required String uid,
  required AppUser? user,
  required SalonRepository salonRepository,
}) async {
  if (!ref.mounted) {
    return;
  }
  if (user == null) {
    _debugLogSession(
      ref: ref,
      uid: uid,
      userDocExists: false,
      salonDocExistsLabel: 'n/a',
      salonId: null,
      role: null,
    );
    AppBootLog.session('profile_snapshot', {
      'authUid': uid,
      'userDocExists': false,
      'role': null,
      'salonId': null,
      'employeeId': null,
    });
    return;
  }
  if (!ref.mounted) {
    return;
  }
  final sid = user.salonId?.trim();
  if (sid == null || sid.isEmpty) {
    _debugLogSession(
      ref: ref,
      uid: uid,
      userDocExists: true,
      salonDocExistsLabel: 'n/a',
      salonId: null,
      role: user.role,
    );
    AppBootLog.session('profile_snapshot', {
      'authUid': uid,
      'userDocExists': true,
      'role': user.role,
      'salonId': null,
      'employeeId': user.employeeId,
    });
    return;
  }
  if (!ref.mounted) {
    return;
  }
  Salon? salon;
  String? salonFetchErrorCode;
  try {
    AppBootLog.session('startup_salon_read_begin', {
      'authUid': uid,
      'path': FirestorePaths.salon(sid),
      'timeoutMs': _startupSalonReadTimeout.inMilliseconds,
    });
    salon = await salonRepository
        .getSalon(sid)
        .timeout(_startupSalonReadTimeout);
    if (!ref.mounted) {
      return;
    }
    AppBootLog.session('startup_salon_read_success', {
      'authUid': uid,
      'path': FirestorePaths.salon(sid),
      'exists': salon != null,
    });
  } on FirebaseException catch (e) {
    salonFetchErrorCode = e.code;
    ref
        .read(appLoggerProvider)
        .warn(
          '[firebase_session] getSalon failed for salonId=$sid: ${e.code} ${e.message}',
        );
    salon = null;
  } on TimeoutException {
    salonFetchErrorCode = 'timeout';
    AppBootLog.session('startup_salon_read_timeout', {
      'authUid': uid,
      'path': FirestorePaths.salon(sid),
      'timeoutMs': _startupSalonReadTimeout.inMilliseconds,
    });
    ref
        .read(appLoggerProvider)
        .warn(
          '[firebase_session] getSalon timed out for salonId=$sid; continuing startup.',
        );
    salon = null;
  }
  final salonLabel = salonFetchErrorCode != null
      ? 'error:$salonFetchErrorCode'
      : '${salon != null}';
  _debugLogSession(
    ref: ref,
    uid: uid,
    userDocExists: true,
    salonDocExistsLabel: salonLabel,
    salonId: sid,
    role: user.role,
  );
  AppBootLog.session('profile_snapshot', {
    'authUid': uid,
    'userDocExists': true,
    'role': user.role,
    'salonId': sid,
    'employeeId': user.employeeId,
  });
}

/// After email/password signup, Firebase Auth can emit before `users/{uid}`
/// exists. Watch the document until it appears (or time out) so owners reach
/// [AppEntrySessionReady] / [AppSessionStatus.ownerNeedsSalon] instead of
/// staying stuck on profile bootstrap.
Stream<AppEntrySession> _watchUntilUserDocAppears({
  required String uid,
  required UserRepository userRepository,
}) {
  StreamSubscription<AppUser?>? subscription;
  Timer? timeout;
  var completed = false;

  void complete() {
    if (completed) {
      return;
    }
    completed = true;
    timeout?.cancel();
    subscription?.cancel();
  }

  late final StreamController<AppEntrySession> controller;
  controller = StreamController<AppEntrySession>(
    onListen: () {
      subscription = userRepository
          .watchUser(uid)
          .listen(
            (next) {
              if (completed || controller.isClosed) {
                return;
              }
              if (next != null) {
                if (!controller.isClosed) {
                  controller.add(_mapLoadedUserToSession(next));
                }
                complete();
                if (!controller.isClosed) {
                  unawaited(controller.close());
                }
              }
            },
            onError: (Object e, StackTrace st) {
              if (completed || controller.isClosed) {
                return;
              }
              if (!controller.isClosed) {
                controller.addError(e, st);
              }
              complete();
              if (!controller.isClosed) {
                unawaited(controller.close());
              }
            },
          );

      timeout = Timer(const Duration(seconds: 20), () {
        if (completed || controller.isClosed) {
          return;
        }
        if (!controller.isClosed) {
          controller.add(AppEntrySessionProfileMissing(uid: uid));
        }
        complete();
        if (!controller.isClosed) {
          unawaited(controller.close());
        }
      });
    },
    onCancel: () {
      complete();
    },
  );

  if (kDebugMode) {
    AppBootLog.session('profile_missing_watch_start', {'authUid': uid});
  }

  return controller.stream;
}

Future<AppEntrySession> _loadInitialEntrySession({
  required Ref ref,
  required String uid,
  required UserRepository userRepository,
  required SalonRepository salonRepository,
}) async {
  try {
    AppBootLog.session('startup_user_read_begin', {
      'authUid': uid,
      'path': FirestorePaths.user(uid),
      'timeoutMs': _startupUserReadTimeout.inMilliseconds,
    });
    final existing = await userRepository
        .getUser(uid)
        .timeout(_startupUserReadTimeout);
    if (!ref.mounted) {
      if (existing == null) {
        return AppEntrySessionProfileMissing(uid: uid);
      }
      return _mapLoadedUserToSession(existing);
    }
    AppBootLog.session('startup_user_read_success', {
      'authUid': uid,
      'path': FirestorePaths.user(uid),
      'exists': existing != null,
    });
    await _debugLogAfterUserLoad(
      ref: ref,
      uid: uid,
      user: existing,
      salonRepository: salonRepository,
    );
    if (existing == null) {
      return AppEntrySessionProfileMissing(uid: uid);
    }
    return _mapLoadedUserToSession(existing);
  } on FirebaseException catch (e, st) {
    AppBootLog.session('profile_load_error', {
      'authUid': uid,
      'error': e.toString(),
      'code': e.code,
    });
    return AppEntrySessionError(e, st);
  } catch (e, st) {
    AppBootLog.session('profile_load_error', {
      'authUid': uid,
      'error': e.toString(),
    });
    return AppEntrySessionError(e, st);
  }
}

void _debugLogSession({
  required Ref ref,
  required String uid,
  required bool userDocExists,
  String? salonDocExistsLabel,
  String? salonId,
  String? role,
}) {
  ref
      .read(appLoggerProvider)
      .debug(
        '[firebase_session] authUid=$uid userDocExists=$userDocExists '
        'salonDocExists=${salonDocExistsLabel ?? 'n/a'} '
        'currentSalonId=${salonId ?? 'null'} currentRole=${role ?? 'null'}',
      );
}

Stream<AppEntrySession> watchAppEntrySession(Ref ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final salonRepository = ref.read(salonRepositoryProvider);

  return authRepository.authStateChanges().asyncExpand((authUser) {
    AppBootLog.session('auth_state_read', {
      'authUid': authUser?.uid ?? '(signed-out)',
    });
    if (authUser == null) {
      _debugLogSession(
        ref: ref,
        uid: '(signed-out)',
        userDocExists: false,
        salonDocExistsLabel: 'n/a',
        salonId: null,
        role: null,
      );
      AppBootLog.session('signed_out', <String, Object?>{});
      return Stream<AppEntrySession>.value(const AppEntrySessionSignedOut());
    }

    return Stream<AppEntrySession>.fromFuture(
      _loadInitialEntrySession(
        ref: ref,
        uid: authUser.uid,
        userRepository: userRepository,
        salonRepository: salonRepository,
      ),
    ).asyncExpand((initial) {
      switch (initial) {
        case AppEntrySessionProfileMissing(:final uid):
          return _watchUntilUserDocAppears(
            uid: uid,
            userRepository: userRepository,
          );
        case AppEntrySessionError():
          return Stream<AppEntrySession>.value(initial);
        case AppEntrySessionSignedOut():
          return Stream<AppEntrySession>.value(initial);
        case AppEntrySessionReady(:final user):
        case AppEntrySessionStaffLinkageIncomplete(:final user):
          return userRepository.watchUser(user.uid).map((next) {
            if (next == null) {
              return AppEntrySessionProfileMissing(uid: user.uid);
            }
            return _mapLoadedUserToSession(next);
          });
      }
    });
  });
}

/// Single source of truth for startup routing: Auth + Firestore profile.
final appEntrySessionProvider = StreamProvider<AppEntrySession>((ref) {
  return watchAppEntrySession(ref);
});

AppSessionState _mapEntryToAppSessionState(
  AsyncValue<AppEntrySession> entryAsync,
  Ref ref,
) {
  final authUid = ref.read(firebaseAuthProvider).currentUser?.uid;
  if (entryAsync.isLoading) {
    return AppSessionState(
      status: AppSessionStatus.initializing,
      firebaseUid: authUid,
    );
  }
  if (entryAsync.hasError) {
    return AppSessionState(
      status: AppSessionStatus.error,
      error: entryAsync.error,
      firebaseUid: authUid,
    );
  }
  final entry = entryAsync.asData?.value;
  if (entry == null) {
    return AppSessionState(
      status: AppSessionStatus.initializing,
      firebaseUid: authUid,
    );
  }
  switch (entry) {
    case AppEntrySessionSignedOut():
      return const AppSessionState(status: AppSessionStatus.unauthenticated);
    case AppEntrySessionProfileMissing(:final uid):
      return AppSessionState(
        status: AppSessionStatus.profileIncomplete,
        firebaseUid: uid,
      );
    case AppEntrySessionStaffLinkageIncomplete(:final user):
      return AppSessionState(
        status: AppSessionStatus.profileIncomplete,
        user: user,
        firebaseUid: user.uid,
      );
    case AppEntrySessionError(:final error):
      return AppSessionState(
        status: AppSessionStatus.error,
        error: error,
        firebaseUid: authUid,
      );
    case AppEntrySessionReady(:final user):
      final ownerWithoutSalon =
          user.role == UserRoles.owner &&
          (user.salonId == null || user.salonId!.trim().isEmpty);
      return AppSessionState(
        status: ownerWithoutSalon
            ? AppSessionStatus.ownerNeedsSalon
            : AppSessionStatus.ready,
        user: user,
        firebaseUid: user.uid,
      );
  }
}

class AppSessionBootstrapNotifier extends Notifier<AppSessionState> {
  @override
  AppSessionState build() {
    ref.listen<AsyncValue<AppEntrySession>>(appEntrySessionProvider, (_, next) {
      if (!ref.mounted) {
        return;
      }
      state = _mapEntryToAppSessionState(next, ref);
    });
    return _mapEntryToAppSessionState(ref.read(appEntrySessionProvider), ref);
  }
}

final appSessionBootstrapProvider =
    NotifierProvider<AppSessionBootstrapNotifier, AppSessionState>(
      AppSessionBootstrapNotifier.new,
    );

/// Firestore-backed [AppUser] for feature code; `null` when signed out or when
/// the profile doc is missing (use [appEntrySessionProvider] for that case).
///
/// Subscribes only to [appEntrySessionProvider] so we do not attach a second
/// Auth/Firestore bootstrap stream (avoids duplicate work and disposed-ref use
/// after async gaps in the entry stream).
final sessionUserProvider = StreamProvider<AppUser?>((ref) {
  final controller = StreamController<AppUser?>();

  void emit(AsyncValue<AppEntrySession> next) {
    if (!ref.mounted || controller.isClosed) {
      return;
    }
    next.when(
      data: (AppEntrySession entry) {
        final AppUser? user = switch (entry) {
          AppEntrySessionReady(:final user) => user,
          AppEntrySessionStaffLinkageIncomplete(:final user) => user,
          _ => null,
        };
        if (!controller.isClosed) {
          controller.add(user);
        }
      },
      loading: () {},
      error: (Object e, StackTrace st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      },
    );
  }

  emit(ref.read(appEntrySessionProvider));
  final sub = ref.listen<AsyncValue<AppEntrySession>>(
    appEntrySessionProvider,
    (_, next) => emit(next),
  );

  ref.onDispose(() {
    sub.close();
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Emits [AppUser.salonId] for the signed-in user, or `null` when signed out
/// or the salon is not set.
///
/// Does **not** subscribe to [UserRepository.watchUser] until `users/{uid}`
/// exists (one-shot [UserRepository.getUser] first), so salon-scoped listeners
/// stay idle until the profile exists.
Stream<String?> watchSessionSalonId(Ref ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);

  return authRepository.authStateChanges().asyncExpand((authUser) {
    if (authUser == null) {
      return Stream<String?>.value(null);
    }

    return Stream<AppUser?>.fromFuture(() async {
      try {
        return await userRepository
            .getUser(authUser.uid)
            .timeout(_startupUserReadTimeout);
      } catch (_) {
        return null;
      }
    }()).asyncExpand((existing) {
      if (existing == null) {
        return Stream<String?>.value(null);
      }
      return userRepository
          .watchUser(authUser.uid)
          .map((user) => user?.salonId);
    });
  });
}
