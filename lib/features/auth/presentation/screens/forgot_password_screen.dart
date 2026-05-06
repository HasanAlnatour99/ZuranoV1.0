import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/theme/auth_premium_tokens.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../providers/repository_providers.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Email is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = e.toString().replaceAll(RegExp(r'\[.*?\] '), '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AuthPremiumColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AuthPremiumColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthPremiumLayout.screenPadding),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: l10n.authV2ForgotPasswordTitle,
                subtitle: _isSent
                    ? l10n.authV2ForgotPasswordSent
                    : l10n.authV2ForgotPasswordDescription,
                illustration: Center(
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_mbe99hio.json',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: AuthPremiumColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AuthPremiumLayout.sectionGap * 2),
              if (!_isSent) ...[
                AppTextField(
                  label: l10n.fieldLabelEmail,
                  controller: _emailController,
                  hintText: l10n.authHintEmailExample,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  errorText: _errorText,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AuthPremiumLayout.sectionGap * 2),
                AuthPrimaryButton(
                  label: l10n.authV2SendResetLink,
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ] else ...[
                const SizedBox(height: AuthPremiumLayout.sectionGap),
                AuthPrimaryButton(
                  label: l10n.authGateSignIn,
                  onPressed: () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
