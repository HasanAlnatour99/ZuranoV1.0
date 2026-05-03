import 'package:barber_shop_app/features/employee_dashboard/domain/enums/attendance_punch_type.dart';
import 'package:barber_shop_app/features/employee_today/domain/attendance_state_resolver.dart';
import 'package:barber_shop_app/features/owner/settings/attendance/domain/models/attendance_settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceStateResolver', () {
    const resolver = AttendanceStateResolver();

    AttendanceSettingsModel settings({bool breaks = true}) {
      return AttendanceSettingsModel.defaults(
        'salon_1',
      ).copyWith(breaksEnabled: breaks);
    }

    test('blocks punch in after punch out for the day', () {
      final result = resolver.resolve(
        settings: settings(),
        punchSequence: const ['punchIn', 'punchOut'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, isEmpty);
      expect(result.nextType, isNull);
      expect(result.blockMessage, contains('completed'));
    });

    test('blocks further work punches after one in and one out', () {
      final result = resolver.resolve(
        settings: settings(),
        punchSequence: const ['punchIn', 'breakOut', 'breakIn', 'punchOut'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, isEmpty);
      expect(result.nextType, isNull);
      expect(result.blockMessage, contains('completed'));
    });

    test('disables break out when breaks are turned off', () {
      final result = resolver.resolve(
        settings: settings(breaks: false),
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

    test('allows break in when last is break out (breaks do not count as work punches)', () {
      final result = resolver.resolve(
        settings: settings(),
        punchSequence: const ['punchIn', 'breakOut'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.nextType, AttendancePunchType.breakIn);
      expect(result.allowedTypes, {AttendancePunchType.breakIn});
    });

    test('allows break in while outside zone during open break', () {
      final result = resolver.resolve(
        settings: settings().copyWith(
          locationRequired: true,
          latitude: 25.0,
          longitude: 55.0,
          allowedRadiusMeters: 50,
        ),
        punchSequence: const ['punchIn', 'breakOut'],
        isInsideZone: false,
        attendanceRequired: true,
      );

      expect(result.nextType, AttendancePunchType.breakIn);
      expect(result.allowedTypes, contains(AttendancePunchType.breakIn));
    });

    test('allows punch out after break in when only one work punch so far', () {
      final result = resolver.resolve(
        settings: settings(),
        punchSequence: const ['punchIn', 'breakOut', 'breakIn'],
        isInsideZone: true,
        attendanceRequired: false,
      );

      expect(result.allowedTypes, contains(AttendancePunchType.punchOut));
      expect(result.nextType, AttendancePunchType.punchOut);
    });
  });
}
