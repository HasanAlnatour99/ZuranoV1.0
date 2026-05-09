import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../logic/create_customer_controller.dart';
import '../../logic/customer_permissions_provider.dart';
import '../../data/customer_repository.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _sourceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _save({required bool bookNow}) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(createCustomerControllerProvider)
          .createCustomer(
            CreateCustomerInput(
              fullName: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              source: _sourceController.text.trim().isEmpty
                  ? null
                  : _sourceController.text.trim(),
            ),
          );
      if (id.isEmpty) {
        throw StateError('Customer ID is empty after creation');
      }
      final salonId =
          ref.read(sessionUserProvider).asData?.value?.salonId?.trim() ?? '';
      if (kDebugMode) {
        debugPrint('[CUSTOMER_CREATE] created customerId=$id salonId=$salonId');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _phoneController.text.trim().isEmpty
                ? l10n.addCustomerSavedNoPhone
                : l10n.addCustomerSavedWithPhone,
          ),
        ),
      );
      if (bookNow) {
        context.go('${AppRoutes.bookingsNew}?customerId=$id');
      } else {
        context.go(AppRoutes.ownerCustomerDetails(id));
      }
    } catch (error) {
      if (!mounted) return;
      final msg = error is DuplicateCustomerPhoneException
          ? l10n.customersDuplicatePhone
          : l10n.customersGenericLoadError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final perms = ref.watch(customerPermissionsProvider);
    if (!perms.canCreateCustomer) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: AddBarberHeader(
                title: l10n.addCustomerTitle,
                subtitle: l10n.customersPermissionErrorSubtitle,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Text(
                    l10n.customersPermissionErrorTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: AddBarberHeader(
              title: l10n.addCustomerTitle,
              subtitle: l10n.addCustomerSaveAndBook,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.addCustomerFieldFullName,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? l10n.addCustomerFullNameRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.addCustomerFieldPhone,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _sourceController,
                    decoration: InputDecoration(
                      labelText: l10n.addCustomerFieldSource,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.addCustomerFieldNotes,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  FilledButton(
                    onPressed: _saving ? null : () => _save(bookNow: false),
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(l10n.addCustomerSaveCustomer),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  OutlinedButton(
                    onPressed: _saving ? null : () => _save(bookNow: true),
                    child: Text(l10n.addCustomerSaveAndBook),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
