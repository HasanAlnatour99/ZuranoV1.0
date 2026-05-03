import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../core/constants/user_roles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employee_today/providers/employee_today_providers.dart';
import '../../../sales/presentation/providers/salon_sales_settings_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../application/employee_punch_controller.dart';
import '../../application/employee_today_attendance_ui_provider.dart';
import '../../domain/enums/attendance_punch_type.dart';

class EmployeeQuickActionsSheet extends ConsumerWidget {
  const EmployeeQuickActionsSheet({super.key});

  void _popThen(BuildContext context, void Function(GoRouter router) fn) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fn(router);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider).asData?.value;
    final salesPosSettings = ref
        .watch(salonSalesSettingsStreamProvider)
        .asData
        ?.value;
    final attendanceAsync = ref.watch(employeeTodayAttendanceProvider);
    final settings = ref.watch(etAttendanceSettingsProvider).asData?.value;

    final canAddSale =
        session != null &&
        (salesPosSettings?.allowEmployeeAddSale ?? true) &&
        session.role.trim() != UserRoles.readonly;

    final canRequestCorrection = settings?.correctionRequestsEnabled ?? true;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.employeeQuickActionsTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (canAddSale)
              _QuickActionTile(
                icon: Icons.point_of_sale_rounded,
                title: l10n.employeeAddSaleFab,
                subtitle: l10n.employeeQuickActionAddSaleSubtitle,
                color: const Color(0xFF7C3AED),
                onTap: () => _popThen(context, (router) {
                  router.push(AppRoutes.employeeAddSale);
                }),
              ),
            attendanceAsync.maybeWhen(
              data: (vm) {
                if (vm.salonId.isEmpty) {
                  return const SizedBox.shrink();
                }
                final type = vm.nextPunchType;
                final enabled = vm.canPunchAny && type != null;
                return _QuickActionTile(
                  icon: vm.primaryActionIcon,
                  title: vm.primaryActionLabel(l10n),
                  subtitle: vm.primaryActionSubtitle(l10n),
                  color: const Color(0xFF7C3AED),
                  onTap: !enabled
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.of(context).pop();
                          await ref
                              .read(
                                employeeTodayAttendanceControllerProvider
                                    .notifier,
                              )
                              .submitPunch(
                                type,
                                l10n,
                                onMessage: (m) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(m)),
                                  );
                                },
                                onSuccess: () {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.employeeTodayPunchRecorded(
                                          _punchLabel(l10n, type),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                        },
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            if (canRequestCorrection)
              _QuickActionTile(
                icon: Icons.edit_calendar_rounded,
                title: l10n.employeeQuickActionRequestCorrectionTitle,
                subtitle: l10n.employeeQuickActionRequestCorrectionSubtitle,
                color: const Color(0xFFF59E0B),
                onTap: () => _popThen(context, (router) {
                  router.push(AppRoutes.employeeAttendanceCorrectionNested);
                }),
              ),
            _QuickActionTile(
              icon: Icons.receipt_long_outlined,
              title: l10n.employeeQuickActionPayrollTitle,
              subtitle: l10n.employeeQuickActionPayrollSubtitle,
              color: const Color(0xFF6366F1),
              onTap: () => _popThen(context, (router) {
                router.go(AppRoutes.employeePayroll);
              }),
            ),
            _QuickActionTile(
              icon: Icons.policy_rounded,
              title: l10n.employeeTodayViewPolicy,
              subtitle: l10n.employeeQuickActionViewPolicySubtitle,
              color: const Color(0xFF10B981),
              onTap: () => _popThen(context, (router) {
                router.push(AppRoutes.employeeAttendancePolicy);
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _punchLabel(AppLocalizations l10n, AttendancePunchType t) {
    switch (t) {
      case AttendancePunchType.punchIn:
        return l10n.employeeTodayPunchIn;
      case AttendancePunchType.punchOut:
        return l10n.employeeTodayPunchOut;
      case AttendancePunchType.breakOut:
        return l10n.employeeTodayBreakOut;
      case AttendancePunchType.breakIn:
        return l10n.employeeTodayBreakIn;
    }
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: disabled
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: disabled
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
