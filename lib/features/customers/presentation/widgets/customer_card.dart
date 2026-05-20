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
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [
      Colors.white,
      const Color(0xFFFCF9FF),
      Color.lerp(
            FinanceDashboardColors.headerGradientEnd,
            FinanceDashboardColors.surface,
            0.94,
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
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
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
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: FinanceDashboardColors.primaryPurple.withValues(
                  alpha: isInactive ? 0.06 : 0.10,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: FinanceDashboardColors.primaryPurple.withValues(
                    alpha: 0.09,
                  ),
                  blurRadius: 30,
                  spreadRadius: -8,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 16,
                  spreadRadius: -10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              FinanceDashboardColors.lightPurple,
                              Colors.white.withValues(alpha: 0.92),
                            ],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: FinanceDashboardColors.primaryPurple
                                  .withValues(alpha: 0.12),
                              blurRadius: 18,
                              spreadRadius: -6,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
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
                            const SizedBox(height: 4),
                            Text(
                              l10n.customersCustomerIdLabel(
                                _shortCustomerId(customer.id),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: FinanceDashboardColors.textSecondary
                                    .withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          _MoreButton(
                            tooltip: l10n.customersActionViewProfile,
                            onPressed: widget.onOpenProfile,
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            color: FinanceDashboardColors.textSecondary
                                .withValues(alpha: 0.62),
                          ),
                        ],
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          icon: Icons.repeat_rounded,
                          value: '${customer.totalVisits}',
                          label: l10n.customersVisitsMetricLabel,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricTile(
                          icon: Icons.payments_outlined,
                          value: spentLabel,
                          label: l10n.customersLifetimeValueLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LoyaltyProgress(
                    label: l10n.customersLoyaltyProgressLabel,
                    value: (customer.totalVisits / 10)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                  ),
                  if (customer.lastServiceName != null &&
                      customer.lastServiceName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
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

String _shortCustomerId(String id) {
  final trimmed = id.trim();
  if (trimmed.length <= 8) return trimmed;
  return trimmed.substring(0, 8).toUpperCase();
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

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              Icons.more_horiz_rounded,
              color: FinanceDashboardColors.primaryPurple,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 16,
              color: FinanceDashboardColors.primaryPurple,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
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

class _LoyaltyProgress extends StatelessWidget {
  const _LoyaltyProgress({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.82),
              valueColor: const AlwaysStoppedAnimation<Color>(
                FinanceDashboardColors.primaryPurple,
              ),
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
