import 'package:flutter/material.dart';

/// Single-line discovery empty row — minimal vertical footprint.
class CustomerCompactEmptyState extends StatelessWidget {
  const CustomerCompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.outline.withValues(alpha: 0.75)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.1,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards-compatible alias — uses compact layout.
class CustomerDiscoverEmpty extends StatelessWidget {
  const CustomerDiscoverEmpty({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CustomerCompactEmptyState(icon: icon, message: message);
  }
}
