import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'staff_attendance_request_sheets.dart';

/// Staff attendance request flow: pick request type, then the matching form.
Future<void> showAttendanceRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Consumer(
      builder: (context, ref, _) => EmployeeNewRequestSheet(
        onSelect: (type) {
          final routerContext = context;
          Navigator.of(routerContext).pop();
          Future.microtask(() {
            if (!routerContext.mounted) {
              return;
            }
            openStaffAttendanceRequestDetail(routerContext, ref, type);
          });
        },
      ),
    ),
  );
}
