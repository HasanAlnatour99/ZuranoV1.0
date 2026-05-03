import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({
    super.key,
    required this.salonId,
    required this.userId,
  });

  final String salonId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (userId.trim().isEmpty) {
      return Scaffold(
        backgroundColor: ZuranoTokens.background,
        appBar: AppBar(
          backgroundColor: ZuranoTokens.surface,
          foregroundColor: ZuranoTokens.textDark,
          elevation: 0,
          title: Text(l10n.notificationsPreferencesTitle),
        ),
        body: Center(
          child: Text(
            l10n.genericError,
            style: const TextStyle(color: ZuranoTokens.textGray),
          ),
        ),
      );
    }
    final docPath = FirestorePaths.salonNotificationSetting(salonId, userId);
    final doc = FirebaseFirestore.instance.doc(docPath);

    return Scaffold(
      backgroundColor: ZuranoTokens.background,
      appBar: AppBar(
        backgroundColor: ZuranoTokens.surface,
        foregroundColor: ZuranoTokens.textDark,
        elevation: 0,
        title: Text(l10n.notificationsPreferencesTitle),
      ),
      body: Theme(
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
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: doc.snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? <String, dynamic>{};
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _SettingsCard(
                  children: [
                    _SettingTile(
                      label: l10n.notificationsSettingBookingUpdates,
                      value: data['booking'] != false,
                      onChanged: (value) => _save(doc, data, 'booking', value),
                    ),
                    const Divider(height: 1, color: ZuranoTokens.border),
                    _SettingTile(
                      label: l10n.notificationsSettingAttendanceUpdates,
                      value: data['attendance'] != false,
                      onChanged: (value) =>
                          _save(doc, data, 'attendance', value),
                    ),
                    const Divider(height: 1, color: ZuranoTokens.border),
                    _SettingTile(
                      label: l10n.notificationsSettingPayrollUpdates,
                      value: data['payroll'] != false,
                      onChanged: (value) => _save(doc, data, 'payroll', value),
                    ),
                    const Divider(height: 1, color: ZuranoTokens.border),
                    _SettingTile(
                      label: l10n.notificationsSettingApprovals,
                      value: data['approvals'] != false,
                      onChanged: (value) =>
                          _save(doc, data, 'approvals', value),
                    ),
                    const Divider(height: 1, color: ZuranoTokens.border),
                    _SettingTile(
                      label: l10n.notificationsSettingSystemAlerts,
                      value: data['system'] != false,
                      onChanged: (value) => _save(doc, data, 'system', value),
                    ),
                    const Divider(height: 1, color: ZuranoTokens.border),
                    _SettingTile(
                      label: l10n.notificationsPrefPushMaster,
                      value: data['pushEnabled'] != false,
                      onChanged: (value) =>
                          _save(doc, data, 'pushEnabled', value),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _save(
    DocumentReference<Map<String, dynamic>> doc,
    Map<String, dynamic> existing,
    String key,
    bool value,
  ) {
    return doc.set({
      ...existing,
      key: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.sectionShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(
          color: ZuranoTokens.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
