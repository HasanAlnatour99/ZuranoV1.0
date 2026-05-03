import 'package:flutter/material.dart';

import 'shift_ui/shift_design_tokens.dart';

class ScheduleOptionTile extends StatelessWidget {
  const ScheduleOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.leadingIcon = Icons.event_note_outlined,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 86,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? ShiftDesignTokens.primary
                      : ShiftDesignTokens.textMuted,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ShiftDesignTokens.softPurple,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ShiftDesignTokens.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: ShiftDesignTokens.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ShiftDesignTokens.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ShiftDesignTokens.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
