import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/currency_for_country.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/utils/localized_input_validators.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/keyboard_safe_form_scaffold.dart';
import '../../../../core/widgets/zurano/zurano.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../salon/data/models/salon.dart';
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../data/models/service.dart';
import '../../data/service_category_catalog.dart';
import '../../data/service_category_helpers.dart';
import '../../data/service_image_storage.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'package:barber_shop_app/shared/services/service_category_icon_resolver.dart';
import 'package:barber_shop_app/shared/widgets/zurano_service_category_icon.dart';

final _editorSalonStreamProvider = StreamProvider.family<Salon?, String>((
  ref,
  salonId,
) {
  final repo = ref.watch(salonRepositoryProvider);
  return repo.watchSalon(salonId);
});

/// Opens the owner add/edit service form in a styled bottom sheet.
Future<void> showOwnerServiceEditorSheet(
  BuildContext context, {
  required String salonId,
  SalonService? existing,
}) {
  return showAppModalBottomSheet<void>(
    context: context,
    expand: true,
    builder: (ctx) =>
        _ServiceFormSheetBody(salonId: salonId, existing: existing),
  );
}

class _ServiceFormSheetBody extends ConsumerStatefulWidget {
  const _ServiceFormSheetBody({required this.salonId, this.existing});

  final String salonId;
  final SalonService? existing;

  @override
  ConsumerState<_ServiceFormSheetBody> createState() =>
      _ServiceFormSheetBodyState();
}

