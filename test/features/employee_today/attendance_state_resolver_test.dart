import 'package:barber_shop_app/features/employee_dashboard/domain/enums/attendance_punch_type.dart';
import 'package:barber_shop_app/features/employee_today/domain/attendance_state_resolver.dart';
import 'package:barber_shop_app/features/owner/settings/attendance/domain/models/attendance_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceStateResolver', () {
    const resolver = AttendanceStateResolver();

    AttendanceSettingsModel settings({
      int maxPunches = 10,
      bool breaks = true,
    }) {
      return AttendanceSettingsModel.defaults(
        'salon_1',
      ).copyWith(maxPunchesPerDay: maxPunches, breaksEnabled: breaks);
    }

    test('allows punch in again after punch out within max punches', () {
      final result = resolver.resolve(
        settings: settings(maxPunches: 10),
        punchSequence: const ['punchIn', 'punchOut'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.nextType, AttendancePunchType.punchIn);
      expect(result.allowedTypes, contains(AttendancePunchType.punchIn));
    });

    test('respects configured max punches above legacy 4', () {
      final result = resolver.resolve(
        settings: settings(maxPunches: 10),
        punchSequence: const ['punchIn', 'punchOut', 'punchIn', 'punchOut'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, isNotEmpty);
      expect(result.allowedTypes, contains(AttendancePunchType.punchIn));
    });

    test('blocks all actions once max punches reached', () {
      final result = resolver.resolve(
        settings: settings(maxPunches: 6),
        punchSequence: const [
          'punchIn',
          'breakOut',
          'breakIn',
          'punchOut',
          'punchIn',
          'punchOut',
        ],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, isEmpty);
      expect(result.nextType, isNull);
      expect(result.blockMessage, contains('completed'));
    });

    test('disables break out when breaks are turned off', () {
      final result = resolver.resolve(
        settings: settings(maxPunches: 10, breaks: false),
        punchSequence: const ['punchIn'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, contains(AttendancePunchType.punchOut));
      expect(
        result.allowedTypes,
        isNot(contains(AttendancePunchType.breakOut)),
      );
    });
  });
}
