import 'package:flutter/material.dart';

class PayrollLockedBanner extends StatelessWidget {
  const PayrollLockedBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD6DE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
      ),
    );
  }
}
