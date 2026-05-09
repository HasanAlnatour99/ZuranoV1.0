import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../core/constants/user_roles.dart';
import '../../permissions/application/permissions_providers.dart';
import '../../permissions/data/models/permission_key.dart';
import '../data/models/export_job_model.dart';
import '../data/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(
    firestore: ref.read(firestoreProvider),
    functions: ref.read(firebaseFunctionsProvider),
  );
});

/// CSV audit export from Activity Center (`permissions.manage` or `settings.manage`, or owner).
final canExportAuditCsvProvider = Provider<bool>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  if (user == null) return false;
  if (user.role.trim() == UserRoles.owner) return true;
  return ref.watch(hasSalonPermissionProvider(PermissionKey.permissionsManage)) ||
      ref.watch(hasSalonPermissionProvider(PermissionKey.settingsManage));
});

/// Anyone who can run at least one export type can open Reports Center.
final canAccessReportsCenterProvider = Provider<bool>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  if (user == null) return false;
  if (user.role.trim() == UserRoles.owner) return true;
  final keys = <PermissionKey>[
    PermissionKey.salesView,
    PermissionKey.payrollView,
    PermissionKey.attendanceView,
    PermissionKey.expensesView,
    PermissionKey.permissionsManage,
    PermissionKey.settingsManage,
  ];
  for (final k in keys) {
    if (ref.watch(hasSalonPermissionProvider(k))) {
      return true;
    }
  }
  return false;
});

final exportJobsProvider =
    StreamProvider.autoDispose<List<ExportJobModel>>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(const []);
  return ref.read(reportsRepositoryProvider).watchExportJobs(salonId);
});

final exportJobDetailsProvider =
    StreamProvider.autoDispose.family<ExportJobModel?, String>((ref, jobId) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(null);
  return ref.read(reportsRepositoryProvider).watchExportJob(salonId, jobId);
});
