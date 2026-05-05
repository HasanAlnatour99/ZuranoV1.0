import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';
import 'employee_quick_actions_sheet.dart';

/// Center-docked quick actions — matches owner shell Zurano FAB (logo + mirror ring).
class EmployeeQuickActionFab extends StatelessWidget {
  const EmployeeQuickActionFab({super.key});

  static const double _fabSize = ZuranoFloatingBottomNav.fabSize;
  static const double _iconSize = 42;
  static const Offset _iconNudge = Offset(0, -2);
  static const String _fabIconAsset = 'assets/images/zurano_icon_nav.png';

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmployeeQuickActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: _fabSize,
      height: _fabSize,
      child: Tooltip(
        message: l10n.employeeQuickActionsTitle,
        child: Hero(
          tag: 'employee_shell_center_fab',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _openSheet(context),
              child: SizedBox(
                width: _fabSize,
                height: _fabSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFDFCFF),
                        ZuranoFloatingBottomNav.borderPurple.withValues(
                          alpha: 0.55,
                        ),
                        const Color(0xFFF7F8FC).withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                    border: Border.all(
                      color: ZuranoFloatingBottomNav.borderPurple.withValues(
                        alpha: 0.82,
                      ),
                      width: 1.25,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ZuranoFloatingBottomNav.activePurple.withValues(
                          alpha: 0.17,
                        ),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.65),
                        blurRadius: 6,
                        spreadRadius: -2,
                        offset: const Offset(-2, -3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Center(
                      child: Transform.translate(
                        offset: _iconNudge,
                        child: Image.asset(
                          _fabIconAsset,
                          width: _iconSize,
                          height: _iconSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
