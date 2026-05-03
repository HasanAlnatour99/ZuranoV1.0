import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../owner/presentation/widgets/overview/overview_design_tokens.dart';
import '../../domain/models/customer_growth_summary.dart';
import '../providers/customer_growth_provider.dart';

class CustomerGrowthCard extends ConsumerWidget {
  const CustomerGrowthCard({super.key, required this.salonId});

  final String salonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmed = salonId.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final text = _CustomerGrowthCopy.of(context);
    final asyncSummary = ref.watch(customerGrowthProvider(trimmed));

    return _CustomerCardShell(
      child: asyncSummary.when(
        loading: () => _CustomerLoading(header: _CustomerHeader(text: text)),
        error: (_, _) => _CustomerError(
          header: _CustomerHeader(text: text),
          message: text.error,
        ),
        data: (summary) => _CustomerGrowthBody(text: text, summary: summary),
      ),
    );
  }
}

class _CustomerGrowthBody extends StatelessWidget {
  const _CustomerGrowthBody({required this.text, required this.summary});

  final _CustomerGrowthCopy text;
  final CustomerGrowthSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomerHeader(text: text),
        const SizedBox(height: 16),
        _CustomerStatsColumn(
          children: [
            _CustomerGrowthVerticalItem(
              icon: Icons.person_add_alt_1_rounded,
              label: text.newToday,
              value: summary.newToday,
            ),
            _CustomerGrowthVerticalItem(
              icon: Icons.replay_rounded,
              label: text.returning,
              value: summary.returningToday,
            ),
            _CustomerGrowthVerticalItem(
              icon: Icons.calendar_month_rounded,
              label: text.thisMonth,
              value: summary.totalThisMonth,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CustomerFooter(text: text.caption),
      ],
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.text});

  final _CustomerGrowthCopy text;

  @override
  Widget build(BuildContext context) {
    return _CustomerInsightHeader(
      icon: Icons.people_alt_rounded,
      title: text.title,
      subtitle: text.subtitle,
    );
  }
}

class _CustomerGrowthVerticalItem extends StatelessWidget {
  const _CustomerGrowthVerticalItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2C7FF)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: OwnerOverviewTokens.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF17151F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7685),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerStatsColumn extends StatelessWidget {
  const _CustomerStatsColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}

class _CustomerFooter extends StatelessWidget {
  const _CustomerFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: OwnerOverviewTokens.purple.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B8795),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerCardShell extends StatelessWidget {
  const _CustomerCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2C7FF), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: OwnerOverviewTokens.purple.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CustomerInsightHeader extends StatelessWidget {
  const _CustomerInsightHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E4FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: OwnerOverviewTokens.purple, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16151F),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A7685),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerLoading extends StatelessWidget {
  const _CustomerLoading({required this.header});

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 16),
        _CustomerStatsColumn(
          children: const [
            _CustomerStatSkeleton(),
            _CustomerStatSkeleton(),
            _CustomerStatSkeleton(),
          ],
        ),
        const SizedBox(height: 14),
        const _CustomerFooter(text: 'Based on completed services'),
      ],
    );
  }
}

class _CustomerStatSkeleton extends StatelessWidget {
  const _CustomerStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2C7FF)),
      ),
      child: Row(
        children: [
          const _SkeletonBlock(width: 42, height: 42, radius: 14),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SkeletonBlock(width: 30, height: 22, radius: 7),
                SizedBox(height: 8),
                _SkeletonBlock(width: 74, height: 12, radius: 99),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OwnerOverviewTokens.purple.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CustomerError extends StatelessWidget {
  const _CustomerError({required this.header, required this.message});

  final Widget header;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CustomerGrowthCopy {
  const _CustomerGrowthCopy({
    required this.title,
    required this.subtitle,
    required this.newToday,
    required this.returning,
    required this.thisMonth,
    required this.caption,
    required this.error,
  });

  final String title;
  final String subtitle;
  final String newToday;
  final String returning;
  final String thisMonth;
  final String caption;
  final String error;

  static _CustomerGrowthCopy of(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isArabic) {
      return _CustomerGrowthCopy(
        title: 'العملاء',
        subtitle: 'اليوم وهذا الشهر',
        newToday: 'جدد اليوم',
        returning: 'عائدون',
        thisMonth: 'هذا الشهر',
        caption: 'يعتمد على الزيارات المكتملة',
        error: 'تعذر تحميل نمو العملاء.',
      );
    }

    return _CustomerGrowthCopy(
      title: 'Customers',
      subtitle: 'Today and this month',
      newToday: 'New Today',
      returning: 'Returning',
      thisMonth: 'This Month',
      caption: 'Based on completed services',
      error: 'Could not load customer growth.',
    );
  }
}
