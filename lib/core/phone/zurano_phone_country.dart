class ZuranoPhoneCountry {
  const ZuranoPhoneCountry({
    required this.isoCode,
    required this.name,
    required this.dialCode,
    required this.flagEmoji,
  });

  final String isoCode;
  final String name;
  final String dialCode;
  final String flagEmoji;
}

class ZuranoPhoneNormalizeResult {
  const ZuranoPhoneNormalizeResult({
    required this.isValid,
    required this.e164,
    required this.national,
    required this.countryIsoCode,
    required this.dialCode,
    this.errorCode,
  });

  final bool isValid;
  final String e164;
  final String national;
  final String countryIsoCode;
  final String dialCode;
  final String? errorCode;
}

