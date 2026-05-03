import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../owner/logic/team_management_providers.dart';
import '../data/team_deck_firestore_repository.dart';
import '../domain/team_member_card_vm.dart';

/// Live Firestore stream of staff deck VMs (employees + composite attendance + performance).
final teamDeckRawVmStreamProvider =
    StreamProvider.autoDispose.family<List<TeamMemberCardVm>, String>(
  (ref, salonId) {
    ref.keepAlive();
    if (salonId.isEmpty) {
      return Stream.value(const []);
    }
    final repo = ref.watch(teamDeckFirestoreRepositoryProvider);
    final now = DateTime.now();
    return repo.watchTeamCards(
      salonId: salonId,
      todayKey: TeamDeckFirestoreRepository.todayCompactKey(now),
      monthKey: TeamDeckFirestoreRepository.monthCompactKey(now),
    );
  },
);

/// [filteredTeamBarberCardsProvider] order, merged with live [teamDeckRawVmStreamProvider] data.
final filteredTeamDeckVmsProvider =
    Provider.autoDispose.family<AsyncValue<List<TeamMemberCardVm>>, String>(
  (ref, salonId) {
    final cardsAsync = ref.watch(filteredTeamBarberCardsProvider);
    final vmsAsync = ref.watch(teamDeckRawVmStreamProvider(salonId));

    if (cardsAsync.isLoading || vmsAsync.isLoading) {
      return const AsyncValue.loading();
    }
    if (cardsAsync.hasError) {
      return AsyncValue.error(
        cardsAsync.error!,
        cardsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (vmsAsync.hasError) {
      return AsyncValue.error(
        vmsAsync.error!,
        vmsAsync.stackTrace ?? StackTrace.current,
      );
    }

    final cards = cardsAsync.requireValue;
    final allVms = vmsAsync.requireValue;
    final byId = {for (final v in allVms) v.employeeId: v};
    final ordered = <TeamMemberCardVm>[];
    for (final c in cards) {
      final v = byId[c.employee.id];
      if (v != null) {
        ordered.add(v);
      }
    }
    return AsyncValue.data(ordered);
  },
);
