import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/booking_lookup_controller.dart';
import '../../data/models/customer_booking_lookup_model.dart';
import '../widgets/customer_booking_lookup_card.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_text_field.dart';

class FindBookingScreen extends ConsumerStatefulWidget {
  const FindBookingScreen({super.key});

  @override
  ConsumerState<FindBookingScreen> createState() => _FindBookingScreenState();
}

class _FindBookingScreenState extends ConsumerState<FindBookingScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _bookingCodeController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _bookingCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bookingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lookupState = ref.watch(bookingLookupControllerProvider);
    final invalidPhone = lookupState.error is BookingLookupException &&
        (lookupState.error! as BookingLookupException).error ==
            BookingLookupError.invalidPhone;
    final missingFields = lookupState.error is BookingLookupException &&
        (lookupState.error! as BookingLookupException).error ==
            BookingLookupError.missingPhoneOrCode;

    return CustomerGradientScaffold(
      child: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.small,
                AppSpacing.medium,
                AppSpacing.large,
              ),
              sliver: SliverToBoxAdapter(
                child: _Header(
                  title: l10n.customerBookingLookupTitle,
                  subtitle: l10n.customerBookingLookupSubtitle,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              sliver: SliverToBoxAdapter(
                child: _SearchCard(
                  phoneController: _phoneController,
                  bookingCodeController: _bookingCodeController,
                  phoneLabel: l10n.customerBookingLookupPhoneNumber,
                  bookingCodeLabel: l10n.customerBookingLookupBookingCode,
                  bookingCodeHint: l10n.customerBookingLookupBookingCodeHint,
                  searchLabel: l10n.customerBookingLookupSearch,
                  phoneErrorText: invalidPhone
                      ? l10n.customerBookingLookupInvalidPhone
                      : null,
                  bookingCodeErrorText: missingFields
                      ? l10n.customerBookingLookupBothRequired
                      : null,
                  loading: lookupState.isLoading,
                  onChanged: () {
                    if (lookupState.hasError) {
                      ref.read(bookingLookupControllerProvider.notifier).clear();
                    }
                  },
                  onSearch: () => ref
                      .read(bookingLookupControllerProvider.notifier)
                      .search(
                        phoneInput: _phoneController.text,
                        bookingCodeInput: _bookingCodeController.text,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
              ),
              sliver: SliverToBoxAdapter(
                child: _InfoCard(message: l10n.customerBookingLookupPhoneHint),
              ),
            ),
            _ResultArea(state: lookupState),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColorsLight.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.phoneController,
    required this.bookingCodeController,
    required this.phoneLabel,
    required this.bookingCodeLabel,
    required this.bookingCodeHint,
    required this.searchLabel,
    required this.loading,
    required this.onChanged,
    required this.onSearch,
    this.phoneErrorText,
    this.bookingCodeErrorText,
  });

  final TextEditingController phoneController;
  final TextEditingController bookingCodeController;
  final String phoneLabel;
  final String bookingCodeLabel;
  final String bookingCodeHint;
  final String searchLabel;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onSearch;
  final String? phoneErrorText;
  final String? bookingCodeErrorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.primary.withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              CustomerTextField(
                controller: phoneController,
                label: phoneLabel,
                errorText: phoneErrorText,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: AppSpacing.medium),
              CustomerTextField(
                controller: bookingCodeController,
                label: bookingCodeLabel,
                hint: bookingCodeHint,
                errorText: bookingCodeErrorText,
                textInputAction: TextInputAction.search,
                inputFormatters: [UpperCaseTextFormatter()],
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: CustomerPrimaryButtonStyle.filled(context),
                  onPressed: loading ? null : onSearch,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(searchLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppBrandColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppBrandColors.primary,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultArea extends StatelessWidget {
  const _ResultArea({required this.state});

  final AsyncValue<List<CustomerBookingLookupModel>?> state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverList.list(
          children: const [
            AppSkeletonBlock(height: 132),
            SizedBox(height: AppSpacing.medium),
            AppSkeletonBlock(height: 132),
          ],
        ),
      );
    }

    if (state.hasError) {
      final isValidation = state.error is BookingLookupException;
      if (isValidation) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupGenericError),
        ),
      );
    }

    final items = state.value;
    if (items == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    if (items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        sliver: SliverToBoxAdapter(
          child: _StateCard(message: l10n.customerBookingLookupNotFound),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.medium),
        itemBuilder: (context, index) {
          return CustomerBookingLookupCard(booking: items[index]);
        },
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColorsLight.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
