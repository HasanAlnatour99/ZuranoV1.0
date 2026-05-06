import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/signup_premium_tokens.dart';
import '../../../../core/utils/localized_input_validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../../router/router_session_refresh.dart';
import '../../logic/register_controller.dart';
import '../widgets/signup/auth_signup_or_divider.dart';
import '../widgets/signup/auth_signup_primary_button.dart';
import '../widgets/signup/auth_signup_social_button.dart';
import '../widgets/signup/auth_signup_text_field.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final AnimationController _entrance;
  late final Animation<double> _fade;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _entrance.forward();

    _nameController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updateName(_nameController.text),
      );
    _emailController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updateEmail(_emailController.text),
      );
    _phoneController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updatePhone(_phoneController.text),
      );
    _cityController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updateCity(_cityController.text),
      );
    _passwordController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updatePassword(_passwordController.text),
      );
    _confirmPasswordController = TextEditingController()
      ..addListener(
        () => ref
            .read(registerControllerProvider.notifier)
            .updateConfirmPassword(_confirmPasswordController.text),
      );

    Future.microtask(() {
      if (!mounted) return;
      final onboarding = ref.read(onboardingPrefsProvider);
      if (onboarding.isStaffLoginFlow) {
        context.go(AppRoutes.staffLogin);
        return;
      }
      final uri = GoRouterState.of(context).uri;
      final prefsRole = onboarding.selectedAuthRole;
      final roleFromPrefs =
          prefsRole == UserRoles.owner || prefsRole == UserRoles.customer
          ? prefsRole
          : null;
      final intendedRole = AppRoutes.registerUriIsSalonOwner(uri)
          ? UserRoles.owner
          : roleFromPrefs ?? UserRoles.customer;
      ref
          .read(registerControllerProvider.notifier)
          .setIntendedRole(intendedRole);
      final preName = onboarding.customerPreauthDisplayName?.trim();
      final prePhone = onboarding.customerPreauthPhone?.trim();
      if (preName != null && preName.isNotEmpty) {
        ref.read(registerControllerProvider.notifier).updateName(preName);
      }
      if (prePhone != null && prePhone.isNotEmpty) {
        ref.read(registerControllerProvider.notifier).updatePhone(prePhone);
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final ok = await ref.read(registerControllerProvider.notifier).submit();
    if (!mounted || !ok) return;
    refreshRouterAfterAuthChange(ref);
  }

  Future<void> _afterSocial(Future<bool> Function() action) async {
    FocusScope.of(context).unfocus();
    final ok = await action();
    if (!mounted || !ok) return;
    refreshRouterAfterAuthChange(ref);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baseTheme = Theme.of(context);
    final signupTheme = signupPremiumThemeOverlay(baseTheme);

    final state = ref.watch(registerControllerProvider);
    final socialBusy = state.isAnyAuthLoading;
    final oauth = state.oauthProviderInFlight;
    final isOwnerFlow = state.intendedRole == UserRoles.owner;

    return Theme(
      data: signupTheme,
      child: Scaffold(
        backgroundColor: SignupPremiumColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Form(
              key: _formKey,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.deferToChild,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SignupPremiumLayout.screenPadding,
                    vertical: 8,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: socialBusy ? null : _onBack,
                        style: IconButton.styleFrom(
                          foregroundColor: SignupPremiumColors.textPrimary,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: l10n.authCommonBack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOwnerFlow
                          ? l10n.registerSalonOwnerTitle
                          : l10n.authSignupTitleCreateAccount,
                      style: signupTheme.textTheme.headlineMedium?.copyWith(
                        color: SignupPremiumColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOwnerFlow
                          ? l10n.registerSalonOwnerDescription
                          : l10n.authSignupSubtitleGetStarted,
                      style: signupTheme.textTheme.bodyLarge?.copyWith(
                        color: SignupPremiumColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    if (isOwnerFlow) ...[
                      const SizedBox(height: 20),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: SignupPremiumColors.purpleDeep.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(
                            SignupPremiumLayout.fieldRadius,
                          ),
                          border: Border.all(
                            color: SignupPremiumColors.purpleDeep.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.storefront_outlined,
                                color: SignupPremiumColors.purpleDeep,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.registerOwnerIntentBanner,
                                  style: signupTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: SignupPremiumColors.purpleDeep,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthSignupTextField(
                            controller: _nameController,
                            labelText: l10n.fieldLabelName,
                            hintText: l10n.registerHintFullName,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            enabled: !socialBusy,
                            validator: (v) =>
                                LocalizedInputValidators.requiredField(
                                  l10n,
                                  v ?? '',
                                  l10n.fieldLabelName,
                                ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(
                            height: SignupPremiumLayout.sectionGap,
                          ),
                          AuthSignupTextField(
                            controller: _emailController,
                            labelText: l10n.fieldLabelEmail,
                            hintText: l10n.registerHintEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            enabled: !socialBusy,
                            validator: (v) =>
                                LocalizedInputValidators.email(l10n, v ?? ''),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(
                            height: SignupPremiumLayout.sectionGap,
                          ),
                          AuthSignupTextField(
                            controller: _phoneController,
                            labelText: l10n.fieldLabelPhone,
                            hintText: l10n.registerHintPhone,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            enabled: !socialBusy,
                            validator: (v) =>
                                LocalizedInputValidators.phone(l10n, v ?? ''),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (!isOwnerFlow) ...[
                            const SizedBox(
                              height: SignupPremiumLayout.sectionGap,
                            ),
                            AuthSignupTextField(
                              controller: _cityController,
                              labelText: l10n.fieldLabelCity,
                              hintText: l10n.registerHintCity,
                              textInputAction: TextInputAction.next,
                              enabled: !socialBusy,
                              validator: (_) => ref
                                  .read(registerControllerProvider)
                                  .cityErrorFor(l10n),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                          const SizedBox(
                            height: SignupPremiumLayout.sectionGap,
                          ),
                          AuthSignupTextField(
                            controller: _passwordController,
                            labelText: l10n.fieldLabelPassword,
                            hintText: l10n.authSignupPasswordHintMinSix,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            enabled: !socialBusy,
                            validator: (v) =>
                                LocalizedInputValidators.passwordSignupMinSix(
                                  l10n,
                                  v ?? '',
                                ),
                            onChanged: (_) {
                              if (_confirmPasswordController.text.isNotEmpty) {
                                _formKey.currentState?.validate();
                              }
                              setState(() {});
                            },
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? l10n.accessibilityShowPassword
                                  : l10n.accessibilityHidePassword,
                              onPressed: socialBusy
                                  ? null
                                  : () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              icon: Icon(
                                _obscurePassword
                                    ? AppIcons.visibility_off_outlined
                                    : AppIcons.visibility_outlined,
                                color: SignupPremiumColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: SignupPremiumLayout.sectionGap,
                          ),
                          AuthSignupTextField(
                            controller: _confirmPasswordController,
                            labelText: l10n.fieldLabelConfirmPassword,
                            hintText: l10n.registerHintConfirmPassword,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            enabled: !socialBusy,
                            validator: (v) =>
                                LocalizedInputValidators.confirmPassword(
                                  l10n,
                                  password: _passwordController.text,
                                  confirmPassword: v ?? '',
                                ),
                            onChanged: (_) => setState(() {}),
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirmPassword
                                  ? l10n.accessibilityShowPassword
                                  : l10n.accessibilityHidePassword,
                              onPressed: socialBusy
                                  ? null
                                  : () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? AppIcons.visibility_off_outlined
                                    : AppIcons.visibility_outlined,
                                color: SignupPremiumColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.submissionError != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.submissionError!,
                        style: signupTheme.textTheme.bodySmall?.copyWith(
                          color: SignupPremiumColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    AuthSignupPrimaryButton(
                      label: l10n.authSignupPrimaryCta,
                      isLoading: state.isSubmitting,
                      onPressed: state.isFormValid && !socialBusy
                          ? _submitEmailSignUp
                          : null,
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          l10n.authV2SignupSigninPrompt,
                          style: signupTheme.textTheme.bodyMedium?.copyWith(
                            color: SignupPremiumColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: socialBusy
                              ? null
                              : () => context.push(AppRoutes.login),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(l10n.authV2SignInLink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AuthSignupOrDivider(text: l10n.authV2OrDivider),
                    const SizedBox(height: 18),
                    AuthSignupSocialColumn(
                      enabled: !socialBusy,
                      googleLabel: l10n.authV2ContinueGoogle,
                      appleLabel: l10n.authV2ContinueApple,
                      facebookLabel: l10n.authV2ContinueFacebook,
                      googleLoading: oauth == 'google',
                      appleLoading: oauth == 'apple',
                      facebookLoading: oauth == 'facebook',
                      onGoogle: () => _afterSocial(
                        () => ref
                            .read(registerControllerProvider.notifier)
                            .signUpWithGoogle(),
                      ),
                      onApple: () => _afterSocial(
                        () => ref
                            .read(registerControllerProvider.notifier)
                            .signUpWithApple(),
                      ),
                      onFacebook: () => _afterSocial(
                        () => ref
                            .read(registerControllerProvider.notifier)
                            .signUpWithFacebook(),
                      ),
                      googleLeading: Icon(
                        AppIcons.g_mobiledata_rounded,
                        color: const Color(0xFF4285F4),
                        size: 24,
                      ),
                      appleLeading: Icon(
                        AppIcons.apple,
                        color: SignupPremiumColors.textPrimary,
                        size: 22,
                      ),
                      facebookLeading: Icon(
                        AppIcons.facebook,
                        color: const Color(0xFF1877F2),
                        size: 22,
                      ),
                    ),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
