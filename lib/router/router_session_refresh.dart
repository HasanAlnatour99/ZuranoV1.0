import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/user_roles.dart';
import '../core/session/app_session_status.dart';
import '../providers/firebase_providers.dart';
import '../providers/session_provider.dart';
import 'app_router.dart';

/// Reloads Firestore-backed entry session and bumps [GoRouter] so [redirect]
/// runs with fresh `users/{uid}` (e.g. after salon creation).
void refreshSessionAndRouter(Ref ref) {
  ref.invalidate(appEntrySessionProvider);
  ref.read(appRouterRefreshProvider).value++;
}

/// After anonymous guest sign-in + Firestore profile write, waits until
/// [appSessionBootstrapProvider] shows a ready customer so redirects and
/// `context.go` agree with loaded `users/{uid}`.
Future<void> refreshSessionAndRouterAwaitCustomerReady(Ref ref) async {
  refreshSessionAndRouter(ref);

  const timeout = Duration(seconds: 15);
  const step = Duration(milliseconds: 80);
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    if (!ref.mounted) {
      return;
    }

    final authUid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final session = ref.read(appSessionBootstrapProvider);

    if (authUid != null &&
        session.status == AppSessionStatus.ready &&
        session.user != null &&
        session.user!.role.trim() == UserRoles.customer) {
      if (kDebugMode) {
        debugPrint(
          '[GUEST_AUTH] after_session_refresh session=ready '
          'uid=$authUid role=${session.user!.role}',
        );
      }
      return;
    }

    if (session.status == AppSessionStatus.error) {
      throw StateError(
        session.error?.toString() ?? 'Session error after guest sign-in.',
      );
    }

    await Future<void>.delayed(step);
  }

  throw TimeoutException(
    'Guest session did not become ready within ${timeout.inSeconds}s.',
  );
}

/// Widget-layer auth / profile changes (same effect as [refreshSessionAndRouter]).
void refreshRouterAfterAuthChange(WidgetRef ref) {
  ref.invalidate(appEntrySessionProvider);
  ref.read(appRouterRefreshProvider).value++;
}
