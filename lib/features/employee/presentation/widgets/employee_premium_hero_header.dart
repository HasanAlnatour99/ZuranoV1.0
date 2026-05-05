import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../l10n/app_localizations.dart';
import 'animated_hero_light_wave.dart';
import 'hero_mesh_background.dart';

/// Hides the shift chip when there is no real shift (avoids a clipped "No" pill).
bool _employeeHeroShowsShiftChip(String shiftLine, AppLocalizations l10n) {
  final s = shiftLine.trim();
  if (s.isEmpty) return false;
  final none = l10n.employeeHeroShiftNone.trim();
  if (s == none) return false;
  if (s.toLowerCase() == none.toLowerCase()) return false;
  if (s.toLowerCase() == 'no') return false;
  return true;
}

/// Premium purple hero for the employee Today tab — full width under the
/// status bar (parent uses [SafeArea] with `top: false`); inner padding clears
/// the notch and nudges content down. Bottom: tier + shift + date in a [Wrap].
class EmployeePremiumHeroHeader extends StatelessWidget {
  const EmployeePremiumHeroHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.salonName,
    required this.tier,
    required this.photoUrl,
    required this.shiftLine,
    required this.formattedDate,
    required this.unreadCount,
    required this.onSettingsTap,
    required this.onNotificationsTap,
  });

  final String greeting;
  final String name;
  final String salonName;
  final String? tier;
  final String? photoUrl;
  final String shiftLine;
  final String formattedDate;
  final int unreadCount;
  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;

  static const BorderRadius _bottomRadius = BorderRadius.vertical(
    bottom: Radius.circular(24),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final mq = MediaQuery.sizeOf(context);
    final narrow = mq.width < 360;
    final veryTight = mq.width < 340;
    final nameSize = veryTight ? 18.0 : (narrow ? 19.0 : 23.0);
    final tierLabel = tier != null && tier!.trim().isNotEmpty
        ? tier!.trim()
        : salonName;

    final statusTop = MediaQuery.paddingOf(context).top;

    /// Extra air below the status bar (avatar, name, actions).
    const contentDrop = 10.0;
    final heroContentHeight = veryTight ? 220.0 : (narrow ? 212.0 : 204.0);
    final pad = veryTight ? 14.0 : 16.0;
    final avatarSize = veryTight ? 62.0 : 70.0;
    final showShiftChip = _employeeHeroShowsShiftChip(shiftLine, l10n);
    final bottomChipLabelWidth = ((mq.width - pad * 2 - 8) * 0.46).clamp(
      118.0,
      210.0,
    );
    final topInset = statusTop + contentDrop;
    final totalHeight = heroContentHeight + topInset;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        height: totalHeight,
        decoration: BoxDecoration(
          borderRadius: _bottomRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B21B6).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _bottomRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const HeroMeshBackground(),
              const AnimatedHeroLightWave(),
              Positioned(
                right: isRtl ? null : -40,
                left: isRtl ? -40 : null,
                top: -30,
                child: _GlowCircle(
                  size: 150,
                  color: const Color(0xFFE879F9).withValues(alpha: 0.35),
                ),
              ),
              Positioned(
                left: isRtl ? null : -50,
                right: isRtl ? -50 : null,
                bottom: -55,
                child: _GlowCircle(
                  size: 150,
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(pad, pad + topInset, pad, pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          _Avatar(photoUrl: photoUrl, diameter: avatarSize),
                          SizedBox(width: veryTight ? 12 : 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ExcludeSemantics(
                                      child: Text(
                                        '✦',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFF5D0FE,
                                          ).withValues(alpha: 0.95),
                                          fontSize: veryTight ? 11 : 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        greeting,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                          fontSize: veryTight ? 12 : 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: veryTight ? 5 : 6),
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: nameSize,
                                    height: 1.05,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HeaderIconButton(
                                tooltip: l10n.employeeTodaySemanticSettings,
                                icon: Icons.settings_rounded,
                                onTap: onSettingsTap,
                                compact: veryTight,
                              ),
                              SizedBox(width: veryTight ? 6 : 8),
                              _HeaderIconButton(
                                tooltip:
                                    l10n.employeeTodaySemanticNotifications,
                                icon: Icons.notifications_none_rounded,
                                onTap: onNotificationsTap,
                                compact: veryTight,
                                iconBuilder: () => AppNotificationBadge(
                                  count: unreadCount,
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: veryTight ? 22 : 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: veryTight ? 8 : 10),
                    Wrap(
                      spacing: veryTight ? 8 : 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      textDirection: isRtl
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        _GlassPill(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: const Color(0xFFFACC15),
                          label: tierLabel,
                          compact: veryTight,
                          maxLabelLines: 4,
                          labelMaxWidth: bottomChipLabelWidth,
                        ),
                        if (showShiftChip)
                          _GlassPill(
                            icon: Icons.schedule_rounded,
                            label: shiftLine,
                            compact: true,
                            dense: veryTight,
                            maxLabelLines: 4,
                            labelMaxWidth: bottomChipLabelWidth,
                          ),
                        _GlassPill(
                          icon: Icons.calendar_month_rounded,
                          label: formattedDate,
                          compact: true,
                          dense: veryTight,
                          maxLabelLines: 3,
                          labelMaxWidth: bottomChipLabelWidth,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, this.diameter = 82});

  final String? photoUrl;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final trimmed = photoUrl?.trim();
    final hasPhoto = trimmed != null && trimmed.isNotEmpty;
    final iconSize = diameter < 68 ? 28.0 : 32.0;

    return Container(
      width: diameter,
      height: diameter,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF0ABFC), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC084FC).withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: hasPhoto ? NetworkImage(trimmed) : null,
        child: hasPhoto
            ? null
            : Icon(
                Icons.person_rounded,
                color: const Color(0xFF7C3AED),
                size: iconSize,
              ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.iconBuilder,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Widget Function()? iconBuilder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dim = compact ? 44.0 : 48.0;
    final iconSize = compact ? 22.0 : 24.0;
    final radius = compact ? 14.0 : 16.0;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: dim,
            height: dim,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Center(
              child:
                  iconBuilder?.call() ??
                  Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.icon,
    required this.label,
    this.compact = false,
    this.dense = false,
    this.iconColor = Colors.white,
    this.maxLabelLines = 1,
    this.labelMaxWidth,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool dense;
  final Color iconColor;
  final int maxLabelLines;
  final double? labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    final textDir = Directionality.of(context);
    final labelWidth =
        labelMaxWidth ??
        (MediaQuery.sizeOf(context).width * 0.78).clamp(140.0, 272.0);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: compact ? (dense ? 8 : 10) : 12,
        vertical: compact ? (dense ? 5 : 6) : (dense ? 6 : 7),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              icon,
              color: iconColor,
              size: compact ? (dense ? 14 : 15) : 16,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              textDirection: textDir,
              softWrap: true,
              maxLines: maxLabelLines,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.94),
                fontSize: compact ? (dense ? 11 : 12) : 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
