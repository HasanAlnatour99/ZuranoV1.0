import '../../logic/team_management_providers.dart';
import '../../../team_member_details/presentation/tabs/team_member_payroll_tab.dart';
import 'package:flutter/material.dart';

class BarberPayrollTab extends StatelessWidget {
  const BarberPayrollTab({
    super.key,
    required this.data,
    required this.currencyCode,
  });

  final BarberDetailsData data;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return TeamMemberPayrollTab(
      salonId: data.employee.salonId,
      employeeId: data.employee.id,
    );
  }
}
