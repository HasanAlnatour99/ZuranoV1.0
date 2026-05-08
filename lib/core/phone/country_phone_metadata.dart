/// Country-level phone metadata used by Zurano customer booking flows.
///
/// Keep this list small for MVP and extend it safely when a new market is added.
class CountryPhoneMetadata {
  const CountryPhoneMetadata({
    required this.isoCode,
    required this.countryName,
    required this.dialCode,
    required this.flagEmoji,
    required this.minNationalLength,
    required this.maxNationalLength,
    this.trunkPrefixes = const ['0'],
  });

  final String isoCode;
  final String countryName;
  final String dialCode;
  final String flagEmoji;
  final int minNationalLength;
  final int maxNationalLength;

  /// Prefixes commonly typed before local/national numbers.
  /// Example: UAE users may type 0501234567, but E.164 becomes +971501234567.
  final List<String> trunkPrefixes;

  String get dialCodeDigits => dialCode.replaceAll(RegExp(r'\D'), '');

  bool get hasFixedNationalLength => minNationalLength == maxNationalLength;
}

class SupportedPhoneCountries {
  const SupportedPhoneCountries._();

  static const qatar = CountryPhoneMetadata(
    isoCode: 'QA',
    countryName: 'Qatar',
    dialCode: '+974',
    flagEmoji: '🇶🇦',
    minNationalLength: 8,
    maxNationalLength: 8,
    trunkPrefixes: [],
  );

  static const unitedArabEmirates = CountryPhoneMetadata(
    isoCode: 'AE',
    countryName: 'United Arab Emirates',
    dialCode: '+971',
    flagEmoji: '🇦🇪',
    minNationalLength: 8,
    maxNationalLength: 9,
  );

  static const saudiArabia = CountryPhoneMetadata(
    isoCode: 'SA',
    countryName: 'Saudi Arabia',
    dialCode: '+966',
    flagEmoji: '🇸🇦',
    minNationalLength: 8,
    maxNationalLength: 9,
  );

  static const jordan = CountryPhoneMetadata(
    isoCode: 'JO',
    countryName: 'Jordan',
    dialCode: '+962',
    flagEmoji: '🇯🇴',
    minNationalLength: 8,
    maxNationalLength: 9,
  );

  static const egypt = CountryPhoneMetadata(
    isoCode: 'EG',
    countryName: 'Egypt',
    dialCode: '+20',
    flagEmoji: '🇪🇬',
    minNationalLength: 8,
    maxNationalLength: 10,
  );

  static const kuwait = CountryPhoneMetadata(
    isoCode: 'KW',
    countryName: 'Kuwait',
    dialCode: '+965',
    flagEmoji: '🇰🇼',
    minNationalLength: 8,
    maxNationalLength: 8,
    trunkPrefixes: [],
  );

  static const bahrain = CountryPhoneMetadata(
    isoCode: 'BH',
    countryName: 'Bahrain',
    dialCode: '+973',
    flagEmoji: '🇧🇭',
    minNationalLength: 8,
    maxNationalLength: 8,
    trunkPrefixes: [],
  );

  static const oman = CountryPhoneMetadata(
    isoCode: 'OM',
    countryName: 'Oman',
    dialCode: '+968',
    flagEmoji: '🇴🇲',
    minNationalLength: 8,
    maxNationalLength: 8,
    trunkPrefixes: [],
  );

  static const all = <CountryPhoneMetadata>[
    qatar,
    unitedArabEmirates,
    saudiArabia,
    jordan,
    egypt,
    kuwait,
    bahrain,
    oman,
  ];

  static CountryPhoneMetadata byIsoCode(
    String? isoCode, {
    CountryPhoneMetadata fallback = qatar,
  }) {
    final normalized = isoCode?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }
    for (final country in all) {
      if (country.isoCode == normalized) {
        return country;
      }
    }
    return fallback;
  }

  static CountryPhoneMetadata? byDialCodeDigits(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return null;
    }
    final sorted = [...all]
      ..sort((a, b) => b.dialCodeDigits.length.compareTo(a.dialCodeDigits.length));
    for (final country in sorted) {
      if (clean.startsWith(country.dialCodeDigits)) {
        return country;
      }
    }
    return null;
  }
}
