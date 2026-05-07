import '../../onboarding/domain/value_objects/country_option.dart';
import '../data/models/customer_salon_model.dart';
import '../data/models/customer_salon_preview_model.dart';

/// Matches [CustomerSalonModel] country fields to English discovery label from onboarding.
bool customerSalonMatchesDiscoveryCountry(
  CustomerSalonModel salon,
  String discoveryCountryName,
) {
  final want = discoveryCountryName.trim();
  if (want.isEmpty) {
    return true;
  }
  final direct = salon.country.trim();
  if (direct.isNotEmpty &&
      direct.toLowerCase() == want.toLowerCase()) {
    return true;
  }
  final iso = salon.countryCodeIso;
  if (iso != null && iso.isNotEmpty) {
    final name = CountryOption.tryFindByIso(iso)?.nameEn;
    if (name != null && name.toLowerCase() == want.toLowerCase()) {
      return true;
    }
  }
  return false;
}

/// Prefer salons in the selected country; if none match (field mismatch / legacy data), show all loaded.
List<CustomerSalonModel> preferCountryFilteredElseAll(
  List<CustomerSalonModel> all,
  String discoveryCountryName, {
  required String customerCountryCode,
}) {
  final wantIso = customerCountryCode.trim().toUpperCase();
  final byIso = all
      .where((s) {
        final iso = s.countryCodeIso?.trim().toUpperCase();
        if (iso == null || iso.isEmpty) {
          return false;
        }
        return iso == wantIso;
      })
      .toList(growable: false);
  final pool = byIso.isNotEmpty ? byIso : all;
  final filtered = pool
      .where((s) => customerSalonMatchesDiscoveryCountry(s, discoveryCountryName))
      .toList(growable: false);
  return filtered.isNotEmpty ? filtered : pool;
}

bool customerSalonPreviewMatchesDiscoveryCountry(
  CustomerSalonPreviewModel salon,
  String discoveryCountryName,
) {
  final want = discoveryCountryName.trim();
  if (want.isEmpty) {
    return true;
  }
  final direct = salon.country.trim();
  if (direct.isNotEmpty && direct.toLowerCase() == want.toLowerCase()) {
    return true;
  }
  final iso = salon.countryCodeIso;
  if (iso != null && iso.isNotEmpty) {
    final name = CountryOption.tryFindByIso(iso)?.nameEn;
    if (name != null && name.toLowerCase() == want.toLowerCase()) {
      return true;
    }
  }
  return false;
}

List<CustomerSalonPreviewModel> preferCountryFilteredElseAllPreview(
  List<CustomerSalonPreviewModel> all,
  String discoveryCountryName, {
  required String customerCountryCode,
}) {
  final wantIso = customerCountryCode.trim().toUpperCase();
  final byIso = all
      .where((s) {
        final iso = s.countryCodeIso?.trim().toUpperCase();
        if (iso == null || iso.isEmpty) {
          return false;
        }
        return iso == wantIso;
      })
      .toList(growable: false);
  final pool = byIso.isNotEmpty ? byIso : all;
  final filtered = pool
      .where(
        (s) =>
            customerSalonPreviewMatchesDiscoveryCountry(s, discoveryCountryName),
      )
      .toList(growable: false);
  return filtered.isNotEmpty ? filtered : pool;
}
