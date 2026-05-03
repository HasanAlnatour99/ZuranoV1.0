import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/currency_for_country.dart';
import 'onboarding_providers.dart';
import 'salon_streams_provider.dart';
import 'session_provider.dart';

/// ISO 4217 code for customer/regional context when no salon document applies.
///
/// Order: signed-in profile [UserAddress.countryCode] → onboarding country ISO
/// → `USD` if nothing is set.
final regionalMoneyCurrencyCodeProvider = Provider<String>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final fromAddress = user?.address?.countryCode.trim();
  if (fromAddress != null && fromAddress.isNotEmpty) {
    return currencyCodeForCountryIso(fromAddress);
  }
  final prefs = ref.watch(onboardingPrefsProvider);
  final iso = prefs.countryCode?.trim();
  if (iso != null && iso.isNotEmpty) {
    return currencyCodeForCountryIso(iso);
  }
  return 'USD';
});

/// Active salon currency when a salon snapshot exists; otherwise regional default.
///
/// While [sessionSalonStreamProvider] is still loading, this follows
/// [regionalMoneyCurrencyCodeProvider] so customer UI does not flash a hardcoded
/// currency.
final sessionSalonMoneyCurrencyCodeProvider = Provider<String>((ref) {
  final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
  if (salon == null) {
    return ref.watch(regionalMoneyCurrencyCodeProvider);
  }
  return resolvedSalonMoneyCurrency(
    salonCurrencyCode: salon.currencyCode,
    salonCountryIso: salon.countryCode,
  );
});
