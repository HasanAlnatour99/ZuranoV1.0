import 'package:flutter/material.dart';

import '../theme/zurano_customer_colors.dart';

/// Compact section chrome for customer discovery screens.
class ZuranoSectionHeaderL10n extends StatelessWidget {
  const ZuranoSectionHeaderL10n({
    super.key,
    required this.title,
    required this.actionLabel,
    this.leading,
    this.onAction,
    this.dense = false,
  });

  final String title;
  final String actionLabel;
  final IconData? leading;
  final VoidCallback? onAction;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final bottom = dense ? 6.0 : 8.0;
    final top = dense ? 6.0 : 0.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, top, 14, bottom),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, size: 18, color: ZuranoCustomerColors.primary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ZuranoCustomerColors.textStrong,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAction ?? () {},
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ZuranoCustomerColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ZuranoCustomerColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
