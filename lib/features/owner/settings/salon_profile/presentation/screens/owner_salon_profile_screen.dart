import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../features/settings/presentation/widgets/zurano/settings_section_card.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_page_scaffold.dart';
import '../../../../../../features/settings/presentation/widgets/zurano/zurano_top_bar.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/constants/app_countries.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/session_provider.dart';
import '../../application/owner_salon_profile_providers.dart';

class OwnerSalonProfileScreen extends ConsumerStatefulWidget {
  const OwnerSalonProfileScreen({super.key});

  @override
  ConsumerState<OwnerSalonProfileScreen> createState() =>
      _OwnerSalonProfileScreenState();
}

class _OwnerSalonProfileScreenState extends ConsumerState<OwnerSalonProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordForPasswordController;
  late final TextEditingController _newPasswordController;

  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordForPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordForPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _promptAndUpdateEmail({
    required String uid,
    required String salonId,
    required String newEmail,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final passwordCtrl = TextEditingController();
    try {
      final password = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.ownerSalonProfileReauthTitle,
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.ownerSalonProfileReauthHint,
                    style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.ownerSalonProfileCurrentPasswordLabel,
                      filled: true,
                      fillColor: ZuranoPremiumUiColors.lightSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: ZuranoPremiumUiColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: ZuranoPremiumUiColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(null),
                          child: Text(l10n.commonCancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: ZuranoPremiumUiColors.softPurple,
                            foregroundColor: ZuranoPremiumUiColors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.of(sheetContext)
                              .pop(passwordCtrl.text.trim()),
                          child: Text(l10n.ownerSalonProfileConfirmCta),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (!mounted || password == null || password.isEmpty) {
        return;
      }

      final ok = await ref
          .read(ownerSalonAccountControllerProvider.notifier)
          .updateAccountEmail(
            uid: uid,
            salonId: salonId,
            newEmail: newEmail,
            currentPassword: password,
          );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? l10n.ownerSalonProfileEmailUpdateRequested
                : l10n.ownerSalonProfileSaveError,
          ),
        ),
      );
    } finally {
      passwordCtrl.dispose();
    }
  }

  Future<void> _pickAndUploadPhoto({
    required String salonId,
    required current,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (current.photoUrls.length >= OwnerSalonPhotosController.maxPhotos) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ownerSalonProfilePhotosLimit)),
      );
      return;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (image == null) return;

    final ok = await ref.read(ownerSalonPhotosControllerProvider.notifier).addPhoto(
          salonId: salonId,
          current: current,
          image: image,
        );
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.ownerSalonProfilePhotoAdded : l10n.ownerSalonProfileSaveError,
        ),
      ),
    );
  }

  Future<CountryChoice?> _pickCountrySheet({
    required AppLocalizations l10n,
    required Locale locale,
    required String? currentCode,
  }) {
    return showModalBottomSheet<CountryChoice>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        final maxH = MediaQuery.sizeOf(sheetContext).height;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            child: SizedBox(
              height: maxH * 0.88,
              child: _CountryPickerSheetContent(
                l10n: l10n,
                locale: locale,
                currentCode: currentCode,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider);
    final user = session.asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final uid = user?.uid.trim() ?? '';

    if (salonId.isEmpty || uid.isEmpty) {
      return Scaffold(
        backgroundColor: ZuranoPremiumUiColors.background,
        body: SafeArea(
          child: ZuranoPageScaffold(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(
                  l10n.ownerLoadError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final profileAsync = ref.watch(ownerSalonProfileProvider(salonId));
    final nameAsync = ref.watch(ownerSalonNameControllerProvider);
    final photosAsync = ref.watch(ownerSalonPhotosControllerProvider);
    final accountAsync = ref.watch(ownerSalonAccountControllerProvider);
    final isBusy =
        nameAsync.isLoading || photosAsync.isLoading || accountAsync.isLoading;

    // Snackbars are shown per-action (name/photo/cover/email/password) so the
    // message matches what the owner changed.

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      body: SafeArea(
        child: ZuranoPageScaffold(
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                ZuranoTopBar(
                  title: l10n.ownerSalonProfileTitle,
                  onBack: () {
                    if (context.canPop()) context.pop();
                  },
                ),
                Expanded(
                  child: profileAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    error: (_, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        child: Text(
                          l10n.ownerSalonProfileLoadError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    data: (profile) {
                      if (!_seeded) {
                        _nameController.text = profile.name;
                        _emailController.text =
                            user?.email.trim() ?? profile.ownerEmail;
                        _seeded = true;
                      }

                      final uiLocale = Localizations.localeOf(context);
                      final cover = profile.coverImageUrl;
                      final photos = profile.photoUrls;

                      return ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        children: [
                    SettingsSectionCard(
                      icon: Icons.storefront_outlined,
                      title: l10n.ownerSalonProfileSectionBasics,
                      subtitle: l10n.ownerSalonProfileSectionBasicsHint,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: isBusy
                                ? null
                                : () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final picked = await _pickCountrySheet(
                                      l10n: l10n,
                                      locale: uiLocale,
                                      currentCode: profile.countryCode,
                                    );
                                    if (!mounted || picked == null) return;
                                    final ok = await ref
                                        .read(
                                          ownerSalonNameControllerProvider
                                              .notifier,
                                        )
                                        .updateCountry(
                                          salonId: salonId,
                                          countryCode: picked.code,
                                          countryName: uiLocale.languageCode ==
                                                  'ar'
                                              ? picked.nameAr
                                              : picked.nameEn,
                                        );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? l10n.ownerSalonProfileCountryUpdated
                                              : l10n.ownerSalonProfileSaveError,
                                        ),
                                      ),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: ZuranoPremiumUiColors.lightSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: ZuranoPremiumUiColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.public_rounded,
                                    color: ZuranoPremiumUiColors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.ownerSalonProfileCountryLabel,
                                          style: const TextStyle(
                                            color:
                                                ZuranoPremiumUiColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          // If salon hasn't set country yet, fall back to label.
                                          AppCountries.nameForCode(
                                                profile.countryCode,
                                                uiLocale,
                                              ) ??
                                              l10n.ownerSalonProfileCountryPickTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color:
                                                ZuranoPremiumUiColors.textPrimary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: ZuranoPremiumUiColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: l10n.fieldLabelSalonName,
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: isBusy
                                  ? null
                                  : () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      final ok = await ref
                                          .read(
                                            ownerSalonNameControllerProvider
                                                .notifier,
                                          )
                                          .updateSalonName(
                                            salonId: salonId,
                                            name: _nameController.text,
                                          );
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? l10n.ownerSalonProfileNameUpdated
                                                : l10n.ownerSalonProfileSaveError,
                                          ),
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isBusy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.ownerSalonProfileSaveNameCta),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SettingsSectionCard(
                      icon: Icons.photo_library_outlined,
                      title: l10n.ownerSalonProfileSectionPhotos,
                      subtitle: l10n.ownerSalonProfileSectionPhotosHint,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (photos.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                l10n.ownerSalonProfilePhotosEmpty,
                                style: const TextStyle(
                                  color: ZuranoPremiumUiColors.textSecondary,
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final url in photos)
                                _PhotoTile(
                                  url: url,
                                  isCover: cover == url,
                                  onSetCover: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final ok = await ref
                                        .read(
                                          ownerSalonPhotosControllerProvider
                                              .notifier,
                                        )
                                        .setCover(
                                          salonId: salonId,
                                          current: profile,
                                          url: url,
                                        );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? l10n.ownerSalonProfileCoverUpdated
                                              : l10n.ownerSalonProfileSaveError,
                                        ),
                                      ),
                                    );
                                  },
                                  onRemove: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final ok = await ref
                                        .read(
                                          ownerSalonPhotosControllerProvider
                                              .notifier,
                                        )
                                        .removePhoto(
                                          salonId: salonId,
                                          current: profile,
                                          url: url,
                                        );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? l10n.ownerSalonProfilePhotoRemoved
                                              : l10n.ownerSalonProfileSaveError,
                                        ),
                                      ),
                                    );
                                  },
                                  l10n: l10n,
                                ),
                              if (photos.length < OwnerSalonPhotosController.maxPhotos)
                                _AddPhotoTile(
                                  onTap: () => _pickAndUploadPhoto(
                                    salonId: salonId,
                                    current: profile,
                                  ),
                                  label: l10n.ownerSalonProfileAddPhoto,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SettingsSectionCard(
                      icon: Icons.lock_outline,
                      title: l10n.ownerSalonProfileSectionAccount,
                      subtitle: l10n.ownerSalonProfileSectionAccountHint,
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.ownerSalonProfileEmailLabel,
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.tonal(
                              onPressed: isBusy
                                  ? null
                                  : () => _promptAndUpdateEmail(
                                        uid: uid,
                                        salonId: salonId,
                                        newEmail: _emailController.text,
                                      ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    ZuranoPremiumUiColors.softPurple,
                                foregroundColor:
                                    ZuranoPremiumUiColors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(l10n.ownerSalonProfileUpdateEmailCta),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: ZuranoPremiumUiColors.border,
                          ),
                          const SizedBox(height: 18),
                          // Password update (keeps current + new password together).
                          TextField(
                            controller: _currentPasswordForPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: l10n.ownerSalonProfileCurrentPasswordLabel,
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
                          const SizedBox(height: 10),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: l10n.ownerSalonProfileNewPasswordLabel,
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.tonal(
                              onPressed: isBusy
                                  ? null
                                  : () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      final ok = await ref
                                          .read(
                                            ownerSalonAccountControllerProvider
                                                .notifier,
                                          )
                                          .updateAccountPassword(
                                            newPassword:
                                                _newPasswordController.text,
                                            currentPassword:
                                                _currentPasswordForPasswordController
                                                    .text,
                                          );
                                      if (!mounted) return;
                                      if (ok) {
                                        _currentPasswordForPasswordController
                                            .clear();
                                        _newPasswordController.clear();
                                      }
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? l10n.ownerSalonProfilePasswordUpdated
                                                : l10n.ownerSalonProfileSaveError,
                                          ),
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    ZuranoPremiumUiColors.softPurple,
                                foregroundColor:
                                    ZuranoPremiumUiColors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(l10n.ownerSalonProfileUpdatePasswordCta),
                            ),
                          ),
                        ],
                      ),
                    ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Country list sheet: owns its [TextEditingController] so dispose runs with the
/// route (avoids "controller used after dispose" during sheet teardown). The
/// parent [SizedBox] gives the [Column] a bounded height so [Expanded] works.
class _CountryPickerSheetContent extends StatefulWidget {
  const _CountryPickerSheetContent({
    required this.l10n,
    required this.locale,
    required this.currentCode,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String? currentCode;

  @override
  State<_CountryPickerSheetContent> createState() =>
      _CountryPickerSheetContentState();
}

class _CountryPickerSheetContentState extends State<_CountryPickerSheetContent> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetContext = context;
    final query = _queryController.text.trim().toLowerCase();
    final rows = query.isEmpty
        ? AppCountries.choices
        : AppCountries.choices.where((c) {
            final name = widget.locale.languageCode == 'ar'
                ? c.nameAr.toLowerCase()
                : c.nameEn.toLowerCase();
            return name.contains(query) ||
                c.code.toLowerCase().contains(query);
          }).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.l10n.ownerSalonProfileCountryPickTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ZuranoPremiumUiColors.textPrimary,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _queryController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: widget.l10n.ownerSalonProfileCountrySearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
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
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final c = rows[i];
                final label = widget.locale.languageCode == 'ar'
                    ? c.nameAr
                    : c.nameEn;
                final selected = widget.currentCode != null &&
                    widget.currentCode!.trim().toUpperCase() ==
                        c.code.toUpperCase();
                return ListTile(
                  title: Text(
                    label,
                    style: const TextStyle(
                      color: ZuranoPremiumUiColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    c.code.toUpperCase(),
                    style: const TextStyle(
                      color: ZuranoPremiumUiColors.textSecondary,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: ZuranoPremiumUiColors.primaryPurple,
                        )
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: ZuranoPremiumUiColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZuranoPremiumUiColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: ZuranoPremiumUiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.url,
    required this.isCover,
    required this.onSetCover,
    required this.onRemove,
    required this.l10n,
  });

  final String url;
  final bool isCover;
  final VoidCallback onSetCover;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: ZuranoPremiumUiColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 6,
            start: 6,
            end: 6,
            child: InkWell(
              onTap: onSetCover,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCover
                      ? scheme.primary.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCover ? l10n.ownerSalonProfileCoverBadge : l10n.ownerSalonProfileSetCover,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCover ? scheme.onPrimary : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

