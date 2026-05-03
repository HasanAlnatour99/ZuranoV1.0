import 'package:flutter/material.dart';

import '../../domain/team_member_card_vm.dart';

/// Approved colors for team member cards (deck + premium). Layout may be LTR/RTL;
/// this palette does not change by locale.
abstract final class TeamCardPalette {
  static const Color cardBackground = Color(0xFFFCFBFF);

  // Performance chip (always Zurano purple family)
  static const Color performanceBg = Color(0xFFF3EDFF);
  static const Color performanceBorder = Color(0xFFD8C7FF);
  static const Color performanceFg = Color(0xFF6D35FF);
  static const Color goldStar = Color(0xFFFFB020);

  // Status — enabled
  static const Color statusOnBg = Color(0xFFEAF8EF);
  static const Color statusOnBorder = Color(0xFFA9E8BC);
  static const Color statusOnFg = Color(0xFF12923B);

  // Status — inactive
  static const Color statusOffBg = Color(0xFFFFE8EC);
  static const Color statusOffBorder = Color(0xFFFFA9B5);
  static const Color statusOffFg = Color(0xFFD92D3E);

  // Attendance — working
  static const Color attendWorkingBg = Color(0xFFFFF2E0);
  static const Color attendWorkingBorder = Color(0xFFFFD08A);
  static const Color attendWorkingFg = Color(0xFFE07A00);

  // Attendance — completed (same greens as status on)
  static const Color attendDoneBg = Color(0xFFEAF8EF);
  static const Color attendDoneBorder = Color(0xFFA9E8BC);
  static const Color attendDoneFg = Color(0xFF12923B);

  // Attendance — absent (same reds as status off)
  static const Color attendAbsentBg = Color(0xFFFFE8EC);
  static const Color attendAbsentBorder = Color(0xFFFFA9B5);
  static const Color attendAbsentFg = Color(0xFFD92D3E);

  // Attendance — today off
  static const Color attendOffBg = Color(0xFFFFF4DF);
  static const Color attendOffBorder = Color(0xFFFFCF80);
  static const Color attendOffFg = Color(0xFFE07A00);

  // Attendance — no check-in (lilac)
  static const Color attendPendingBg = Color(0xFFF1ECFF);
  static const Color attendPendingBorder = Color(0xFFD8C7FF);
  static const Color attendPendingFg = Color(0xFF6D35FF);

  /// Good performance (>= 3), or **no monthly doc yet**: light green wave.
  /// With a doc and rating **below 3**: light red wave.
  static const Color waveGoodGreen = Color(0xFFCFF7DA);
  static const Color waveBelowThreeRed = Color(0xFFFFD6DC);

  static Color waveColorFor(bool hasPerformanceData, double rating) {
    if (!hasPerformanceData) {
      return waveGoodGreen;
    }
    final safe = rating.clamp(0.0, 5.0);
    if (safe >= 3.0) {
      return waveGoodGreen;
    }
    return waveBelowThreeRed;
  }

  static ({Color bg, Color border, Color fg}) statusMiniPill(bool isActive) {
    if (isActive) {
      return (bg: statusOnBg, border: statusOnBorder, fg: statusOnFg);
    }
    return (bg: statusOffBg, border: statusOffBorder, fg: statusOffFg);
  }

  static ({Color bg, Color border, Color fg}) attendanceMiniPill(
    TeamAttendanceState state,
  ) {
    return switch (state) {
      TeamAttendanceState.working => (
          bg: attendWorkingBg,
          border: attendWorkingBorder,
          fg: attendWorkingFg,
        ),
      TeamAttendanceState.completed => (
          bg: attendDoneBg,
          border: attendDoneBorder,
          fg: attendDoneFg,
        ),
      TeamAttendanceState.absent => (
          bg: attendAbsentBg,
          border: attendAbsentBorder,
          fg: attendAbsentFg,
        ),
      TeamAttendanceState.dayOff => (
          bg: attendOffBg,
          border: attendOffBorder,
          fg: attendOffFg,
        ),
      TeamAttendanceState.notCheckedIn => (
          bg: attendPendingBg,
          border: attendPendingBorder,
          fg: attendPendingFg,
        ),
    };
  }

  static ({Color bg, Color border, Color fg}) performanceMiniPill() {
    return (
      bg: performanceBg,
      border: performanceBorder,
      fg: performanceFg,
    );
  }
}
