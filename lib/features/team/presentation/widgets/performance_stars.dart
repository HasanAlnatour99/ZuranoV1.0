import 'package:flutter/material.dart';

import '../theme/team_card_palette.dart';

/// Star rating: [compact] fits narrow chips with five stars; otherwise a [Wrap] of stars.
class PerformanceStars extends StatelessWidget {
  const PerformanceStars({
    super.key,
    required this.rating,
    this.compact = false,
    this.size = 12,
    this.color,
    this.hasPerformanceData = true,
  });

  final double rating;
  final bool compact;
  final double size;
  final Color? color;

  /// When false (no Firestore performance row), shows empty stars in compact mode.
  final bool hasPerformanceData;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? TeamCardPalette.goldStar;
    final effectiveRating = rating.isFinite
        ? rating.clamp(0, 5).toDouble()
        : 0.0;

    if (!hasPerformanceData) {
      if (compact) {
        return _StarRow(
          fullStars: 0,
          hasHalf: false,
          size: size,
          starColor: starColor,
          emptyOnly: true,
        );
      }
      return _StarRow(
        fullStars: 0,
        hasHalf: false,
        size: size,
        starColor: starColor,
        emptyOnly: true,
      );
    }

    final fullStars = effectiveRating.floor();
    final hasHalf = effectiveRating - fullStars >= 0.5;

    if (compact) {
      return _StarRow(
        fullStars: fullStars,
        hasHalf: hasHalf,
        size: size,
        starColor: starColor,
        emptyOnly: false,
      );
    }

    return Wrap(
      spacing: -1,
      runSpacing: 0,
      children: List.generate(5, (index) {
        late final IconData icon;
        if (index < fullStars) {
          icon = Icons.star_rounded;
        } else if (index == fullStars && hasHalf) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: starColor);
      }),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.fullStars,
    required this.hasHalf,
    required this.size,
    required this.starColor,
    required this.emptyOnly,
  });

  final int fullStars;
  final bool hasHalf;
  final double size;
  final Color starColor;
  final bool emptyOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: List.generate(5, (index) {
        late final IconData icon;
        late final Color c;
        if (emptyOnly) {
          icon = Icons.star_border_rounded;
          c = starColor.withValues(alpha: 0.78);
        } else if (index < fullStars) {
          icon = Icons.star_rounded;
          c = starColor;
        } else if (index == fullStars && hasHalf) {
          icon = Icons.star_half_rounded;
          c = starColor;
        } else {
          icon = Icons.star_border_rounded;
          c = starColor.withValues(alpha: 0.78);
        }
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 1),
          child: Icon(icon, size: size + 1, color: c),
        );
      }),
    );
  }
}
