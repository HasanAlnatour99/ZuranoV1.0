import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerNearbyMapScreen extends StatelessWidget {
  const CustomerNearbyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zuranoNearbyViewMap),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: AppEmptyState(
            title: l10n.zuranoNearbyViewMap,
            message: l10n.zuranoNearbyMapSnack,
            icon: Icons.map_outlined,
            compactTypography: true,
            centerContent: true,
          ),
        ),
      ),
    );
  }
}

