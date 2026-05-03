import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class MoneyFormatter {
  const MoneyFormatter._();

  static String format(
    BuildContext context,
    num amount, {
    required String currencyCode,
    String fallbackCurrencyCode = 'USD',
  }) {
    final safeAmount = amount.isFinite ? amount : 0;
    final locale = Localizations.localeOf(context).toString();
    final safeCode = currencyCode.trim().isEmpty
        ? fallbackCurrencyCode
        : currencyCode.trim().toUpperCase();
    final formatter = NumberFormat.currency(
      locale: locale,
      name: safeCode,
      decimalDigits: 2,
    );
    return formatter.format(safeAmount);
  }
}
