import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../owner/logic/team_management_providers.dart';
import '../../../owner/presentation/screens/barber_details_screen.dart';
import '../../../owner/presentation/widgets/team_member_card.dart';
import '../../domain/team_member_card_vm.dart';
import 'team_deck_card.dart';

/// Team member cards in a **vertical queue** (no overlap): every card keeps
/// avatar, name, and pills fully visible below the previous one.
class StackedTeamDeck extends StatelessWidget {
  const StackedTeamDeck({
    super.key,
    required this.members,
    required this.cards,
    required this.onMenuSelected,
  }) : assert(members.length == cards.length);

  final List<TeamMemberCardVm> members;
  final List<TeamBarberCardData> cards;
  final void Function(TeamBarberCardData card, TeamMemberCardMenuAction action)
  onMenuSelected;

  static const double _cardGap = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final n = members.length;
    if (n == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(height: _cardGap),
          AppOpenContainerRoute(
            closedBuilder: (context, openContainer) {
              return TeamDeckCard(
                member: members[i],
                onProfileTap: openContainer,
                onMenuSelected: (a) => onMenuSelected(cards[i], a),
              );
            },
            openBuilder: (context, _) =>
                BarberDetailsScreen(employeeId: members[i].employeeId),
          ),
        ],
        const SizedBox(height: 8),
        _DeckFooter(text: l10n.teamDeckFooterMemberCount(members.length)),
      ],
    );
  }
}

class _DeckFooter extends StatelessWidget {
  const _DeckFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 1,
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.groups_rounded,
          size: 17,
          color: ZuranoPremiumUiColors.primaryPurple,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 72,
          height: 1,
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}
