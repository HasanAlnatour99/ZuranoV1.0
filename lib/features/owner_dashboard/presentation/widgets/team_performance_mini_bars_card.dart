import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../owner/presentation/widgets/overview/overview_design_tokens.dart';
import '../../domain/models/team_performance_item.dart';
import '../providers/team_performance_provider.dart';

/// Owner overview: top barbers by today’s completed POS revenue (live).
class TeamPerformanceMiniBarsCard extends ConsumerWidget {
  const TeamPerformanceMiniBarsCard({
    super.key,
    required this.salonId,
    required this.currencyCode,
  });

  final String salonId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmedSalonId = salonId.trim();
    if (trimmedSalonId.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final asyncPerformance = ref.watch(
      todayTeamPerformanceProvider(trimmedSalonId),
    );

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
      child: asyncPerformance.when(
        loading: () => const _TeamPerformanceLoading(),
        error: (_, _) => _TeamPerformanceError(
          message: l10n.ownerOverviewTeamPerformanceError,
        ),
        data: (items) {
          if (items.isEmpty) {
            return _TeamPerformanceEmpty(l10n: l10n);
          }

          final maxRevenue = items.fold<double>(
            0,
            (prev, item) => item.revenue > prev ? item.revenue : prev,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(l10n: l10n),
              const SizedBox(height: 18),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 14),
                  child: _PerformanceRow(
                    l10n: l10n,
                    locale: locale,
                    item: item,
                    maxRevenue: maxRevenue,
                    currencyCode: currencyCode,
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

class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

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
          child: Icon(
            Icons.groups_rounded,
            color: OwnerOverviewTokens.purple,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ownerOverviewTeamPerformanceTitle,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16151F),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.ownerOverviewTeamPerformanceSubtitle,
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

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({
    required this.l10n,
    required this.locale,
    required this.item,
    required this.maxRevenue,
    required this.currencyCode,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final TeamPerformanceItem item;
  final double maxRevenue;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final progress = maxRevenue <= 0 ? 0.0 : item.revenue / maxRevenue;
    final displayName = item.displayName.trim().isEmpty
        ? l10n.ownerOverviewTeamPerformanceFallbackName
        : item.displayName.trim();
    final revenueLabel = formatAppMoney(item.revenue, currencyCode, locale);
    final servicesLabel = l10n.ownerOverviewTeamPerformanceServicesToday(
      item.servicesCount,
    );

    return Semantics(
      label: '$displayName, $revenueLabel, $servicesLabel',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: displayName, imageUrl: item.profileImageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17151F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      revenueLabel,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: OwnerOverviewTokens.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0E7FF),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      OwnerOverviewTokens.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  servicesLabel,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B8795),
                    fontWeight: FontWeight.w500,
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFFA855F7)],
        ),
        boxShadow: [
          BoxShadow(
            color: OwnerOverviewTokens.purple.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
                imageUrl!.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialAvatar(initial: initial),
              )
            : _InitialAvatar(initial: initial),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _TeamPerformanceLoading extends StatelessWidget {
  const _TeamPerformanceLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: OwnerOverviewTokens.purple,
        ),
      ),
    );
  }
}

class _TeamPerformanceEmpty extends StatelessWidget {
  const _TeamPerformanceEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(l10n: l10n),
        const SizedBox(height: 18),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              l10n.ownerOverviewTeamPerformanceEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B8795),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamPerformanceError extends StatelessWidget {
  const _TeamPerformanceError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(l10n: l10n),
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
