import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/firebase_providers.dart';
import '../../../../../providers/session_provider.dart';
import '../../data/models/shift_template_model.dart';
import '../../data/repositories/shift_repository.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(firestore: ref.read(firestoreProvider));
});

final activeOwnerSalonIdProvider = Provider<String?>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim();
  if (salonId == null || salonId.isEmpty) {
    return null;
  }
  return salonId;
});

final shiftTemplatesStreamProvider =
    StreamProvider.autoDispose<List<ShiftTemplateModel>>((ref) {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) {
        return const Stream<List<ShiftTemplateModel>>.empty();
      }
      return ref.watch(shiftRepositoryProvider).streamShiftTemplates(salonId);
    });

final deactivateShiftTemplateControllerProvider =
    AsyncNotifierProvider<DeactivateShiftTemplateController, void>(
      DeactivateShiftTemplateController.new,
    );

final reorderShiftTemplatesControllerProvider =
    AsyncNotifierProvider<ReorderShiftTemplatesController, void>(
      ReorderShiftTemplatesController.new,
    );

class DeactivateShiftTemplateController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deactivate(String shiftId) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    if (salonId == null) {
      throw StateError('Missing active salon id for shift deactivation.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(shiftRepositoryProvider)
          .deactivateShiftTemplate(salonId: salonId, shiftId: shiftId),
    );
  }
}

class ReorderShiftTemplatesController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> reorder(List<String> orderedTemplateIds) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    if (salonId == null) {
      throw StateError('Missing active salon id for shift reorder.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(shiftRepositoryProvider)
          .reorderShiftTemplates(
            salonId: salonId,
            orderedTemplateIds: orderedTemplateIds,
          ),
    );
  }
}

final shiftTemplateProvider = FutureProvider.autoDispose
    .family<ShiftTemplateModel?, String>((ref, shiftId) async {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) {
        return null;
      }
      return ref
          .watch(shiftRepositoryProvider)
          .getShiftTemplate(salonId: salonId, shiftId: shiftId);
    });

final saveShiftTemplateControllerProvider =
    AsyncNotifierProvider<SaveShiftTemplateController, void>(
      SaveShiftTemplateController.new,
    );

class SaveShiftTemplateController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(ShiftTemplateModel model) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    if (salonId == null) {
      throw StateError('Missing active salon id for shift create.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(shiftRepositoryProvider)
          .createShiftTemplate(salonId: salonId, model: model),
    );
  }

  Future<void> updateShiftTemplate(ShiftTemplateModel model) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    if (salonId == null) {
      throw StateError('Missing active salon id for shift update.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(shiftRepositoryProvider)
          .updateShiftTemplate(salonId: salonId, model: model),
    );
  }
}
