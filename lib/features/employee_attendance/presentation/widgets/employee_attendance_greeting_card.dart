import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employee_today/presentation/employee_today_theme.dart';

class EmployeeAttendanceGreetingCard extends StatelessWidget {
  const EmployeeAttendanceGreetingCard({
    super.key,
    required this.employeeName,
    required this.now,
  });

  final String employeeName;
  final DateTime now;

  String _greeting(AppLocalizations l10n) {
    final h = now.hour;
    if (h < 12) {
      return l10n.employeeAttendanceGreetingMorning;
    }
    if (h < 17) {
      return l10n.employeeAttendanceGreetingAfternoon;
    }
    return l10n.employeeAttendanceGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat.EEEE(locale).format(now);
    final date = DateFormat.yMMMd(locale).format(now);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            EmployeeTodayColors.heroGradientStart,
            EmployeeTodayColors.heroGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EmployeeTodayColors.primaryPurple.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(l10n),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                TeamMemberNameText(
                  employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.employeeAttendanceProductiveDay,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  weekday,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
