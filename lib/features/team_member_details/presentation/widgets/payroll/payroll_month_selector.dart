import 'package:flutter/material.dart';

class PayrollMonthSelector extends StatelessWidget {
  const PayrollMonthSelector({
    super.key,
    required this.selectedMonthKey,
    required this.onPrevious,
    required this.onNext,
  });

  final String selectedMonthKey;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Text(
            selectedMonthKey,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
