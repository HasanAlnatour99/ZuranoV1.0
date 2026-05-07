import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/last_booked_model.dart';
import '../models/recently_viewed_salon_model.dart';

class CustomerRecentActivityRepository {
  CustomerRecentActivityRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kRecentlyViewedKey = 'customer_recently_viewed_salons_v1';
  static const _kLastBookedKey = 'customer_last_booked_v1';

  List<RecentlyViewedSalonModel> _parseRecentlyViewed(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => RecentlyViewedSalonModel.fromJson(
                Map<String, dynamic>.from(m),
              ))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<RecentlyViewedSalonModel>> getRecentlyViewed() async {
    final raw = _prefs.getString(_kRecentlyViewedKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    final list = _parseRecentlyViewed(raw);
    final out = [...list]..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
    return out;
  }

  Future<void> addRecentlyViewed({
    required String salonId,
    required String name,
    String? area,
    String? coverImageUrl,
  }) async {
    final id = salonId.trim();
    final title = name.trim();
    if (id.isEmpty || title.isEmpty) return;

    final now = DateTime.now();
    final current = await getRecentlyViewed();
    final next = <RecentlyViewedSalonModel>[
      RecentlyViewedSalonModel(
        salonId: id,
        name: title,
        area: area?.trim().isNotEmpty == true ? area!.trim() : null,
        coverImageUrl: coverImageUrl?.trim().isNotEmpty == true
            ? coverImageUrl!.trim()
            : null,
        viewedAt: now,
      ),
      ...current.where((e) => e.salonId != id),
    ].take(12).toList(growable: false);

    await _prefs.setString(
      _kRecentlyViewedKey,
      jsonEncode(next.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  LastBookedModel? _parseLastBooked(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return LastBookedModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<LastBookedModel?> getLastBooked() async {
    final raw = _prefs.getString(_kLastBookedKey);
    if (raw == null || raw.trim().isEmpty) return null;
    return _parseLastBooked(raw);
  }

  Future<void> saveLastBooked(LastBookedModel model) async {
    await _prefs.setString(_kLastBookedKey, jsonEncode(model.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_kRecentlyViewedKey);
    await _prefs.remove(_kLastBookedKey);
  }
}

