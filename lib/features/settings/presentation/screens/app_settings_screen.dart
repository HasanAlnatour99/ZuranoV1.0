import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_countries.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/bookings/data/models/booking.dart';
import '../../../../features/users/data/models/app_user.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/app_settings_providers.dart'
    show appLocalePreferenceProvider;
import '../../../../providers/customer_salon_streams_provider.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../widgets/zurano/app_settings_actions_card.dart';
import '../widgets/zurano/country_dropdown_card.dart';
import '../widgets/zurano/language_option_tile.dart';
import '../widgets/zurano/settings_section_card.dart';
import '../widgets/zurano/zurano_info_banner.dart';
import '../widgets/zurano/zurano_page_scaffold.dart';
import '../widgets/zurano/zurano_top_bar.dart';
import '../utils/zurano_sign_out_dialog.dart';
import '../../../../core/widgets/customer_app_footer.dart';
import '../../../../core/widgets/customer_profile_header_card.dart';
import '../../../../core/widgets/customer_settings_tile_card.dart';
import '../../../../core/widgets/customer_stats_strip_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

({int total, int salons, int upcoming}) _customerBookingStatCounts(
  List<Booking> bookings,
) {
  final now = DateTime.now().toUtc();
  final kept = bookings
      .where((b) => b.status != BookingStatuses.cancelled)
      .toList(growable: false);
  final total = kept.length;
  final salons = kept.map((b) => b.salonId).toSet().length;
  final upcoming = kept.where((b) {
    if (b.status == BookingStatuses.cancelled) {
      return false;
    }
    if (!(b.status == BookingStatuses.pending ||
        b.status == BookingStatuses.confirmed ||
        b.status == BookingStatuses.rescheduled)) {
      return false;
    }
    return b.startAt.toUtc().isAfter(now);
  }).length;
  return (total: total, salons: salons, upcoming: upcoming);
}

