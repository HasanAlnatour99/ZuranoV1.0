import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class PlaceStatusChip extends StatelessWidget {
  const PlaceStatusChip({
    super.key,
    required this.isClosed,
    this.compact = false,
  });

  final bool isClosed;

  /// Dense chip for [PremiumPlaceCard.compact] list rows.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = isClosed ? l10n.placeStatusClosed : l10n.placeStatusOpen;

    final hPad = compact ? 8.0 : 16.0;
    final vPad = compact ? 4.0 : 11.0;
    final iconSize = compact ? 13.0 : 20.0;
    final gap = compact ? 4.0 : 7.0;
    final fontSize = compact ? 11.0 : 15.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: PlaceDiscoveryColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClosed ? Icons.access_time_rounded : Icons.check_circle_rounded,
            size: iconSize,
            color: PlaceDiscoveryColors.primary,
          ),
          SizedBox(width: gap),
          Text(
            text,
            style: TextStyle(
              color: PlaceDiscoveryColors.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
