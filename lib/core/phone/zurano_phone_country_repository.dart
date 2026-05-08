import 'dart:ui';

import 'package:phonecodes/phonecodes.dart' as pc;

import '../constants/app_countries.dart';
import 'zurano_phone_country.dart';

class ZuranoPhoneCountryRepository {
  const ZuranoPhoneCountryRepository();

  static final List<ZuranoPhoneCountry> _countries = () {
    final byIso = <String, ZuranoPhoneCountry>{};
    for (final c in pc.Country.values) {
      final iso = c.code.trim().toUpperCase();
      if (iso.isEmpty) continue;
      if (byIso.containsKey(iso)) continue;
      byIso[iso] = ZuranoPhoneCountry(
        isoCode: iso,
        name: c.name.trim(),
        dialCode: c.dialCode.trim(),
        flagEmoji: c.flag,
      );
    }
    final out = byIso.values.toList(growable: false);
    out.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return out;
  }();

  List<ZuranoPhoneCountry> getAllCountries() => _countries;

  ZuranoPhoneCountry? findByIsoCode(String isoCode) {
    final code = isoCode.trim().toUpperCase();
    if (code.isEmpty) return null;
    for (final c in _countries) {
      if (c.isoCode == code) return c;
    }
    return null;
  }

  List<ZuranoPhoneCountry> findByDialCode(String dialCode) {
    final dc = dialCode.trim();
    if (dc.isEmpty) return const [];
    final normalized = dc.startsWith('+') ? dc : '+$dc';
    return _countries.where((c) => c.dialCode == normalized).toList(growable: false);
  }

  List<ZuranoPhoneCountry> search(String query, {int limit = 80}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return _countries.take(limit).toList(growable: false);
    }
    final qDial = q.startsWith('+') ? q : '+$q';
    final hits = <ZuranoPhoneCountry>[];
    for (final c in _countries) {
      if (c.name.toLowerCase().contains(q) ||
          c.isoCode.toLowerCase().contains(q) ||
          c.dialCode.contains(qDial)) {
        hits.add(c);
        if (hits.length >= limit) break;
      }
    }
    return hits;
  }

  ZuranoPhoneCountry defaultCountry({
    String? salonIsoCode,
    String? appCountryIsoCode,
    Locale? locale,
  }) {
    final candidates = [
      salonIsoCode,
      appCountryIsoCode,
      locale?.countryCode,
    ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);

    for (final c in candidates) {
      final found = findByIsoCode(c);
      if (found != null) {
        return found;
      }
    }

    // Safety fallback only. Normal runtime should find from package list.
    final qa = findByIsoCode('QA');
    if (qa != null) return qa;
    return _countries.first;
  }

  /// Locale-aware display name using existing CLDR Arabic map when available.
  String displayNameForLocale(ZuranoPhoneCountry country, Locale locale) {
    final isAr = locale.languageCode.toLowerCase() == 'ar';
    if (!isAr) return country.name;
    return AppCountries.nameForCode(country.isoCode, locale) ?? country.name;
  }
}

