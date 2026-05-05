import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Aggregated Firestore fields for the employee “Today” premium hero header.
class EmployeeHeaderModel {
  const EmployeeHeaderModel({
    required this.employeeId,
    required this.name,
    required this.salonName,
    this.tier,
    this.photoUrl,
    this.shiftStartTime,
    this.shiftNameEn,
    this.shiftNameAr,
    required this.headerAt,
  });

  final String employeeId;
  final String name;
  final String salonName;

  /// Optional HR tier (e.g. Golden). When null/empty, UI shows [salonName] in the tier pill.
  final String? tier;
  final String? photoUrl;
  final String? shiftStartTime;
  final String? shiftNameEn;
  final String? shiftNameAr;
  final DateTime headerAt;

  bool get hasShiftDetails =>
      (shiftStartTime?.trim().isNotEmpty ?? false) ||
      (shiftNameEn?.trim().isNotEmpty ?? false) ||
      (shiftNameAr?.trim().isNotEmpty ?? false);
}

/// Localized single-line label for the shift chip (supports Arabic shift names).
String formatEmployeeHeaderShiftLine({
  required EmployeeHeaderModel model,
  required AppLocalizations l10n,
  required Locale locale,
}) {
  if (!model.hasShiftDetails) {
    return l10n.employeeHeroShiftNone;
  }
  final isAr = locale.languageCode.toLowerCase().startsWith('ar');
  final name = isAr
      ? (model.shiftNameAr?.trim().isNotEmpty == true
            ? model.shiftNameAr!.trim()
            : model.shiftNameEn?.trim() ?? '')
      : (model.shiftNameEn?.trim().isNotEmpty == true
            ? model.shiftNameEn!.trim()
            : model.shiftNameAr?.trim() ?? '');
  final time = model.shiftStartTime?.trim() ?? '';
  final prefix = l10n.employeeTodayShiftLabel;
  if (time.isEmpty && name.isEmpty) {
    return l10n.employeeHeroShiftNone;
  }
  if (time.isEmpty) {
    return '$prefix • $name';
  }
  if (name.isEmpty) {
    return '$prefix: $time';
  }
  return '$prefix: $time • $name';
}
