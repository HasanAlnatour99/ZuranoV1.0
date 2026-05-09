import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/permissions/application/permissions_providers.dart';
import '../../features/permissions/data/models/permission_key.dart';

/// Shows [child] only when the signed-in user has [permission] for the current salon.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final PermissionKey permission;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ok = ref.watch(hasSalonPermissionProvider(permission));
    if (!ok) return fallback;
    return child;
  }
}
