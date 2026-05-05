import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../customers/data/models/customer.dart';
import '../../../customers/logic/customer_providers.dart';
import '../../../../l10n/app_localizations.dart';

enum _AddSaleCustomerSegment { salon, walkIn }

/// Bottom sheet: pick a salon customer (links sale + visit stats) or enter
/// walk-in name and optional phone.
class AddSaleCustomerSheet extends ConsumerStatefulWidget {
  const AddSaleCustomerSheet({
    super.key,
    required this.salonId,
    required this.initialWalkInName,
    required this.initialWalkInPhone,
    required this.onSelectSalonCustomer,
    required this.onWalkIn,
    required this.onClear,
  });

  final String salonId;
  final String initialWalkInName;
  final String initialWalkInPhone;
  final void Function(Customer customer) onSelectSalonCustomer;
  final void Function({required String name, required String phone}) onWalkIn;
  final VoidCallback onClear;

  @override
  ConsumerState<AddSaleCustomerSheet> createState() =>
      _AddSaleCustomerSheetState();
}

class _AddSaleCustomerSheetState extends ConsumerState<AddSaleCustomerSheet> {
  late final TextEditingController _search;
  late final TextEditingController _walkInName;
  late final TextEditingController _walkInPhone;
  _AddSaleCustomerSegment _segment = _AddSaleCustomerSegment.salon;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController()..addListener(_onSearchChanged);
    _walkInName = TextEditingController(text: widget.initialWalkInName);
    _walkInPhone = TextEditingController(text: widget.initialWalkInPhone);
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _search
      ..removeListener(_onSearchChanged)
      ..dispose();
    _walkInName.dispose();
    _walkInPhone.dispose();
    super.dispose();
  }

  List<Customer> _filter(List<Customer> all) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) {
      return all;
    }
    return all
        .where(
          (c) =>
              c.visibleDisplayName.toLowerCase().contains(q) ||
              c.phone.replaceAll(RegExp(r'\s'), '').contains(
                    q.replaceAll(RegExp(r'\s'), ''),
                  ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final async = ref.watch(salonCustomersForPosProvider(widget.salonId));

    return Material(
      color: scheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.addSaleCustomerSheetTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.addSaleCustomerTabSalon),
                      selected: _segment == _AddSaleCustomerSegment.salon,
                      onSelected: (_) => setState(
                        () => _segment = _AddSaleCustomerSegment.salon,
                      ),
                    ),
                    ChoiceChip(
                      label: Text(l10n.addSaleCustomerTabWalkIn),
                      selected: _segment == _AddSaleCustomerSegment.walkIn,
                      onSelected: (_) => setState(
                        () => _segment = _AddSaleCustomerSegment.walkIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_segment == _AddSaleCustomerSegment.salon) ...[
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.addSaleCustomerSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 320,
                    child: async.when(
                      data: (list) {
                        final rows = _filter(list);
                        if (rows.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.addSaleCustomerEmptySalonList,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final c = rows[i];
                            final phone = c.phone.trim();
                            return ListTile(
                              title: Text(c.visibleDisplayName),
                              subtitle: phone.isEmpty
                                  ? null
                                  : Text(phone),
                              trailing: c.discountPercentage > 0.001
                                  ? Text(
                                      '${c.discountPercentage.toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                              onTap: () =>
                                  widget.onSelectSalonCustomer(c),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          e.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _walkInName,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.addSaleCustomerWalkInNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _walkInPhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n.addSaleCustomerWalkInPhoneLabel} (${l10n.addSaleCustomerWalkInPhoneOptional})',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final name = _walkInName.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addSaleCustomerWalkInNameRequired),
                          ),
                        );
                        return;
                      }
                      widget.onWalkIn(
                        name: name,
                        phone: _walkInPhone.text.trim(),
                      );
                    },
                    child: Text(l10n.addSaleCustomerSaveWalkIn),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.addSaleCustomerClear),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
