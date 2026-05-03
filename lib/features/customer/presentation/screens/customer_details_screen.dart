import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../application/customer_booking_availability_providers.dart';
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/customer_phone_normalizer.dart';
import '../../data/models/customer_booking_settings.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_gender_selector.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_text_field.dart';

class CustomerDetailsScreen extends ConsumerStatefulWidget {
  const CustomerDetailsScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends ConsumerState<CustomerDetailsScreen> {
  static const _maxNotesLength = 300;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  String? _selectedGender;
  bool _touchedName = false;
  bool _touchedPhone = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(customerBookingDraftProvider);
    _nameController = TextEditingController(text: draft.customerName ?? '');
    _phoneController = TextEditingController(text: draft.customerPhone ?? '');
    _notesController = TextEditingController(text: draft.customerNote ?? '');
    _selectedGender = draft.customerGender;
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardDraft());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _guardDraft() {
    if (!mounted) {
      return;
    }
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.salonId != widget.salonId || !draft.hasServices) {
      context.goNamed(
        AppRouteNames.customerServiceSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (!draft.hasTeamSelection) {
      context.goNamed(
        AppRouteNames.customerTeamSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (!draft.hasDateTime) {
      context.goNamed(
        AppRouteNames.customerDateTimeSelection,
        pathParameters: {'salonId': widget.salonId},
      );
    }
  }

  String? _nameError(AppLocalizations l10n, CustomerBookingSettings policy) {
    final value = _nameController.text.trim();
    if (!policy.requireCustomerName) {
      if (value.isEmpty) {
        return null;
      }
      if (value.length < 2) {
        return l10n.customerDetailsNameTooShort;
      }
      return null;
    }
    if (value.isEmpty) {
      return _touchedName ? l10n.customerDetailsRequiredField : null;
    }
    if (value.length < 2) {
      return l10n.customerDetailsNameTooShort;
    }
    return null;
  }

  String? _phoneError(AppLocalizations l10n, CustomerBookingSettings policy) {
    final value = _phoneController.text.trim();
    if (!policy.requireCustomerPhone) {
      if (value.isEmpty) {
        return null;
      }
      final normalized = CustomerPhoneNormalizer.normalizePhone(value);
      if (!CustomerPhoneNormalizer.isValidPhone(normalized)) {
        return l10n.customerDetailsInvalidPhone;
      }
      return null;
    }
    if (value.isEmpty) {
      return _touchedPhone ? l10n.customerDetailsRequiredField : null;
    }
    final normalized = CustomerPhoneNormalizer.normalizePhone(value);
    if (!CustomerPhoneNormalizer.isValidPhone(normalized)) {
      return l10n.customerDetailsInvalidPhone;
    }
    return null;
  }

  bool _formValid(AppLocalizations l10n, CustomerBookingSettings policy) {
    final name = _nameController.text.trim();
    final phoneNorm = _phoneController.text.trim().isEmpty
        ? ''
        : CustomerPhoneNormalizer.normalizePhone(_phoneController.text);
    return policy.customerDetailsSatisfied(
          customerName: name.isEmpty ? null : name,
          customerPhoneNormalized: phoneNorm.isEmpty ? null : phoneNorm,
        ) &&
        _nameError(l10n, policy) == null &&
        _phoneError(l10n, policy) == null &&
        _notesController.text.length <= _maxNotesLength;
  }

  void _continue(AppLocalizations l10n, CustomerBookingSettings policy) {
    setState(() {
      _touchedName = true;
      _touchedPhone = true;
    });
    if (!_formValid(l10n, policy)) {
      return;
    }
    final name = _nameController.text.trim();
    final phoneRaw = _phoneController.text.trim();
    final normalized = phoneRaw.isEmpty
        ? ''
        : CustomerPhoneNormalizer.normalizePhone(_phoneController.text);
    ref
        .read(customerBookingDraftProvider.notifier)
        .setCustomerDetails(
          customerName: name.isEmpty ? '' : name,
          customerPhone: phoneRaw.isEmpty ? '' : phoneRaw,
          customerPhoneNormalized: normalized.isEmpty ? '' : normalized,
          customerGender: _selectedGender,
          customerNote: _notesController.text.trim(),
        );
    final isGuestAnonymous =
        ref.read(firebaseAuthProvider).currentUser?.isAnonymous == true;
    if (isGuestAnonymous) {
      context.pushNamed(
        AppRouteNames.customerGuestNickname,
        pathParameters: {'salonId': widget.salonId},
      );
    } else {
      context.pushNamed(
        AppRouteNames.customerBookingReview,
        pathParameters: {'salonId': widget.salonId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref
        .watch(customerPublicBookingFlowSettingsProvider(widget.salonId))
        .maybeWhen(
          data: (s) => s,
          orElse: () => const CustomerBookingSettings(),
        );
    final draft = ref.watch(customerBookingDraftProvider);
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final total = formatMoney(
      draft.totalAmount,
      moneyCode,
      Localizations.localeOf(context),
    );
    final selectedDateTime = draft.selectedStartAt == null
        ? ''
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).add_jm().format(draft.selectedStartAt!);

    return CustomerGradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.medium,
        ),
        child: BookingSummaryBar(
          title: l10n.customerDetailsSummaryTitle(
            draft.serviceCount,
            draft.selectedEmployeeName ?? l10n.customerTeamSelectionAnyTitle,
          ),
          subtitle: l10n.customerDetailsSummarySubtitle(
            selectedDateTime,
            total,
          ),
          trailing: CustomerActionButton(
            label: l10n.customerServiceSelectionContinue,
            onPressed: _formValid(l10n, policy)
                ? () => _continue(l10n, policy)
                : null,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.small,
                  AppSpacing.small,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerDetailsTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerDetailsSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                child: CustomerBookingProgressHeader(
                  stepLabel: l10n.customerDetailsStepLabel,
                  title: l10n.customerDetailsProgressTitle,
                  progress: 0.8,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  140,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormCard(
                      child: Column(
                        children: [
                          CustomerTextField(
                            controller: _nameController,
                            label: l10n.customerDetailsFullName,
                            errorText: _nameError(l10n, policy),
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(60),
                            ],
                            onChanged: (_) => setState(() {
                              _touchedName = true;
                            }),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          CustomerTextField(
                            controller: _phoneController,
                            label: l10n.customerDetailsPhoneNumber,
                            errorText: _phoneError(l10n, policy),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {
                              _touchedPhone = true;
                            }),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          CustomerGenderSelector(
                            label: l10n.customerDetailsGender,
                            selectedValue: _selectedGender,
                            options: {
                              'male': l10n.customerDetailsGenderMale,
                              'female': l10n.customerDetailsGenderFemale,
                              'preferNotToSay':
                                  l10n.customerDetailsGenderPreferNotToSay,
                            },
                            onChanged: (value) =>
                                setState(() => _selectedGender = value),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          CustomerTextField(
                            controller: _notesController,
                            label: l10n.customerDetailsNotes,
                            hint: l10n.customerDetailsNotesHint,
                            errorText:
                                _notesController.text.length > _maxNotesLength
                                ? l10n.customerDetailsNotesTooLong
                                : null,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            maxLength: _maxNotesLength,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(_maxNotesLength),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    _InfoCard(message: l10n.customerDetailsPhoneInfo),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: child,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppBrandColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppBrandColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppBrandColors.primary,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsLight.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
