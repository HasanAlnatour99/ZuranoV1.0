import '../../../core/phone/zurano_phone_country_repository.dart';
import '../../../core/phone/zurano_phone_normalizer.dart';

class CustomerPhoneNormalizer {
  const CustomerPhoneNormalizer._();

  /// Legacy wrapper kept for backward compatibility.
  /// New flows should use [ZuranoPhoneNormalizer.normalize] with a selected country.
  static String normalizePhone(String input) {
    final repo = ZuranoPhoneCountryRepository();
    final defaultCountry = repo.defaultCountry(salonIsoCode: 'QA');
    return ZuranoPhoneNormalizer.normalize(
      input: input,
      country: defaultCountry,
    ).e164;
  }

  static bool isValidPhone(String normalizedPhone) {
    final value = normalizedPhone.trim();
    if (!value.startsWith('+')) {
      return false;
    }
    final digits = value.substring(1);
    return RegExp(r'^\d{8,15}$').hasMatch(digits);
  }

  static bool isValidQatarLocalMobile(String input) {
    final digits = input.trim().replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^[3567]\d{7}$').hasMatch(digits);
  }

  static String displayPhone(String normalizedPhone) {
    return normalizedPhone.trim();
  }
}
