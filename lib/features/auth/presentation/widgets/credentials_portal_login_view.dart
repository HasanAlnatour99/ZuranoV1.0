import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../../router/router_session_refresh.dart';
import '../../logic/guest_customer_sign_in_controller.dart';
import '../../logic/user_login_controller.dart';
import 'auth_app_divider.dart';
import 'auth_luxury_social_login_stack.dart';
import 'auth_primary_button.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Shared presentation for customer vs staff credential sign-in (Riverpod only).
class CredentialsPortalLoginView extends ConsumerStatefulWidget {
  const CredentialsPortalLoginView({super.key, required this.customerPortal});

  /// When true: email-oriented copy, signup + social. When false: staff only.
  final bool customerPortal;

  @override
  ConsumerState<CredentialsPortalLoginView> createState() =>
      _CredentialsPortalLoginViewState();
}

class _CredentialsPortalLoginViewState
    extends ConsumerState<CredentialsPortalLoginView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _entrance.forward();
    _identifierController = TextEditingController()
      ..addListener(_syncIdentifierToCanonical);
    _passwordController = TextEditingController()
      ..addListener(
        () => ref
            .read(userLoginControllerProvider.notifier)
            .updatePassword(_passwordController.text),
      );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _identifierController.removeListener(_syncIdentifierToCanonical);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Keeps the text field and Riverpod state in sync with lowercase identifiers.
  void _syncIdentifierToCanonical() {
    final raw = _identifierController.text;
    final canonical = raw.trim().toLowerCase();
    if (raw != canonical) {
      final len = canonical.length;
      _identifierController.value = TextEditingValue(
        text: canonical,
        selection: TextSelection.collapsed(offset: len),
      );
    }
    ref.read(userLoginControllerProvider.notifier).updateIdentifier(canonical);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(userLoginControllerProvider.notifier)
        .submit(
          AppLocalizations.of(context)!,
          staffCredentialPortal: !widget.customerPortal,
        );
    if (!mounted || !ok) return;
    refreshRouterAfterAuthChange(ref);
  }

  Future<void> _afterOAuth(Future<bool> Function() action) async {
    FocusScope.of(context).unfocus();
    final ok = await action();
    if (!mounted || !ok) return;
    refreshRouterAfterAuthChange(ref);
  }

  Future<void> _onBackToRoleSelection() async {
    await ref.read(onboardingPrefsProvider.notifier).clearPreAuthPortal();
    if (!mounted) return;
    context.go(AppRoutes.roleSelection);
  }

  Future<void> _continueAsGuest(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    if (kDebugMode) {
      debugPrint('[GUEST_AUTH] guest_button_pressed_from_ui');
    }
    final ok = await ref
        .read(guestCustomerSignInControllerProvider.notifier)
        .continueAsGuest();
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(guestCustomerSignInControllerProvider).errorMessage;
      if (err != null) {
        final message =
            err == GuestCustomerSignInController.sessionTimeoutMarker
            ? l10n.guestAuthSessionTimeout
            : l10n.guestAuthSignInFailed(err);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }
    context.go(AppRoutes.customerHome);
  }

  Future<void> _showForgotPassword(AppLocalizations l10n) async {
    final id = _identifierController.text.trim();
    if (!id.contains('@')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userLoginForgotPasswordNeedEmail)),
      );
      return;
    }
    final submittedEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(text: id);
        return AlertDialog(
          title: Text(l10n.authV2ForgotPassword),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: l10n.fieldLabelEmail),
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(l10n.authCommonBack),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(l10n.authV2SendResetLink),
            ),
          ],
        );
      },
    );

    if (submittedEmail == null) return;

    final sent = await ref
        .read(userLoginControllerProvider.notifier)
        .sendPasswordReset(submittedEmail);
    if (!mounted) return;
    if (sent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authV2ForgotPasswordSent)));
    } else {
      final err = ref.read(userLoginControllerProvider).submissionError;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(userLoginControllerProvider);
    final guestState = ref.watch(guestCustomerSignInControllerProvider);
    final socialBusy = state.isAnyAuthLoading;
    final oauth = state.oauthProviderInFlight;
    final customer = widget.customerPortal;
    final guestBusy = guestState.isLoading;

    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.large,
              vertical: AppSpacing.medium,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: socialBusy || state.isSubmitting || guestBusy
                          ? null
                          : _onBackToRoleSelection,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: scheme.onSurface,
                      ),
                      tooltip: l10n.authCommonBack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Image.asset(
                      'assets/branding/zurano_logo.png',
                      width: 260,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    customer
                        ? l10n.authV2UserLoginHeadline
                        : l10n.staffLoginHeadline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    customer
                        ? l10n.authV2UserLoginSubtitle
                        : l10n.staffLoginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: customer
                        ? const [AutofillHints.email]
                        : const [AutofillHints.email, AutofillHints.username],
                    decoration: InputDecoration(
                      labelText: customer
                          ? l10n.fieldLabelEmail
                          : l10n.fieldLabelEmailOrUsername,
                      hintText: customer
                          ? l10n.loginHintEmail
                          : l10n.loginHintIdentifier,
                      errorText: state.identifierErrorFor(l10n),
                    ),
                    enabled: !socialBusy && !guestBusy,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: l10n.fieldLabelPassword,
                      hintText: l10n.loginHintPassword,
                      errorText: state.passwordErrorFor(l10n),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.accessibilityShowPassword
                            : l10n.accessibilityHidePassword,
                        onPressed: socialBusy || guestBusy
                            ? null
                            : () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        icon: Icon(
                          _obscurePassword
                              ? AppIcons.visibility_off_outlined
                              : AppIcons.visibility_outlined,
                        ),
                      ),
                    ),
                    enabled: !socialBusy && !guestBusy,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: socialBusy || guestBusy
                          ? null
                          : () => _showForgotPassword(l10n),
                      child: Text(l10n.authV2ForgotPassword),
                    ),
                  ),
                  if (state.submissionError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.submissionError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                  AuthPrimaryButton(
                    label: l10n.loginSignInButton,
                    isLoading: state.isSubmitting,
                    minHeight: 56,
                    borderRadius: 18,
                    onPressed: state.isFormValid && !socialBusy && !guestBusy
                        ? _submit
                        : null,
                  ),
                  if (customer) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: scheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            l10n.guestAuthOrDivider,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: scheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: socialBusy || state.isSubmitting || guestBusy
                            ? null
                            : () => _continueAsGuest(l10n),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          side: const BorderSide(
                            color: Color(0xFF7C3AED),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: const Color(0xFFF7F0FF),
                        ),
                        child: guestBusy
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: const Color(0xFF7C3AED),
                                ),
                              )
                            : Text(
                                l10n.guestAuthContinueAsGuest,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.guestAuthGuestSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.3,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          l10n.authV2LoginSignupPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: socialBusy || guestBusy
                              ? null
                              : () => context.push(AppRoutes.signup),
                          child: Text(l10n.authV2SignUpLink),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    AuthOrDivider(text: l10n.authV2OrDivider),
                    const SizedBox(height: AppSpacing.medium),
                    AuthLuxurySocialLoginStack(
                      enabled: !socialBusy && !guestBusy,
                      googleLoading: oauth == 'google',
                      appleLoading: oauth == 'apple',
                      facebookLoading: oauth == 'facebook',
                      onGoogle: () => _afterOAuth(
                        () => ref
                            .read(userLoginControllerProvider.notifier)
                            .signInWithGoogle(),
                      ),
                      onApple: () => _afterOAuth(
                        () => ref
                            .read(userLoginControllerProvider.notifier)
                            .signInWithApple(),
                      ),
                      onFacebook: () => _afterOAuth(
                        () => ref
                            .read(userLoginControllerProvider.notifier)
                            .signInWithFacebook(),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      l10n.staffLoginNoSignupHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
