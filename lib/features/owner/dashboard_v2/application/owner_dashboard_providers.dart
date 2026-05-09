import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../data/models/owner_dashboard_snapshot_model.dart';
import 'owner_dashboard_actions_controller.dart';

String _todayKey(DateTime now) {
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _periodId(DateTime now) {
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  return '$y-$m';
}

final todayDashboardSnapshotProvider =
    StreamProvider.autoDispose<OwnerDashboardSnapshotModel?>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(null);
  final today = _todayKey(DateTime.now());
  return ref.read(ownerDashboardRepositoryProvider).watchDailySnapshot(
        salonId,
        today,
      );
});

final currentMonthDashboardSnapshotProvider =
    StreamProvider.autoDispose<OwnerDashboardSnapshotModel?>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(null);
  final pid = _periodId(DateTime.now());
  return ref.read(ownerDashboardRepositoryProvider).watchMonthlySnapshot(
        salonId,
        pid,
      );
});

/// Alias requested by dashboard wiring (refresh/regenerate snapshots).
final ownerDashboardRefreshControllerProvider =
    ownerDashboardActionsControllerProvider;

