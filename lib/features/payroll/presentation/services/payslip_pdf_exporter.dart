import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../salon/data/models/salon.dart';
import '../../data/models/payslip_model.dart';

/// Builds a simple payslip PDF from persisted [PayslipModel] (no recalculation).
Future<void> sharePayslipPdf({
  required PayslipModel payslip,
  required String salonDisplayName,
  required String subject,
}) async {
  final doc = pw.Document();
  final dateFmt = DateFormat.yMMMd();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                salonDisplayName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Employee: ${formatTeamMemberName(payslip.employeeName)}',
              ),
              pw.Text('Role: ${payslip.employeeRole}'),
              pw.Text(
                'Period: ${dateFmt.format(payslip.periodStart)} – ${dateFmt.format(payslip.periodEnd)}',
              ),
              pw.Text('Status: ${payslip.status}'),
              pw.SizedBox(height: 16),
              pw.Text(
                'Net pay: ${payslip.netPay.toStringAsFixed(2)} ${payslip.currency}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Earnings', style: const pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              ...payslip.lines
                  .where((l) => l.isEarning)
                  .map(
                    (l) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text(l.elementName)),
                          pw.Text(
                            '${l.amount.toStringAsFixed(2)} ${payslip.currency}',
                          ),
                        ],
                      ),
                    ),
                  ),
              pw.SizedBox(height: 12),
              pw.Text('Deductions', style: const pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              ...payslip.lines
                  .where((l) => !l.isEarning)
                  .map(
                    (l) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text(l.elementName)),
                          pw.Text(
                            '${l.amount.toStringAsFixed(2)} ${payslip.currency}',
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    ),
  );

  final bytes = await doc.save();
  await Printing.sharePdf(bytes: bytes, filename: '${payslip.id}.pdf');
}

/// Salon name for PDF header — pass from UI via [sessionSalonStreamProvider].
String defaultSalonNameForPdf(Salon? salon) =>
    (salon?.name ?? '').trim().isEmpty ? 'Salon' : salon!.name.trim();
