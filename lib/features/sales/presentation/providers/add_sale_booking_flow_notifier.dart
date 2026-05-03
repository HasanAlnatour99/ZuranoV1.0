import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/repository_providers.dart'
    show addSaleRepositoryProvider, employeeRepositoryProvider;
import '../../../../providers/session_provider.dart';
import '../../data/models/guest_booking_snapshot.dart';
import '../../data/repositories/add_sale_repository.dart';

final addSaleBookingFlowProvider =
    NotifierProvider.autoDispose<
      AddSaleBookingFlowNotifier,
      AddSaleBookingFlowState
    >(AddSaleBookingFlowNotifier.new);

class AddSaleBookingFlowState {
  const AddSaleBookingFlowState({
    this.bookingCodeInput = '',
    this.preview,
    this.lookupLoading = false,
    this.submitLoading = false,
    this.errorCode,
  });

  final String bookingCodeInput;
  final GuestBookingSnapshot? preview;
  final bool lookupLoading;
  final bool submitLoading;
  final String? errorCode;

  AddSaleBookingFlowState copyWith({
    String? bookingCodeInput,
    GuestBookingSnapshot? preview,
    bool clearPreview = false,
    bool? lookupLoading,
    bool? submitLoading,
    String? errorCode,
    bool clearError = false,
  }) {
    return AddSaleBookingFlowState(
      bookingCodeInput: bookingCodeInput ?? this.bookingCodeInput,
      preview: clearPreview ? null : (preview ?? this.preview),
      lookupLoading: lookupLoading ?? this.lookupLoading,
      submitLoading: submitLoading ?? this.submitLoading,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

class AddSaleBookingFlowNotifier extends Notifier<AddSaleBookingFlowState> {
  @override
  AddSaleBookingFlowState build() => const AddSaleBookingFlowState();

  void updateBookingCode(String value) {
    final mismatchPreview =
        state.preview != null &&
        state.preview!.bookingCode.trim().toUpperCase() !=
            value.trim().toUpperCase();
    if (state.bookingCodeInput == value && !mismatchPreview) return;
    state = state.copyWith(
      bookingCodeInput: value,
      clearError: true,
      clearPreview: mismatchPreview,
    );
  }

  void resetPreview() {
    state = state.copyWith(clearPreview: true, clearError: true);
  }

  Future<void> retrieveBooking(String salonId) async {
    state = state.copyWith(
      lookupLoading: true,
      clearError: true,
      clearPreview: true,
    );
    try {
      final booking = await ref
          .read(addSaleRepositoryProvider)
          .getBookingByCode(
            bookingCode: state.bookingCodeInput,
            salonId: salonId,
          );
      final user = ref.read(sessionUserProvider).asData?.value;
      if (user != null) {
        final role = user.role.trim().toLowerCase();
        final isBarber = role == 'barber' || role == 'employee';
        final eid = user.employeeId?.trim() ?? '';
        if (isBarber && eid.isNotEmpty && booking.barberId.trim() != eid) {
          state = state.copyWith(
            lookupLoading: false,
            errorCode: 'not_your_booking',
          );
          return;
        }
      }
      state = state.copyWith(lookupLoading: false, preview: booking);
    } on AddSaleBookingException catch (e) {
      state = state.copyWith(lookupLoading: false, errorCode: e.code);
    } catch (_) {
      state = state.copyWith(lookupLoading: false, errorCode: 'unknown');
    }
  }

  Future<String?> createSaleFromBooking(String salonId) async {
    final preview = state.preview;
    if (preview == null) {
      state = state.copyWith(errorCode: 'no_preview');
      return null;
    }
    state = state.copyWith(submitLoading: true, clearError: true);
    try {
      final user = ref.read(sessionUserProvider).asData?.value;
      if (user == null) {
        state = state.copyWith(submitLoading: false, errorCode: 'no_session');
        return null;
      }
      final barber = await ref
          .read(employeeRepositoryProvider)
          .getEmployee(salonId, preview.barberId.trim());
      if (barber == null || !barber.isActive) {
        state = state.copyWith(
          submitLoading: false,
          errorCode: 'barber_missing',
        );
        return null;
      }
      final id = await ref
          .read(addSaleRepositoryProvider)
          .createSaleFromBooking(
            bookingCode: preview.bookingCode,
            salonId: salonId,
            actor: user,
            performingBarber: barber,
          );
      state = state.copyWith(submitLoading: false, clearPreview: true);
      return id;
    } on AddSaleBookingException catch (e) {
      state = state.copyWith(submitLoading: false, errorCode: e.code);
      return null;
    } catch (_) {
      state = state.copyWith(submitLoading: false, errorCode: 'unknown');
      return null;
    }
  }
}
