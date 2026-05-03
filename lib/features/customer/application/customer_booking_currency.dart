import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/money_currency_providers.dart';
import 'customer_salon_profile_providers.dart';

/// Money ISO code for customer booking flows: public salon profile when loaded,
/// otherwise the signed-in / onboarding regional default.
String watchCustomerSalonMoneyCode(WidgetRef ref, String salonId) {
  final sid = salonId.trim();
  if (sid.isEmpty) {
    return ref.watch(regionalMoneyCurrencyCodeProvider);
  }
  final salon = ref.watch(customerSalonProfileProvider(sid)).asData?.value;
  if (salon == null) {
    return ref.watch(regionalMoneyCurrencyCodeProvider);
  }
  return salon.currencyCode;
}
