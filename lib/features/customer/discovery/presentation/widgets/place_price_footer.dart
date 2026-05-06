import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class PlacePriceFooter extends StatelessWidget {
  const PlacePriceFooter({
    super.key,
    required this.currencyCode,
    required this.amountText,
    required this.onTap,
  });

  final String currencyCode;
  final String amountText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: const BoxDecoration(
        color: PlaceDiscoveryColors.primarySoft,
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: PlaceDiscoveryColors.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${l10n.placePriceFromLabel}\n',
                    style: const TextStyle(
                      color: PlaceDiscoveryColors.textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '$currencyCode $amountText',
                    style: const TextStyle(
                      color: PlaceDiscoveryColors.primary,
                      fontSize: 23,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.55),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(
                height: 58,
                width: 58,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: PlaceDiscoveryColors.primaryDark,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
