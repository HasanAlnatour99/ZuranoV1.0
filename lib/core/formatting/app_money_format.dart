import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/currency_for_country.dart';

String formatAppMoney(double amount, String currencyCode, Locale locale) {
  final code = resolvedSalonMoneyCurrency(
    salonCurrencyCode: currencyCode,
    salonCountryIso: null,
  );
  try {
    // Always show the ISO code (e.g. `202 QAR`, `202 SAR`) instead of
    // locale-specific currency names/symbols (e.g. "Riyal", "ر.س").
    final digits = amount % 1 == 0 ? 0 : 2;
    final formatted = NumberFormat.decimalPatternDigits(
      locale: locale.toString(),
      decimalDigits: digits,
    ).format(amount);
    return '$formatted ${code.toUpperCase()}';
  } on Object {
    final fixed = amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return '$fixed ${code.toUpperCase()}';
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
