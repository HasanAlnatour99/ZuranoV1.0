import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/app_illustrations.dart';
import '../../../../core/widgets/app_form_section_header.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/app_inline_message.dart';
import '../../../../core/widgets/app_onboarding_scaffold.dart';
import '../../../../core/widgets/app_phone_with_country_field.dart';
import '../../../../core/widgets/app_submit_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/luxury_auth_theme.dart';
import '../../../../core/widgets/password_strength_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/salon_owner_signup_controller.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class SalonOwnerSignupScreen extends ConsumerStatefulWidget {
  const SalonOwnerSignupScreen({super.key});

  @override
  ConsumerState<SalonOwnerSignupScreen> createState() =>
      _SalonOwnerSignupScreenState();
}

class _SalonOwnerSignupScreenState
    extends ConsumerState<SalonOwnerSignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneNationalController;
  late final FocusNode _passwordFocusNode;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordFieldFocused = false;
  ProviderSubscription<SalonOwnerSignupState>? _signupSubscription;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode()
      ..addListener(() {
        setState(() {
          _passwordFieldFocused = _passwordFocusNode.hasFocus;
        });
      });
    _nameController = TextEditingController()
      ..addListener(
        () => ref
            .read(salonOwnerSignupControllerProvider.notifier)
            .updateFullName(_nameController.text),
      );
    _emailController = TextEditingController()
      ..addListener(
        () => ref
            .read(salonOwnerSignupControllerProvider.notifier)
            .updateEmail(_emailController.text),
      );
    _passwordController = TextEditingController()
      ..addListener(() {
        ref
            .read(salonOwnerSignupControllerProvider.notifier)
            .updatePassword(_passwordController.text);
        if (_passwordFieldFocused) setState(() {});
      });
    _confirmPasswordController = TextEditingController()
      ..addListener(
        () => ref
            .read(salonOwnerSignupControllerProvider.notifier)
            .updateConfirmPassword(_confirmPasswordController.text),
      );
    _phoneNationalController = TextEditingController()
      ..addListener(
        () => ref
            .read(salonOwnerSignupControllerProvider.notifier)
            .updatePhoneNational(_phoneNationalController.text),
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _signupSubscription = ref.listenManual<SalonOwnerSignupState>(
        salonOwnerSignupControllerProvider,
        (previous, next) {
          if (!context.mounted) return;
          if (previous == null || !next.hasSubmitted) return;
          if (previous.isSubmitting &&
              !next.isSubmitting &&
              next.submissionError == null) {
            context.go(AppRoutes.createSalon);
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _signupSubscription?.close();
    _passwordFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNationalController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(salonOwnerSignupControllerProvider.notifier).submit();
    if (!context.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(salonOwnerSignupControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final busy = state.isSubmitting;

    return LuxuryAuthTheme(
      child: AppOnboardingScaffold(
        leading: Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            tooltip: l10n.authCommonBack,
            onPressed: busy ? null : _goBack,
            icon: const Icon(AppIcons.arrow_back),
          ),
        ),
        topVisual: AppIllustration(
          assetName: AppIllustrations.onboardingOwnerSignup,
          size: AppIllustrationSize.hero,
          semanticLabel: l10n.semanticIllustrationSalonOwnerSignup,
        ),
        eyebrow: l10n.salonOwnerSignupEyebrow,
        title: l10n.salonOwnerSignupTitle,
        description: l10n.salonOwnerSignupDescription,
        onboardingStep: 1,
        onboardingTotalSteps: 2,
        onboardingStepLabel: l10n.registerSalonOwnerStepLabel,
        footer: Center(
          child: TextButton(
            onPressed: busy
                ? null
                : () {
                    if (context.canPop()) {
                      context.pushReplacement(AppRoutes.login);
                    } else {
                      context.go(AppRoutes.login);
                    }
                  },
            child: Text(
              l10n.registerFooterSignIn,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormSectionHeader(
              title: l10n.registerSectionYourDetails,
              subtitle: l10n.registerSectionProfileHint,
            ),
            const SizedBox(height: AppSpacing.large),
            AppTextField(
              label: l10n.fieldLabelFullName,
              hintText: l10n.registerHintFullName,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              errorText: state.fullNameError(l10n),
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.medium),
            AppTextField(
              label: l10n.fieldLabelEmail,
              hintText: l10n.registerHintEmail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: state.emailError(l10n),
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.medium),
            AppTextField(
              label: l10n.fieldLabelPassword,
              hintText: l10n.registerHintPassword,
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              errorText: state.passwordError(l10n),
              enabled: !busy,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? l10n.accessibilityShowPassword
                    : l10n.accessibilityHidePassword,
                onPressed: busy
                    ? null
                    : () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? AppIcons.visibility_off
                      : AppIcons.visibility,
                  color: scheme.primary,
                ),
              ),
            ),
            if (_passwordFieldFocused) ...[
              const SizedBox(height: AppSpacing.medium),
              PasswordStrengthIndicator(password: _passwordController.text),
            ],
            const SizedBox(height: AppSpacing.medium),
            AppTextField(
              label: l10n.fieldLabelConfirmPassword,
              hintText: l10n.registerHintConfirmPassword,
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.next,
              errorText: state.confirmPasswordError(l10n),
              enabled: !busy,
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword
                    ? l10n.accessibilityShowPassword
                    : l10n.accessibilityHidePassword,
                onPressed: busy
                    ? null
                    : () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                icon: Icon(
                  _obscureConfirmPassword
                      ? AppIcons.visibility_off
                      : AppIcons.visibility,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            AppPhoneWithCountryField(
              label: l10n.fieldLabelPhone,
              countryLabel: l10n.fieldLabelCountry,
              countrySelected: state.country,
              onCountryChanged: busy
                  ? (_) {}
                  : (c) => ref
                        .read(salonOwnerSignupControllerProvider.notifier)
                        .updateCountry(c),
              nationalController: _phoneNationalController,
              countryErrorText: state.countryError(l10n),
              nationalErrorText: state.phoneError(l10n),
              enabled: !busy,
            ),
            if (state.submissionError != null) ...[
              const SizedBox(height: AppSpacing.medium),
              AppInlineMessage.error(message: state.submissionError!),
            ],
            const SizedBox(height: AppSpacing.large),
            AppSubmitButton(
              label: l10n.salonOwnerSignupSubmit,
              isLoading: busy,
              onPressed: state.isFormValid && !busy ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
