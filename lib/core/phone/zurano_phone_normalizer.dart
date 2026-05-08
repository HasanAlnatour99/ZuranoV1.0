import 'zurano_phone_country.dart';

class ZuranoPhoneNormalizer {
  const ZuranoPhoneNormalizer._();

  static ZuranoPhoneNormalizeResult normalize({
    required String input,
    required ZuranoPhoneCountry country,
  }) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return ZuranoPhoneNormalizeResult(
        isValid: false,
        e164: '',
        national: '',
        countryIsoCode: country.isoCode,
        dialCode: country.dialCode,
        errorCode: 'empty',
      );
    }

    var value = raw.replaceAll(RegExp(r'[\s\-\(\)\[\]\.]+'), '');
    if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final dialDigits = country.dialCode.replaceAll(RegExp(r'\D'), '');

    // International with explicit +.
    if (value.startsWith('+')) {
      final e164 = '+${digitsOnly.replaceFirst(RegExp(r'^0+'), '')}';
      return _validate(
        e164: e164,
        country: country,
        national: _nationalFromE164(e164, dialDigits),
      );
    }

    // Starts with country code digits (without +).
    if (dialDigits.isNotEmpty &&
        digitsOnly.startsWith(dialDigits) &&
        digitsOnly.length > dialDigits.length) {
      final e164 = '+${digitsOnly.replaceFirst(RegExp(r'^0+'), '')}';
      return _validate(
        e164: e164,
        country: country,
        national: _nationalFromE164(e164, dialDigits),
      );
    }

    var national = digitsOnly;
    if (national.isEmpty) {
      return ZuranoPhoneNormalizeResult(
        isValid: false,
        e164: '',
        national: '',
        countryIsoCode: country.isoCode,
        dialCode: country.dialCode,
        errorCode: 'empty',
      );
    }

    // Remove a single trunk-leading 0 when it's a known regional pattern.
    if (national.startsWith('0') && _shouldStripLeadingTrunkZero(country.isoCode)) {
      national = national.substring(1);
    }

    final e164 = '${country.dialCode}$national';
    return _validate(e164: e164, country: country, national: national);
  }

  static bool isValidE164(String e164) {
    final v = e164.trim();
    if (!v.startsWith('+')) return false;
    final digits = v.substring(1);
    return RegExp(r'^\d{8,15}$').hasMatch(digits);
  }

  static bool _shouldStripLeadingTrunkZero(String isoUpper) {
    // Conservative MVP: only strip when we are confident.
    // Extend via country metadata if we later adopt libphonenumber.
    switch (isoUpper.toUpperCase()) {
      case 'AE':
      case 'SA':
        return true;
      default:
        return false;
    }
  }

  static String _nationalFromE164(String e164, String dialDigits) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (dialDigits.isNotEmpty && digits.startsWith(dialDigits)) {
      return digits.substring(dialDigits.length);
    }
    return digits;
  }

  static ZuranoPhoneNormalizeResult _validate({
    required String e164,
    required ZuranoPhoneCountry country,
    required String national,
  }) {
    final ok = isValidE164(e164);
    return ZuranoPhoneNormalizeResult(
      isValid: ok,
      e164: ok ? e164 : '',
      national: national,
      countryIsoCode: country.isoCode,
      dialCode: country.dialCode,
      errorCode: ok ? null : 'invalid',
    );
  }
}

