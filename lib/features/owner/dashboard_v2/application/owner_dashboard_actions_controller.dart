import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';

class OwnerDashboardRefreshState {
  const OwnerDashboardRefreshState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;
}

class OwnerDashboardActionsController extends Notifier<OwnerDashboardRefreshState> {
  @override
  OwnerDashboardRefreshState build() => const OwnerDashboardRefreshState();

  Future<void> refresh() async {
    final user = ref.read(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    if (salonId.isEmpty) {
      state = const OwnerDashboardRefreshState(
        isLoading: false,
        errorMessage: 'missing_salon',
      );
      return;
    }

    state = const OwnerDashboardRefreshState(isLoading: true);
    try {
      await ref.read(ownerDashboardRepositoryProvider).generateSnapshot(salonId);
      state = const OwnerDashboardRefreshState(isLoading: false);
    } catch (_) {
      state = const OwnerDashboardRefreshState(
        isLoading: false,
        errorMessage: 'generic_error',
      );
    }
  }
}

final ownerDashboardActionsControllerProvider =
    NotifierProvider<OwnerDashboardActionsController, OwnerDashboardRefreshState>(
  OwnerDashboardActionsController.new,
);

