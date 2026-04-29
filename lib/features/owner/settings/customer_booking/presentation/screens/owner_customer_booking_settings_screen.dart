import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../features/customer/data/models/customer_booking_settings_model.dart';
import '../../../../../../features/customer/data/repositories/customer_booking_settings_repository.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/settings_section_card.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_page_scaffold.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_top_bar.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/session_provider.dart';
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

  void _syncFromServer(CustomerBookingSettingsModel server) {
    if (!_seeded) {
      setState(() {
        _draft = server;
        _baseline = server;
        _messageController.text = server.publicBookingMessage;
        _seeded = true;
      });
      return;
    }
    if (_dirty) {
      return;
    }
    setState(() {
      _draft = server;
      _baseline = server;
      _messageController.text = server.publicBookingMessage;
    });
  }

  bool get _dirty {
    final d = _draft;
    final b = _baseline;
    if (d == null || b == null) {
      return false;
    }
    final msg = _messageController.text;
    return !d.samePolicyAs(b) || msg != b.publicBookingMessage;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.ownerCustomerBookingSaveSuccess)),
    );
    setState(() {
      _baseline = merged;
      _draft = merged;
    });
    ref.read(customerBookingSettingsControllerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider);
    final user = session.asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final saveAsync = ref.watch(customerBookingSettingsControllerProvider);

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

    ref.listen(customerBookingSettingsProvider(salonId), (prev, next) {
      next.whenData(_syncFromServer);
    });

    final settingsAsync = ref.watch(customerBookingSettingsProvider(salonId));

    return ZuranoPageScaffold(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
          ZuranoTopBar(
            title: l10n.ownerCustomerBookingTitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              }
            },
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
                final d = _draft;
                if (d == null) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  children: [
                    _HeaderCard(enabled: d.customerBookingEnabled, l10n: l10n),
                    const SizedBox(height: 14),
                    SettingsSectionCard(
                      icon: Icons.toggle_on_rounded,
                      title: l10n.ownerCustomerBookingEnableBooking,
                      subtitle: l10n.ownerCustomerBookingSectionAvailability,
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: d.customerBookingEnabled,
                        onChanged: (v) => setState(() {
                          _draft = _draft!.copyWith(customerBookingEnabled: v);
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
                              () => _draft = _draft!.copyWith(bufferMinutes: v),
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
