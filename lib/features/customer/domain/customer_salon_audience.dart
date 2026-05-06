/// Canonical audience keys on `salons/{salonId}` and customer search index:
/// `men` | `ladies` | `unisex`.
///
/// Some mirrors may use `genderTarget`; older data may use `customerAudience`.
String? readSalonAudienceForCustomers(Map<String, dynamic> data) {
  String? pick(String key) {
    final v = data[key];
    if (v is String && v.trim().isNotEmpty) {
      return v.trim().toLowerCase();
    }
    return null;
  }

  return pick('genderTarget') ?? pick('audience') ?? pick('customerAudience');
}
