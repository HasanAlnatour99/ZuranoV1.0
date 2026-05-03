import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/customer_booking_draft.dart';
import '../data/models/customer_service_public_model.dart';

final customerBookingDraftProvider =
    NotifierProvider<CustomerBookingDraftNotifier, CustomerBookingDraft>(
      CustomerBookingDraftNotifier.new,
    );

class CustomerBookingDraftNotifier extends Notifier<CustomerBookingDraft> {
  @override
  CustomerBookingDraft build() => CustomerBookingDraft.empty();

  void startForSalon(String salonId) {
    final id = salonId.trim();
    if (state.salonId == id) {
      return;
    }
    state = CustomerBookingDraft(salonId: id);
  }

  void toggleService(CustomerServicePublicModel service) {
    final exists = state.selectedServices.any((s) => s.id == service.id);
    final nextServices = exists
        ? state.selectedServices.where((s) => s.id != service.id).toList()
        : [...state.selectedServices, service];
    _setServices(nextServices);
  }

  void clearServices() {
    _setServices(const []);
  }

  void setTeamMember({
    required String employeeId,
    required String employeeName,
    bool keepAnyAvailable = false,
  }) {
    state = state.copyWith(
      selectedEmployeeId: employeeId.trim(),
      selectedEmployeeName: employeeName.trim(),
      anyAvailableEmployee: keepAnyAvailable,
      selectedStartAt: null,
      selectedEndAt: null,
    );
  }

  void setAnyAvailableTeamMember() {
    state = state.copyWith(
      selectedEmployeeId: null,
      selectedEmployeeName: null,
      anyAvailableEmployee: true,
      selectedStartAt: null,
      selectedEndAt: null,
    );
  }

  void setDateTime({required DateTime startAt, required DateTime endAt}) {
    state = state.copyWith(selectedStartAt: startAt, selectedEndAt: endAt);
  }

  void setCustomerDetails({
    required String customerName,
    required String customerPhone,
    required String customerPhoneNormalized,
    String? customerGender,
    String? customerNote,
  }) {
    state = state.copyWith(
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      customerPhoneNormalized: customerPhoneNormalized.trim(),
      customerGender: customerGender?.trim(),
      customerNote: customerNote?.trim(),
    );
  }

  void setGuestNickname({
    required String guestNicknameKey,
    required String guestDisplayName,
  }) {
    state = state.copyWith(
      guestNicknameKey: guestNicknameKey.trim().toLowerCase(),
      guestDisplayName: guestDisplayName.trim(),
    );
  }

  void clearGuestNickname() {
    state = state.copyWith(guestNicknameKey: null, guestDisplayName: null);
  }

  void reset() {
    state = CustomerBookingDraft.empty();
  }

  void _setServices(List<CustomerServicePublicModel> services) {
    final subtotal = services.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
    final duration = services.fold<int>(
      0,
      (sum, service) => sum + service.durationMinutes,
    );
    final discount = state.discountAmount;
    state = state.copyWith(
      selectedServices: List.unmodifiable(services),
      selectedEmployeeId: null,
      selectedEmployeeName: null,
      anyAvailableEmployee: false,
      selectedStartAt: null,
      selectedEndAt: null,
      guestNicknameKey: null,
      guestDisplayName: null,
      subtotal: subtotal,
      totalAmount: (subtotal - discount).clamp(0, double.infinity).toDouble(),
      durationMinutes: duration,
    );
  }
}
