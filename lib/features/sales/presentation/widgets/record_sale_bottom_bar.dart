import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class RecordSaleBottomBar extends StatelessWidget {
  const RecordSaleBottomBar({
    super.key,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.total,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
    this.primaryActionLabel,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;
  final double total;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  /// When set, replaces [AppLocalizations.addSaleRecordSale] on the button.
  final String? primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: Opacity(
              opacity: enabled || isLoading ? 1 : 0.58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: enabled && !isLoading
                      ? const LinearGradient(
                          colors: [
                            FinanceDashboardColors.primaryPurple,
                            FinanceDashboardColors.deepPurple,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : LinearGradient(
                          colors: [
                            FinanceDashboardColors.primaryPurple.withValues(
                              alpha: 0.40,
                            ),
                            FinanceDashboardColors.deepPurple.withValues(
                              alpha: 0.40,
                            ),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (enabled && !isLoading)
                      BoxShadow(
                        color: FinanceDashboardColors.primaryPurple.withValues(
                          alpha: 0.26,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: FilledButton(
                  onPressed: enabled && !isLoading ? onPressed : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              primaryActionLabel ?? l10n.addSaleRecordSale,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatAppMoney(total, currencyCode, locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
