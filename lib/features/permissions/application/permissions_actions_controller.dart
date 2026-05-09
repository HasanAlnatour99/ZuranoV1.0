import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';

class PermissionsActionsState {
  const PermissionsActionsState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  PermissionsActionsState copyWith({bool? isLoading, String? errorMessage}) {
    return PermissionsActionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PermissionsActionsController extends Notifier<PermissionsActionsState> {
  @override
  PermissionsActionsState build() => const PermissionsActionsState();

  Future<void> bootstrapStaffDocuments() async {
    final salonId = _salonId();
    if (salonId == null) {
      state = state.copyWith(errorMessage: 'missing_salon');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(permissionsRepositoryProvider).bootstrapSalonStaffForOwner(
            salonId,
          );
      await _refreshCallerToken();
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'generic_error');
    }
  }

  Future<void> updateStaffPermissions({
    required String targetUid,
    required Map<String, bool> permissions,
  }) async {
    final salonId = _salonId();
    if (salonId == null) {
      state = state.copyWith(errorMessage: 'missing_salon');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(permissionsRepositoryProvider).updateStaffPermissions(
            salonId: salonId,
            targetUid: targetUid,
            permissions: permissions,
          );
      await ref.read(permissionsRepositoryProvider).syncUserClaimsForStaff(
            salonId: salonId,
            targetUid: targetUid,
          );
      await _refreshCallerToken();
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'generic_error');
    }
  }

  Future<void> assignRolePreset({
    required String targetUid,
    required String roleId,
  }) async {
    final salonId = _salonId();
    if (salonId == null) {
      state = state.copyWith(errorMessage: 'missing_salon');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(permissionsRepositoryProvider).assignRolePresetToStaff(
            salonId: salonId,
            targetUid: targetUid,
            roleId: roleId,
          );
      await ref.read(permissionsRepositoryProvider).syncUserClaimsForStaff(
            salonId: salonId,
            targetUid: targetUid,
          );
      await _refreshCallerToken();
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'generic_error');
    }
  }

  Future<void> setStaffActive({
    required String targetUid,
    required bool isActive,
  }) async {
    final salonId = _salonId();
    if (salonId == null) {
      state = state.copyWith(errorMessage: 'missing_salon');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(permissionsRepositoryProvider).setStaffActiveStatus(
            salonId: salonId,
            targetUid: targetUid,
            isActive: isActive,
          );
      await ref.read(permissionsRepositoryProvider).syncUserClaimsForStaff(
            salonId: salonId,
            targetUid: targetUid,
          );
      await _refreshCallerToken();
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'generic_error');
    }
  }

  String? _salonId() {
    final user = ref.read(sessionUserProvider).asData?.value;
    final id = user?.salonId?.trim() ?? '';
    return id.isEmpty ? null : id;
  }

  Future<void> _refreshCallerToken() async {
    await ref.read(firebaseAuthProvider).currentUser?.getIdToken(true);
  }
}

final permissionsActionsControllerProvider =
    NotifierProvider<PermissionsActionsController, PermissionsActionsState>(
  PermissionsActionsController.new,
);
