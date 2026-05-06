import '../data/models/salon.dart';

/// Tokenize discovery terms for [Salon.searchKeywords] (mirrors Cloud Functions
/// `buildKeywords` in `customerSearchIndex.ts`, caps at 80 terms).
List<String> buildSalonSearchKeywords(Salon salon) {
  final set = <String>{};
  void consume(String? value) {
    if (value == null) return;
    final normalized = value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
    if (normalized.isEmpty) return;
    for (final part in normalized.split(RegExp(r'\s+'))) {
      if (part.isNotEmpty) set.add(part);
    }
    set.add(normalized);
  }

  consume(salon.name);
  consume(salon.publicName);
  consume(salon.city);
  consume(salon.area);
  consume(salon.countryName);
  consume(salon.businessType);
  consume(salon.category);
  consume(salon.audience);
  if (salon.address.trim().isNotEmpty) {
    consume(salon.address);
  }
  for (final t in salon.tags) {
    consume(t);
  }
  for (final k in salon.searchKeywords) {
    consume(k);
  }

  final out = set.toList(growable: false);
  if (out.length <= 80) return out;
  return out.sublist(0, 80);
}
