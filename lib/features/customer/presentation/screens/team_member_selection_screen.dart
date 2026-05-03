import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../widgets/any_available_specialist_card.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/selectable_team_member_card.dart';

class TeamMemberSelectionScreen extends ConsumerStatefulWidget {
  const TeamMemberSelectionScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<TeamMemberSelectionScreen> createState() =>
      _TeamMemberSelectionScreenState();
}

class _TeamMemberSelectionScreenState
    extends ConsumerState<TeamMemberSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardServices());
  }

  @override
  void didUpdateWidget(covariant TeamMemberSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.salonId != widget.salonId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _guardServices());
    }
  }

  void _guardServices() {
    if (!mounted) {
      return;
    }
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.salonId != widget.salonId || !draft.hasServices) {
      context.goNamed(
        AppRouteNames.customerServiceSelection,
        pathParameters: {'salonId': widget.salonId},
      );
    }
  }

  void _continue(AppLocalizations l10n, bool hasTeamMembers) {
    final draft = ref.read(customerBookingDraftProvider);
    if (!hasTeamMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerTeamSelectionNoStaffHint)),
      );
      return;
    }
    if (!draft.hasTeamSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerTeamSelectionRequiredSnack)),
      );
      return;
    }
    context.pushNamed(
      AppRouteNames.customerDateTimeSelection,
      pathParameters: {'salonId': widget.salonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(customerBookingDraftProvider);
    final teamAsync = ref.watch(
      customerBookableTeamMembersProvider(widget.salonId),
    );
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final total = formatMoney(
      draft.totalAmount,
      moneyCode,
      Localizations.localeOf(context),
    );
    final hasTeamMembers = teamAsync.maybeWhen(
      data: (members) => members.isNotEmpty,
      orElse: () => false,
    );

    return CustomerGradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.medium,
        ),
        child: BookingSummaryBar(
          title: l10n.customerServiceSelectionSelectedCount(draft.serviceCount),
          subtitle: l10n.customerServiceSelectionSummary(
            draft.durationMinutes,
            total,
          ),
          trailing: CustomerActionButton(
            label: l10n.customerServiceSelectionContinue,
            onPressed: draft.hasTeamSelection && hasTeamMembers
                ? () => _continue(l10n, hasTeamMembers)
                : null,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.small,
                  AppSpacing.small,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerTeamSelectionTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerTeamSelectionSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                child: CustomerBookingProgressHeader(
                  stepLabel: l10n.customerTeamSelectionStepLabel,
                  title: l10n.customerTeamSelectionProgressTitle,
                  progress: 0.4,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
            teamAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                sliver: SliverList.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.small),
                  itemBuilder: (_, _) => const _TeamSkeletonCard(),
                ),
              ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _TeamSelectionError(
                  message: l10n.genericError,
                  retryLabel: l10n.customerSalonDiscoveryRetry,
                  onRetry: () => ref.invalidate(
                    customerBookableTeamMembersProvider(widget.salonId),
                  ),
                ),
              ),
              data: (members) {
                final hasMembers = members.isNotEmpty;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    0,
                    AppSpacing.large,
                    140,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      AnyAvailableSpecialistCard(
                        title: l10n.customerTeamSelectionAnyTitle,
                        subtitle: l10n.customerTeamSelectionAnySubtitle,
                        selected: draft.anyAvailableEmployee,
                        enabled: hasMembers,
                        onTap: () => ref
                            .read(customerBookingDraftProvider.notifier)
                            .setAnyAvailableTeamMember(),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      if (!hasMembers)
                        _EmptyTeamState(
                          title: l10n.customerTeamSelectionEmpty,
                          subtitle: l10n.customerTeamSelectionNoStaffHint,
                        )
                      else
                        for (final member in members)
                          SelectableTeamMemberCard(
                            member: member,
                            selected:
                                draft.selectedEmployeeId == member.id &&
                                !draft.anyAvailableEmployee,
                            onTap: () => ref
                                .read(customerBookingDraftProvider.notifier)
                                .setTeamMember(
                                  employeeId: member.id,
                                  employeeName: member.displayTitle,
                                ),
                          ),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSkeletonCard extends StatelessWidget {
  const _TeamSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
      ),
    );
  }
}

class _EmptyTeamState extends StatelessWidget {
  const _EmptyTeamState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        children: [
          Icon(
            Icons.groups_2_outlined,
            size: 48,
            color: AppColorsLight.textSecondary,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSelectionError extends StatelessWidget {
  const _TeamSelectionError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
