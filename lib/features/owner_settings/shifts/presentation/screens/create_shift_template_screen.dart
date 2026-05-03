import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/session_provider.dart';
import '../../domain/services/shift_time_calculator.dart';
import '../../data/models/shift_template_model.dart';
import '../providers/shift_providers.dart';
import '../widgets/shift_ui/shift_design_tokens.dart';
import '../widgets/shift_ui/shift_glass_card.dart';
import '../widgets/shift_ui/shift_gradient_button.dart';
import '../widgets/shift_ui/shift_hero_header.dart';
import '../widgets/shift_ui/shift_icon_tile.dart';
import '../widgets/shift_ui/shift_page_shell.dart';

class CreateShiftTemplateScreen extends ConsumerStatefulWidget {
  const CreateShiftTemplateScreen({super.key, this.shiftId});

  final String? shiftId;

  @override
  ConsumerState<CreateShiftTemplateScreen> createState() =>
      _CreateShiftTemplateScreenState();
}

class _CreateShiftTemplateScreenState
    extends ConsumerState<CreateShiftTemplateScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _breakController = TextEditingController(text: '0');
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _colorHex = '#6D3CEB';
  bool _isDefault = false;
  bool _seeded = false;

  bool get _isEdit =>
      widget.shiftId != null && widget.shiftId!.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final salonId = ref.watch(activeOwnerSalonIdProvider);
    final user = ref.watch(sessionUserProvider).asData?.value;
    final saving = ref.watch(saveShiftTemplateControllerProvider).isLoading;
    final templates = ref.watch(shiftTemplatesStreamProvider).asData?.value ?? const <ShiftTemplateModel>[];
    final editAsync = _isEdit
        ? ref.watch(shiftTemplateProvider(widget.shiftId!))
        : const AsyncData<ShiftTemplateModel?>(null);

    if (_isEdit) {
      editAsync.whenData((model) {
        if (!_seeded && model != null) {
          _seedForm(model);
        }
      });
    }

    return ShiftPageShell(
      scrollPadding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
      bottomBar: Row(
        children: [
          Expanded(
            child: _OutlineActionButton(
              label: l10n.ownerShiftCancelCta,
              onPressed: saving
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRouteNames.ownerShiftsSettings);
                      }
                    },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: saving
                ? const SizedBox(
                    height: 64,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ShiftGradientButton(
                    label: l10n.ownerShiftSaveCta,
                    onPressed: _validate(l10n, templates) != null || salonId == null
                        ? null
                        : () => _save(l10n, user?.uid ?? ''),
                  ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShiftHeroHeader(
            title: _isEdit
                ? l10n.ownerShiftEditTitle
                : l10n.ownerShiftCreateTitle,
            subtitle: _isEdit
                ? l10n.ownerShiftEditSubtitle
                : l10n.ownerShiftCreateSubtitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRouteNames.ownerShiftsSettings);
              }
            },
          ),
          const SizedBox(height: 24),
          editAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(l10n.ownerShiftsLoadError),
            data: (_) {
              final validationError = _validate(l10n, templates);
              final preview = _buildPreview();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShiftGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shiftFieldCaption(l10n.ownerShiftNameLabel),
                        _StyledInputShell(
                          leading: const Icon(
                            Icons.badge_outlined,
                            color: ShiftDesignTokens.primary,
                          ),
                          trailing: _nameController.text.trim().isEmpty
                              ? null
                              : GestureDetector(
                                  onTap: () {
                                    _nameController.clear();
                                    setState(() {});
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: ShiftDesignTokens.textMuted,
                                    size: 22,
                                  ),
                                ),
                          child: TextField(
                            controller: _nameController,
                            maxLength: 30,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ShiftDesignTokens.textDark,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: l10n.ownerShiftNameHint,
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: const TextStyle(
                                color: ShiftDesignTokens.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _TimeSelectorBox(
                                label: l10n.ownerShiftStartTimeLabel,
                                value: _startTime,
                                onTap: () => _pickTime(
                                  context,
                                  initial:
                                      _startTime ??
                                      const TimeOfDay(hour: 9, minute: 0),
                                  onSelected: (v) =>
                                      setState(() => _startTime = v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _TimeSelectorBox(
                                label: l10n.ownerShiftEndTimeLabel,
                                value: _endTime,
                                onTap: () => _pickTime(
                                  context,
                                  initial:
                                      _endTime ??
                                      const TimeOfDay(hour: 17, minute: 0),
                                  onSelected: (v) =>
                                      setState(() => _endTime = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (preview.isOvernight) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const ShiftIconTile.small(
                                icon: Icons.nights_stay_outlined,
                                size: 52,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.ownerShiftsOvernightBadge,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: ShiftDesignTokens.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        _shiftFieldCaption(l10n.ownerShiftBreakMinutesLabel),
                        _StyledInputShell(
                          leading: const Icon(
                            Icons.coffee_outlined,
                            color: ShiftDesignTokens.primary,
                          ),
                          child: TextField(
                            controller: _breakController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ShiftDesignTokens.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.ownerShiftBreakMinutesHint,
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: const TextStyle(
                                color: ShiftDesignTokens.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _shiftFieldCaption(l10n.ownerShiftNotesLabel),
                        _StyledInputShell(
                          height: null,
                          leading: const Icon(
                            Icons.notes_outlined,
                            color: ShiftDesignTokens.primary,
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 2,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: ShiftDesignTokens.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.ownerShiftNotesHint,
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: const TextStyle(
                                color: ShiftDesignTokens.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _shiftFieldCaption(l10n.ownerShiftColorLabel),
                        _ColorPickerRow(
                          selectedColorHex: _colorHex,
                          onChanged: (hex) => setState(() => _colorHex = hex),
                        ),
                        const SizedBox(height: 18),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _isDefault,
                          onChanged: (value) => setState(() => _isDefault = value),
                          title: Text(
                            l10n.ownerShiftDefaultLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ShiftDesignTokens.textDark,
                            ),
                          ),
                          subtitle: Text(
                            l10n.ownerShiftDefaultHint,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ShiftDesignTokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShiftGlassCard(
                    padding: const EdgeInsets.all(18),
                    child: _PreviewCardContent(
                      title: _nameController.text.trim().isEmpty
                          ? l10n.ownerShiftPreviewTitleFallback
                          : _nameController.text.trim(),
                      startTime: preview.startTime,
                      endTime: preview.endTime,
                      durationMinutes: preview.durationMinutes,
                      isOvernight: preview.isOvernight,
                      colorHex: _colorHex,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ShiftGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const ShiftIconTile.small(
                          icon: Icons.groups_2_outlined,
                          size: 48,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.ownerApplyScheduleInfoCard,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: ShiftDesignTokens.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      validationError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (salonId == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.ownerShiftsLoadError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _shiftFieldCaption(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ShiftDesignTokens.textMuted,
        ),
      ),
    );
  }

  void _seedForm(ShiftTemplateModel model) {
    _seeded = true;
    _nameController.text = model.name;
    final legacyOffType = model.type == 'off';
    _breakController.text = '${legacyOffType ? 0 : model.breakMinutes}';
    _colorHex = model.colorHex;
    _isDefault = model.isDefault;
    _startTime = model.startTime != null
        ? _hhmmToTimeOfDay(model.startTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = model.endTime != null
        ? _hhmmToTimeOfDay(model.endTime!)
        : const TimeOfDay(hour: 17, minute: 0);
  }

  String? _validate(AppLocalizations l10n, List<ShiftTemplateModel> templates) {
    final name = _nameController.text.trim();
    final breakMinutes = int.tryParse(_breakController.text.trim()) ?? 0;
    if (name.isEmpty) {
      return l10n.ownerShiftValidationNameRequired;
    }
    if (name.length > 30) {
      return l10n.ownerShiftValidationNameLength;
    }
    if (_startTime == null || _endTime == null) {
      return l10n.ownerShiftValidationTimeRequired;
    }
    final startHhMm = ShiftTimeCalculator.timeOfDayToHHmm(_startTime!);
    final endHhMm = ShiftTimeCalculator.timeOfDayToHHmm(_endTime!);
    final duration = ShiftTimeCalculator.calculateDurationMinutes(
      startHhMm,
      endHhMm,
    );
    if (duration <= 0) {
      return l10n.ownerShiftValidationDurationPositive;
    }
    if (duration > (16 * 60)) {
      return l10n.ownerShiftValidationDurationMax;
    }
    if (breakMinutes < 0) {
      return l10n.ownerShiftValidationBreakMin;
    }
    if (breakMinutes >= duration) {
      return l10n.ownerShiftValidationBreakMax;
    }
    final hasOtherDefault = templates.any((template) {
      if (!template.isDefault) {
        return false;
      }
      if (_isEdit && template.id == widget.shiftId) {
        return false;
      }
      return true;
    });
    if (!_isDefault && !hasOtherDefault) {
      return l10n.ownerShiftValidationDefaultRequired;
    }
    return null;
  }

  ({
    String? startTime,
    String? endTime,
    int durationMinutes,
    int breakMinutes,
    bool isOvernight,
  })
  _buildPreview() {
    final start = _startTime;
    final end = _endTime;
    if (start == null || end == null) {
      return (
        startTime: null,
        endTime: null,
        durationMinutes: 0,
        breakMinutes: 0,
        isOvernight: false,
      );
    }
    final startHhMm = ShiftTimeCalculator.timeOfDayToHHmm(start);
    final endHhMm = ShiftTimeCalculator.timeOfDayToHHmm(end);
    return (
      startTime: startHhMm,
      endTime: endHhMm,
      durationMinutes: ShiftTimeCalculator.calculateDurationMinutes(
        startHhMm,
        endHhMm,
      ),
      breakMinutes: int.tryParse(_breakController.text.trim()) ?? 0,
      isOvernight: ShiftTimeCalculator.isOvernight(startHhMm, endHhMm),
    );
  }

  Future<void> _save(AppLocalizations l10n, String uid) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    if (salonId == null) {
      return;
    }
    final preview = _buildPreview();
    final name = _nameController.text.trim();
    final code = name.toUpperCase().replaceAll(' ', '_');
    final nowModel = ShiftTemplateModel(
      id: widget.shiftId ?? '',
      salonId: salonId,
      name: name,
      code: code,
      type: 'working',
      startTime: preview.startTime,
      endTime: preview.endTime,
      isOvernight: preview.isOvernight,
      durationMinutes: preview.durationMinutes,
      breakMinutes: preview.breakMinutes,
      colorHex: _colorHex,
      iconKey: preview.isOvernight ? 'moon' : 'sun',
      isActive: true,
      isDefault: _isDefault,
      sortOrder: 0,
      createdBy: uid,
    );

    final notifier = ref.read(saveShiftTemplateControllerProvider.notifier);
    if (_isEdit) {
      await notifier.updateShiftTemplate(nowModel);
    } else {
      await notifier.create(nowModel);
    }
    if (!mounted) return;
    final state = ref.read(saveShiftTemplateControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ownerShiftSaveError)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ownerShiftSaveSuccess)));
    context.goNamed(AppRouteNames.ownerShiftsSettings);
  }

  TimeOfDay _hhmmToTimeOfDay(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      onSelected(picked);
    }
  }
}

class _StyledInputShell extends StatelessWidget {
  const _StyledInputShell({
    this.leading,
    this.trailing,
    this.height = 58,
    required this.child,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height ?? 58),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ShiftDesignTokens.smallRadius),
        border: Border.all(color: ShiftDesignTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(child: child),
          if (trailing != null) ...[trailing!],
        ],
      ),
    );
  }
}

class _TimeSelectorBox extends StatelessWidget {
  const _TimeSelectorBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ShiftDesignTokens.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ShiftDesignTokens.smallRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ShiftDesignTokens.smallRadius),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ShiftDesignTokens.smallRadius,
                ),
                border: Border.all(color: ShiftDesignTokens.border),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: ShiftDesignTokens.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value?.format(context) ?? '--:--',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ShiftDesignTokens.textDark,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: ShiftDesignTokens.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  const _ColorPickerRow({
    required this.selectedColorHex,
    required this.onChanged,
  });

  final String selectedColorHex;
  final ValueChanged<String> onChanged;

  static const _colors = <String>[
    '#6D3CEB',
    '#7C3AED',
    '#2563EB',
    '#06B6D4',
    '#16A34A',
    '#F59E0B',
    '#EC4899',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colors.map((hex) {
        final selected = hex == selectedColorHex;
        final color = Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16),
        );
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onChanged(hex),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? ShiftDesignTokens.primary
                      : Colors.transparent,
                  width: selected ? 3 : 0,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PreviewCardContent extends StatelessWidget {
  const _PreviewCardContent({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.isOvernight,
    required this.colorHex,
    required this.l10n,
  });

  final String title;
  final String? startTime;
  final String? endTime;
  final int durationMinutes;
  final bool isOvernight;
  final String colorHex;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16),
    );
    final subtitle = '${startTime ?? '--:--'} - ${endTime ?? '--:--'}';
    final durationText = '${(durationMinutes / 60).toStringAsFixed(1)}h';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShiftDesignTokens.softPurple.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ShiftDesignTokens.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOvernight
                      ? Icons.nights_stay_outlined
                      : Icons.wb_sunny_outlined,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: ShiftDesignTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ShiftDesignTokens.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ShiftDesignTokens.border),
                ),
                child: Text(
                  durationText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ShiftDesignTokens.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        height: 64,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ShiftDesignTokens.border, width: 2),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ShiftDesignTokens.textDark,
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
