import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../core/utils/currency_for_country.dart';
import '../../../../../core/theme/zurano_tokens.dart';
import '../../../../../core/widgets/app_modal_sheet.dart';
import '../../../../../core/widgets/zurano/zurano_gradient_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/firebase_providers.dart';
import '../../../../../providers/repository_providers.dart';
import '../../../../employees/data/models/employee.dart';
import '../../../../services/data/models/service.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'package:barber_shop_app/shared/widgets/zurano_service_category_icon.dart';

/// Premium Zurano bottom sheet: select which catalog services are assigned
/// to a team member.
Future<void> showZuranoServiceAssignmentSheet({
  required BuildContext context,
  required List<SalonService> salonServices,
  required String salonId,
  required String employeeId,
  required Employee? employee,
  required String salonFallbackCurrencyCode,
  required Set<String> initialSelectedIds,
}) {
  return showAppModalBottomSheet<void>(
    context: context,
    expand: true,
    builder: (modalContext) {
      return _ZuranoServiceAssignmentBody(
        salonServices: salonServices,
        salonId: salonId,
        employeeId: employeeId,
        employee: employee,
        salonFallbackCurrencyCode: salonFallbackCurrencyCode,
        initialSelectedIds: initialSelectedIds,
      );
    },
  );
}

class _ZuranoServiceAssignmentBody extends ConsumerStatefulWidget {
  const _ZuranoServiceAssignmentBody({
    required this.salonServices,
    required this.salonId,
    required this.employeeId,
    required this.employee,
    required this.salonFallbackCurrencyCode,
    required this.initialSelectedIds,
  });

  final List<SalonService> salonServices;
  final String salonId;
  final String employeeId;
  final Employee? employee;
  final String salonFallbackCurrencyCode;
  final Set<String> initialSelectedIds;

  @override
  ConsumerState<_ZuranoServiceAssignmentBody> createState() =>
      _ZuranoServiceAssignmentBodyState();
}

class _ZuranoServiceAssignmentBodyState
    extends ConsumerState<_ZuranoServiceAssignmentBody> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
  }

  Future<void> _save() async {
    if (widget.employee == null) return;

    final repo = ref.read(employeeRepositoryProvider);
    await repo.syncEmployeeAssignedServices(
      salonId: widget.salonId,
      employeeId: widget.employeeId,
      assignedServiceIds: _selectedIds.toList(growable: false),
      assignedByUid: ref.read(firebaseAuthProvider).currentUser?.uid,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    /// Modest gap above home indicator / any shell chrome peek-through.
    final footerPad = 16.0 + bottomInset + 16.0;

    final currency = resolvedSalonMoneyCurrency(
      salonCurrencyCode: widget.salonFallbackCurrencyCode,
      salonCountryIso: null,
    );

    return ColoredBox(
      color: ZuranoTokens.background,
      child: SafeArea(
        top: true,
        left: false,
        right: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _ZuranoServiceAssignmentHeader(
                title: l10n.teamServicesEditAssignmentsAction,
                subtitle: l10n.teamServicesEditAssignmentCardSubtitle,
              ),
            ),
          if (widget.salonServices.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIds = {
                            for (final s in widget.salonServices) s.id,
                          };
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: ZuranoTokens.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: Text(l10n.teamServicesAssignmentSelectAll),
                    ),
                    TextButton(
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () {
                              setState(() => _selectedIds.clear());
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: ZuranoTokens.textGray,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: Text(l10n.teamServicesAssignmentClearSelection),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: widget.salonServices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = widget.salonServices[index];
                final selected = _selectedIds.contains(service.id);
                final title = service.localizedTitleForLanguageCode(lang);
                final meta = [
                  l10n.bookingDurationMinutes(service.durationMinutes),
                  formatAppMoney(service.price, currency, locale),
                ].join(' · ');

                return _ZuranoAssignmentServiceCard(
                  title: title,
                  meta: meta,
                  catalogActive: service.isActive,
                  activeLabel: l10n.teamServicesServiceActive,
                  inactiveLabel: l10n.teamServicesServiceInactive,
                  selected: selected,
                  categoryKey: service.categoryKey,
                  iconKey: service.iconKey,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedIds.remove(service.id);
                      } else {
                        _selectedIds.add(service.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, footerPad),
            child: ZuranoGradientButton(
              height: 52,
              fontSize: 15,
              label: l10n.teamSaveChangesAction,
              onPressed: widget.employee == null ? null : _save,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Hero-style Zurano header: soft gradient surface, orb icon, accent rail.
class _ZuranoServiceAssignmentHeader extends StatelessWidget {
  const _ZuranoServiceAssignmentHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final borderTint = Color.lerp(
      ZuranoTokens.sectionBorder,
      ZuranoTokens.primary,
      0.22,
    )!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          end: -28,
          top: -32,
          child: IgnorePointer(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZuranoTokens.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: -20,
          bottom: -24,
          child: IgnorePointer(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZuranoTokens.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                ZuranoTokens.surface,
                Color.lerp(
                  ZuranoTokens.surface,
                  ZuranoTokens.lightPurple,
                  0.85,
                )!,
              ],
            ),
            border: Border.all(color: borderTint),
            boxShadow: ZuranoTokens.sectionShadow,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            ZuranoTokens.lightPurple,
                            Color.lerp(
                              ZuranoTokens.lightPurple,
                              ZuranoTokens.secondary,
                              0.12,
                            )!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ZuranoTokens.primary.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        AppIcons.tune_rounded,
                        color: ZuranoTokens.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.45,
                              height: 1.2,
                              color: ZuranoTokens.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                              color: ZuranoTokens.textGray.withValues(
                                alpha: 0.92,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    height: 4,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: ZuranoTokens.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: ZuranoTokens.primary.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ZuranoAssignmentServiceCard extends StatelessWidget {
  const _ZuranoAssignmentServiceCard({
    required this.title,
    required this.meta,
    required this.catalogActive,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.selected,
    required this.categoryKey,
    required this.iconKey,
    required this.onTap,
  });

  final String title;
  final String meta;
  final bool catalogActive;
  final String activeLabel;
  final String inactiveLabel;
  final bool selected;
  final String? categoryKey;
  final String? iconKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        border: Border.all(
          color: selected ? ZuranoTokens.primary : ZuranoTokens.sectionBorder,
          width: selected ? 2 : 1,
        ),
        color: selected ? ZuranoTokens.activeCardFill : ZuranoTokens.surface,
        boxShadow: ZuranoTokens.softCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: ZuranoTokens.primary.withValues(alpha: 0.08),
          highlightColor: ZuranoTokens.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ZuranoServiceCategoryIcon(
                  categoryKey: categoryKey,
                  iconKey: iconKey,
                  size: 48,
                  iconSize: 24,
                  backgroundColor: ZuranoTokens.lightPurple,
                  iconColor: ZuranoTokens.primary,
                  borderRadius: 16,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: ZuranoTokens.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusChip(
                            active: catalogActive,
                            activeLabel: activeLabel,
                            inactiveLabel: inactiveLabel,
                          ),
                          Text(
                            meta,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ZuranoTokens.textGray.withValues(
                                alpha: 0.92,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SelectionDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.active,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    final bg =
        active
            ? const Color(0xFFDDFCE8)
            : ZuranoTokens.chipUnselected;
    final fg =
        active
            ? const Color(0xFF047857)
            : ZuranoTokens.textGray;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? activeLabel : inactiveLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? ZuranoTokens.primary : ZuranoTokens.border,
          width: selected ? 2 : 1.5,
        ),
        color: selected ? ZuranoTokens.primary : Colors.white,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: ZuranoTokens.primary.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
