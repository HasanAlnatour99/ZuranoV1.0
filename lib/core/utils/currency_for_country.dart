import 'package:sealed_countries/sealed_countries.dart';

/// ISO 3166-1 alpha-2 → primary ISO 4217 currency for that territory.
///
/// Uses [WorldCountry] data (official/legal tender list). Falls back to `USD`
/// only when the code is unknown or has no mapped currencies.
String currencyCodeForCountryIso(String iso) {
  final trimmed = iso.trim().toUpperCase();
  if (trimmed.length != 2) {
    return 'USD';
  }
  final country = WorldCountry.codeShortMap.maybeFindByCode(trimmed);
  if (country == null) {
    return 'USD';
  }
  final list = country.currencies;
  if (list == null || list.isEmpty) {
    return 'USD';
  }
  return list.first.code;
}

/// Prefer salon-stored currency; otherwise derive from salon [countryIso], else USD.
String resolvedSalonMoneyCurrency({
  String? salonCurrencyCode,
  String? salonCountryIso,
}) {
  final direct = salonCurrencyCode?.trim();
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }
  final iso = salonCountryIso?.trim();
  if (iso != null && iso.isNotEmpty) {
    return currencyCodeForCountryIso(iso);
  }
  return 'USD';
}
