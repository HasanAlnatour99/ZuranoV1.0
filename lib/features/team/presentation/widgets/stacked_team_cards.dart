import 'package:flutter/material.dart';

import '../../../../core/motion/app_motion_widgets.dart';
import '../../../owner/logic/team_management_providers.dart';
import '../../../owner/presentation/screens/barber_details_screen.dart';
import '../../../owner/presentation/widgets/team_member_card.dart';
import '../../domain/team_member_card_vm.dart';
import 'premium_team_member_card.dart';

/// Up to three overlapping member cards (back to front).
class StackedTeamCards extends StatelessWidget {
  const StackedTeamCards({
    super.key,
    required this.members,
    required this.cards,
    required this.onWhatsAppTap,
    required this.onMenuSelected,
  }) : assert(members.length == cards.length);

  final List<TeamMemberCardVm> members;
  final List<TeamBarberCardData> cards;
  final void Function(TeamBarberCardData card) onWhatsAppTap;
  final void Function(TeamBarberCardData card, TeamMemberCardMenuAction action)
  onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final visibleMembers = members.take(3).toList();
    final visibleCards = cards.take(3).toList();

    // Tall enough for intrinsic-height cards (header row + chip row) × overlap.
    return SizedBox(
      height: 430,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          for (var i = visibleMembers.length - 1; i >= 0; i--)
            AppOpenContainerRoute(
              closedBuilder: (context, openContainer) {
                return PremiumTeamMemberCard(
                  member: visibleMembers[i],
                  index: i,
                  onTap: openContainer,
                  onWhatsAppTap: () => onWhatsAppTap(visibleCards[i]),
                  onMenuSelected: (a) => onMenuSelected(visibleCards[i], a),
                  hasPhone:
                      visibleCards[i].employee.phone?.trim().isNotEmpty ??
                      false,
                );
              },
              openBuilder: (context, _) =>
                  BarberDetailsScreen(employeeId: visibleMembers[i].employeeId),
            ),
        ],
      ),
    );
  }
}
