import 'package:flutter/material.dart';

import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';

class TeamMemberInfoRowData {
  TeamMemberInfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingIcon,
    this.onTap,
    this.valueColor,
    this.valueBackgroundColor,
    this.valueBorderColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final Color? valueColor;
  final Color? valueBackgroundColor;
  final Color? valueBorderColor;
  final bool showChevron;
}

class TeamMemberInfoSection extends StatelessWidget {
  const TeamMemberInfoSection({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<TeamMemberInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (int index = 0; index < rows.length; index++) ...[
            _InfoRow(data: rows[index], scheme: scheme, textTheme: textTheme),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.data,
    required this.scheme,
    required this.textTheme,
  });

  final TeamMemberInfoRowData data;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TeamMemberProfileColors.softPurple,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: TeamMemberProfileColors.border.withValues(alpha: 0.65),
              ),
            ),
            child: Icon(
              data.icon,
              color: TeamMemberProfileColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Builder(
                  builder: (context) {
                    final valueText = Text(
                      data.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: data.valueColor ?? scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                    if (data.valueBackgroundColor == null) {
                      return valueText;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: data.valueBackgroundColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              data.valueBorderColor ??
                              scheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: valueText,
                    );
                  },
                ),
              ],
            ),
          ),
          if (data.trailingIcon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TeamMemberProfileColors.softPurple,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TeamMemberProfileColors.border.withValues(alpha: 0.65),
                ),
              ),
              child: Icon(
                data.trailingIcon,
                color: TeamMemberProfileColors.primary,
                size: 22,
              ),
            )
          else if (data.showChevron)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TeamMemberProfileColors.softPurple,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: TeamMemberProfileColors.border.withValues(alpha: 0.65),
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: TeamMemberProfileColors.primary,
                size: 24,
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );

    if (data.onTap == null) return row;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: data.onTap,
      child: row,
    );
  }
}
