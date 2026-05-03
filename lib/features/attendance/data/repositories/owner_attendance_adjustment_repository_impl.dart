import '../../domain/repositories/owner_attendance_adjustment_repository.dart';
import '../datasources/attendance_adjustment_remote_datasource.dart';

class OwnerAttendanceAdjustmentRepositoryImpl
    implements OwnerAttendanceAdjustmentRepository {
  OwnerAttendanceAdjustmentRepositoryImpl({
    required AttendanceAdjustmentRemoteDataSource datasource,
  }) : _ds = datasource;

  final AttendanceAdjustmentRemoteDataSource _ds;

  @override
  Future<OwnerAttendanceAdjustmentLoad> loadContext({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
  }) =>
      _ds.load(
        salonId: salonId,
        employeeId: employeeId,
        attendanceDate: attendanceDate,
      );

  @override
  Future<OwnerAttendanceAdjustmentSaveResult> saveViaCloudFunction({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
    String? shiftId,
    required String statusApiValue,
    required DateTime? punchInAt,
    required DateTime? breakOutAt,
    required DateTime? breakInAt,
    required DateTime? punchOutAt,
    required String reason,
    String? managerNote,
  }) =>
      _ds.reprocessAttendance(
        salonId: salonId,
        employeeId: employeeId,
        attendanceDate: attendanceDate,
        shiftId: shiftId,
        status: statusApiValue,
        punchInAt: punchInAt,
        breakOutAt: breakOutAt,
        breakInAt: breakInAt,
        punchOutAt: punchOutAt,
        reason: reason,
        managerNote: managerNote,
      );
}
