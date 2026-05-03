import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/currency_for_country.dart';

String formatAppMoney(double amount, String currencyCode, Locale locale) {
  final code = resolvedSalonMoneyCurrency(
    salonCurrencyCode: currencyCode,
    salonCountryIso: null,
  );
  try {
    return NumberFormat.simpleCurrency(
      name: code,
      locale: locale.toString(),
    ).format(amount);
  } on Object {
    return '${amount.toStringAsFixed(0)} $code';
  }
}

/// Explicit `CODE 0.00` (e.g. `QAR 217.50`) using salon ISO code — avoids `$`
/// when the device locale maps simpleCurrency to USD symbols.
String formatSalonMoneyWithCode(
  double amount,
  String currencyCode,
  Locale locale,
) {
  final code = resolvedSalonMoneyCurrency(
    salonCurrencyCode: currencyCode,
    salonCountryIso: null,
  ).toUpperCase();
  try {
    final digits = NumberFormat.decimalPatternDigits(
      locale: locale.toString(),
      decimalDigits: 2,
    ).format(amount);
    return '$code $digits';
  } on Object {
    return '$code ${amount.toStringAsFixed(2)}';
  }
}

/// Salon-safe money string (QAR, SAR, AED, USD, …) — never hardcodes `\$`.
///
/// Pass [locale] from `Localizations.localeOf(context)` when available.
String formatMoney(num value, String currencyCode, [Locale? locale]) {
  return formatAppMoney(
    value.toDouble(),
    currencyCode,
    locale ?? const Locale('en'),
  );
}
