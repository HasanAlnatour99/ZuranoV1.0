import 'package:flutter/material.dart';

/// Small badge for booking preview (cash/card + pending/paid).
class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({
    super.key,
    required this.paymentMethodLabel,
    required this.paymentStatusLabel,
  });

  final String paymentMethodLabel;
  final String paymentStatusLabel;

  @override
  Widget build(BuildContext context) {
    final method = paymentMethodLabel.toLowerCase();
    final status = paymentStatusLabel.toLowerCase();
    Color bg;
    Color fg = Colors.white;
    if (method.contains('card') && status.contains('paid')) {
      bg = const Color(0xFF059669);
    } else if (method.contains('wallet') || method.contains('digital')) {
      bg = const Color(0xFF7C3AED);
    } else {
      bg = const Color(0xFFEA580C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$paymentMethodLabel · $paymentStatusLabel',
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
