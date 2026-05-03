import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Stable [Page] key for go_router-backed [Navigator] stacks.
///
/// Problems this avoids:
///
/// 1. **Parameterized routes**: [GoRouterState.pageKey] follows the route
///    *pattern* (e.g. `/owner/customers/:customerId`). Two fullscreen pages with
///    different ids would share one key → duplicate-key assert.
///
/// 2. **Shared [GoRouterState.uri]**: Each [RouteMatch]'s state uses the **same**
///    full-app [Uri], so keys based only on [GoRouterState.uri] can collide
///    across matches in one stack (e.g. shell + overlay).
///
/// Pairing pattern [ValueKey.value] with this match's [GoRouterState.matchedLocation]
/// (and optional query string) yields a distinct key per page in normal stacks.
LocalKey goRouterPageKey(GoRouterState state) {
  final pattern = state.pageKey.value;
  final loc = state.matchedLocation;
  final q = state.uri.query;
  final querySuffix = q.isEmpty ? '' : '?$q';
  return ValueKey<String>('$pattern|$loc$querySuffix');
}
