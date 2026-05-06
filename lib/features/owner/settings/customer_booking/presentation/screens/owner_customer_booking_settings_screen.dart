import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/booking/availability_schedule.dart';
import '../../../../../../features/customer/data/models/customer_booking_settings_model.dart';
import '../../../../../../features/customer/data/repositories/customer_booking_settings_repository.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/settings_section_card.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_page_scaffold.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_top_bar.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/session_provider.dart';
import '../../../../../../providers/salon_streams_provider.dart'
    show sessionSalonStreamProvider;
import '../../../../../../providers/repository_providers.dart'
    show salonRepositoryProvider;
import '../../../../../../features/salon/data/models/salon.dart';
import '../../application/customer_booking_salon_settings_providers.dart';

class OwnerCustomerBookingSettingsScreen extends ConsumerStatefulWidget {
  const OwnerCustomerBookingSettingsScreen({super.key});

  @override
  ConsumerState<OwnerCustomerBookingSettingsScreen> createState() =>
      _OwnerCustomerBookingSettingsScreenState();
}

class _OwnerCustomerBookingSettingsScreenState
    extends ConsumerState<OwnerCustomerBookingSettingsScreen> {
  static const _minNoticeOptions = [0, 30, 60, 120, 1440];
  static const _maxDaysOptions = [7, 14, 30, 60, 90];
  static const _slotOptions = [15, 30, 45, 60];
  static const _bufferOptions = [0, 5, 10, 15, 30];
  static const _cancelHoursOptions = [1, 2, 4, 12, 24];

  CustomerBookingSettingsModel? _draft;
  CustomerBookingSettingsModel? _baseline;
  bool _seeded = false;
  late final TextEditingController _messageController;
  WeeklyAvailability? _weeklyDraft;
  WeeklyAvailability? _weeklyBaseline;
  bool _weeklySeeded = false;

  /// `men` | `ladies` | `unisex` — matches [Salon.audience] / customer discovery filters.
  String? _audienceDraft;
  String? _audienceBaseline;
  bool _audienceSeeded = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _syncFromServerInBuild(CustomerBookingSettingsModel server) {
    if (!_seeded) {
      _draft = server;
      _baseline = server;
      _messageController.text = server.publicBookingMessage;
      _seeded = true;
      return;
    }
    if (_dirty) {
      return;
    }
    _draft = server;
    _baseline = server;
    if (_messageController.text != server.publicBookingMessage) {
      _messageController.text = server.publicBookingMessage;
    }
  }

  bool get _dirty {
    final d = _draft;
    final b = _baseline;
    if (d == null || b == null) {
      return false;
    }
    final msg = _messageController.text;
    return !d.samePolicyAs(b) ||
        msg != b.publicBookingMessage ||
        !_sameWeekly(_weeklyDraft, _weeklyBaseline) ||
        _audienceDirty;
  }

  bool get _audienceDirty {
    final a = _audienceDraft;
    final b = _audienceBaseline;
    if (a == null || b == null) {
      return false;
    }
    return a != b;
  }

  static String _normalizeAudience(String? raw) {
    final s = raw?.trim().toLowerCase() ?? '';
    if (s == 'men' || s == 'ladies' || s == 'unisex') {
      return s;
    }
    return 'unisex';
  }

  void _syncAudienceFromSalon(Salon? salon) {
    if (salon == null) {
      return;
    }
    final normalized = _normalizeAudience(salon.audience);
    if (!_audienceSeeded) {
      _audienceDraft = normalized;
      _audienceBaseline = normalized;
      _audienceSeeded = true;
      return;
    }
    if (_audienceDirty) {
      return;
    }
    if (normalized != _audienceDraft) {
      _audienceDraft = normalized;
      _audienceBaseline = normalized;
    }
  }

  bool _sameWeekly(WeeklyAvailability? a, WeeklyAvailability? b) {
    final am = a?.byWeekday ?? const <int, DaySchedule>{};
    final bm = b?.byWeekday ?? const <int, DaySchedule>{};
    if (am.length != bm.length) return false;
    for (final w in <int>[1, 2, 3, 4, 5, 6, 7]) {
      final ad = am[w];
      final bd = bm[w];
      if (ad == null && bd == null) continue;
      if (ad == null || bd == null) return false;
      if (ad.isDayOff != bd.isDayOff) return false;
      if (ad.openMinute != bd.openMinute) return false;
      if (ad.closeMinute != bd.closeMinute) return false;
      // breaks not editable in this UI yet; treat both as same if both empty.
      if (ad.breaks.isNotEmpty || bd.breaks.isNotEmpty) {
        if (ad.breaks.length != bd.breaks.length) return false;
        for (var i = 0; i < ad.breaks.length; i++) {
          if (ad.breaks[i].$1 != bd.breaks[i].$1 ||
              ad.breaks[i].$2 != bd.breaks[i].$2) {
            return false;
          }
        }
      }
    }
    return true;
  }

  WeeklyAvailability _defaultWeekly() {
    return WeeklyAvailability({
      for (final w in <int>[1, 2, 3, 4, 5, 6, 7]) w: DaySchedule.defaultWindow(),
    });
  }

  void _syncWeeklyFromSalonInBuild(Salon salon) {
    if (_weeklySeeded) {
      if (_dirty) return;
      _weeklyDraft = salon.weeklyAvailability ?? _defaultWeekly();
      _weeklyBaseline = _weeklyDraft;
      return;
    }
    _weeklyDraft = salon.weeklyAvailability ?? _defaultWeekly();
    _weeklyBaseline = _weeklyDraft;
    _weeklySeeded = true;
  }

  String _weekdayLabel(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // 2020-01-06 is a Monday.
    final base = DateTime(2020, 1, 6).add(Duration(days: weekday - 1));
    return DateFormat.EEEE(locale).format(base);
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _fromMinutes(int minutes) =>
      TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);

  Future<void> _pickTime({
    required int weekday,
    required bool pickOpen,
  }) async {
    final current = _weeklyDraft ?? _defaultWeekly();
    final existing = current.byWeekday[weekday] ?? DaySchedule.defaultWindow();
    final initial = pickOpen
        ? _fromMinutes(existing.openMinute)
        : _fromMinutes(existing.closeMinute);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final nextDay = DaySchedule(
      isDayOff: existing.isDayOff,
      openMinute: pickOpen ? _toMinutes(picked) : existing.openMinute,
      closeMinute: pickOpen ? existing.closeMinute : _toMinutes(picked),
      breaks: existing.breaks,
    );
    setState(() {
      _weeklyDraft = WeeklyAvailability({...current.byWeekday, weekday: nextDay});
    });
  }

  String _timeLabel(BuildContext context, int minutes) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      _fromMinutes(minutes),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  String? _weeklyValidationErrorKey(WeeklyAvailability weekly) {
    for (final w in <int>[1, 2, 3, 4, 5, 6, 7]) {
      final d = weekly.byWeekday[w] ?? DaySchedule.defaultWindow();
      if (d.isDayOff) continue;
      if (d.closeMinute <= d.openMinute) {
        return 'timeOrder';
      }
    }
    return null;
  }

  CustomerBookingSettingsModel _draftWithMessage() {
    final d = _draft!;
    return d.copyWith(publicBookingMessage: _messageController.text);
  }

  String _validationMessage(AppLocalizations l10n, String? key) {
    return switch (key) {
      'minNotice' => l10n.ownerCustomerBookingValidationMinNotice,
      'maxDays' => l10n.ownerCustomerBookingValidationMaxDays,
      'slotDuration' => l10n.ownerCustomerBookingValidationSlot,
      'buffer' => l10n.ownerCustomerBookingValidationBuffer,
      'cancelHours' => l10n.ownerCustomerBookingValidationCancelHours,
      'messageLength' => l10n.ownerCustomerBookingValidationMessage,
      _ => l10n.ownerCustomerBookingSaveError,
    };
  }

  Future<void> _save(String salonId, String uid) async {
    final l10n = AppLocalizations.of(context)!;
    final merged = _draftWithMessage();
    final err = merged.validationErrorKey();
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_validationMessage(l10n, err))));
      return;
    }
    final weekly = _weeklyDraft;
    if (weekly != null) {
      final weeklyErr = _weeklyValidationErrorKey(weekly);
      if (weeklyErr == 'timeOrder') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ownerCustomerBookingValidationTimeOrder)),
        );
        return;
      }
    }
    await ref
        .read(customerBookingSettingsControllerProvider.notifier)
        .save(salonId: salonId, settings: merged, updatedByUid: uid);
    if (!mounted) {
      return;
    }
    final saveState = ref.read(customerBookingSettingsControllerProvider);
    if (saveState.hasError) {
      final err = saveState.error;
      final msg = err is CustomerBookingSettingsValidationException
          ? _validationMessage(l10n, err.code)
          : l10n.ownerCustomerBookingSaveError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      ref.read(customerBookingSettingsControllerProvider.notifier).reset();
      return;
    }

    final salon = ref.read(sessionSalonStreamProvider).asData?.value;
    final needsWeeklySave =
        salon != null && weekly != null && !_sameWeekly(weekly, _weeklyBaseline);
    if (needsWeeklySave) {
      try {
        await ref
            .read(salonRepositoryProvider)
            .updateSalon(salon.copyWith(weeklyAvailability: weekly));
      } catch (_) {
        // Keep booking settings saved; surface a warning.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ownerCustomerBookingSaveError)),
        );
        return;
      }
    }

    final audienceSel = _audienceDraft;
    if (salon != null &&
        audienceSel != null &&
        _audienceBaseline != null &&
        audienceSel != _audienceBaseline) {
      try {
        await ref
            .read(salonRepositoryProvider)
            .updateSalon(salon.copyWith(audience: audienceSel));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ownerCustomerBookingSaveError)),
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.ownerCustomerBookingSaveSuccess)),
    );
    setState(() {
      _baseline = merged;
      _draft = merged;
      _weeklyBaseline = weekly ?? _weeklyBaseline;
      if (_audienceDraft != null) {
        _audienceBaseline = _audienceDraft;
      }
    });
    ref.read(customerBookingSettingsControllerProvider.notifier).reset();
  }

  Future<void> _saveSalonVisibility({
    required String salonId,
    required Salon salon,
    required bool publish,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(salonRepositoryProvider)
          .updateSalon(salon.copyWith(isPublished: publish));
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            publish
                ? AppLocalizations.of(context)!.ownerCustomerBookingShowSalon
                : AppLocalizations.of(context)!.ownerCustomerBookingShowSalonHint,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider);
    final user = session.asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final saveAsync = ref.watch(customerBookingSettingsControllerProvider);
    final salonAsync = ref.watch(sessionSalonStreamProvider);

    if (salonId.isEmpty) {
      return ZuranoPageScaffold(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Text(
                l10n.ownerLoadError,
                textAlign: TextAlign.center,
                style: TextStyle(color: ZuranoPremiumUiColors.textSecondary),
              ),
            ),
          ),
        ),
      );
    }

    final settingsAsync = ref.watch(customerBookingSettingsProvider(salonId));

    return ZuranoPageScaffold(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: ZuranoTopBar(
                title: l10n.ownerCustomerBookingTitle,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
            Expanded(
              child: settingsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Text(
                      l10n.ownerCustomerBookingLoadError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ZuranoPremiumUiColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (server) {
                  _syncFromServerInBuild(server);
                  final d = _draft ?? server;
                  final salon = salonAsync.asData?.value;
                  if (salon != null) {
                    _syncWeeklyFromSalonInBuild(salon);
                    _syncAudienceFromSalon(salon);
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    children: [
                      _HeaderCard(
                        enabled: d.customerBookingEnabled,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 14),
                      if (salon != null) ...[
                        SettingsSectionCard(
                          icon: Icons.public_rounded,
                          title: l10n.ownerCustomerBookingSectionPublic,
                          subtitle: l10n.ownerCustomerBookingSectionPublicHint,
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.ownerCustomerBookingShowSalon,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ZuranoPremiumUiColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              l10n.ownerCustomerBookingShowSalonHint,
                              style: const TextStyle(
                                color: ZuranoPremiumUiColors.textSecondary,
                              ),
                            ),
                            value: salon.isPublished,
                            onChanged: (v) => _saveSalonVisibility(
                              salonId: salonId,
                              salon: salon,
                              publish: v,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SettingsSectionCard(
                          icon: Icons.groups_outlined,
                          title: l10n.ownerCustomerBookingGenderTarget,
                          subtitle:
                              l10n.ownerCustomerBookingGenderTargetSectionHint,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: 'men',
                                label: Text(l10n.ownerCustomerBookingGenderMen),
                              ),
                              ButtonSegment<String>(
                                value: 'ladies',
                                label:
                                    Text(l10n.ownerCustomerBookingGenderLadies),
                              ),
                              ButtonSegment<String>(
                                value: 'unisex',
                                label:
                                    Text(l10n.ownerCustomerBookingGenderUnisex),
                              ),
                            ],
                            emptySelectionAllowed: false,
                            showSelectedIcon: false,
                            selected: <String>{
                              _audienceDraft ?? 'unisex',
                            },
                            onSelectionChanged: (next) {
                              if (next.isEmpty) {
                                return;
                              }
                              setState(() {
                                _audienceDraft = next.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        SettingsSectionCard(
                          icon: Icons.schedule_rounded,
                          title: l10n.ownerCustomerBookingWorkingHours,
                          subtitle: l10n.ownerCustomerBookingSectionAvailability,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => setState(() {
                                        final current =
                                            _weeklyDraft ?? _defaultWeekly();
                                        _weeklyDraft = WeeklyAvailability({
                                          for (final w
                                              in <int>[1, 2, 3, 4, 5, 6, 7])
                                            w: DaySchedule(
                                              isDayOff: false,
                                              openMinute:
                                                  current.byWeekday[w]?.openMinute ??
                                                      DaySchedule.defaultWindow()
                                                          .openMinute,
                                              closeMinute:
                                                  current.byWeekday[w]?.closeMinute ??
                                                      DaySchedule.defaultWindow()
                                                          .closeMinute,
                                              breaks: const [],
                                            ),
                                        });
                                      }),
                                      child: Text(l10n.ownerCustomerBookingOpenAll),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => setState(() {
                                        final current =
                                            _weeklyDraft ?? _defaultWeekly();
                                        _weeklyDraft = WeeklyAvailability({
                                          for (final w
                                              in <int>[1, 2, 3, 4, 5, 6, 7])
                                            w: DaySchedule(
                                              isDayOff: true,
                                              openMinute:
                                                  current.byWeekday[w]?.openMinute ??
                                                      0,
                                              closeMinute:
                                                  current.byWeekday[w]?.closeMinute ??
                                                      0,
                                              breaks: const [],
                                            ),
                                        });
                                      }),
                                      child: Text(l10n.ownerCustomerBookingCloseAll),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              for (final weekday in <int>[1, 2, 3, 4, 5, 6, 7])
                                _WorkingDayRow(
                                  label: _weekdayLabel(context, weekday),
                                  isClosed: (_weeklyDraft?.byWeekday[weekday]
                                              ?.isDayOff ??
                                          false),
                                  openLabel: l10n.ownerCustomerBookingFrom,
                                  closeLabel: l10n.ownerCustomerBookingTo,
                                  openTime: _timeLabel(
                                    context,
                                    _weeklyDraft?.byWeekday[weekday]?.openMinute ??
                                        DaySchedule.defaultWindow().openMinute,
                                  ),
                                  closeTime: _timeLabel(
                                    context,
                                    _weeklyDraft?.byWeekday[weekday]?.closeMinute ??
                                        DaySchedule.defaultWindow().closeMinute,
                                  ),
                                  onToggleClosed: (closed) => setState(() {
                                    final current =
                                        _weeklyDraft ?? _defaultWeekly();
                                    final existing =
                                        current.byWeekday[weekday] ??
                                            DaySchedule.defaultWindow();
                                    _weeklyDraft = WeeklyAvailability({
                                      ...current.byWeekday,
                                      weekday: DaySchedule(
                                        isDayOff: closed,
                                        openMinute: existing.openMinute,
                                        closeMinute: existing.closeMinute,
                                        breaks: existing.breaks,
                                      ),
                                    });
                                  }),
                                  onPickOpen: () => _pickTime(
                                    weekday: weekday,
                                    pickOpen: true,
                                  ),
                                  onPickClose: () => _pickTime(
                                    weekday: weekday,
                                    pickOpen: false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      SettingsSectionCard(
                        icon: Icons.toggle_on_rounded,
                        title: l10n.ownerCustomerBookingEnableBooking,
                        subtitle: l10n.ownerCustomerBookingSectionAvailability,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: d.customerBookingEnabled,
                          onChanged: (v) => setState(() {
                            _draft = _draft!.copyWith(
                              customerBookingEnabled: v,
                            );
                          }),
                        ),
                      ),
                      SettingsSectionCard(
                        icon: Icons.rule_folder_outlined,
                        title: l10n.ownerCustomerBookingSectionRules,
                        subtitle: l10n.ownerCustomerBookingSettingsSubtitle,
                        child: Column(
                          children: [
                            _switch(
                              l10n.ownerCustomerBookingAutoConfirm,
                              d.autoConfirmBookings,
                              (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  autoConfirmBookings: v,
                                ),
                              ),
                            ),
                            _switch(
                              l10n.ownerCustomerBookingSameDay,
                              d.allowSameDayBooking,
                              (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  allowSameDayBooking: v,
                                ),
                              ),
                            ),
                            _switch(
                              l10n.ownerCustomerBookingRequirePhone,
                              d.requireCustomerPhone,
                              (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  requireCustomerPhone: v,
                                ),
                              ),
                            ),
                            _switch(
                              l10n.ownerCustomerBookingRequireName,
                              d.requireCustomerName,
                              (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  requireCustomerName: v,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SettingsSectionCard(
                        icon: Icons.schedule_rounded,
                        title: l10n.ownerCustomerBookingTimeRulesTitle,
                        subtitle: l10n.ownerCustomerBookingSectionRules,
                        child: Column(
                          children: [
                            _dropdownInt(
                              label: l10n.ownerCustomerBookingMinNotice,
                              value: d.minimumNoticeMinutes,
                              options: _minNoticeOptions,
                              display: (n) => n == 1440
                                  ? l10n.ownerCustomerBookingMinutesDay
                                  : l10n.ownerCustomerBookingMinutesShort(n),
                              onChanged: (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  minimumNoticeMinutes: v,
                                ),
                              ),
                            ),
                            _dropdownInt(
                              label: l10n.ownerCustomerBookingMaxDaysAhead,
                              value: d.maxBookingDaysAhead,
                              options: _maxDaysOptions,
                              display: (n) => '$n',
                              onChanged: (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  maxBookingDaysAhead: v,
                                ),
                              ),
                            ),
                            _dropdownInt(
                              label: l10n.ownerCustomerBookingSlotDuration,
                              value: d.slotDurationMinutes,
                              options: _slotOptions,
                              display: (n) =>
                                  l10n.ownerCustomerBookingMinutesShort(n),
                              onChanged: (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  slotDurationMinutes: v,
                                ),
                              ),
                            ),
                            _dropdownInt(
                              label: l10n.ownerCustomerBookingBuffer,
                              value: d.bufferMinutes,
                              options: _bufferOptions,
                              display: (n) =>
                                  l10n.ownerCustomerBookingMinutesShort(n),
                              onChanged: (v) => setState(
                                () =>
                                    _draft = _draft!.copyWith(bufferMinutes: v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SettingsSectionCard(
                        icon: Icons.event_busy_outlined,
                        title: l10n.ownerCustomerBookingCancellationTitle,
                        subtitle: l10n.ownerCustomerBookingSectionRules,
                        child: Column(
                          children: [
                            _switch(
                              l10n.ownerCustomerBookingAllowCancel,
                              d.allowCustomerCancellation,
                              (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  allowCustomerCancellation: v,
                                ),
                              ),
                            ),
                            _dropdownInt(
                              label: l10n.ownerCustomerBookingCancelNotice,
                              value: d.cancellationNoticeHours,
                              options: _cancelHoursOptions,
                              display: (n) =>
                                  l10n.ownerCustomerBookingHoursShort(n),
                              onChanged: (v) => setState(
                                () => _draft = _draft!.copyWith(
                                  cancellationNoticeHours: v,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SettingsSectionCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: l10n.ownerCustomerBookingPublicMessageTitle,
                        subtitle: l10n.ownerCustomerBookingPublicMessageHint,
                        child: TextField(
                          controller: _messageController,
                          onChanged: (_) => setState(() {}),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          maxLines: 3,
                          maxLength: 250,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ZuranoPremiumUiColors.lightSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: ZuranoPremiumUiColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: ZuranoPremiumUiColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                      !_dirty ||
                          saveAsync.isLoading ||
                          user == null ||
                          user.uid.isEmpty
                      ? null
                      : () => _save(salonId, user.uid),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: saveAsync.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.ownerCustomerBookingSaveCta),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: ZuranoPremiumUiColors.textPrimary,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dropdownInt({
    required String label,
    required int value,
    required List<int> options,
    required String Function(int) display,
    required ValueChanged<int> onChanged,
  }) {
    final safe = options.contains(value) ? value : options.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: ZuranoPremiumUiColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ZuranoPremiumUiColors.border),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: safe,
            items: [
              for (final o in options)
                DropdownMenuItem(value: o, child: Text(display(o))),
            ],
            onChanged: (v) {
              if (v != null) {
                onChanged(v);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _WorkingDayRow extends StatelessWidget {
  const _WorkingDayRow({
    required this.label,
    required this.isClosed,
    required this.openLabel,
    required this.closeLabel,
    required this.openTime,
    required this.closeTime,
    required this.onToggleClosed,
    required this.onPickOpen,
    required this.onPickClose,
  });

  final String label;
  final bool isClosed;
  final String openLabel;
  final String closeLabel;
  final String openTime;
  final String closeTime;
  final ValueChanged<bool> onToggleClosed;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: !isClosed,
                onChanged: (v) => onToggleClosed(!v),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _TimeChip(
                  enabled: !isClosed,
                  label: openLabel,
                  value: openTime,
                  onTap: onPickOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeChip(
                  enabled: !isClosed,
                  label: closeLabel,
                  value: closeTime,
                  onTap: onPickClose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.enabled,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? ZuranoPremiumUiColors.lightSurface
              : ZuranoPremiumUiColors.lightSurface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZuranoPremiumUiColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: enabled
                    ? ZuranoPremiumUiColors.textPrimary
                    : ZuranoPremiumUiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.enabled, required this.l10n});

  final bool enabled;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZuranoPremiumUiColors.softPurple,
            ZuranoPremiumUiColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ZuranoPremiumUiColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ownerCustomerBookingTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ownerCustomerBookingSettingsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ZuranoPremiumUiColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFDCFCE7)
                  : ZuranoPremiumUiColors.lightSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: enabled
                    ? const Color(0xFF16A34A)
                    : ZuranoPremiumUiColors.border,
              ),
            ),
            child: Text(
              enabled
                  ? l10n.ownerCustomerBookingStatusEnabled
                  : l10n.ownerCustomerBookingStatusDisabled,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: enabled
                    ? const Color(0xFF166534)
                    : ZuranoPremiumUiColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
