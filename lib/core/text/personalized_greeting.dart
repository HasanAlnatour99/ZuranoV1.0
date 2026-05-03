import '../../l10n/app_localizations.dart';
import 'team_member_name.dart';

/// Time-of-day greeting using existing localized strings (EN / AR).
String getGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().toLocal().hour;
  if (hour < 12) {
    return l10n.ownerOverviewGreetingMorning;
  }
  if (hour < 17) {
    return l10n.ownerOverviewGreetingAfternoon;
  }
  return l10n.ownerOverviewGreetingEvening;
}

extension StringDisplayNameCapitalization on String {
  /// Title-cases each whitespace-separated segment, e.g. `"alice alnatour"` → `"Alice Alnatour"`.
  String toUpperCaseFirst() => formatTeamMemberName(this);
}
