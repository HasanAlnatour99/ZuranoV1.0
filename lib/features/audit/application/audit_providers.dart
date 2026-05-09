import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../../core/constants/user_roles.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/session_provider.dart';
import '../../permissions/application/permissions_providers.dart';
import '../../permissions/data/models/permission_key.dart';
import '../data/audit_repository.dart';
import '../data/models/audit_log_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(firestore: ref.read(firestoreProvider));
});

/// Matches [salon_route_permissions] rules for Activity Center / audit reads.
final canReadSalonActivityAuditProvider = Provider<bool>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  if (user == null) return false;
  if (user.role.trim() == UserRoles.owner) return true;
  return ref.watch(hasSalonPermissionProvider(PermissionKey.analyticsView)) ||
      ref.watch(hasSalonPermissionProvider(PermissionKey.settingsManage)) ||
      ref.watch(hasSalonPermissionProvider(PermissionKey.permissionsManage));
});

final auditModuleFilterProvider = StateProvider<String?>((ref) => null);

final auditActorUidFilterProvider = StateProvider<String?>((ref) => null);

final auditDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final auditSearchQueryProvider = StateProvider<String>((ref) => '');

final auditLogsRawProvider =
    StreamProvider.autoDispose<List<AuditLogModel>>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(const []);

  return ref.read(auditRepositoryProvider).watchAuditLogsSimple(
        salonId: salonId,
        limit: 250,
      );
});

final auditLogsProvider = Provider.autoDispose<AsyncValue<List<AuditLogModel>>>((ref) {
  final raw = ref.watch(auditLogsRawProvider);
  final module = ref.watch(auditModuleFilterProvider);
  final actorUid = ref.watch(auditActorUidFilterProvider);
  final range = ref.watch(auditDateRangeProvider);
  final q = ref.watch(auditSearchQueryProvider).trim().toLowerCase();

  return raw.whenData((logs) {
    var list = logs;
    if (module != null && module.isNotEmpty) {
      list = list.where((e) => e.module == module).toList();
    }
    if (actorUid != null && actorUid.isNotEmpty) {
      list = list.where((e) => e.actorUid == actorUid).toList();
    }
    if (range != null) {
      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final endDay = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
        999,
      );
      list = list.where((e) {
        final t = e.createdAt;
        if (t == null) return false;
        final local = t.toLocal();
        return !local.isBefore(start) && !local.isAfter(endDay);
      }).toList();
    }
    if (q.isNotEmpty) {
      list = list.where((e) {
        final hay = [
          e.summary,
          e.actionType,
          e.actorName,
          e.targetLabel ?? '',
          e.targetId ?? '',
        ].join(' ').toLowerCase();
        return hay.contains(q);
      }).toList();
    }
    return list;
  });
});

final auditLogDetailsProvider = StreamProvider.autoDispose
    .family<AuditLogModel?, String>((ref, auditId) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(null);
  return ref.read(auditRepositoryProvider).watchAuditLogDetails(salonId, auditId);
});
