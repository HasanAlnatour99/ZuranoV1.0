import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../employees/data/models/employee.dart';
import '../../../../core/constants/user_roles.dart';

/// Role shown on the team member profile (maps Firestore `employees.role`).
enum TeamMemberProfileRole { owner, admin, barber, teamMember }

/// View-model for the team member profile overview (backed by
/// `salons/{salonId}/employees/{employeeId}` — same document as [Employee]).
class TeamMemberModel {
  const TeamMemberModel({
    required this.employeeId,
    required this.salonId,
    required this.fullName,
    required this.searchName,
    required this.profileRole,
    required this.isActive,
    required this.isFrozen,
    required this.attendanceRequired,
    required this.commissionTypeRaw,
    required this.commissionPercent,
    required this.fixedSalary,
    required this.currencyCode,
    required this.bookableLater,
    this.uid,
    this.phone,
    this.phoneE164,
    this.email,
    this.profileImageUrl,
    this.profileImagePath,
    this.permissions = const {},
    this.createdAt,
    this.updatedAt,
    this.hiredAt,
  });

  final String employeeId;
  final String salonId;
  final String? uid;
  final String fullName;
  final String searchName;
  final TeamMemberProfileRole profileRole;
  final String? phone;
  final String? phoneE164;
  final String? email;
  final String? profileImageUrl;
  final String? profileImagePath;
  final bool isActive;
  final bool isFrozen;
  final bool attendanceRequired;
  final String commissionTypeRaw;
  final num commissionPercent;
  final num fixedSalary;
  final String currencyCode;
  final bool bookableLater;
  final Map<String, dynamic> permissions;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final DateTime? hiredAt;

  factory TeamMemberModel.fromEmployee(
    Employee employee, {
    required String currencyCode,
    String? phoneE164,
    bool? isFrozenOverride,
  }) {
    final frozen =
        isFrozenOverride ?? employee.status.trim().toLowerCase() == 'frozen';
    return TeamMemberModel(
      employeeId: employee.id,
      salonId: employee.salonId,
      uid: employee.uid,
      fullName: employee.name,
      searchName: employee.name.trim().toLowerCase(),
      profileRole: _profileRoleFromEmployeeRole(employee.role),
      phone: employee.phone,
      phoneE164: phoneE164,
      email: employee.email,
      profileImageUrl: employee.avatarUrl,
      profileImagePath: null,
      isActive: employee.isActive,
      isFrozen: frozen,
      attendanceRequired: employee.attendanceRequired,
      commissionTypeRaw: employee.commissionType,
      commissionPercent: employee.resolvedCommissionPercentage,
      fixedSalary: employee.resolvedCommissionFixedAmount,
      currencyCode: currencyCode.trim().isEmpty ? 'USD' : currencyCode.trim(),
      bookableLater: employee.isBookable,
      permissions: const {},
      createdAt: employee.createdAt != null
          ? Timestamp.fromDate(employee.createdAt!)
          : null,
      updatedAt: employee.updatedAt != null
          ? Timestamp.fromDate(employee.updatedAt!)
          : null,
      hiredAt: employee.hiredAt,
    );
  }

  bool get canBeBooked => isActive && !isFrozen && bookableLater;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || fullName.trim().isEmpty) return 'TM';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static TeamMemberProfileRole _profileRoleFromEmployeeRole(String role) {
    switch (role.trim()) {
      case UserRoles.owner:
        return TeamMemberProfileRole.owner;
      case UserRoles.admin:
        return TeamMemberProfileRole.admin;
      case UserRoles.barber:
      case UserRoles.employee:
        return TeamMemberProfileRole.barber;
      case UserRoles.readonly:
        return TeamMemberProfileRole.teamMember;
      default:
        return TeamMemberProfileRole.teamMember;
    }
  }
}
