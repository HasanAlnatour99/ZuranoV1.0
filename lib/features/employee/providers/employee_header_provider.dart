import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../data/employee_header_model.dart';
import '../data/employee_header_repository.dart';

final employeeHeaderRepositoryProvider = Provider<EmployeeHeaderRepository>((ref) {
  return EmployeeHeaderRepository(ref.watch(firestoreProvider));
});

/// Real-time hero header: user, salon, employee, and shift documents.
final employeeHeaderStreamProvider =
    StreamProvider.autoDispose<EmployeeHeaderModel>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EmployeeHeaderModel>.error(
          const EmployeeHeaderException('WORKSPACE_SCOPE_MISSING'),
          StackTrace.current,
        );
      }
      return ref.watch(employeeHeaderRepositoryProvider).watchHeader(scope: scope);
    });
