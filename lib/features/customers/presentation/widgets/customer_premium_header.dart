import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';

const _primaryPurple = Color(0xFF7B2FF7);
const _deepPurple = Color(0xFF5B21FF);
const _lightPurple = Color(0xFFB388FF);

class CustomerPremiumHeader extends StatelessWidget {
  const CustomerPremiumHeader({
    super.key,
    required this.salonName,
    required this.showProBadge,
    required this.unreadNotifications,
    required this.height,
    required this.onMenuTap,
  });

  final String salonName;
  final bool showProBadge;
  final int unreadNotifications;
  final double height;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displaySalon = salonName.trim().isEmpty
        ? l10n.customersScreenTitle
        : salonName.trim();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_deepPurple, _primaryPurple, _lightPurple],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const PositionedDirectional(
                top: -66,
                end: -36,
                child: _SoftCircle(size: 138, opacity: 0.20),
              ),
              const PositionedDirectional(
                bottom: -62,
                start: -34,
                child: _SoftCircle(size: 126, opacity: 0.13),
              ),
              const PositionedDirectional(
                top: 26,
                end: 112,
                child: _SoftCircle(size: 52, opacity: 0.08),
              ),
              CustomPaint(painter: _HeaderWavePainter()),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    20,
                    10,
                    20,
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _HeaderActionButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).openAppDrawerTooltip,
                        icon: Icons.menu_rounded,
                        onTap: onMenuTap,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.customersScreenTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.45,
                                height: 1.02,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displaySalon,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.80,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                if (showProBadge) ...[
                                  const SizedBox(width: 8),
                                  _ProPill(
                                    label: l10n.ownerDashboardHeroProBadge,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _HeaderActionButton(
                        tooltip: l10n.notificationsInboxTooltip,
                        icon: Icons.notifications_none_rounded,
                        badgeCount: unreadNotifications,
                        onTap: () => context.push(AppRoutes.notifications),
                      ),
                      const SizedBox(width: 8),
                      _HeaderActionButton(
                        tooltip: l10n.ownerDashboardSettingsTooltip,
                        icon: Icons.settings_rounded,
                        onTap: () => context.push(AppRoutes.ownerSettings),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProPill extends StatelessWidget {
  const _ProPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 21),
                if (badgeCount > 0)
                  PositionedDirectional(
                    top: 7,
                    end: 7,
                    child: _NotificationBadge(count: badgeCount),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.11);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.18);

    for (var i = 0; i < 3; i += 1) {
      final y = size.height * (0.35 + i * 0.18);
      final path = Path()
        ..moveTo(-18, y)
        ..cubicTo(
          size.width * 0.25,
          y - 20,
          size.width * 0.58,
          y + 24,
          size.width + 18,
          y - 10,
        );
      canvas.drawPath(path, wavePaint);
    }

    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.25),
      1.8,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.68),
      1.4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.74),
      1.2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
