import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/debug/agent_session_log.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/auth_premium_tokens.dart';
import '../../../../core/utils/localized_change_temporary_password_messages.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/onboarding_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../../../router/router_session_refresh.dart'
    show refreshRouterAfterAuthChange;
import '../../../users/data/models/app_user.dart';
import '../widgets/auth_primary_button.dart';

/// Blocks dashboard access until salon staff rotate a temporary password.
class ChangeTemporaryPasswordScreen extends ConsumerStatefulWidget {
  const ChangeTemporaryPasswordScreen({super.key});

  @override
  ConsumerState<ChangeTemporaryPasswordScreen> createState() =>
      _ChangeTemporaryPasswordScreenState();
}

class _ChangeTemporaryPasswordScreenState
    extends ConsumerState<ChangeTemporaryPasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _fieldError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateFields(AppLocalizations l10n) {
    if (_currentController.text.trim().isEmpty) {
      return l10n.changeTemporaryPasswordErrorCurrentRequired;
    }
    final n = _newController.text;
    if (n.length < 8) {
      return l10n.changeTemporaryPasswordErrorNewMinLength;
    }
    final hasLetter = RegExp('[A-Za-z]').hasMatch(n);
    final hasDigit = RegExp('[0-9]').hasMatch(n);
    if (!hasLetter || !hasDigit) {
      return l10n.changeTemporaryPasswordErrorNewRequiresLetterAndNumber;
    }
    if (n != _confirmController.text) {
      return l10n.changeTemporaryPasswordErrorConfirmMismatch;
    }
    return null;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    final v = _validateFields(l10n);
    if (v != null) {
      setState(() => _fieldError = v);
      return;
    }
    setState(() {
      _fieldError = null;
      _submitting = true;
    });

    final auth = ref.read(authRepositoryProvider);
    final users = ref.read(userRepositoryProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) {
      setState(() => _submitting = false);
      return;
    }

    final sessionAsync = ref.read(sessionUserProvider);
    final appUser = sessionAsync.asData?.value;
    final salonId = appUser?.salonId?.trim();
    if (appUser == null || salonId == null || salonId.isEmpty) {
      setState(() {
        _submitting = false;
        _fieldError = l10n.changeTemporaryPasswordErrorGeneric;
      });
      return;
    }

    void log(String message, [Map<String, Object?>? data]) {
      if (kDebugMode) {
        agentSessionLog(
          hypothesisId: 'H-pwd',
          location: 'change_temporary_password_screen.dart:_submit',
          message: message,
          data: data,
        );
      }
    }

    try {
      log('password_change_start');
      await auth.reauthenticateWithCurrentEmailPassword(
        _currentController.text,
      );
      log('password_reauth_success', <String, Object?>{'uid': user.uid});
      await auth.updateCurrentUserPassword(_newController.text);
      log('firebase_password_update_success', <String, Object?>{
        'uid': user.uid,
      });

      log('clear_must_change_password_start');
      try {
        await users.clearStaffMustChangePasswordAfterPasswordRotation(
          uid: user.uid,
          salonId: salonId,
          employeeId: appUser.employeeId?.trim(),
          role: appUser.role,
        );
      } on FirebaseException catch (e) {
        log('clear_must_change_password_failed', <String, Object?>{
          'uid': user.uid,
          'code': e.code,
        });
        if (mounted) {
          setState(() {
            _submitting = false;
            _fieldError = l10n.changeTemporaryPasswordFirestorePartialFailure;
          });
        }
        return;
      }

      refreshRouterAfterAuthChange(ref);
      log('post_password_session_refresh', <String, Object?>{'uid': user.uid});

      AppUser? refreshed;
      for (var i = 0; i < 20; i++) {
        refreshed = await users.getUser(user.uid);
        if (refreshed?.mustChangePassword != true) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      if (refreshed?.mustChangePassword == true) {
        log('clear_must_change_password_failed', <String, Object?>{
          'uid': user.uid,
          'code': 'must_change_still_true_after_poll',
        });
        if (mounted) {
          setState(() {
            _submitting = false;
            _fieldError = l10n.changeTemporaryPasswordFirestorePartialFailure;
          });
        }
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);

      final role = refreshed?.role ?? appUser.role;
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      log('post_password_redirect', <String, Object?>{
        'uid': user.uid,
        'role': role,
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.changeTemporaryPasswordSuccessSnack)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!context.mounted) {
        return;
      }
      router.go(AppRoutes.staffPostPasswordChangeHome(role));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _fieldError =
              LocalizedChangeTemporaryPasswordMessages.fromFirebaseAuthException(
                l10n,
                e,
              );
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _fieldError = l10n.changeTemporaryPasswordErrorGeneric;
        });
      }
    }
  }

  /// [AuthRepository.logout] performs `FirebaseAuth.instance.signOut()` and
  /// best-effort social session cleanup — no passwords are logged.
  Future<void> _signOut() async {
    await ref.read(onboardingPrefsProvider.notifier).clearPreAuthPortal();
    await ref.read(authRepositoryProvider).logout();
    if (!mounted) {
      return;
    }
    refreshRouterAfterAuthChange(ref);
    if (!mounted) {
      return;
    }
    GoRouter.of(context).go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AuthPremiumColors.scaffold,
        appBar: AppBar(
          backgroundColor: AuthPremiumColors.scaffold,
          elevation: 0,
          foregroundColor: scheme.onSurface,
          title: Text(
            l10n.changeTemporaryPasswordTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton.icon(
                onPressed: _submitting ? null : _signOut,
                icon: Icon(
                  Icons.logout_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
                label: Text(
                  l10n.changeTemporaryPasswordSignOut,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AuthPremiumLayout.screenPadding,
              vertical: AppSpacing.medium,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.changeTemporaryPasswordSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AuthPremiumColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                TextField(
                  controller: _currentController,
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _fieldError = null),
                  decoration: InputDecoration(
                    labelText: l10n.changeTemporaryPasswordFieldCurrent,
                    filled: true,
                    fillColor: AuthPremiumColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureCurrent
                          ? l10n.accessibilityShowPassword
                          : l10n.accessibilityHidePassword,
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      icon: Icon(
                        _obscureCurrent
                            ? AppIcons.visibility_off_outlined
                            : AppIcons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _newController,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _fieldError = null),
                  decoration: InputDecoration(
                    labelText: l10n.changeTemporaryPasswordFieldNew,
                    filled: true,
                    fillColor: AuthPremiumColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureNew
                          ? l10n.accessibilityShowPassword
                          : l10n.accessibilityHidePassword,
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      icon: Icon(
                        _obscureNew
                            ? AppIcons.visibility_off_outlined
                            : AppIcons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _fieldError = null),
                  onSubmitted: _submitting ? null : (_) => _submit(l10n),
                  decoration: InputDecoration(
                    labelText: l10n.changeTemporaryPasswordFieldConfirm,
                    filled: true,
                    fillColor: AuthPremiumColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirm
                          ? l10n.accessibilityShowPassword
                          : l10n.accessibilityHidePassword,
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? AppIcons.visibility_off_outlined
                            : AppIcons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                if (_fieldError != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    _fieldError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                AuthPrimaryButton(
                  label: l10n.changeTemporaryPasswordSubmit,
                  isLoading: _submitting,
                  minHeight: 56,
                  borderRadius: 18,
                  onPressed: _submitting ? null : () => _submit(l10n),
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _signOut,
                  icon: Icon(Icons.logout_rounded, color: scheme.primary),
                  label: Text(l10n.changeTemporaryPasswordSignOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.65),
                    ),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
