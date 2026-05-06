import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../../providers/repository_providers.dart';
import '../data/models/customer_booking_settings.dart';
import '../data/models/customer_booking_slot.dart';
import '../data/repositories/customer_booking_availability_repository.dart';
import 'customer_booking_draft_provider.dart';
import 'customer_salon_profile_providers.dart';
import 'customer_slot_availability_service.dart';

final customerBookingAvailabilityRepositoryProvider =
    Provider<CustomerBookingAvailabilityRepository>((ref) {
      return FirestoreCustomerBookingAvailabilityRepository(
        ref.watch(firestoreProvider),
        ref.watch(bookingRepositoryProvider),
      );
    });

final customerSlotAvailabilityServiceProvider =
    Provider<CustomerSlotAvailabilityService>((ref) {
      return CustomerSlotAvailabilityService(
        ref.watch(customerBookingAvailabilityRepositoryProvider),
      );
    });

class SelectedCustomerBookingDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateUtils.dateOnly(DateTime.now());

  void setDate(DateTime date) {
    state = DateUtils.dateOnly(date);
  }
}

final selectedCustomerBookingDateProvider =
    NotifierProvider<SelectedCustomerBookingDateNotifier, DateTime>(
      SelectedCustomerBookingDateNotifier.new,
    );

/// Public booking policy from `publicSalons/{salonId}` (synced from salon settings).
final customerPublicBookingFlowSettingsProvider =
    FutureProvider.family<CustomerBookingSettings, String>((ref, salonId) {
      return ref
          .watch(customerBookingAvailabilityRepositoryProvider)
          .getBookingSettings(salonId);
    });

final customerBookingSlotsProvider =
    FutureProvider.family<List<CustomerBookingSlot>, String>((
      ref,
      salonId,
    ) async {
      final selectedDate = ref.watch(selectedCustomerBookingDateProvider);
      final draft = ref.watch(customerBookingDraftProvider);
      if (!draft.hasServices || !draft.hasTeamSelection) {
        return const [];
      }
      final team = await ref.watch(
        customerBookableTeamMembersProvider(salonId).future,
      );
      return ref
          .watch(customerSlotAvailabilityServiceProvider)
          .generateSlots(
            salonId: salonId,
            date: selectedDate,
            draft: draft,
            teamMembers: team,
          );
    });
