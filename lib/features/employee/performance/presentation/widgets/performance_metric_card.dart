import 'package:flutter/material.dart';

import '../../../../employee_today/presentation/employee_today_theme.dart';

class PerformanceMetricCard extends StatelessWidget {
  const PerformanceMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: EmployeeTodayColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: EmployeeTodayColors.primaryPurple.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 27),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: EmployeeTodayColors.deepText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isRtl ? TextAlign.end : TextAlign.start,
            style: const TextStyle(
              color: EmployeeTodayColors.mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
