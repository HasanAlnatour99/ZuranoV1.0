/// Maps to Cloud Functions `exportType` for CSV exports (`requestReportExport`).
enum ReportCsvExportKind {
  sales,
  payroll,
  attendance,
  expenses,
  audit,
}

extension ReportCsvExportKindX on ReportCsvExportKind {
  String get wireValue {
    switch (this) {
      case ReportCsvExportKind.sales:
        return 'sales';
      case ReportCsvExportKind.payroll:
        return 'payroll';
      case ReportCsvExportKind.attendance:
        return 'attendance';
      case ReportCsvExportKind.expenses:
        return 'expenses';
      case ReportCsvExportKind.audit:
        return 'audit';
    }
  }
}

ReportCsvExportKind? parseReportCsvExportKind(String? raw) {
  switch (raw?.trim()) {
    case 'sales':
      return ReportCsvExportKind.sales;
    case 'payroll':
      return ReportCsvExportKind.payroll;
    case 'attendance':
      return ReportCsvExportKind.attendance;
    case 'expenses':
      return ReportCsvExportKind.expenses;
    case 'audit':
      return ReportCsvExportKind.audit;
    default:
      return null;
  }
}
