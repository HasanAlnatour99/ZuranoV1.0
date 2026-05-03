import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../data/models/et_attendance_punch.dart';

/// One shift per day: one punch in + one punch out. Break events are excluded.
const int kMaxWorkPunchesPerDay = 2;

bool _isWorkPunchName(String name) =>
    name == AttendancePunchType.punchIn.name ||
    name == AttendancePunchType.punchOut.name;

bool _isWorkPunchType(AttendancePunchType t) =>
    t == AttendancePunchType.punchIn || t == AttendancePunchType.punchOut;

int workPunchCountInSequenceNames(Iterable<String> names) =>
    names.where(_isWorkPunchName).length;

int workPunchCountInTypes(Iterable<AttendancePunchType> types) =>
    types.where(_isWorkPunchType).length;

int workPunchCountInPunches(Iterable<EtAttendancePunch> punches) =>
    workPunchCountInTypes(punches.map((p) => p.type));
