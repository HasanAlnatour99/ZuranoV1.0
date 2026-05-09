import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders before/after maps as key/value rows.
class AuditDiffView extends StatelessWidget {
  const AuditDiffView({
    super.key,
    required this.before,
    required this.after,
    required this.beforeTitle,
    required this.afterTitle,
    required this.emptyLabel,
  });

  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final String beforeTitle;
  final String afterTitle;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (before.isEmpty && after.isEmpty) {
      return Text(
        emptyLabel,
        style: const TextStyle(color: ZuranoPremiumUiColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          beforeTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        ...before.entries.map((e) => _kv(context, e.key, e.value)),
        const SizedBox(height: 16),
        Text(
          afterTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        ...after.entries.map((e) => _kv(context, e.key, e.value)),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, Object? v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: const TextStyle(
                color: ZuranoPremiumUiColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v?.toString() ?? 'null',
              style: const TextStyle(
                color: ZuranoPremiumUiColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
