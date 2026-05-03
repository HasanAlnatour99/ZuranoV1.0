import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/add_sale_booking_flow_notifier.dart';
import '../utils/add_sale_booking_error_l10n.dart';
import 'booking_sale_preview_card.dart';

/// Booking code entry, retrieve, preview, and sticky checkout for POS-from-booking.
class BookingCodeSaleForm extends ConsumerStatefulWidget {
  const BookingCodeSaleForm({
    super.key,
    required this.salonId,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
  });

  final String salonId;
  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;

  @override
  ConsumerState<BookingCodeSaleForm> createState() =>
      _BookingCodeSaleFormState();
}

class _BookingCodeSaleFormState extends ConsumerState<BookingCodeSaleForm> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(addSaleBookingFlowProvider).bookingCodeInput;
    _codeController = TextEditingController(text: initial);
    _codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    ref
        .read(addSaleBookingFlowProvider.notifier)
        .updateBookingCode(_codeController.text);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(addSaleBookingFlowProvider);
    final notifier = ref.read(addSaleBookingFlowProvider.notifier);

    ref.listen(addSaleBookingFlowProvider, (prev, next) {
      if (prev?.bookingCodeInput == next.bookingCodeInput) return;
      if (_codeController.text == next.bookingCodeInput) return;
      _codeController.value = TextEditingValue(
        text: next.bookingCodeInput,
        selection: TextSelection.collapsed(
          offset: next.bookingCodeInput.length,
        ),
      );
    });

    final err = localizedAddSaleBookingError(widget.l10n, flow.errorCode);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.l10n.addSaleBookingCodeHint,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: FinanceDashboardColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.l10n.addSaleBookingCodeExample,
                  style: const TextStyle(
                    fontSize: 13,
                    color: FinanceDashboardColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: widget.l10n.addSaleBookingCodeFieldLabel,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: flow.lookupLoading || widget.salonId.isEmpty
                      ? null
                      : () => notifier.retrieveBooking(widget.salonId),
                  icon: flow.lookupLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(widget.l10n.addSaleRetrieveBooking),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: FinanceDashboardColors.primaryPurple,
                  ),
                ),
                if (flow.errorCode != null && !flow.lookupLoading) ...[
                  const SizedBox(height: 12),
                  Text(
                    err,
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (flow.preview != null)
                  BookingSalePreviewCard(
                    booking: flow.preview!,
                    l10n: widget.l10n,
                    locale: widget.locale,
                    currencyCode: widget.currencyCode,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
