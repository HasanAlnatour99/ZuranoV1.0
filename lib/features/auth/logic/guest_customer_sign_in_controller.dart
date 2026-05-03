import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/firebase_error_message.dart';
import '../../../providers/repository_providers.dart';
import '../../../router/router_session_refresh.dart';

final guestCustomerSignInControllerProvider =
    NotifierProvider.autoDispose<
      GuestCustomerSignInController,
      GuestCustomerSignInState
    >(GuestCustomerSignInController.new);

class GuestCustomerSignInState {
  const GuestCustomerSignInState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  GuestCustomerSignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GuestCustomerSignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GuestCustomerSignInController extends Notifier<GuestCustomerSignInState> {
  /// UI maps this to [AppLocalizations.guestAuthSessionTimeout] (localized).
  static const String sessionTimeoutMarker = 'guest-session-timeout';

  @override
  GuestCustomerSignInState build() => const GuestCustomerSignInState();

  Future<bool> continueAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (kDebugMode) {
        debugPrint('[GUEST_AUTH] continue_as_guest_tapped');
      }
      await ref.read(authRepositoryProvider).signInAsAnonymousGuestCustomer();
      if (kDebugMode) {
        debugPrint(
          '[GUEST_AUTH] repository_sign_in_complete_awaiting_customer_session',
        );
      }
      await refreshSessionAndRouterAwaitCustomerReady(ref);
      if (kDebugMode) {
        debugPrint(
          '[GUEST_AUTH] after_session_refresh route_target=/customer/home',
        );
      }
      state = const GuestCustomerSignInState();
      return true;
    } on TimeoutException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GUEST_AUTH] failed timeout=$e');
        debugPrintStack(stackTrace: st, label: '[GUEST_AUTH]');
      }
      state = const GuestCustomerSignInState(
        isLoading: false,
        errorMessage: sessionTimeoutMarker,
      );
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[GUEST_AUTH] failed error=$e');
        debugPrintStack(stackTrace: st, label: '[GUEST_AUTH]');
      }
      state = GuestCustomerSignInState(
        isLoading: false,
        errorMessage: FirebaseErrorMessage.fromException(e),
      );
      return false;
    }
  }
}
