import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/guest_profile_repository_provider.dart';
import '../../data/repositories/guest_profile_repository.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_text_field.dart';

class CustomerGuestNicknameScreen extends ConsumerStatefulWidget {
  const CustomerGuestNicknameScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<CustomerGuestNicknameScreen> createState() =>
      _CustomerGuestNicknameScreenState();
}

class _CustomerGuestNicknameScreenState
    extends ConsumerState<CustomerGuestNicknameScreen> {
  late final TextEditingController _nicknameController;
  bool _touched = false;
  bool _reserving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardDraft());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _guardDraft() {
    if (!mounted) return;
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null || !user.isAnonymous) {
      context.goNamed(
        AppRouteNames.customerBookingReview,
        pathParameters: {'salonId': widget.salonId},
      );
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
      return;
    }
    if (!draft.hasCustomerDetails) {
      context.goNamed(
        AppRouteNames.customerDetails,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (draft.hasGuestNickname) {
      context.goNamed(
        AppRouteNames.customerBookingReview,
        pathParameters: {'salonId': widget.salonId},
      );
    }
  }

  String? _localError(AppLocalizations l10n) {
    final value = _nicknameController.text.trim();
    if (value.length < 2) {
      return _touched ? l10n.guestNicknameErrorTooShort : null;
    }
    if (!GuestProfileRepository.allowedNicknameBasePattern.hasMatch(value)) {
      return l10n.guestNicknameErrorInvalid;
    }
    return null;
  }

  Future<void> _continue(AppLocalizations l10n) async {
    setState(() => _touched = true);
    if (!mounted) return;
    final err = _localError(l10n);
    if (err != null) {
      return;
    }
    setState(() => _reserving = true);
    try {
      final result = await ref
          .read(guestProfileRepositoryProvider)
          .reserveUniqueGuestProfile(rawBase: _nicknameController.text.trim());
      if (!mounted) return;
      ref
          .read(customerBookingDraftProvider.notifier)
          .setGuestNickname(
            guestNicknameKey: result.nicknameKey,
            guestDisplayName: result.guestDisplayName,
          );
      if (!mounted) return;
      context.pushNamed(
        AppRouteNames.customerBookingReview,
        pathParameters: {'salonId': widget.salonId},
      );
    } on GuestNicknameException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.guestNicknameErrorReserveFailed)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.guestNicknameErrorReserveFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _reserving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(customerBookingDraftProvider);
    final locale = Localizations.localeOf(context);
    final selectedDateTime = draft.selectedStartAt == null
        ? ''
        : DateFormat.yMMMd(
            locale.toString(),
          ).add_jm().format(draft.selectedStartAt!);
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final total = formatMoney(draft.totalAmount, moneyCode, locale);
    final canContinue =
        _nicknameController.text.trim().length >= 2 &&
        GuestProfileRepository.allowedNicknameBasePattern.hasMatch(
          _nicknameController.text.trim(),
        );

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
            label: l10n.guestNicknameContinue,
            onPressed: !_reserving && canContinue
                ? () => _continue(l10n)
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
                      onPressed: _reserving ? null : () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.guestNicknameScreenTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.guestNicknameScreenSubtitle,
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
                  title: l10n.guestNicknameScreenTitle,
                  progress: 0.9,
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
                    CustomerTextField(
                      controller: _nicknameController,
                      label: l10n.guestNicknameFieldLabel,
                      errorText: _localError(l10n),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [LengthLimitingTextInputFormatter(24)],
                      onChanged: (_) => setState(() {}),
                    ),
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
