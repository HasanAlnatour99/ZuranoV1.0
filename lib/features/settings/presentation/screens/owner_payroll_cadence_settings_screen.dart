import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../widgets/zurano/zurano_page_scaffold.dart';
import '../widgets/zurano/zurano_top_bar.dart';

/// Owner-only: salon default payroll cadence (monthly vs ISO weekly).
class OwnerPayrollCadenceSettingsScreen extends ConsumerStatefulWidget {
  const OwnerPayrollCadenceSettingsScreen({super.key});

  @override
  ConsumerState<OwnerPayrollCadenceSettingsScreen> createState() =>
      _OwnerPayrollCadenceSettingsScreenState();
}

class _OwnerPayrollCadenceSettingsScreenState
    extends ConsumerState<OwnerPayrollCadenceSettingsScreen> {
  String? _pendingChoice;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final salonAsync = ref.watch(sessionSalonStreamProvider);

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      body: SafeArea(
        child: ZuranoPageScaffold(
          child: salonAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text(l10n.payrollGenericError)),
            data: (salon) {
              if (salon == null) {
                return Center(child: Text(l10n.payrollGenericError));
              }
              final effective = SalonPayrollPeriods.normalize(
                _pendingChoice ?? salon.defaultPayrollPeriod,
              );
              final canSave = _pendingChoice != null;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ZuranoTopBar(
                      title: l10n.settingsPayrollCadenceTitle,
                      onBack: () => context.pop(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          l10n.settingsPayrollCadenceSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: ZuranoPremiumUiColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.settingsPayrollCadenceMonthly),
                              selected:
                                  effective == SalonPayrollPeriods.monthly,
                              onSelected: _saving
                                  ? null
                                  : (selected) {
                                      if (!selected) {
                                        return;
                                      }
                                      final server =
                                          SalonPayrollPeriods.normalize(
                                        salon.defaultPayrollPeriod,
                                      );
                                      setState(() {
                                        _pendingChoice =
                                            SalonPayrollPeriods.monthly ==
                                                    server
                                                ? null
                                                : SalonPayrollPeriods.monthly;
                                      });
                                    },
                            ),
                            ChoiceChip(
                              label: Text(l10n.settingsPayrollCadenceWeekly),
                              selected:
                                  effective == SalonPayrollPeriods.weekly,
                              onSelected: _saving
                                  ? null
                                  : (selected) {
                                      if (!selected) {
                                        return;
                                      }
                                      final server =
                                          SalonPayrollPeriods.normalize(
                                        salon.defaultPayrollPeriod,
                                      );
                                      setState(() {
                                        _pendingChoice =
                                            SalonPayrollPeriods.weekly ==
                                                    server
                                                ? null
                                                : SalonPayrollPeriods.weekly;
                                      });
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.large),
                        FilledButton(
                          onPressed: !_saving && canSave
                              ? () => _save(context, salon.id, effective)
                              : null,
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.settingsPayrollCadenceSave),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    String salonId,
    String choice,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _saving = true);
    try {
      final salon = ref.read(sessionSalonStreamProvider).asData?.value;
      if (salon == null) {
        return;
      }
      await ref.read(salonRepositoryProvider).updateSalon(
            salon.copyWith(defaultPayrollPeriod: choice),
          );
      ref.invalidate(sessionSalonStreamProvider);
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingChoice = null;
        _saving = false;
      });
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.settingsPayrollCadenceSaved)),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
      }
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.teamSaveErrorGeneric)),
      );
    }
  }
}
