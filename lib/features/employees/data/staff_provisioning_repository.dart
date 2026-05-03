import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/text/team_member_name.dart';
import '../domain/staff_provisioning_exception.dart';
import '../domain/employee_role.dart';
import 'models/staff_provisioning_result.dart';
import 'staff_invite_remote_data_source.dart';
import 'staff_provisioning_error_mapper.dart';

class StaffProvisioningRepository {
  StaffProvisioningRepository({required StaffInviteRemoteDataSource remote})
    : _remote = remote;

  final StaffInviteRemoteDataSource _remote;

  /// Creates Firebase Auth + `users/{uid}` + employee row via Cloud Function.
  Future<StaffProvisioningResult> createStaffMemberWithAuth({
    required String salonId,
    required String email,
    required String username,
    required String displayName,
    required String password,
    String? phone,
    String? role,
    required double commissionPercent,
    required bool attendanceRequired,
    required bool isBookable,
    required bool isActive,
    required Map<String, bool> permissions,
  }) async {
    final formattedDisplayName = formatTeamMemberName(displayName);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const StaffProvisioningException(
        StaffProvisioningFailureKind.invalidArgument,
        message: 'Email is required.',
      );
    }
    final normalizedRole = _validatedProvisioningRole(role);
    try {
      developer.log(
        'staff_provisioning invoke ${StaffInviteRemoteDataSource.callableName} '
        'sanitizedPayload={displayNameLen: ${formattedDisplayName.length}, '
        'displayNameTrimmedEmpty: ${formattedDisplayName.isEmpty}, '
        'email: $normalizedEmail, username: ${username.trim()}, '
        'role: $normalizedRole }',
        name: 'staff_provisioning',
      );
      final map = await _remote.createStaffWithAuth(
        salonId: salonId,
        email: normalizedEmail,
        username: username.trim(),
        displayName: formattedDisplayName,
        password: password,
        role: normalizedRole,
        phone: phone,
        commissionPercent: commissionPercent,
        attendanceRequired: attendanceRequired,
        isBookable: isBookable,
        isActive: isActive,
        permissions: permissions,
      );
      final employeeId = map['employeeId']?.toString() ?? '';
      final uid = map['uid']?.toString() ?? '';
      final outEmail = map['email']?.toString() ?? '';
      final outUsername = map['username']?.toString() ?? username.trim();
      if (employeeId.isEmpty || uid.isEmpty) {
        throw StaffProvisioningException(
          StaffProvisioningFailureKind.unknown,
          message: 'Invalid server response.',
        );
      }
      return StaffProvisioningResult(
        employeeId: employeeId,
        uid: uid,
        email: outEmail,
        username: outUsername,
      );
    } on FirebaseFunctionsException catch (e, stackTrace) {
      developer.log(
        'FirebaseFunctionsException code=${e.code} message=${e.message} '
        'details=${e.details}',
        name: 'staff_provisioning',
        error: e,
        stackTrace: stackTrace,
      );
      throw _mapFunctionsException(e);
    }
  }

  Never _mapFunctionsException(FirebaseFunctionsException e) {
    final kind = staffProvisioningFailureKindForCode(e.code);
    throw StaffProvisioningException(kind, message: e.message, code: e.code);
  }

  String _validatedProvisioningRole(String? role) {
    try {
      final parsed = employeeRoleFromString(role);
      if (parsed == EmployeeRole.owner) {
        throw const StaffProvisioningException(
          StaffProvisioningFailureKind.invalidArgument,
          message: 'Missing or invalid role.',
        );
      }
      return employeeRoleToFirestoreString(parsed);
    } on StaffProvisioningException {
      rethrow;
    } catch (_) {
      throw const StaffProvisioningException(
        StaffProvisioningFailureKind.invalidArgument,
        message: 'Missing or invalid role.',
      );
    }
  }
}
