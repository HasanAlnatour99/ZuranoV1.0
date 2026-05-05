import 'package:flutter/material.dart';

Widget _maybeTooltip({required String? message, required Widget child}) {
  if (message == null || message.isEmpty) {
    return child;
  }
  return Tooltip(message: message, child: child);
}

/// One tab in [ZuranoFloatingBottomNav] (visual order: slot 0 … slot 3).
class ZuranoFloatingNavSlot {
  const ZuranoFloatingNavSlot({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
}

/// Premium floating bottom navigation (custom [Stack], not [BottomNavigationBar]).
///
/// Four slots with a fixed center gap; optional center [InkWell] when both
/// [onCenterTap] and [centerChild] are set. Otherwise only the outer ring is
/// shown in the gap (e.g. employee shell with a separate [FloatingActionButton]).
class ZuranoFloatingBottomNav extends StatelessWidget {
  const ZuranoFloatingBottomNav({
    super.key,
    required this.slots,
    required this.selectedSlotIndex,
    this.centerTooltip,
    this.centerHeroTag,
    this.onCenterTap,
    this.centerChild,
  }) : assert(
         slots.length == 4,
         'ZuranoFloatingBottomNav expects exactly 4 slots',
       );

  final List<ZuranoFloatingNavSlot> slots;

  /// Index into [slots] for the active pill; negative or `>= 4` selects none.
  final int selectedSlotIndex;
  final String? centerTooltip;
  final String? centerHeroTag;
  final VoidCallback? onCenterTap;
  final Widget? centerChild;

  static const Color activePurple = Color(0xFF7B2CFF);
  static const Color borderPurple = Color(0xFFD9C4FF);
  static const Color navBg = Color(0xFFF7F8FC);

  static const double stackHeight = 96;
  static const double barHeight = 74;
  static const double navBorderRadius = 30;
  static const double outerRingSize = 62;
  static const double fabSize = 56;
  static const double ringTop = 18;
  static const double fabTop = 22;
  static const double centerGapWidth = 72;

  /// Gap between the pill / system home inset and the physical bottom edge.
  static const double outerBottomSpacing = 4;

  /// Extra bottom padding for scrollables above this bar.
  static double scrollBottomPadding(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    const barTopFromBottom = barHeight;
    final fabTopFromBottom = stackHeight - fabTop;
    final protrusion = (fabTopFromBottom - barTopFromBottom).clamp(0.0, 100.0);
    return protrusion + 26 + safe + outerBottomSpacing;
  }

  bool get _hasInteractiveCenter => onCenterTap != null && centerChild != null;

  @override
  Widget build(BuildContext context) {
    final rowChildren = <Widget>[
      for (var i = 0; i < 2; i++)
        Expanded(
          child: ZuranoFloatingNavItem(
            icon: slots[i].icon,
            selectedIcon: slots[i].selectedIcon,
            label: slots[i].label,
            isActive: i == selectedSlotIndex,
            onTap: slots[i].onTap,
          ),
        ),
      const SizedBox(width: centerGapWidth),
      for (var i = 2; i < 4; i++)
        Expanded(
          child: ZuranoFloatingNavItem(
            icon: slots[i].icon,
            selectedIcon: slots[i].selectedIcon,
            label: slots[i].label,
            isActive: i == selectedSlotIndex,
            onTap: slots[i].onTap,
          ),
        ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, outerBottomSpacing),
        child: SizedBox(
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: barHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: navBg,
                    borderRadius: BorderRadius.circular(navBorderRadius),
                    border: Border.all(
                      color: borderPurple.withValues(alpha: 0.85),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: activePurple.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    clipBehavior: Clip.none,
                    child: Row(children: rowChildren),
                  ),
                ),
              ),
              Positioned(
                top: ringTop,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: SizedBox(
                      width: outerRingSize,
                      height: outerRingSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: navBg.withValues(alpha: 0.88),
                          border: Border.all(
                            color: borderPurple.withValues(alpha: 0.65),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activePurple.withValues(alpha: 0.09),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_hasInteractiveCenter)
                Positioned(
                  top: fabTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _maybeTooltip(
                      message: centerTooltip,
                      child: Hero(
                        tag: centerHeroTag ?? 'zurano_shell_center_fab',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onCenterTap,
                            child: SizedBox(
                              width: fabSize,
                              height: fabSize,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: borderPurple.withValues(alpha: 0.82),
                                    width: 1.25,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: activePurple.withValues(
                                        alpha: 0.17,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Center(child: centerChild),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

class ZuranoFloatingNavItem extends StatelessWidget {
  const ZuranoFloatingNavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _activePurple = Color(0xFF7B2CFF);
  static const Color _softPurple = Color(0xFFE6DBFF);
  static const Color _inactiveDark = Color(0xFF2D2F39);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 12 : 6,
              vertical: isActive ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: isActive ? _softPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: AnimatedScale(
              scale: isActive ? 1.02 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? selectedIcon : icon,
                    size: isActive ? 22 : 21,
                    color: isActive ? _activePurple : _inactiveDark,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isActive ? 12 : 11.5,
                          height: 1.05,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive ? _activePurple : _inactiveDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [FloatingActionButtonLocation.centerDocked] lines the FAB center up with the
/// **top** of [Scaffold.bottomNavigationBar]. [ZuranoFloatingBottomNav] paints
/// the ring and inner chip lower inside [stackHeight]; shift the FAB down so it
/// sits in the circular cutout (same vertical center as the owner shell chip).
class ZuranoEmployeeCenterDockedFabLocation
    extends FloatingActionButtonLocation {
  const ZuranoEmployeeCenterDockedFabLocation();

  static double get _extraDy =>
      ZuranoFloatingBottomNav.fabTop + ZuranoFloatingBottomNav.fabSize / 2;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return FloatingActionButtonLocation.centerDocked.getOffset(
          scaffoldGeometry,
        ) +
        Offset(0, _extraDy);
  }

  @override
  String toString() => 'ZuranoEmployeeCenterDockedFabLocation';
}

/// Use with [EmployeeQuickActionFab] + [ZuranoFloatingBottomNav].
const FloatingActionButtonLocation zuranoEmployeeCenterDockedFabLocation =
    ZuranoEmployeeCenterDockedFabLocation();
