import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/app_settings_providers.dart';
import '../domain/models/recent_customer_search.dart';

final customerRecentSearchesControllerProvider = NotifierProvider<
  CustomerRecentSearchesController,
  List<RecentCustomerSearch>
>(CustomerRecentSearchesController.new);

class CustomerRecentSearchesController
    extends Notifier<List<RecentCustomerSearch>> {
  static const _prefsKey = 'recent_customer_searches';
  static const _maxItems = 8;

  @override
  List<RecentCustomerSearch> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getStringList(_prefsKey) ?? const <String>[];
    final out = <RecentCustomerSearch>[];
    for (final row in raw) {
      try {
        final map = jsonDecode(row);
        if (map is! Map) continue;
        final query = '${map['query'] ?? ''}'.trim();
        if (query.isEmpty) continue;
        final type = map['type'] == null ? null : '${map['type']}'.trim();
        final ms = map['createdAtMs'];
        final createdAt = ms is num
            ? DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true)
            : DateTime.now().toUtc();
        out.add(
          RecentCustomerSearch(query: query, type: type, createdAt: createdAt),
        );
      } catch (_) {
        // Ignore malformed rows (forward compatible).
      }
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out.take(_maxItems).toList(growable: false);
  }

  Future<void> add(String query, {String? type}) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final now = DateTime.now().toUtc();
    final normalized = q.toLowerCase();

    final next = <RecentCustomerSearch>[
      RecentCustomerSearch(query: q, type: type?.trim(), createdAt: now),
      ...state.where((s) => s.query.trim().toLowerCase() != normalized),
    ].take(_maxItems).toList(growable: false);

    await _persist(next);
    state = next;
  }

  Future<void> remove(String query) async {
    final normalized = query.trim().toLowerCase();
    final next = state
        .where((s) => s.query.trim().toLowerCase() != normalized)
        .toList(growable: false);
    await _persist(next);
    state = next;
  }

  Future<void> clear() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_prefsKey);
    state = const <RecentCustomerSearch>[];
  }

  Future<void> _persist(List<RecentCustomerSearch> items) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = items
        .map(
          (e) => jsonEncode({
            'query': e.query,
            'type': e.type,
            'createdAtMs': e.createdAt.millisecondsSinceEpoch,
          }),
        )
        .toList(growable: false);
    await prefs.setStringList(_prefsKey, raw);
  }
}

