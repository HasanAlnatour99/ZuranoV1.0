import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../data/models/customer.dart';
import '../../logic/customer_providers.dart';
import '../../logic/customer_permissions_provider.dart';
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../data/customer_repository.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  const EditCustomerScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _notes;
  late final TextEditingController _discount;
  bool _saving = false;
  bool _seededFromRemote = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _notes = TextEditingController();
    _discount = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    _discount.dispose();
    super.dispose();
  }

  void _applyCustomer(Customer c) {
    _name.text = c.fullName;
    _phone.text = c.phone;
    _notes.text = c.notes ?? '';
    _discount.text = c.discountPercentage.toStringAsFixed(
      c.discountPercentage == c.discountPercentage.roundToDouble() ? 0 : 1,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    if (user == null || salonId.isEmpty) return;
    final discount = double.tryParse(_discount.text.replaceAll(',', '.')) ?? 0;
    if (discount < 0 || discount > 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.customerDiscountInvalid)));
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = await ref
          .read(customerRepositoryProvider)
          .getCustomerById(salonId, widget.customerId);
      if (existing == null) {
        throw StateError('Customer missing');
      }
      final updated = existing.copyWith(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        discountPercentage: discount,
      );
      await ref
          .read(customerRepositoryProvider)
          .updateCustomer(salonId, updated);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addCustomerSavedWithPhone)));
      context.pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      final msg = e is DuplicateCustomerPhoneException
          ? l10n.customersDuplicatePhone
          : l10n.customersGenericLoadError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final perms = ref.watch(customerPermissionsProvider);
    if (!perms.canEditCustomer) {
      return Scaffold(
        backgroundColor: FinanceDashboardColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.customersPermissionErrorTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: FinanceDashboardColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final customerAsync = salonId.isEmpty
        ? const AsyncValue<Customer?>.data(null)
        : ref.watch(
            customerDetailsProvider(
              CustomerDetailsArgs(
                salonId: salonId,
                customerId: widget.customerId,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      body: customerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: FinanceDashboardColors.primaryPurple,
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (c) {
          if (c == null) {
            return Center(child: Text(l10n.customerNotFound));
          }
          if (!_seededFromRemote) {
            _seededFromRemote = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _applyCustomer(c);
            });
          }
          return Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: AddBarberHeader(
                    title: l10n.customerDetailsEdit,
                    subtitle: c.fullName,
                    compact: true,
                    onBack: () => context.pop(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l10n.addCustomerFieldFullName,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? ' ' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.addCustomerFieldPhone,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _discount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.customerDiscountPercentLabel,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notes,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.addCustomerFieldNotes,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: FinanceDashboardColors.primaryPurple,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.addCustomerSaveCustomer),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
