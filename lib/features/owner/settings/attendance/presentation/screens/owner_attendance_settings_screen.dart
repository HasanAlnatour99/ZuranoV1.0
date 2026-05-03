import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/session_provider.dart';
import '../../../../../settings/presentation/widgets/zurano/zurano_page_scaffold.dart';
import '../../../../../settings/presentation/widgets/zurano/zurano_top_bar.dart';
import '../../application/attendance_settings_providers.dart';
import '../../domain/models/attendance_settings_model.dart';
import '../widgets/attendance_rules_section.dart';
import '../widgets/attendance_settings_save_bar.dart';
import '../widgets/attendance_violations_section.dart';
import '../widgets/attendance_zone_section.dart';

/// Section anchors used by `?section=` deep links from the settings menu.
enum _AttendanceSection { zone, rules, grace, correction, violations }

_AttendanceSection? _parseSection(String? raw) {
  switch (raw) {
    case 'zone':
      return _AttendanceSection.zone;
    case 'rules':
    case 'punch':
      return _AttendanceSection.rules;
    case 'grace':
      return _AttendanceSection.grace;
    case 'correction':
    case 'corrections':
      return _AttendanceSection.correction;
    case 'violations':
    case 'hr':
      return _AttendanceSection.violations;
    default:
      return null;
  }
}

/// Unified owner attendance settings screen — single source of truth for
/// `salons/{salonId}/settings/attendance`. Replaces the legacy
/// `SalonAttendanceSettingsScreen` (zone-only) and the previous owner
/// attendance rules placeholder.
class OwnerAttendanceSettingsScreen extends ConsumerStatefulWidget {
  const OwnerAttendanceSettingsScreen({super.key});

  @override
  ConsumerState<OwnerAttendanceSettingsScreen> createState() =>
      _OwnerAttendanceSettingsScreenState();
}

