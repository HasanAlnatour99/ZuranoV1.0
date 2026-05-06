import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../widgets/owner_bookings_module.dart';

/// Full-screen salon bookings list (filters, FAB, detail sheets).
class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      appBar: AppBar(
        backgroundColor: FinanceDashboardColors.background,
        foregroundColor: FinanceDashboardColors.textPrimary,
        elevation: 0,
        title: Text(l10n.ownerBookingsListTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: salonId.isEmpty
          ? Center(child: Text(l10n.ownerServicesWaitingForSalon))
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.small),
              child: OwnerBookingsModule(salonId: salonId),
            ),
    );
  }
}
