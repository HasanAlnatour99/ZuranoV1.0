import 'package:flutter/material.dart';

import '../../../../payroll/domain/models/payroll_status.dart';

class PayrollStatusChip extends StatelessWidget {
  const PayrollStatusChip({
    super.key,
    required this.status,
    this.light = false,
  });

  final PayrollStatus status;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = switch (status) {
      PayrollStatus.draft => scheme.surfaceContainerHighest,
      PayrollStatus.ready => scheme.primaryContainer,
      PayrollStatus.paid => Colors.green.withValues(alpha: 0.2),
      PayrollStatus.cancelled => scheme.errorContainer,
    };
    final fg = light ? Colors.white : scheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.value,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