class _ServiceFormSheetBodyState extends ConsumerState<_ServiceFormSheetBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameC;
  late final TextEditingController _nameArC;
  late final TextEditingController _durationC;
  late final TextEditingController _priceC;
  late final TextEditingController _imageUrlC;
  late final TextEditingController _descriptionC;
  late final TextEditingController _customCategoryC;
  late String _categoryKey;
  String? _iconKey;
  late bool _isActive;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _provisionalServiceId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameC = TextEditingController(text: e?.name ?? '');
    _nameArC = TextEditingController(text: e?.nameAr ?? '');
    _durationC = TextEditingController(
      text: e != null ? '${e.durationMinutes}' : '30',
    );
    _priceC = TextEditingController(
      text: e != null ? _trimPrice(e.price) : '50',
    );
    _imageUrlC = TextEditingController(text: e?.imageUrl?.trim() ?? '');
    _descriptionC = TextEditingController(text: e?.description?.trim() ?? '');
    _customCategoryC = TextEditingController();

    final resolved = e != null ? effectiveCategoryKeyOf(e) : null;
    var key = resolved ?? ServiceCategoryKeys.hair;
    if (!ServiceCategoryKeys.pickerOrderedKeys.contains(key)) {
      key = ServiceCategoryKeys.hair;
    }
    _categoryKey = key;
    if (_categoryKey == ServiceCategoryKeys.other) {
      _customCategoryC.text = e?.customCategoryName?.trim().isNotEmpty == true
          ? e!.customCategoryName!.trim()
          : (e?.category?.trim() ?? '');
    }
    _iconKey = e?.iconKey?.trim().isNotEmpty == true
        ? e!.iconKey!.trim()
        : null;
    _isActive = e?.isActive ?? true;
    _imageUrlC.addListener(() => setState(() {}));
  }

  String _trimPrice(double p) {
    if (p == p.roundToDouble()) {
      return '${p.toInt()}';
    }
    return '$p';
  }

  String _effectiveServiceId() {
    final e = widget.existing;
    if (e != null && e.id.isNotEmpty) {
      return e.id;
    }
    _provisionalServiceId ??= ref
        .read(firestoreProvider)
        .collection(FirestorePaths.salonServices(widget.salonId))
        .doc()
        .id;
    return _provisionalServiceId!;
  }

  String _contentTypeForXFile(XFile x) {
    final m = x.mimeType?.toLowerCase();
    if (m != null && m.isNotEmpty) {
      return m;
    }
    final path = x.path.toLowerCase();
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  Future<void> _pickAndUpload(AppLocalizations l10n, ImageSource source) async {
    if (_uploadingPhoto || _saving) {
      return;
    }
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (x == null || !mounted) {
      return;
    }
    final bytes = await x.readAsBytes();
    if (!mounted) {
      return;
    }
    if (bytes.length > ServiceImageStorage.maxBytes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ownerServicePhotoTooLarge)));
      return;
    }
    setState(() => _uploadingPhoto = true);
    try {
      final storage = ref.read(serviceImageStorageProvider);
      final sid = _effectiveServiceId();
      final url = await storage.uploadServicePhoto(
        salonId: widget.salonId,
        serviceId: sid,
        bytes: bytes,
        contentType: _contentTypeForXFile(x),
      );
      if (!mounted) {
        return;
      }
      _imageUrlC.text = url;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ownerServicePhotoUploadError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  Future<void> _promptPickSource(AppLocalizations l10n) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(AppIcons.photo_library_outlined),
                title: Text(l10n.ownerServicePhotoChooseGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(AppIcons.photo_camera_outlined),
                title: Text(l10n.ownerServicePhotoChooseCamera),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) {
      return;
    }
    await _pickAndUpload(l10n, source);
  }

  void _clearPhoto() {
    _imageUrlC.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _nameC.dispose();
    _nameArC.dispose();
    _durationC.dispose();
    _priceC.dispose();
    _imageUrlC.dispose();
    _descriptionC.dispose();
    _customCategoryC.dispose();
    super.dispose();
  }

  bool _duplicateCustomExists(String normalized, String? excludeServiceId) {
    final list = ref.read(servicesStreamProvider).asData?.value;
    if (list == null) {
      return false;
    }
    for (final s in list) {
      if (s.id == excludeServiceId) {
        continue;
      }
      if (effectiveCategoryKeyOf(s) != ServiceCategoryKeys.other) {
        continue;
      }
      if (normalizeCustomCategoryName(s.customCategoryName) == normalized) {
        return true;
      }
    }
    return false;
  }

  Future<void> _openCategoryPicker(AppLocalizations l10n) async {
    if (_saving || _uploadingPhoto) {
      return;
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceCategoryPickerSheet(
        title: l10n.ownerServiceCategoryPickerLabel,
        subtitle: l10n.ownerServiceSectionDetailsSubtitle,
        selectedKey: _categoryKey,
        options: [
          for (final key in getDefaultServiceCategories())
            _ServiceCategoryOption(
              key: key,
              label: serviceCategoryLabelForKey(key, l10n),
              icon: ServiceCategoryIconResolver.resolve(categoryKey: key),
            ),
        ],
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      final prev = _categoryKey;
      _categoryKey = selected;
      if (prev != selected) {
        _iconKey = null;
      }
      if (selected != ServiceCategoryKeys.other) {
        _customCategoryC.clear();
      }
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_saving) {
      return;
    }
    final nameErr = LocalizedInputValidators.requiredField(
      l10n,
      _nameC.text,
      l10n.ownerServiceName,
    );
    if (nameErr != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(nameErr)));
      return;
    }
    final nameArErr = LocalizedInputValidators.requiredField(
      l10n,
      _nameArC.text,
      l10n.ownerServiceNameArabic,
    );
    if (nameArErr != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(nameArErr)));
      return;
    }
    if (_categoryKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerServiceValidationCategoryRequired)),
      );
      return;
    }
    final customStored = formatCustomCategoryForStorage(_customCategoryC.text);
    if (_categoryKey == ServiceCategoryKeys.other) {
      if (customStored.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ownerServiceValidationCustomCategoryRequired),
          ),
        );
        return;
      }
      final norm = normalizeCustomCategoryName(customStored);
      if (_duplicateCustomExists(norm, widget.existing?.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ownerServiceValidationDuplicateCustomCategory),
          ),
        );
        return;
      }
    }
    final dm = int.tryParse(_durationC.text.trim());
    if (dm == null || dm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerServiceValidationDurationInvalid)),
      );
      return;
    }
    final price = double.tryParse(_priceC.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerServiceValidationPriceInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    final existing = widget.existing;
    final repo = ref.read(serviceRepositoryProvider);
    var desc = _descriptionC.text.trim();
    if (desc.length > 300) {
      desc = desc.substring(0, 300);
    }
    final image = _imageUrlC.text.trim();
    final serviceId = _effectiveServiceId();

    final categoryLabel = _categoryKey == ServiceCategoryKeys.other
        ? l10n.ownerServiceCategoryOther
        : serviceCategoryLabelForKey(_categoryKey, l10n);
    final customName = _categoryKey == ServiceCategoryKeys.other
        ? customStored
        : null;
    final legacyDisplay =
        customName ??
        (_categoryKey == ServiceCategoryKeys.other
            ? l10n.ownerServiceCategoryOther
            : categoryLabel);

    try {
      final name = _nameC.text.trim();
      final nameAr = _nameArC.text.trim();
      final built = SalonService(
        id: serviceId,
        salonId: widget.salonId,
        name: name,
        serviceName: name,
        nameAr: nameAr,
        durationMinutes: dm,
        price: price,
        description: desc.isEmpty ? null : desc,
        categoryKey: _categoryKey,
        categoryLabel: categoryLabel,
        customCategoryName: customName,
        category: legacyDisplay,
        iconKey: _iconKey?.trim().isNotEmpty == true ? _iconKey!.trim() : null,
        imageUrl: image.isEmpty ? null : image,
        timesUsed: existing?.timesUsed,
        totalRevenue: existing?.totalRevenue,
        isActive: _isActive,
        bookable: existing?.bookable ?? true,
        createdAt: existing?.createdAt,
        updatedAt: existing?.updatedAt,
      );

      if (existing == null) {
        await repo.addService(widget.salonId, built);
      } else {
        await repo.updateService(widget.salonId, built);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ownerServiceSavedSuccess)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final existing = widget.existing;
    final showCustom = _categoryKey == ServiceCategoryKeys.other;
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final editorSalonAsync = ref.watch(
      _editorSalonStreamProvider(widget.salonId),
    );
    final activeSalon =
        editorSalonAsync.asData?.value ?? salonAsync.asData?.value;
    final currencyCode = resolvedSalonMoneyCurrency(
      salonCurrencyCode: activeSalon?.currencyCode,
      salonCountryIso: activeSalon?.countryCode,
    );
    final busy = _uploadingPhoto || _saving;
    final photoUrl = _imageUrlC.text.trim().isEmpty
        ? null
        : _imageUrlC.text.trim();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    const ctaHeight = 56.0;
    const ctaOuterBottom = 16.0;
    const ctaHorizontal = 24.0;
    const ctaToContentGap = 20.0;
    final contentBottomPadding =
        ctaHeight +
        ctaOuterBottom +
        ctaToContentGap +
        bottomSafe +
        kKeyboardSafePaddingExtra;

    return ColoredBox(
      color: ZuranoTokens.background,
      child: Stack(
        children: [
          KeyboardSafeModalFormScroll(
            padding: EdgeInsets.fromLTRB(24, 0, 24, contentBottomPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AddBarberHeader(
                    title: existing == null
                        ? l10n.ownerAddService
                        : l10n.ownerEditService,
                    subtitle: l10n.ownerAddServiceSheetSubtitle,
                    compact: true,
                    onBack: () {
                      if (busy) {
                        return;
                      }
                      Navigator.of(context).maybePop();
                    },
                  ),
                  const SizedBox(height: 18),
                  ZuranoSectionCard(
                    icon: AppIcons.design_services_outlined,
                    title: l10n.ownerServiceSectionDetailsTitle,
                    subtitle: l10n.ownerServiceSectionDetailsSubtitle,
                    children: [
                      ZuranoTextField(
                        controller: _nameC,
                        label: l10n.ownerServiceName,
                        hint: l10n.ownerServiceNamePlaceholder,
                        requiredField: true,
                        enabled: !busy,
                      ),
                      const SizedBox(height: 16),
                      ZuranoTextField(
                        controller: _nameArC,
                        label: l10n.ownerServiceNameArabic,
                        hint: l10n.ownerServiceNameArabicPlaceholder,
                        requiredField: true,
                        enabled: !busy,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: busy ? null : () => _openCategoryPicker(l10n),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE9DDFE)),
                          ),
                          child: Row(
                            children: [
                              ZuranoServiceCategoryIcon(
                                categoryKey: _categoryKey,
                                iconKey: _iconKey,
                                size: 44,
                                iconSize: 22,
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF7C3AED),
                                borderRadius: 14,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.ownerServiceCategoryPickerLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      serviceCategoryLabelForKey(
                                        _categoryKey,
                                        l10n,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF7C3AED),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.ownerServiceCategoryIconPreviewHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                      if (showCustom) ...[
                        const SizedBox(height: 16),
                        ZuranoTextField(
                          controller: _customCategoryC,
                          label: l10n.ownerServiceCustomCategoryLabel,
                          hint: l10n.ownerServiceCategoryOther,
                          requiredField: true,
                          enabled: !busy,
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.ownerServiceActiveLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ZuranoTokens.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.ownerServiceActiveSubtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ZuranoTokens.textGray,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme
                                  .copyWith(primary: ZuranoTokens.primary),
                            ),
                            child: Switch.adaptive(
                              value: _isActive,
                              onChanged: busy
                                  ? null
                                  : (v) => setState(() => _isActive = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ZuranoSectionCard(
                    icon: AppIcons.access_time_outlined,
                    title: l10n.ownerServiceSectionDurationTitle,
                    subtitle: l10n.ownerServiceSectionDurationSubtitle,
                    children: [
                      LayoutBuilder(
                        builder: (context, c) {
                          final row = c.maxWidth >= 340;
                          Widget durationWidget() => ZuranoTextField(
                            controller: _durationC,
                            label: l10n.ownerServiceDuration,
                            hint: '30',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                            enabled: !busy,
                            suffix: ZuranoSuffixPill(
                              text: l10n.ownerServiceSuffixMin,
                            ),
                          );
                          Widget priceWidget() => ZuranoTextField(
                            controller: _priceC,
                            label: l10n.ownerServicePrice,
                            hint: '0',
                            requiredField: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            enabled: !busy,
                            suffix: ZuranoSuffixPill(text: currencyCode),
                          );
                          if (row) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: durationWidget()),
                                const SizedBox(width: 14),
                                Expanded(child: priceWidget()),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              durationWidget(),
                              const SizedBox(height: 14),
                              priceWidget(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  ZuranoSectionCard(
                    icon: AppIcons.add_photo_alternate_outlined,
                    title: l10n.ownerServicePhotoSectionLabel,
                    subtitle: l10n.ownerServiceSectionPhotoSubtitle,
                    children: [
                      ZuranoUploadPhotoCard(
                        imageUrl: photoUrl,
                        onTap: () => _promptPickSource(l10n),
                        onRemove: photoUrl == null ? null : _clearPhoto,
                        uploadTitle: l10n.ownerServiceUploadPhotoAction,
                        formatsHint: l10n.ownerServicePhotoFormatsHint,
                        sizeHint: l10n.ownerServicePhotoSizeHint,
                        busy: _uploadingPhoto,
                      ),
                    ],
                  ),
                  ZuranoSectionCard(
                    icon: AppIcons.chat_outlined,
                    title: l10n.ownerServiceFormDescriptionHint,
                    subtitle: l10n.ownerServiceSectionDescriptionSubtitle,
                    children: [
                      ZuranoTextField(
                        controller: _descriptionC,
                        label: '',
                        hint: l10n.ownerServiceDescriptionPlaceholderLong,
                        maxLines: 4,
                        maxLength: 300,
                        enabled: !busy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: ctaHorizontal,
              right: ctaHorizontal,
              bottom: keyboardInset + bottomSafe + ctaOuterBottom,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SizedBox(
                  height: ctaHeight,
                  child: ZuranoGradientButton(
                    label: l10n.ownerServiceSaveCta,
                    icon: Icons.save_outlined,
                    isLoading: _saving,
                    onPressed: busy ? null : () => _submit(l10n),
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

class _ServiceCategoryOption {
  const _ServiceCategoryOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

class _ServiceCategoryPickerSheet extends StatefulWidget {
  const _ServiceCategoryPickerSheet({
    required this.title,
    required this.subtitle,
    required this.selectedKey,
    required this.options,
  });

  final String title;
  final String subtitle;
  final String selectedKey;
  final List<_ServiceCategoryOption> options;

  @override
  State<_ServiceCategoryPickerSheet> createState() =>
      _ServiceCategoryPickerSheetState();
}

class _ServiceCategoryPickerSheetState
    extends State<_ServiceCategoryPickerSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleOptions = query.isEmpty
        ? widget.options
        : widget.options
              .where((option) => option.label.toLowerCase().contains(query))
              .toList(growable: false);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: MaterialLocalizations.of(context).searchFieldLabel,
                prefixIcon: const Icon(AppIcons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.58,
              ),
              child: visibleOptions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          AppLocalizations.of(context)!.ownerServicesNoMatches,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: visibleOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = visibleOptions[index];
                        final selected = widget.selectedKey == option.key;
                        return Material(
                          color: selected
                              ? const Color(0xFFF4ECFF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.pop(context, option.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFFE5E7EB),
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE9DDFE),
                                      ),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: const Color(0xFF7C3AED),
                                      size: 21,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF7C3AED),
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
