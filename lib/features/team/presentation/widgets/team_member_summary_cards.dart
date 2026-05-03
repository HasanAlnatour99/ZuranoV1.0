import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';

class TeamMemberSummaryCards extends StatelessWidget {
  const TeamMemberSummaryCards({
    super.key,
    required this.todaySales,
    required this.servicesCount,
    required this.attendanceLabel,
    required this.currencyCode,
    required this.salesTitle,
    required this.servicesTitle,
    required this.attendanceTitle,
  }) : isLoading = false,
       isError = false;

  const TeamMemberSummaryCards.loading({
    super.key,
    required this.salesTitle,
    required this.servicesTitle,
    required this.attendanceTitle,
  }) : todaySales = 0,
       servicesCount = 0,
       attendanceLabel = '',
       currencyCode = '',
       isLoading = true,
       isError = false;

  const TeamMemberSummaryCards.error({
    super.key,
    required this.salesTitle,
    required this.servicesTitle,
    required this.attendanceTitle,
  }) : todaySales = 0,
       servicesCount = 0,
       attendanceLabel = '',
       currencyCode = '',
       isLoading = false,
       isError = true;

  final double todaySales;
  final int servicesCount;
  final String attendanceLabel;
  final String currencyCode;
  final String salesTitle;
  final String servicesTitle;
  final String attendanceTitle;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        children: [
          Expanded(child: _SummarySkeleton()),
          SizedBox(width: 10),
          Expanded(child: _SummarySkeleton()),
          SizedBox(width: 10),
          Expanded(child: _SummarySkeleton()),
        ],
      );
    }

    final currency = NumberFormat.simpleCurrency(name: currencyCode);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.shopping_bag_outlined,
              label: salesTitle,
              value: isError ? '—' : currency.format(todaySales),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.content_cut_rounded,
              label: servicesTitle,
              value: isError ? '—' : '$servicesCount',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.check_circle_outline_rounded,
              label: attendanceTitle,
              value: attendanceLabel,
              compactValueFont: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.compactValueFont = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compactValueFont;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftIcon(icon: icon),
          const SizedBox(height: 12),
          Text(
            label,
            softWrap: true,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            softWrap: true,
            style: textTheme.titleMedium?.copyWith(
              color: TeamMemberProfileColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: compactValueFont ? 14 : 18,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.softPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TeamMemberProfileColors.border.withValues(alpha: 0.65),
        ),
      ),
      child: Icon(
        icon,
        color: TeamMemberProfileColors.primary,
        size: 22,
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
