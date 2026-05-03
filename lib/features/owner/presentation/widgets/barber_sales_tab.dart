import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../team_member_profile/presentation/tabs/team_member_sales_tab.dart';
import '../../logic/team_management_providers.dart';

class BarberSalesTab extends ConsumerWidget {
  const BarberSalesTab({
    super.key,
    required this.data,
    required this.currencyCode,
    required this.onAddSale,
  });

  final BarberDetailsData data;
  final String currencyCode;
  final VoidCallback onAddSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TeamMemberSalesTab(
      salonId: data.employee.salonId,
      employeeId: data.employee.id,
      employeeName: formatTeamMemberName(data.employee.name),
      currencyCode: currencyCode,
      onAddSale: onAddSale,
    );
  }
}
