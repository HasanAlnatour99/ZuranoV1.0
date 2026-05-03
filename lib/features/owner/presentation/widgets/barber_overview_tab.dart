import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_countries.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/utils/currency_for_country.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employees/data/models/employee.dart';
import '../../../salon/data/models/salon.dart';
import '../../../team/data/models/team_member_model.dart';
import '../../../team/data/models/team_member_today_summary_model.dart';
import '../../../team/presentation/widgets/team_member_action_row.dart';
import '../../../team/presentation/widgets/team_member_info_section.dart';
import '../../../team/presentation/widgets/team_member_profile_header.dart';
import '../../../team/presentation/widgets/team_member_summary_cards.dart';
import '../../../payroll/domain/effective_payroll_period.dart';
import '../../../team/providers/team_member_profile_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../logic/team_management_providers.dart';
import 'add_barber_sheet.dart';

/// Premium profile overview for a salon team member (Firestore-backed).
class BarberOverviewTab extends ConsumerWidget {
  const BarberOverviewTab({
    super.key,
    required this.data,
    required this.currencyCode,
  });

  final BarberDetailsData data;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final salon = salonAsync.asData?.value;
    final dialDigits = _dialDigitsForSalon(salon);

    final args = TeamMemberProfileArgs(
      salonId: data.employee.salonId,
      employeeId: data.employee.id,
      currencyCode: currencyCode,
    );

    final memberAsync = ref.watch(teamMemberProfileStreamProvider(args));
    final member =
        memberAsync.asData?.value ??
        TeamMemberModel.fromEmployee(data.employee, currencyCode: currencyCode);

