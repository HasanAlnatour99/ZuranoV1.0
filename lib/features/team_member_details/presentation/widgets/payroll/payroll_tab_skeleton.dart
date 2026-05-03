import 'package:flutter/material.dart';

class PayrollTabSkeleton extends StatelessWidget {
  const PayrollTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(height: 40, color: scheme.surfaceContainerHighest),
        const SizedBox(height: 16),
        Container(height: 170, color: scheme.surfaceContainerHighest),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 72,
                color: scheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
