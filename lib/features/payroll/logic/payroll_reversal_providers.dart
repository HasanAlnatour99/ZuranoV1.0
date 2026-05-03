import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../../users/data/models/app_user.dart';
import '../data/models/payroll_result_model.dart';

/// Result rows for a payroll run (owner reversal flow).
///
/// Waits for [sessionUserProvider] before querying Firestore. Returning early
/// with `[]` while session was still loading made the reversal UI treat runs as
/// single-employee and blocked partial reversal / staff picker.
final payrollReversalRunResultsProvider =
    FutureProvider.family<List<PayrollResultModel>, String>((ref, runId) async {
      final rid = runId.trim();
      if (rid.isEmpty) {
        return const <PayrollResultModel>[];
      }

      final AppUser? user = await ref.watch(sessionUserProvider.future);
      final salonId = user?.salonId?.trim() ?? '';
      if (salonId.isEmpty) {
        return const <PayrollResultModel>[];
      }

      return ref.read(payrollRunRepositoryProvider).getResults(salonId, rid);
    });
