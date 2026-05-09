import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../providers/customer_map_providers.dart';

class MapFilterChips extends ConsumerWidget {
  const MapFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filters = ref.watch(mapFilterStateProvider);

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            _typeChip(
              context,
              ref,
              label: l10n.customerMapFilterAll,
              selected: filters.businessType == MapBusinessTypeChip.all,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(businessType: MapBusinessTypeChip.all),
            ),
            _typeChip(
              context,
              ref,
              label: l10n.customerMapFilterBarber,
              selected: filters.businessType == MapBusinessTypeChip.barber,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(businessType: MapBusinessTypeChip.barber),
            ),
            _typeChip(
              context,
              ref,
              label: l10n.customerMapFilterSalon,
              selected: filters.businessType == MapBusinessTypeChip.salon,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(businessType: MapBusinessTypeChip.salon),
            ),
            _typeChip(
              context,
              ref,
              label: l10n.customerMapFilterSpa,
              selected: filters.businessType == MapBusinessTypeChip.spa,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(businessType: MapBusinessTypeChip.spa),
            ),
            _toggleChip(
              context,
              ref,
              label: l10n.customerMapFilterOpenNow,
              selected: filters.openNowOnly,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(openNowOnly: !filters.openNowOnly),
            ),
            _toggleChip(
              context,
              ref,
              label: l10n.customerMapFilterTopRated,
              selected: filters.topRatedOnly,
              onTap: () => ref.read(mapFilterStateProvider.notifier).state =
                  filters.copyWith(topRatedOnly: !filters.topRatedOnly),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _toggleChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