    final summaryAsync = ref.watch(teamMemberTodaySummaryProvider(args));
    final perfSnap = ref.watch(teamMemberCurrentMonthPerformanceProvider(args));
    final perf = perfSnap.asData?.value;
    final hasPerfData = perf != null;
    final perfRating = perf?.rating ?? 0.0;
    final phoneForContact = member.phoneE164 ?? member.phone;
    final canContact =
        phoneForContact != null && phoneForContact.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teamMemberTodaySummaryProvider(args));
        ref.invalidate(teamMemberProfileStreamProvider(args));
        ref.invalidate(teamMemberCurrentMonthPerformanceProvider(args));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeamMemberProfileHeader(
              member: member,
              l10n: l10n,
              localeName: locale,
              performanceRating: perfRating,
              hasPerformanceData: hasPerfData,
            ),
            const SizedBox(height: 16),
            TeamMemberActionRow(
              canContact: canContact,
              showBookingAction: false,
              callLabel: l10n.teamProfileActionCall,
              whatsappLabel: l10n.customerDetailsWhatsApp,
              onCall: () => ContactLauncher.callPhone(
                context,
                member.phoneE164 ?? member.phone,
                unavailableMessage: l10n.teamProfilePhoneMissingSnack,
                launchErrorMessage: l10n.teamProfileDialerErrorSnack,
              ),
              onWhatsApp: () => ContactLauncher.openWhatsApp(
                context,
                member.phoneE164 ?? member.phone,
                message: '${l10n.teamProfileActionCall} ${member.fullName}',
                defaultCountryCallingCode: dialDigits,
                unavailableMessage: l10n.teamProfilePhoneMissingSnack,
                unavailableAppMessage: l10n.teamProfileWhatsAppUnavailableSnack,
              ),
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              loading: () => TeamMemberSummaryCards.loading(
                salesTitle: l10n.teamProfileTodaySalesLabel,
                servicesTitle: l10n.teamProfileServicesLabel,
                attendanceTitle: l10n.teamProfileAttendanceLabel,
              ),
              error: (_, _) => TeamMemberSummaryCards.error(
                salesTitle: l10n.teamProfileTodaySalesLabel,
                servicesTitle: l10n.teamProfileServicesLabel,
                attendanceTitle: l10n.teamProfileAttendanceLabel,
              ),
              data: (summary) => TeamMemberSummaryCards(
                todaySales: summary.todaySales,
                servicesCount: summary.servicesCount,
                attendanceLabel: _attendanceSummaryLabel(l10n, member, summary),
                currencyCode: member.currencyCode,
                salesTitle: l10n.teamProfileTodaySalesLabel,
                servicesTitle: l10n.teamProfileServicesLabel,
                attendanceTitle: l10n.teamProfileAttendanceLabel,
              ),
            ),
            const SizedBox(height: 18),
            TeamMemberInfoSection(
              title: l10n.teamProfileSectionContact,
              rows: [
                TeamMemberInfoRowData(
                  icon: Icons.phone_outlined,
                  label: l10n.teamFieldPhone,
                  value: member.phone?.trim().isNotEmpty == true
                      ? member.phone!.trim()
                      : l10n.teamValueNotAvailable,
                  showChevron: false,
                  onTap: () => ContactLauncher.callPhone(
                    context,
                    member.phoneE164 ?? member.phone,
                    unavailableMessage: l10n.teamProfilePhoneMissingSnack,
                    launchErrorMessage: l10n.teamProfileDialerErrorSnack,
                  ),
                ),
                TeamMemberInfoRowData(
                  icon: Icons.email_outlined,
                  label: l10n.teamFieldEmail,
                  value: () {
                    final e = member.email?.trim() ?? '';
                    return e.isNotEmpty ? e : l10n.teamValueNotAvailable;
                  }(),
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 18),
            TeamMemberInfoSection(
              title: l10n.teamProfileSectionWorkSettings,
              rows: [
                TeamMemberInfoRowData(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.teamFieldHiringDate,
                  value: member.hiredAt != null
                      ? DateFormat.yMMMd(locale).format(member.hiredAt!)
                      : l10n.teamValueNotAvailable,
                  showChevron: true,
                  onTap: () => showAddBarberSheet(
                    context,
                    salonId: data.employee.salonId,
                    existing: data.employee,
                  ),
                ),
                if (data.employee.role != UserRoles.owner)
                  TeamMemberInfoRowData(
                    icon: Icons.payments_outlined,
                    label: l10n.teamPayrollPeriodLabel,
                    value: _payrollPeriodOverviewValue(
                      l10n,
                      data.employee,
                      salon,
                    ),
                    showChevron: true,
                    onTap: () => _pickPayrollPeriod(
                      context: context,
                      ref: ref,
                      employee: data.employee,
                      salon: salon,
                      profileArgs: args,
                    ),
                  ),
                TeamMemberInfoRowData(
                  icon: Icons.event_available_outlined,
                  label: l10n.teamFieldAttendanceRequired,
                  value: member.attendanceRequired
                      ? l10n.teamValueYes
                      : l10n.teamValueNo,
                  valueColor: member.attendanceRequired
                      ? const Color(0xFF16A34A)
                      : ZuranoPremiumUiColors.textSecondary,
                  valueBackgroundColor: member.attendanceRequired
                      ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                      : ZuranoPremiumUiColors.primaryPurple.withValues(
                          alpha: 0.08,
                        ),
                  valueBorderColor: member.attendanceRequired
                      ? const Color(0xFF16A34A).withValues(alpha: 0.28)
                      : ZuranoPremiumUiColors.border,
                  showChevron: true,
                  onTap: () => _pickAttendanceRequired(
                    context: context,
                    ref: ref,
                    employee: data.employee,
                    member: member,
                    profileArgs: args,
                  ),
                ),
                TeamMemberInfoRowData(
                  icon: Icons.percent_outlined,
                  label: l10n.teamDetailsCommissionRate,
                  value: _commissionSummary(
                    l10n,
                    locale,
                    data.employee,
                    currencyCode,
                  ),
                  showChevron: true,
                  onTap: () => showAddBarberSheet(
                    context,
                    salonId: data.employee.salonId,
                    existing: data.employee,
                  ),
                ),
                TeamMemberInfoRowData(
                  icon: Icons.person_outline,
                  label: l10n.teamDetailsStatusLabel,
                  value: _workSettingsStatusLabel(l10n, member),
                  valueColor: member.isFrozen
                      ? const Color(0xFF475569)
                      : member.isActive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9F1239),
                  valueBackgroundColor: member.isFrozen
                      ? const Color(0xFF64748B).withValues(alpha: 0.12)
                      : member.isActive
                      ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                      : const Color(0xFFE11D48).withValues(alpha: 0.10),
                  valueBorderColor: member.isFrozen
                      ? const Color(0xFF64748B).withValues(alpha: 0.28)
                      : member.isActive
                      ? const Color(0xFF16A34A).withValues(alpha: 0.28)
                      : const Color(0xFFE11D48).withValues(alpha: 0.24),
                  showChevron: true,
                  onTap: () => _pickEmployeeStatus(
                    context: context,
                    ref: ref,
                    employee: data.employee,
                    member: member,
                    profileArgs: args,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _workSettingsStatusLabel(
    AppLocalizations l10n,
    TeamMemberModel member,
  ) {
    if (member.isFrozen) return l10n.teamProfileStatusFrozen;
    if (!member.isActive) return l10n.teamStatusInactive;
    return l10n.teamStatusActive;
  }

  static String _attendanceSummaryLabel(
    AppLocalizations l10n,
    TeamMemberModel member,
    TeamMemberTodaySummaryModel summary,
  ) {
    if (!member.attendanceRequired) {
      return l10n.teamProfileAttendanceNotRequiredSummary;
    }
    return switch (summary.attendanceDay) {
      TeamMemberAttendanceDaySummary.notCheckedIn =>
        l10n.teamMemberNotCheckedIn,
      TeamMemberAttendanceDaySummary.checkedIn => l10n.teamStatusCheckedIn,
      TeamMemberAttendanceDaySummary.checkedOut => l10n.barberAttendanceOut,
      TeamMemberAttendanceDaySummary.absent =>
        l10n.barberAttendanceStatusAbsent,
    };
  }

  static String? _dialDigitsForSalon(Salon? salon) {
    final code = salon?.countryCode?.trim();
    if (code == null || code.isEmpty) return null;
    final upper = code.toUpperCase();
    for (final c in AppCountries.choices) {
      if (c.code.toUpperCase() == upper) {
        return c.dialCode.replaceAll(RegExp(r'\D'), '');
      }
    }
    return null;
  }

  static String _payrollPeriodOverviewValue(
    AppLocalizations l10n,
    Employee employee,
    Salon? salon,
  ) {
    final effective = effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod: salon?.defaultPayrollPeriod ?? '',
      employeePayrollPeriodOverride: employee.payrollPeriodOverride,
    );
    return effective == SalonPayrollPeriods.weekly
        ? l10n.teamPayrollPeriodWeekly
        : l10n.teamPayrollPeriodMonthly;
  }

  static bool _samePayrollPeriodOverrideStorage(
    Employee employee,
    String? newOverride,
  ) {
    final a = employee.payrollPeriodOverride?.trim();
    final b = newOverride?.trim();
    if ((a == null || a.isEmpty) && (b == null || b.isEmpty)) return true;
    if (a == null || a.isEmpty || b == null || b.isEmpty) return false;
    return SalonPayrollPeriods.normalize(a) ==
        SalonPayrollPeriods.normalize(b);
  }

  static Future<void> _pickPayrollPeriod({
    required BuildContext context,
    required WidgetRef ref,
    required Employee employee,
    required Salon? salon,
    required TeamMemberProfileArgs profileArgs,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final salonDefault = SalonPayrollPeriods.normalize(
      salon?.defaultPayrollPeriod,
    );
    final effective = effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod: salon?.defaultPayrollPeriod ?? '',
      employeePayrollPeriodOverride: employee.payrollPeriodOverride,
    );

    final selected = await _showZuranoChoiceSheet<String>(
      context: context,
      options: [
        _SheetOption<String>(
          value: SalonPayrollPeriods.monthly,
          label: l10n.teamPayrollPeriodMonthly,
          icon: Icons.calendar_month_outlined,
          selected: effective == SalonPayrollPeriods.monthly,
        ),
        _SheetOption<String>(
          value: SalonPayrollPeriods.weekly,
          label: l10n.teamPayrollPeriodWeekly,
          icon: Icons.date_range,
          selected: effective == SalonPayrollPeriods.weekly,
        ),
      ],
    );
    if (selected == null || !context.mounted) return;

    final newOverride =
        selected == salonDefault ? null : SalonPayrollPeriods.normalize(selected);
    if (_samePayrollPeriodOverrideStorage(employee, newOverride)) return;

    final updated = employee.copyWith(payrollPeriodOverride: newOverride);

    await _saveEmployee(
      context: context,
      ref: ref,
      employee: updated,
      employeeName: employee.name,
      profileRefreshArgs: profileArgs,
    );
  }

  static String _commissionSummary(
    AppLocalizations l10n,
    String localeName,
    Employee employee,
    String currencyCode,
  ) {
    final nf = NumberFormat.decimalPattern(localeName);
    final ccy = resolvedSalonMoneyCurrency(
      salonCurrencyCode: currencyCode,
      salonCountryIso: null,
    );
    switch (employee.commissionType) {
      case EmployeeCommissionTypes.percentage:
        return l10n.teamCommissionPercentValue(
          employee.resolvedCommissionPercentage.toStringAsFixed(0),
        );
      case EmployeeCommissionTypes.fixed:
        return l10n.teamCommissionSummaryFixed(
          nf.format(employee.resolvedCommissionFixedAmount),
          ccy,
        );
      case EmployeeCommissionTypes.percentagePlusFixed:
        return l10n.teamCommissionSummaryMixed(
          employee.resolvedCommissionPercentage.toStringAsFixed(0),
          nf.format(employee.resolvedCommissionFixedAmount),
          ccy,
        );
      default:
        return l10n.teamValueNotAvailable;
    }
  }

  static Future<void> _pickAttendanceRequired({
    required BuildContext context,
    required WidgetRef ref,
    required Employee employee,
    required TeamMemberModel member,
    required TeamMemberProfileArgs profileArgs,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await _showZuranoChoiceSheet<bool>(
      context: context,
      options: [
        _SheetOption<bool>(
          value: true,
          label: l10n.teamValueYes,
          icon: Icons.check_circle_outline,
          selected: member.attendanceRequired,
        ),
        _SheetOption<bool>(
          value: false,
          label: l10n.teamValueNo,
          icon: Icons.cancel_outlined,
          selected: !member.attendanceRequired,
        ),
      ],
    );
    if (selected == null || selected == member.attendanceRequired) return;
    if (!context.mounted) return;

    await _saveEmployee(
      context: context,
      ref: ref,
      employee: employee.copyWith(attendanceRequired: selected),
      employeeName: employee.name,
      profileRefreshArgs: profileArgs,
    );
  }

  static Future<void> _pickEmployeeStatus({
    required BuildContext context,
    required WidgetRef ref,
    required Employee employee,
    required TeamMemberModel member,
    required TeamMemberProfileArgs profileArgs,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await _showZuranoChoiceSheet<String>(
      context: context,
      options: [
        _SheetOption<String>(
          value: 'active',
          label: l10n.teamStatusActive,
          icon: Icons.verified_user_outlined,
          selected: member.isActive && !member.isFrozen,
        ),
        _SheetOption<String>(
          value: 'inactive',
          label: l10n.teamStatusInactive,
          icon: Icons.pause_circle_outline,
          selected: !member.isActive,
        ),
        _SheetOption<String>(
          value: 'frozen',
          label: l10n.teamProfileStatusFrozen,
          icon: Icons.ac_unit_outlined,
          selected: member.isFrozen,
        ),
      ],
    );
    if (selected == null) return;

    final current = member.isFrozen
        ? 'frozen'
        : (member.isActive ? 'active' : 'inactive');
    if (selected == current) return;
    if (!context.mounted) return;

    final updated = switch (selected) {
      'active' => employee.copyWith(isActive: true, status: 'active'),
      'inactive' => employee.copyWith(isActive: false, status: 'inactive'),
      'frozen' => employee.copyWith(isActive: true, status: 'frozen'),
      _ => employee,
    };

    await _saveEmployee(
      context: context,
      ref: ref,
      employee: updated,
      employeeName: employee.name,
      profileRefreshArgs: profileArgs,
    );
  }

  static Future<void> _saveEmployee({
    required BuildContext context,
    required WidgetRef ref,
    required Employee employee,
    required String employeeName,
    TeamMemberProfileArgs? profileRefreshArgs,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(employeeRepositoryProvider)
          .updateEmployee(employee.salonId, employee);
      ref.invalidate(barberDetailsProvider(employee.id));
      if (profileRefreshArgs != null) {
        ref.invalidate(teamMemberProfileStreamProvider(profileRefreshArgs));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.teamEditBarberSuccess(formatTeamMemberName(employeeName)),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.teamSaveErrorGeneric)));
      }
    }
  }
}

class _SheetOption<T> {
  const _SheetOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool selected;
}

Future<T?> _showZuranoChoiceSheet<T>({
  required BuildContext context,
  required List<_SheetOption<T>> options,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: ZuranoPremiumUiColors.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: ZuranoPremiumUiColors.textSecondary.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              for (final option in options)
                _ZuranoSheetTile<T>(
                  option: option,
                  textStyle: theme.textTheme.titleMedium,
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _ZuranoSheetTile<T> extends StatelessWidget {
  const _ZuranoSheetTile({required this.option, required this.textStyle});

  final _SheetOption<T> option;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isSelected = option.selected;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pop(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? ZuranoPremiumUiColors.primaryPurple.withValues(alpha: 0.1)
              : ZuranoPremiumUiColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ZuranoPremiumUiColors.primaryPurple.withValues(alpha: 0.5)
                : ZuranoPremiumUiColors.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? ZuranoPremiumUiColors.primaryPurple.withValues(
                        alpha: 0.16,
                      )
                    : ZuranoPremiumUiColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: isSelected
                    ? ZuranoPremiumUiColors.primaryPurple
                    : ZuranoPremiumUiColors.textSecondary,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: textStyle?.copyWith(
                  color: ZuranoPremiumUiColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: ZuranoPremiumUiColors.primaryPurple,
              ),
          ],
        ),
      ),
    );
  }
}
