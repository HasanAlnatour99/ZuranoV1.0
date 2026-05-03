import 'package:flutter/material.dart';

import '../../../../../core/text/team_member_name.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/repositories/schedule_repository.dart';
import 'shift_ui/shift_design_tokens.dart';

class EmployeeFixedColumn extends StatelessWidget {
  const EmployeeFixedColumn({
    super.key,
    required this.employee,
    required this.width,
    required this.height,
  });

  final ScheduleEmployeeItem employee;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = employee.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: ShiftDesignTokens.softPurple,
              backgroundImage: hasAvatar
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: hasAvatar
                  ? null
                  : const Icon(
                      Icons.person_outline,
                      size: 22,
                      color: ShiftDesignTokens.primary,
                    ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: TeamMemberNameText(
                  employee.name,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ShiftDesignTokens.textDark,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
