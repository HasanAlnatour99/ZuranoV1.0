import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/cloud_functions_region.dart';
import '../../../providers/firebase_providers.dart';
import '../data/datasources/attendance_adjustment_remote_datasource.dart';
import '../data/repositories/owner_attendance_adjustment_repository_impl.dart';
import '../domain/repositories/owner_attendance_adjustment_repository.dart';
import 'attendance_adjustment_form_state.dart';

final attendanceAdjustmentRemoteDataSourceProvider =
    Provider<AttendanceAdjustmentRemoteDataSource>((ref) {
  return AttendanceAdjustmentRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    functions: appCloudFunctions(),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final ownerAttendanceAdjustmentRepositoryProvider =
    Provider<OwnerAttendanceAdjustmentRepository>((ref) {
  return OwnerAttendanceAdjustmentRepositoryImpl(
    datasource: ref.watch(attendanceAdjustmentRemoteDataSourceProvider),
  );
});

final attendanceAdjustmentLoadProvider =
    FutureProvider.autoDispose.family<OwnerAttendanceAdjustmentLoad, AttendanceAdjustmentParams>((ref, params) async {
  return ref.read(ownerAttendanceAdjustmentRepositoryProvider).loadContext(
        salonId: params.salonId,
        employeeId: params.employeeId,
        attendanceDate: params.day,
      );
});
