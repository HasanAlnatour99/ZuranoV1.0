import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/notification_settings_model.dart';
import 'notification_toggle_row.dart';

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final NotificationSettingsModel settings;
  final ValueChanged<NotificationSettingsModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.sectionShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return ZuranoTokens.primary;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return ZuranoTokens.lightPurple;
              }
              return ZuranoTokens.chipUnselected;
            }),
          ),
        ),
        child: Column(
          children: [
            NotificationToggleRow(
              label: l10n.notificationsSettingBookingUpdates,
              value: settings.bookingUpdates,
              onChanged: (v) =>
                  onChanged(settings.copyWith(bookingUpdates: v)),
            ),
            const Divider(height: 1, color: ZuranoTokens.border),
            NotificationToggleRow(
              label: l10n.notificationsSettingAttendanceUpdates,
              value: settings.attendanceUpdates,
              onChanged: (v) =>
                  onChanged(settings.copyWith(attendanceUpdates: v)),
            ),
            const Divider(height: 1, color: ZuranoTokens.border),
            NotificationToggleRow(
              label: l10n.notificationsSettingPayrollUpdates,
              value: settings.payrollUpdates,
              onChanged: (v) =>
                  onChanged(settings.copyWith(payrollUpdates: v)),
            ),
            const Divider(height: 1, color: ZuranoTokens.border),
            NotificationToggleRow(
              label: l10n.notificationsSettingApprovals,
              value: settings.approvalRequests,
              onChanged: (v) =>
                  onChanged(settings.copyWith(approvalRequests: v)),
            ),
            const Divider(height: 1, color: ZuranoTokens.border),
            NotificationToggleRow(
              label: l10n.notificationsSettingSystemAlerts,
              value: settings.systemAlerts,
              onChanged: (v) => onChanged(settings.copyWith(systemAlerts: v)),
            ),
            const Divider(height: 1, color: ZuranoTokens.border),
            NotificationToggleRow(
              label: l10n.notificationsPrefPushMaster,
              value: settings.pushNotifications,
              onChanged: (v) =>
                  onChanged(settings.copyWith(pushNotifications: v)),
            ),
          ],
        ),
      ),
    );
  }
}
