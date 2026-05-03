import 'package:flutter/material.dart';

import 'employee_quick_actions_sheet.dart';

/// Center-docked gradient + button for employee shell quick actions.
class EmployeeQuickActionFab extends StatelessWidget {
  const EmployeeQuickActionFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        heroTag: null,
        elevation: 10,
        highlightElevation: 6,
        backgroundColor: const Color(0xFF7C3AED),
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const EmployeeQuickActionsSheet(),
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
