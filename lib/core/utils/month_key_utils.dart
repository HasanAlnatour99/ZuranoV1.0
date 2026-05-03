class MonthKeyUtils {
  const MonthKeyUtils._();

  static String fromDate(DateTime date) {
    final safe = DateTime(date.year, date.month, 1);
    final month = safe.month.toString().padLeft(2, '0');
    return '${safe.year}-$month';
  }

  static DateTime monthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime nextMonthStart(DateTime date) =>
      DateTime(date.year, date.month + 1, 1);
}
