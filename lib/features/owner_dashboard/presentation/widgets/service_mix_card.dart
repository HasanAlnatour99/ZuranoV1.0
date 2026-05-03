import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../owner/presentation/widgets/overview/overview_design_tokens.dart';
import '../../domain/models/service_mix_item.dart';
import '../providers/service_mix_provider.dart';

class ServiceMixCard extends ConsumerWidget {
  const ServiceMixCard({
    super.key,
    required this.salonId,
    required this.currencyCode,
  });

  final String salonId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmed = salonId.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final text = _OverviewInsightCopy.of(context);
    final asyncItems = ref.watch(todayServiceMixProvider(trimmed));

    return _InsightCardShell(
      child: asyncItems.when(
        loading: () => _InsightLoading(header: _ServiceMixHeader(text: text)),
        error: (_, _) => _InsightError(
          header: _ServiceMixHeader(text: text),
          message: text.serviceMixError,
        ),
        data: (items) {
          if (items.isEmpty) {
            return _InsightEmpty(
              header: _ServiceMixHeader(text: text),
              icon: Icons.content_cut_rounded,
              message: text.serviceMixEmpty,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ServiceMixHeader(text: text),
              const SizedBox(height: 18),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 14),
                  child: _ServiceMixRow(
                    item: item,
                    currencyCode: currencyCode,
                    countLabel: text.servicesCount(item.count),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceMixHeader extends StatelessWidget {
  const _ServiceMixHeader({required this.text});

  final _OverviewInsightCopy text;

  @override
  Widget build(BuildContext context) {
    return _InsightHeader(
      icon: Icons.bar_chart_rounded,
      title: text.serviceMixTitle,
      subtitle: text.serviceMixSubtitle,
    );
  }
}

class _ServiceMixRow extends StatelessWidget {
  const _ServiceMixRow({
    required this.item,
    required this.currencyCode,
    required this.countLabel,
  });

  final ServiceMixItem item;
  final String currencyCode;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final percent = (item.percentage * 100).round().clamp(0, 100);
    final revenue = formatAppMoney(item.revenue, currencyCode, locale);

    return Semantics(
      label: '${item.serviceLabel}, $percent%, $countLabel, $revenue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.serviceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17151F),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent%',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: OwnerOverviewTokens.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: item.percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF0E7FF),
              valueColor: AlwaysStoppedAnimation<Color>(
                OwnerOverviewTokens.purple,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$countLabel  |  $revenue',
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B8795),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCardShell extends StatelessWidget {
  const _InsightCardShell({required this.child});

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

class _InsightHeader extends StatelessWidget {
  const _InsightHeader({
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

class _InsightLoading extends StatelessWidget {
  const _InsightLoading({required this.header});

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        SizedBox(
          height: 116,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: OwnerOverviewTokens.purple,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightEmpty extends StatelessWidget {
  const _InsightEmpty({
    required this.header,
    required this.icon,
    required this.message,
  });

  final Widget header;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F2FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(icon, color: OwnerOverviewTokens.purple, size: 26),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7685),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightError extends StatelessWidget {
  const _InsightError({required this.header, required this.message});

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

class _OverviewInsightCopy {
  const _OverviewInsightCopy({
    required this.serviceMixTitle,
    required this.serviceMixSubtitle,
    required this.serviceMixEmpty,
    required this.serviceMixError,
    required this.servicesCount,
  });

  final String serviceMixTitle;
  final String serviceMixSubtitle;
  final String serviceMixEmpty;
  final String serviceMixError;
  final String Function(int count) servicesCount;

  static _OverviewInsightCopy of(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isArabic) {
      return _OverviewInsightCopy(
        serviceMixTitle: 'مزيج الخدمات',
        serviceMixSubtitle: 'الخدمات الاكثر طلبا اليوم',
        serviceMixEmpty: 'لا توجد خدمات مسجلة اليوم',
        serviceMixError: 'تعذر تحميل مزيج الخدمات.',
        servicesCount: (count) => '$count خدمات',
      );
    }
    return _OverviewInsightCopy(
      serviceMixTitle: 'Service Mix',
      serviceMixSubtitle: 'Most popular services today',
      serviceMixEmpty: 'No services recorded yet today',
      serviceMixError: 'Could not load service mix.',
      servicesCount: (count) => count == 1 ? '1 service' : '$count services',
    );
  }
}
