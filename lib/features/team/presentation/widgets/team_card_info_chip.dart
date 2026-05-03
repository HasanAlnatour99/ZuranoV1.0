import 'package:flutter/material.dart';

import '../theme/team_card_palette.dart';

enum TeamCardChipTone {
  green,
  red,
  orange,
  purple,
  dayOff,
  pendingCheckIn,
}

class TeamCardInfoChip extends StatelessWidget {
  const TeamCardInfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.customValue,
    required this.tone,
    this.expandToParentWidth = false,
  }) : assert(
         (value != null) ^ (customValue != null),
         'Provide exactly one of value or customValue',
       );

  final IconData icon;
  final String label;
  final String? value;
  final Widget? customValue;
  final TeamCardChipTone tone;

  /// When true, skips max width so the chip can fill [Expanded] in a [Row].
  final bool expandToParentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final (Color fg, Color bg, Color border) = switch (tone) {
      TeamCardChipTone.green => (
        TeamCardPalette.statusOnFg,
        TeamCardPalette.statusOnBg,
        TeamCardPalette.statusOnBorder,
      ),
      TeamCardChipTone.red => (
        TeamCardPalette.statusOffFg,
        TeamCardPalette.statusOffBg,
        TeamCardPalette.statusOffBorder,
      ),
      TeamCardChipTone.orange => (
        TeamCardPalette.attendWorkingFg,
        TeamCardPalette.attendWorkingBg,
        TeamCardPalette.attendWorkingBorder,
      ),
      TeamCardChipTone.purple => (
        TeamCardPalette.performanceFg,
        TeamCardPalette.performanceBg,
        TeamCardPalette.performanceBorder,
      ),
      TeamCardChipTone.dayOff => (
        TeamCardPalette.attendOffFg,
        TeamCardPalette.attendOffBg,
        TeamCardPalette.attendOffBorder,
      ),
      TeamCardChipTone.pendingCheckIn => (
        TeamCardPalette.attendPendingFg,
        TeamCardPalette.attendPendingBg,
        TeamCardPalette.attendPendingBorder,
      ),
    };

    final body = Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: isRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (customValue != null)
            Align(
              alignment: isRtl
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: customValue!,
            )
          else
            Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF101828),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );

    if (expandToParentWidth) {
      return body;
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 112),
      child: body,
    );
  }
}
