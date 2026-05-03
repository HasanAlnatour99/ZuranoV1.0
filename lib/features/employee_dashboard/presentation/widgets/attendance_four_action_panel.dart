import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/employee_today_attendance_vm.dart';
import '../../domain/enums/attendance_punch_type.dart';

class AttendanceFourActionPanel extends StatelessWidget {
  const AttendanceFourActionPanel({
    super.key,
    required this.vm,
    required this.busyType,
    required this.onPunch,
  });

  final EmployeeTodayAttendanceVm vm;
  final AttendancePunchType? busyType;
  final ValueChanged<AttendancePunchType> onPunch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actionInFlight = busyType != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(
          type: AttendancePunchType.punchIn,
          label: l10n.employeeTodayPunchIn,
          icon: Icons.login_rounded,
          color: const Color(0xFF16A34A),
          enabled: !actionInFlight && vm.canPunch(AttendancePunchType.punchIn),
          loading: busyType == AttendancePunchType.punchIn,
          onTap: onPunch,
        ),
        _ActionItem(
          type: AttendancePunchType.breakOut,
          label: l10n.employeeTodayBreakOut,
          icon: Icons.free_breakfast_outlined,
          color: const Color(0xFFF59E0B),
          enabled: !actionInFlight && vm.canPunch(AttendancePunchType.breakOut),
          loading: busyType == AttendancePunchType.breakOut,
          onTap: onPunch,
        ),
        _ActionItem(
          type: AttendancePunchType.breakIn,
          label: l10n.employeeTodayBreakIn,
          icon: Icons.coffee_rounded,
          color: const Color(0xFF4F46E5),
          enabled: !actionInFlight && vm.canPunch(AttendancePunchType.breakIn),
          loading: busyType == AttendancePunchType.breakIn,
          onTap: onPunch,
        ),
        _ActionItem(
          type: AttendancePunchType.punchOut,
          label: l10n.employeeTodayPunchOut,
          icon: Icons.logout_rounded,
          color: const Color(0xFFDC2626),
          enabled: !actionInFlight && vm.canPunch(AttendancePunchType.punchOut),
          loading: busyType == AttendancePunchType.punchOut,
          onTap: onPunch,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final AttendancePunchType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final bool loading;
  final ValueChanged<AttendancePunchType> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          GestureDetector(
            onTap: enabled && !loading ? () => onTap(type) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: enabled
                    ? color.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: enabled
                      ? color.withValues(alpha: 0.18)
                      : Colors.grey.withValues(alpha: 0.12),
                ),
              ),
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Icon(
                        icon,
                        color: enabled
                            ? color
                            : Colors.grey.withValues(alpha: 0.35),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
