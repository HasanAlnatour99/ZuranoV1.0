import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/onboarding_providers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';

class CustomerProfileSetupScreen extends ConsumerStatefulWidget {
  const CustomerProfileSetupScreen({super.key});

  @override
  ConsumerState<CustomerProfileSetupScreen> createState() =>
      _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState
    extends ConsumerState<CustomerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingPrefsProvider);
    _nameController = TextEditingController(
      text: existing.customerPreauthDisplayName ?? '',
    );
    _phoneController = TextEditingController(
      text: existing.customerPreauthPhone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(onboardingPrefsProvider.notifier)
        .setCustomerPreauthDraft(
          name: _nameController.text,
          phone: _phoneController.text,
        );
    if (!mounted) return;
    context.go(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            Color.lerp(scheme.surface, scheme.primaryContainer, 0.28)!,
          ],
        ),
      ),
      child: AuthScaffold(
        bottom: AuthPrimaryButton(
          label: l10n.customerProfileSetupContinue,
          onPressed: _submit,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.customerOnboarding);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: l10n.authCommonBack,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                l10n.customerProfileSetupTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.customerProfileSetupSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xlarge),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: l10n.customerProfileSetupNameLabel,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.customerProfileSetupNameError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.medium),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: InputDecoration(
                  labelText: l10n.customerProfileSetupPhoneLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
