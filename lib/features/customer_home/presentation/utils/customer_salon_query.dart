import '../../data/models/customer_salon_model.dart';

/// Local MVP search over denormalized fields (guest-safe; no Algolia dependency).
List<CustomerSalonModel> filterSalonsForQuery(
  List<CustomerSalonModel> list,
  String rawQuery,
) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) {
    return List<CustomerSalonModel>.from(list);
  }
  return list
      .where((s) {
        if (s.name.toLowerCase().contains(q)) {
          return true;
        }
        if (s.city.toLowerCase().contains(q)) {
          return true;
        }
        if (s.area.toLowerCase().contains(q)) {
          return true;
        }
        for (final t in s.tags) {
          if (t.toLowerCase().contains(q)) {
            return true;
          }
        }
        for (final k in s.searchKeywords) {
          if (k.toLowerCase().contains(q)) {
            return true;
          }
        }
        return false;
      })
      .toList(growable: false);
}
