import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/app_settings_providers.dart';

const _kCustomersGoldenBannerDismissed = 'customers_golden_banner_dismissed';

/// Compact “Golden customers” tip; dismiss persists for this device.
class CustomerInfoBanner extends ConsumerStatefulWidget {
  const CustomerInfoBanner({super.key});

  @override
  ConsumerState<CustomerInfoBanner> createState() =>
      _CustomerInfoBannerState();
}

class _CustomerInfoBannerState extends ConsumerState<CustomerInfoBanner> {
  bool _loaded = false;
  bool _dismissed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _dismissed = prefs.getBool(_kCustomersGoldenBannerDismissed) ?? false;
    });
  }

  Future<void> _dismiss() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kCustomersGoldenBannerDismissed, true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: FinanceDashboardColors.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.customersGoldenInfoTitle,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.customersGoldenInfoSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textSecondary,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.customersGoldenInfoDismissSemantics,
            onPressed: _dismiss,
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: FinanceDashboardColors.textSecondary.withValues(
                alpha: 0.85,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