/// Language + country (local prefs). Works signed in or out.
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _showInfoBanner = true;
  bool _updatingEmployeePhoto = false;
  int _employeeSelectedTab = 0;

  void _onSettingsBack(BuildContext context, AppUser? user) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final role = user?.role.trim() ?? '';
    if (role == UserRoles.owner || role == UserRoles.admin) {
      context.go(AppRoutes.ownerOverview);
    } else if (role == UserRoles.customer) {
      context.go(AppRoutes.customerHome);
    } else {
      context.go(AppRoutes.roleSelection);
    }
  }

  Future<void> _pickCountry(BuildContext context, String? currentCode) async {
    final l10n = AppLocalizations.of(context)!;
    final uiLocale = Localizations.localeOf(context);
    final onboarding = ref.read(onboardingPrefsProvider);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.appSettingsCountrySection,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final country in AppCountries.choices)
                ListTile(
                  title: Text(
                    uiLocale.languageCode == 'ar'
                        ? country.nameAr
                        : country.nameEn,
                  ),
                  trailing: currentCode == country.code
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(ctx).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(ctx).pop(country.code),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null || !context.mounted) {
      return;
    }
    final notifier = ref.read(onboardingPrefsProvider.notifier);
    if (onboarding.countryCompleted) {
      await notifier.updateCountryCode(picked);
    } else {
      await notifier.completeCountrySelection(picked);
    }
  }

  String _localizedRoleLabel(AppLocalizations l10n, String role) {
    switch (role.trim()) {
      case UserRoles.owner:
        return l10n.roleOwner;
      case UserRoles.admin:
        return l10n.roleAdmin;
      case UserRoles.barber:
      case UserRoles.employee:
      case UserRoles.readonly:
        return l10n.roleBarber;
      case UserRoles.customer:
        return l10n.roleCustomer;
      default:
        return role.trim();
    }
  }

  Future<void> _sendEmployeeResetPassword(
    BuildContext context,
    AppUser user,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(user.email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authV2ForgotPasswordSent)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authLoginErrorGeneric)));
    }
  }

  Future<void> _updateEmployeePhoto(BuildContext context, AppUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final salonId = user.salonId?.trim() ?? '';
    final employeeId = user.employeeId?.trim() ?? '';
    if (salonId.isEmpty || employeeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.employeeWorkspaceNotLinkedBody)),
      );
      return;
    }
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (image == null) {
      return;
    }
    setState(() => _updatingEmployeePhoto = true);
    try {
      final employeeRepo = ref.read(employeeRepositoryProvider);
      final url = await employeeRepo.uploadEmployeeProfilePhoto(
        salonId: salonId,
        employeeId: employeeId,
        image: image,
      );
      final role = user.role.trim();
      final canWriteEmployeeDoc =
          role == UserRoles.owner || role == UserRoles.admin;
      if (canWriteEmployeeDoc) {
        await employeeRepo.updateEmployeePhoto(
          salonId: salonId,
          employeeId: employeeId,
          photoUrl: url,
        );
      }
      await ref
          .read(userRepositoryProvider)
          .updateUserPhoto(uid: user.uid, photoUrl: url);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.salonAttendanceZoneSaved)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authLoginErrorGeneric)));
    } finally {
      if (mounted) {
        setState(() => _updatingEmployeePhoto = false);
      }
    }
  }

  Widget _employeeSettingsBody(
    BuildContext context,
    AppLocalizations l10n,
    Locale locale,
    AppUser user,
  ) {
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final salonName =
        salonAsync.asData?.value?.name ?? user.salonId ?? l10n.employeeNoData;
    final roleLabel = _localizedRoleLabel(l10n, user.role);
    final username = user.username?.trim().isNotEmpty == true
        ? user.username!.trim()
        : l10n.employeeNoData;
    final status = user.isActive
        ? l10n.customersStatusActive
        : l10n.customersStatusInactive;
    final languageOptions = <(Locale locale, String label)>[
      (const Locale('en'), l10n.onboardingLanguageEnglish),
      (const Locale('ar'), l10n.onboardingLanguageArabic),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsHeader(
            title: l10n.appSettingsTitle,
            subtitle: l10n.employeeSettingsHeaderSubtitle,
            onBack: () => _onSettingsBack(context, user),
          ),
          const SizedBox(height: 20),
          _ProfileSummaryCard(
            imageUrl: user.photoUrl,
            title: l10n.employeeProfilePhotoTitle,
            subtitle: l10n.employeeProfileSummarySubtitle,
            actionLabel: l10n.employeeProfileUpdateShort,
            uploading: _updatingEmployeePhoto,
            onUpdatePhoto: () => _updateEmployeePhoto(context, user),
          ),
          const SizedBox(height: 18),
          _SettingsSegmentedTabs(
            selectedIndex: _employeeSelectedTab,
            overviewLabel: l10n.employeeProfileTabOverview,
            accountLabel: l10n.employeeProfileTabAccountInfo,
            onChanged: (index) {
              setState(() => _employeeSelectedTab = index);
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _employeeSelectedTab == 0
                  ? Column(
                      key: const ValueKey('employee_settings_overview'),
                      children: [
                        _SecurityCard(
                          title: l10n.authV2ForgotPasswordTitle,
                          subtitle: l10n.employeeProfileResetPasswordHint,
                          actionLabel: l10n.employeeProfileResetPasswordAction,
                          onTap: () =>
                              _sendEmployeeResetPassword(context, user),
                        ),
                        const SizedBox(height: 16),
                        _LanguageCard(
                          title: l10n.appSettingsLanguageSection,
                          subtitle: l10n.appSettingsLanguageSubtitle,
                          options: languageOptions,
                          selectedLocale: locale,
                          onSelect: (next) {
                            ref
                                .read(appLocalePreferenceProvider.notifier)
                                .setLocale(next);
                          },
                        ),
                        const SizedBox(height: 16),
                        _LogoutCard(
                          title: l10n.customerSignOut,
                          subtitle: l10n.signOutSubtitle,
                          onTap: () => unawaited(
                            showZuranoSignOutConfirmDialog(context),
                          ),
                        ),
                      ],
                    )
                  : _AccountInfoCard(
                      key: const ValueKey('employee_settings_account'),
                      rows: [
                        _AccountInfoRowData(
                          icon: Icons.email_rounded,
                          label: l10n.fieldLabelEmail,
                          value: user.email,
                        ),
                        _AccountInfoRowData(
                          icon: Icons.badge_rounded,
                          label: l10n.employeeProfileRoleLabel,
                          value: roleLabel,
                        ),
                        _AccountInfoRowData(
                          icon: Icons.storefront_rounded,
                          label: l10n.fieldLabelSalonName,
                          value: salonName,
                        ),
                        _AccountInfoRowData(
                          icon: Icons.verified_rounded,
                          label: l10n.employeeProfileAccountStatusLabel,
                          value: status,
                        ),
                        _AccountInfoRowData(
                          icon: Icons.alternate_email_rounded,
                          label: l10n.employeeProfileUsernameLabel,
                          value: username,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _customerProfileArea(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final sessionAsync = ref.watch(sessionUserProvider);
    final bookingsAsync = ref.watch(customerBookingsForProfileStreamProvider);
    return sessionAsync.maybeWhen(
      data: (u) {
        if (u == null || u.role != UserRoles.customer) {
          return null;
        }
        final stats = bookingsAsync.when(
          data: _customerBookingStatCounts,
          loading: () => (total: 0, salons: 0, upcoming: 0),
          error: (_, _) => (total: 0, salons: 0, upcoming: 0),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.customerProfileTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: ZuranoPremiumUiColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            CustomerProfileHeaderCard(displayName: u.name, email: u.email),
            const SizedBox(height: 16),
            CustomerStatsStripCard(
              items: [
                CustomerStatStripItem(
                  value: '${stats.total}',
                  label: l10n.customerStatBookings,
                ),
                CustomerStatStripItem(
                  value: '${stats.salons}',
                  label: l10n.customerStatSalonsVisited,
                ),
                CustomerStatStripItem(
                  value: '${stats.upcoming}',
                  label: l10n.customerStatUpcoming,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomerSettingsGroupCard(
              children: [
                CustomerSettingsTile(
                  icon: AppIcons.notifications_outlined,
                  title: l10n.customerNotificationsTooltip,
                  subtitle: l10n.customerSettingsTileNotificationsSubtitle,
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                CustomerSettingsTile(
                  icon: AppIcons.event_note_outlined,
                  title: l10n.customerMyBookings,
                  subtitle: l10n.customerSettingsTileBookingsSubtitle,
                  onTap: () => context.push(AppRoutes.customerMyBookings),
                ),
              ],
            ),
          ],
        );
      },
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(appLocalePreferenceProvider);
    final onboarding = ref.watch(onboardingPrefsProvider);
    final uiLocale = Localizations.localeOf(context);
    final sessionAsync = ref.watch(sessionUserProvider);
    final user = sessionAsync.asData?.value;

    final languageOptions = <(Locale locale, String label)>[
      (const Locale('en'), l10n.onboardingLanguageEnglish),
      (const Locale('ar'), l10n.onboardingLanguageArabic),
    ];

    String countryLabel() {
      final code = onboarding.countryCode;
      if (code == null || !AppCountries.choices.any((c) => c.code == code)) {
        return l10n.appSettingsCountryLabel;
      }
      final row = AppCountries.choices.firstWhere((c) => c.code == code);
      return uiLocale.languageCode == 'ar' ? row.nameAr : row.nameEn;
    }

    final customerArea = _customerProfileArea(context, l10n, theme);
    final isEmployeeProfile =
        user != null &&
        (user.role == UserRoles.barber ||
            user.role == UserRoles.employee ||
            user.role == UserRoles.readonly);

    if (isEmployeeProfile) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: _employeeSettingsBody(context, l10n, locale, user),
        ),
      );
    }

    /// Single entry for zone + punch rules + grace + corrections + violations.
    final attendanceSettingsTile = sessionAsync.maybeWhen(
      data: (AppUser? u) {
        if (u == null) {
          return null;
        }
        final salonOk = u.salonId != null && u.salonId!.trim().isNotEmpty;
        final canManage =
            u.role == UserRoles.owner || u.role == UserRoles.admin;
        if (!canManage || !salonOk) {
          return null;
        }
        return SettingsOptionTile(
          icon: Icons.fact_check_outlined,
          title: l10n.ownerAttendanceSettingsTitle,
          subtitle: l10n.ownerAttendanceSettingsSubtitle,
          onTap: () => context.pushNamed(AppRouteNames.ownerAttendanceSettings),
        );
      },
      orElse: () => null,
    );

    final customerBookingTile = sessionAsync.maybeWhen(
      data: (AppUser? u) {
        if (u == null) {
          return null;
        }
        final salonOk = u.salonId != null && u.salonId!.trim().isNotEmpty;
        final canManage =
            u.role == UserRoles.owner || u.role == UserRoles.admin;
        if (!canManage || !salonOk) {
          return null;
        }
        return SettingsOptionTile(
          icon: Icons.calendar_month_outlined,
          title: l10n.ownerCustomerBookingTileTitle,
          subtitle: l10n.ownerCustomerBookingTileSubtitle,
          onTap: () => context.push(AppRoutes.ownerSettingsCustomerBooking),
        );
      },
      orElse: () => null,
    );

    final ownerShiftsTile = sessionAsync.maybeWhen(
      data: (AppUser? u) {
        if (u == null) {
          return null;
        }
        final salonOk = u.salonId != null && u.salonId!.trim().isNotEmpty;
        final canManage =
            u.role == UserRoles.owner || u.role == UserRoles.admin;
        if (!canManage || !salonOk) {
          return null;
        }
        return SettingsOptionTile(
          icon: Icons.schedule_rounded,
          title: l10n.ownerShiftsTileTitle,
          subtitle: l10n.ownerShiftsTileSubtitle,
          onTap: () => context.pushNamed(AppRouteNames.ownerShiftsSettings),
        );
      },
      orElse: () => null,
    );

    final payrollCadenceTile = sessionAsync.maybeWhen(
      data: (AppUser? u) {
        if (u == null) {
          return null;
        }
        final salonOk = u.salonId != null && u.salonId!.trim().isNotEmpty;
        final canManage =
            u.role == UserRoles.owner || u.role == UserRoles.admin;
        if (!canManage || !salonOk) {
          return null;
        }
        return SettingsOptionTile(
          icon: Icons.date_range_outlined,
          title: l10n.settingsPayrollCadenceTitle,
          subtitle: l10n.settingsPayrollCadenceSubtitle,
          onTap: () => context.push(AppRoutes.ownerSettingsPayrollCadence),
        );
      },
      orElse: () => null,
    );

    final ownerSettingsTiles = <Widget>[
      ?customerBookingTile,
      ?attendanceSettingsTile,
      ?ownerShiftsTile,
      ?payrollCadenceTile,
    ];

    final accountActionChildren = <Widget>[
      if (sessionAsync.hasValue && sessionAsync.value != null)
        SettingsOptionTile(
          icon: Icons.logout_rounded,
          title: l10n.customerSignOut,
          subtitle: l10n.signOutSubtitle,
          danger: true,
          showChevron: false,
          onTap: () => unawaited(showZuranoSignOutConfirmDialog(context)),
        ),
      SettingsOptionTile(
        icon: Icons.info_outline_rounded,
        title: l10n.appSettingsMoreSectionTitle,
        subtitle: l10n.appSettingsMoreActionSubtitle,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.appSettingsMoreSectionBody)),
          );
        },
      ),
    ];

    final body = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ZuranoTopBar(
            title: l10n.appSettingsTitle,
            onBack: () => _onSettingsBack(context, user),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                l10n.appSettingsIntroBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ZuranoPremiumUiColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              if (customerArea != null) ...[
                customerArea,
                const SizedBox(height: 20),
              ],
              if (ownerSettingsTiles.isNotEmpty) ...[
                AppSettingsActionsCard(children: ownerSettingsTiles),
                const SizedBox(height: 16),
              ],
              SettingsSectionCard(
                icon: Icons.language_rounded,
                title: l10n.appSettingsLanguageSection,
                subtitle: l10n.appSettingsLanguageSubtitle,
                child: Column(
                  children: [
                    for (var i = 0; i < languageOptions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      LanguageOptionTile(
                        title: languageOptions[i].$2,
                        selected: locale == languageOptions[i].$1,
                        onTap: () {
                          ref
                              .read(appLocalePreferenceProvider.notifier)
                              .setLocale(languageOptions[i].$1);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsSectionCard(
                icon: Icons.location_on_outlined,
                title: l10n.appSettingsCountrySection,
                subtitle: l10n.appSettingsCountrySubtitle,
                child: CountryDropdownCard(
                  label: countryLabel(),
                  onTap: () =>
                      unawaited(_pickCountry(context, onboarding.countryCode)),
                ),
              ),
              const SizedBox(height: 16),
              if (_showInfoBanner) ...[
                ZuranoInfoBanner(
                  text: l10n.appSettingsChangeAnytimeBanner,
                  onClose: () => setState(() => _showInfoBanner = false),
                ),
                const SizedBox(height: 16),
              ],
              AppSettingsActionsCard(children: accountActionChildren),
              const SizedBox(height: 24),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final v = snap.data?.version ?? '1.0.0';
                  return Center(
                    child: CustomerAppFooter(
                      text: l10n.customerAppFooterVersion(l10n.appTitle, v),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      body: SafeArea(child: ZuranoPageScaffold(child: body)),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.uploading,
    required this.onUpdatePhoto,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool uploading;
  final VoidCallback onUpdatePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasPhoto = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return _SettingsCard(
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: scheme.primaryContainer,
                backgroundImage: hasPhoto ? NetworkImage(imageUrl!) : null,
                child: hasPhoto
                    ? null
                    : Icon(
                        Icons.person_rounded,
                        color: scheme.primary,
                        size: 38,
                      ),
              ),
              PositionedDirectional(
                end: -2,
                bottom: -2,
                child: GestureDetector(
                  onTap: uploading ? null : onUpdatePhoto,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 3),
                    ),
                    child: uploading
                        ? Padding(
                            padding: const EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.camera_alt_rounded,
                            size: 15,
                            color: scheme.onPrimary,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                maximumSize: const Size(132, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: uploading ? null : onUpdatePhoto,
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: Text(actionLabel, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSegmentedTabs extends StatelessWidget {
  const _SettingsSegmentedTabs({
    required this.selectedIndex,
    required this.overviewLabel,
    required this.accountLabel,
    required this.onChanged,
  });

  final int selectedIndex;
  final String overviewLabel;
  final String accountLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabPill(
            label: overviewLabel,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabPill(
            label: accountLabel,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SettingsCard(
      child: Row(
        children: [
          _SettingsIconBox(icon: Icons.lock_reset_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedLocale,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final List<(Locale locale, String label)> options;
  final Locale selectedLocale;
  final ValueChanged<Locale> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SettingsIconBox(icon: Icons.language_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _LanguageOptionTile(
              title: options[i].$2,
              selected: selectedLocale == options[i].$1,
              onTap: () => onSelect(options[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.45)
                : scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language_rounded,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? scheme.primary : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SettingsCard(
      child: Row(
        children: [
          _SettingsIconBox(icon: Icons.logout_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(title)),
        ],
      ),
    );
  }
}

class _AccountInfoRowData {
  const _AccountInfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({super.key, required this.rows});

  final List<_AccountInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _AccountInfoRow(data: rows[i]),
            if (i != rows.length - 1) const _SettingsDivider(),
          ],
        ],
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({required this.data});

  final _AccountInfoRowData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(data.icon, color: scheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            data.label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            data.value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsIconBox extends StatelessWidget {
  const _SettingsIconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: scheme.primary, size: 26),
    );
  }
}