class _OwnerAttendanceSettingsScreenState
    extends ConsumerState<OwnerAttendanceSettingsScreen> {
  final _scrollController = ScrollController();
  final _zoneKey = GlobalKey();
  final _rulesKey = GlobalKey();
  final _graceKey = GlobalKey();
  final _correctionKey = GlobalKey();
  final _violationsKey = GlobalKey();

  AttendanceSettingsModel? _draft;
  AttendanceSettingsModel? _baseline;
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDirty {
    final draft = _draft;
    final baseline = _baseline;
    if (draft == null || baseline == null) return false;
    return !_mapsEqual(
      draft.toFirestoreMergeMap(),
      baseline.toFirestoreMergeMap(),
    );
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (entry.value is Map && other is Map) {
        if (!_mapsEqual(
          Map<String, dynamic>.from(entry.value as Map),
          Map<String, dynamic>.from(other),
        )) {
          return false;
        }
      } else if (entry.value != other) {
        return false;
      }
    }
    return true;
  }

  String? _validate(AttendanceSettingsModel s, AppLocalizations l10n) {
    if (s.locationRequired && (s.latitude == null || s.longitude == null)) {
      return l10n.ownerAttendanceSettingsValidationLocationMissing;
    }
    if (s.allowedRadiusMeters < 10 || s.allowedRadiusMeters > 500) {
      return l10n.ownerAttendanceSettingsValidationRadius;
    }
    if (s.maxBreaksPerDay < 0 || s.maxBreaksPerDay > 5) {
      return l10n.ownerAttendanceSettingsValidationMaxBreaks;
    }
    if (s.lateGraceMinutes < 0 || s.lateGraceMinutes > 120) {
      return l10n.ownerAttendanceSettingsValidationGraceLate;
    }
    if (s.earlyExitGraceMinutes < 0 || s.earlyExitGraceMinutes > 120) {
      return l10n.ownerAttendanceSettingsValidationGraceEarly;
    }
    if (s.minimumShiftMinutes <= 0) {
      return l10n.ownerAttendanceSettingsValidationMinShift;
    }
    if (s.maximumShiftMinutes <= s.minimumShiftMinutes) {
      return l10n.ownerAttendanceSettingsValidationMaxShift;
    }
    final percents = [
      s.missingCheckoutDeductionPercent,
      s.absenceDeductionPercent,
      s.lateDeductionPercent,
      s.earlyExitDeductionPercent,
    ];
    if (percents.any((p) => p < 0 || p > 100)) {
      return l10n.ownerAttendanceSettingsValidationDeduction;
    }
    final allowances = [
      s.allowedLateCountPerMonth,
      s.allowedEarlyExitCountPerMonth,
      s.allowedMissingCheckoutCountPerMonth,
      s.maxCorrectionRequestsPerMonth,
    ];
    if (allowances.any((c) => c < 0)) {
      return l10n.ownerAttendanceSettingsValidationAllowance;
    }
    return null;
  }

  Future<void> _onSave(String salonId, String updatedBy) async {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft;
    if (draft == null) return;
    final messenger = ScaffoldMessenger.of(context);

    final error = _validate(draft, l10n);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final ok = await ref
        .read(attendanceSettingsControllerProvider.notifier)
        .save(salonId: salonId, settings: draft, updatedBy: updatedBy);

    if (!mounted) return;
    if (ok) {
      setState(() => _baseline = draft);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ownerAttendanceSettingsSaved)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ownerAttendanceSettingsSaveFailed)),
      );
    }
  }

  void _maybeScrollToSection() {
    if (_initialScrollDone) return;
    final raw = GoRouterState.of(context).uri.queryParameters['section'];
    final section = _parseSection(raw);
    if (section == null) {
      _initialScrollDone = true;
      return;
    }
    final key = switch (section) {
      _AttendanceSection.zone => _zoneKey,
      _AttendanceSection.rules => _rulesKey,
      _AttendanceSection.grace => _graceKey,
      _AttendanceSection.correction => _correctionKey,
      _AttendanceSection.violations => _violationsKey,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
      _initialScrollDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(sessionUserProvider);
    final sessionUser = sessionAsync.asData?.value;
    final salonId = sessionUser?.salonId;
    final updatedBy = sessionUser?.uid ?? 'unknown';

    if (salonId == null || salonId.trim().isEmpty) {
      return Scaffold(
        backgroundColor: ZuranoPremiumUiColors.background,
        body: ZuranoPageScaffold(
          child: SafeArea(
            child: Column(
              children: [
                ZuranoTopBar(
                  title: l10n.ownerAttendanceSettingsTitle,
                  onBack: () => _safeBack(context),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final settingsAsync = ref.watch(attendanceSettingsProvider(salonId));
    final controllerState = ref.watch(attendanceSettingsControllerProvider);

    return settingsAsync.when(
      loading: () => _scaffold(
        l10n,
        const Expanded(child: Center(child: CircularProgressIndicator())),
      ),
      error: (err, _) => _scaffold(
        l10n,
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.ownerAttendanceSettingsSaveFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
      data: (loaded) {
        if (_baseline == null) {
          _baseline = loaded;
          _draft = loaded;
        }
        _maybeScrollToSection();
        final draft = _draft ?? loaded;

        return Scaffold(
          backgroundColor: ZuranoPremiumUiColors.background,
          body: ZuranoPageScaffold(
            child: SafeArea(
              child: Column(
                children: [
                  ZuranoTopBar(
                    title: l10n.ownerAttendanceSettingsTitle,
                    onBack: () => _safeBack(context),
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      children: [
                        _HeaderCard(draft: draft),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _zoneKey,
                          child: AttendanceZoneSection(
                            draft: draft,
                            onChanged: (s) => setState(() => _draft = s),
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _rulesKey,
                          child: AttendanceRulesSection(
                            draft: draft,
                            onChanged: (s) => setState(() => _draft = s),
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _graceKey,
                          child: AttendanceGraceSection(
                            draft: draft,
                            onChanged: (s) => setState(() => _draft = s),
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _correctionKey,
                          child: AttendanceCorrectionSection(
                            draft: draft,
                            onChanged: (s) => setState(() => _draft = s),
                          ),
                        ),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _violationsKey,
                          child: AttendanceViolationsSection(
                            draft: draft,
                            onChanged: (s) => setState(() => _draft = s),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AttendanceSettingsSaveBar(
            dirty: _isDirty,
            saving: controllerState.isSaving,
            onSave: () => _onSave(salonId, updatedBy),
          ),
        );
      },
    );
  }

  Widget _scaffold(AppLocalizations l10n, Widget body) {
    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      body: ZuranoPageScaffold(
        child: SafeArea(
          child: Column(
            children: [
              ZuranoTopBar(
                title: l10n.ownerAttendanceSettingsTitle,
                onBack: () => _safeBack(context),
              ),
              body,
            ],
          ),
        ),
      ),
    );
  }

  void _safeBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/owner/settings');
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.draft});

  final AttendanceSettingsModel draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isActive =
        draft.hasSalonLocationConfigured && draft.attendanceRequired;
    const emerald = Color(0xFF34D399);
    const amber = Color(0xFFF59E0B);
    final badgeColor = isActive ? emerald : amber;
    final badgeLabel = isActive
        ? l10n.ownerAttendanceSettingsStatusActive
        : l10n.ownerAttendanceSettingsStatusLocationMissing;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ZuranoPremiumUiColors.primaryPurple,
            ZuranoPremiumUiColors.deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33543CC4),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      badgeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.ownerAttendanceSettingsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.ownerAttendanceSettingsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
