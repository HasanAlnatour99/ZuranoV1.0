import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer.dart';
import '../../domain/customer_model.dart';
import 'customer_card_action_button.dart';

/// Soft Zurano-style surface gradient for CRM customer tiles.
LinearGradient _customerCardSurfaceGradient({required bool isInactive}) {
  if (isInactive) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF3F4F6),
        FinanceDashboardColors.surface,
      ],
    );
  }
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(
            FinanceDashboardColors.lightPurple,
            Colors.white,
            0.35,
          ) ??
          FinanceDashboardColors.lightPurple,
      FinanceDashboardColors.surface,
      Color.lerp(
            FinanceDashboardColors.headerGradientEnd,
            FinanceDashboardColors.surface,
            0.92,
          ) ??
          FinanceDashboardColors.surface,
    ],
    stops: const [0.0, 0.48, 1.0],
  );
}

class CustomerCard extends StatefulWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.l10n,
    required this.localeName,
    required this.currencyCode,
    required this.onTap,
    required this.onOpenProfile,
    this.listIndex = 0,
  });

  final Customer customer;
  final AppLocalizations l10n;
  final String localeName;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onOpenProfile;
  final int listIndex;

  static String initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    return ('$a$b').toUpperCase();
  }

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  bool _pressed = false;

  Future<void> _tryLaunch(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.customersActionCouldNotOpen)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.customersActionCouldNotOpen)),
        );
      }
    }
  }

  String _digitsOnly(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final l10n = widget.l10n;
    final isInactive = !customer.isActive;
    final segment = segmentForCustomer(customer);
    final lastVisit = customer.lastVisitAt;
    final locale = Localizations.localeOf(context);
    final spentLabel = formatSalonMoneyWithCode(
      customer.totalSpent,
      widget.currencyCode,
      locale,
    );

    final card = AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: FinanceDashboardColors.primaryPurple.withValues(
            alpha: 0.12,
          ),
          highlightColor: FinanceDashboardColors.primaryPurple.withValues(
            alpha: 0.06,
          ),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: _customerCardSurfaceGradient(isInactive: isInactive),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: FinanceDashboardColors.primaryPurple.withValues(
                  alpha: isInactive ? 0.06 : 0.12,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: FinanceDashboardColors.primaryPurple.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                        child: Text(
                          CustomerCard.initialsFor(customer.visibleDisplayName),
                          style: const TextStyle(
                            color: FinanceDashboardColors.primaryPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    customer.visibleDisplayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: FinanceDashboardColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusPill(isInactive: isInactive, l10n: l10n),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _CategoryBadge(segment: segment, l10n: l10n),
                            const SizedBox(height: 8),
                            Text(
                              customer.phone,
                              style: const TextStyle(
                                color: FinanceDashboardColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: FinanceDashboardColors.textSecondary.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailLine(
                    icon: Icons.calendar_month_outlined,
                    text: lastVisit == null
                        ? l10n.customersLastVisitNever
                        : l10n.customersLastVisitShort(
                            DateFormat.yMMMd(
                              widget.localeName,
                            ).format(lastVisit.toLocal()),
                          ),
                  ),
                  const SizedBox(height: 6),
                  _DetailLine(
                    icon: Icons.repeat_rounded,
                    text: l10n.customersVisitsShort(customer.totalVisits),
                  ),
                  const SizedBox(height: 6),
                  _DetailLine(
                    icon: Icons.payments_outlined,
                    text: l10n.customersTotalSpentLine(spentLabel),
                  ),
                  if (customer.lastServiceName != null &&
                      customer.lastServiceName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailLine(
                      icon: Icons.content_cut_rounded,
                      text: l10n.customersLastServiceLine(
                        customer.lastServiceName!.trim(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Opacity(
                        opacity: customer.phone.trim().isEmpty ? 0.35 : 1,
                        child: CustomerCardActionButton(
                          icon: Icons.call_rounded,
                          semanticLabel: l10n.customersActionCall,
                          onPressed: customer.phone.trim().isEmpty
                              ? () {}
                              : () {
                                  final d = _digitsOnly(customer.phone);
                                  if (d.isEmpty) return;
                                  _tryLaunch(
                                    context,
                                    Uri(scheme: 'tel', path: d),
                                  );
                                },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Opacity(
                        opacity: _digitsOnly(customer.phone).isEmpty ? 0.35 : 1,
                        child: CustomerCardActionButton(
                          icon: Icons.chat_rounded,
                          semanticLabel: l10n.customersActionMessage,
                          onPressed: () {
                            final d = _digitsOnly(customer.phone);
                            if (d.isEmpty) return;
                            _tryLaunch(
                              context,
                              Uri.parse('https://wa.me/$d'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomerCardActionButton(
                        icon: Icons.person_outline_rounded,
                        semanticLabel: l10n.customersActionViewProfile,
                        onPressed: widget.onOpenProfile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return card
        .animate()
        .fadeIn(
          duration: 340.ms,
          delay: math.min(240, 40 * widget.listIndex).ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 360.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.segment, required this.l10n});

  final CustomerSegment segment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final data = switch (segment) {
      CustomerSegment.vip => (
        label: l10n.customersTagVip,
        icon: Icons.workspace_premium_rounded,
        bg: const Color(0xFFF3E8FF),
        fg: FinanceDashboardColors.primaryPurple,
      ),
      CustomerSegment.regular => (
        label: l10n.customersCategoryRegularBadge,
        icon: Icons.star_border_rounded,
        bg: FinanceDashboardColors.greenProfitSoft,
        fg: FinanceDashboardColors.greenProfit,
      ),
      CustomerSegment.newCustomer => (
        label: l10n.customersCategoryNewBadge,
        icon: Icons.auto_awesome_rounded,
        bg: FinanceDashboardColors.bluePayrollSoft,
        fg: FinanceDashboardColors.bluePayroll,
      ),
    };

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: data.bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.label,
              style: TextStyle(
                color: data.fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(data.icon, size: 14, color: data.fg),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isInactive, required this.l10n});

  final bool isInactive;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = isInactive
        ? FinanceDashboardColors.textSecondary
        : FinanceDashboardColors.greenProfit;
    final label = isInactive
        ? l10n.customersStatusInactive
        : l10n.customersStatusActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: FinanceDashboardColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
