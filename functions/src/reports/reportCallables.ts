import {
  FieldValue,
  getFirestore,
  Timestamp,
  type DocumentReference,
} from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { PDFDocument, StandardFonts, rgb } from "pdf-lib";

import {
  assertCanDownloadExportJob,
  assertEmployeeOwnPayslip,
  assertExportTypeAllowed,
  assertPayslipFinanceAccess,
  loadStaffPermissionsRow,
  maySalonPermissionKey,
  type ExportType,
  type FireUser,
} from "./exportPermissions";
import { formatTimestampForCsv, toCsvDocument } from "./csvBuilder";
import { payslipIdFor } from "../payrollShared";

const db = getFirestore();

const COL_EXPORT_JOBS = "exportJobs";
const REGION = "us-central1";

async function loadUser(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return snap.data() ?? {};
}

function userDisplayName(u: Record<string, unknown>): string {
  return String(u.name ?? u.email ?? "").trim() || "User";
}

function parsePeriodYm(periodId: string): { year: number; month: number } | null {
  const m = /^(\d{4})-(\d{2})$/.exec(periodId.trim());
  if (!m) return null;
  const year = Number(m[1]);
  const month = Number(m[2]);
  if (!Number.isFinite(year) || month < 1 || month > 12) return null;
  return { year, month };
}

function parseIsoDay(s: string): Date | null {
  const d = new Date(s.trim());
  if (Number.isNaN(d.getTime())) return null;
  return d;
}

function startEndUtcFromPeriod(periodId: string): { start: Date; end: Date } | null {
  const ym = parsePeriodYm(periodId);
  if (!ym) return null;
  const start = new Date(Date.UTC(ym.year, ym.month - 1, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(ym.year, ym.month, 0, 23, 59, 59, 999));
  return { start, end };
}

function msDays(a: Date, b: Date): number {
  return Math.abs(a.getTime() - b.getTime()) / (24 * 60 * 60 * 1000);
}

async function writeJobFailed(jobRef: DocumentReference, code: string): Promise<void> {
  await jobRef.update({
    status: "failed",
    errorCode: code,
    failedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

export const requestReportExport = onCall(
  { region: REGION, enforceAppCheck: true, timeoutSeconds: 300, memory: "512MiB" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const uid = request.auth.uid;
    const salonId = String(request.data?.salonId ?? "").trim();
    const exportType = String(request.data?.exportType ?? "").trim() as ExportType;
    const format = String(request.data?.format ?? "csv").trim();
    const periodId = request.data?.periodId != null ? String(request.data.periodId).trim() : "";
    const dateFromRaw = request.data?.dateFrom != null ? String(request.data.dateFrom).trim() : "";
    const dateToRaw = request.data?.dateTo != null ? String(request.data.dateTo).trim() : "";

    if (!salonId) {
      throw new HttpsError("invalid-argument", "salonId required.");
    }
    if (!["sales", "payroll", "attendance", "expenses", "audit"].includes(exportType)) {
      throw new HttpsError("invalid-argument", "Invalid exportType.");
    }
    if (format !== "csv") {
      throw new HttpsError("invalid-argument", "Only csv format is supported.");
    }

    const user = (await loadUser(uid)) as FireUser;
    const staff = await loadStaffPermissionsRow(db, salonId, uid);
    assertExportTypeAllowed(user, salonId, exportType, staff);

    let rangeStart: Date;
    let rangeEnd: Date;
    let periodLabel: string;

    if (periodId.length > 0) {
      const se = startEndUtcFromPeriod(periodId);
      if (!se) {
        throw new HttpsError("invalid-argument", "periodId must be YYYY-MM.");
      }
      rangeStart = se.start;
      rangeEnd = se.end;
      periodLabel = periodId;
    } else if (dateFromRaw && dateToRaw) {
      const a = parseIsoDay(dateFromRaw);
      const b = parseIsoDay(dateToRaw);
      if (!a || !b) {
        throw new HttpsError("invalid-argument", "Invalid dateFrom/dateTo.");
      }
      rangeStart = new Date(a.getFullYear(), a.getMonth(), a.getDate(), 0, 0, 0, 0);
      rangeEnd = new Date(b.getFullYear(), b.getMonth(), b.getDate(), 23, 59, 59, 999);
      if (rangeStart > rangeEnd) {
        throw new HttpsError("invalid-argument", "dateFrom must be before dateTo.");
      }
      if (msDays(rangeStart, rangeEnd) > 400) {
        throw new HttpsError("invalid-argument", "Date range too large (max ~13 months).");
      }
      periodLabel = `${dateFromRaw}_${dateToRaw}`;
    } else {
      throw new HttpsError("invalid-argument", "Provide periodId or dateFrom and dateTo.");
    }

    const jobsCol = db.collection(`salons/${salonId}/${COL_EXPORT_JOBS}`);
    const jobRef = jobsCol.doc();
    const jobId = jobRef.id;
    const timestamp = Date.now();
    const baseFileName = `${exportType}_${periodLabel}_${jobId}.csv`;
    const storagePath = `exports/${salonId}/${periodLabel}/${exportType}_${timestamp}.csv`;

    await jobRef.set({
      salonId,
      exportType,
      format: "csv",
      periodId: periodId || null,
      dateFrom: Timestamp.fromDate(rangeStart),
      dateTo: Timestamp.fromDate(rangeEnd),
      employeeId: null,
      status: "processing",
      fileName: baseFileName,
      storagePath,
      downloadUrl: null,
      requestedBy: uid,
      requestedByName: userDisplayName(user as Record<string, unknown>),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      completedAt: null,
      failedAt: null,
      errorCode: null,
    });

    try {
      let csv = "";
      if (exportType === "sales") {
        csv = await buildSalesCsv(salonId, rangeStart, rangeEnd);
      } else if (exportType === "payroll") {
        csv = await buildPayrollCsv(salonId, rangeStart, rangeEnd);
      } else if (exportType === "attendance") {
        csv = await buildAttendanceCsv(salonId, rangeStart, rangeEnd);
      } else if (exportType === "expenses") {
        csv = await buildExpensesCsv(salonId, rangeStart, rangeEnd);
      } else {
        csv = await buildAuditCsv(salonId, rangeStart, rangeEnd);
      }

      const bucket = getStorage().bucket();
      await bucket.file(storagePath).save(Buffer.from(csv, "utf8"), {
        contentType: "text/csv",
        resumable: false,
      });

      await jobRef.update({
        status: "completed",
        completedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      return { jobId, status: "completed", storagePath };
    } catch (e) {
      const code = e instanceof Error ? e.message.slice(0, 120) : "internal";
      await writeJobFailed(jobRef, code);
      throw new HttpsError("internal", "Export failed.");
    }
  },
);

async function buildSalesCsv(salonId: string, start: Date, end: Date): Promise<string> {
  const header = [
    "id",
    "soldAt",
    "employeeId",
    "employeeName",
    "customerId",
    "total",
    "status",
    "paymentMethod",
    "reportPeriodKey",
  ];
  const rows: unknown[][] = [];
  const snap = await db
    .collection(`salons/${salonId}/sales`)
    .where("soldAt", ">=", Timestamp.fromDate(start))
    .where("soldAt", "<=", Timestamp.fromDate(end))
    .orderBy("soldAt", "desc")
    .limit(5000)
    .get();

  for (const doc of snap.docs) {
    const d = doc.data();
    rows.push([
      doc.id,
      formatTimestampForCsv(d.soldAt),
      d.employeeId ?? "",
      d.employeeName ?? "",
      d.customerId ?? "",
      d.total ?? "",
      d.status ?? "",
      d.paymentMethod ?? "",
      d.reportPeriodKey ?? "",
    ]);
  }
  return toCsvDocument(header, rows);
}

async function buildPayrollCsv(salonId: string, start: Date, end: Date): Promise<string> {
  const header = [
    "payslipId",
    "employeeId",
    "employeeName",
    "year",
    "month",
    "currency",
    "status",
    "netPay",
    "totalEarnings",
    "totalDeductions",
    "periodStart",
    "periodEnd",
  ];
  const rows: unknown[][] = [];

  const snap = await db
    .collection(`salons/${salonId}/payslips`)
    .where("periodStart", ">=", Timestamp.fromDate(start))
    .where("periodStart", "<=", Timestamp.fromDate(end))
    .limit(5000)
    .get();

  for (const doc of snap.docs) {
    const d = doc.data();
    rows.push([
      doc.id,
      d.employeeId ?? "",
      d.employeeName ?? "",
      d.year ?? "",
      d.month ?? "",
      d.currency ?? "",
      d.status ?? "",
      d.netPay ?? "",
      d.totalEarnings ?? "",
      d.totalDeductions ?? "",
      formatTimestampForCsv(d.periodStart),
      formatTimestampForCsv(d.periodEnd),
    ]);
  }
  return toCsvDocument(header, rows);
}

async function buildAttendanceCsv(salonId: string, start: Date, end: Date): Promise<string> {
  const header = [
    "id",
    "workDate",
    "employeeId",
    "employeeName",
    "status",
    "checkInAt",
    "checkOutAt",
    "approvalStatus",
  ];
  const rows: unknown[][] = [];
  const snap = await db
    .collection(`salons/${salonId}/attendance`)
    .where("workDate", ">=", Timestamp.fromDate(start))
    .where("workDate", "<=", Timestamp.fromDate(end))
    .limit(5000)
    .get();

  for (const doc of snap.docs) {
    const d = doc.data();
    rows.push([
      doc.id,
      formatTimestampForCsv(d.workDate),
      d.employeeId ?? "",
      d.employeeName ?? "",
      d.status ?? "",
      formatTimestampForCsv(d.checkInAt),
      formatTimestampForCsv(d.checkOutAt),
      d.approvalStatus ?? "",
    ]);
  }
  return toCsvDocument(header, rows);
}

async function buildExpensesCsv(salonId: string, start: Date, end: Date): Promise<string> {
  const header = [
    "id",
    "title",
    "category",
    "amount",
    "incurredAt",
    "vendorName",
    "createdByName",
    "reportPeriodKey",
  ];
  const rows: unknown[][] = [];
  const snap = await db
    .collection(`salons/${salonId}/expenses`)
    .where("incurredAt", ">=", Timestamp.fromDate(start))
    .where("incurredAt", "<=", Timestamp.fromDate(end))
    .limit(5000)
    .get();

  for (const doc of snap.docs) {
    const d = doc.data();
    rows.push([
      doc.id,
      d.title ?? "",
      d.category ?? "",
      d.amount ?? "",
      formatTimestampForCsv(d.incurredAt),
      d.vendorName ?? "",
      d.createdByName ?? "",
      d.reportPeriodKey ?? "",
    ]);
  }
  return toCsvDocument(header, rows);
}

function shrinkJson(v: unknown, max = 400): string {
  try {
    const s = JSON.stringify(v ?? {});
    return s.length > max ? `${s.slice(0, max)}…` : s;
  } catch {
    return "";
  }
}

async function buildAuditCsv(salonId: string, start: Date, end: Date): Promise<string> {
  const header = [
    "id",
    "createdAt",
    "actionType",
    "module",
    "actorName",
    "actorRole",
    "summary",
    "targetLabel",
    "beforeJson",
    "afterJson",
  ];
  const rows: unknown[][] = [];
  const snap = await db
    .collection(`salons/${salonId}/auditLogs`)
    .where("createdAt", ">=", Timestamp.fromDate(start))
    .where("createdAt", "<=", Timestamp.fromDate(end))
    .orderBy("createdAt", "desc")
    .limit(3000)
    .get();

  for (const doc of snap.docs) {
    const d = doc.data();
    rows.push([
      doc.id,
      formatTimestampForCsv(d.createdAt),
      d.actionType ?? "",
      d.module ?? "",
      d.actorName ?? "",
      d.actorRole ?? "",
      d.summary ?? "",
      d.targetLabel ?? "",
      shrinkJson(d.before),
      shrinkJson(d.after),
    ]);
  }
  return toCsvDocument(header, rows);
}

export const generatePayslipPdf = onCall(
  { region: REGION, enforceAppCheck: true, timeoutSeconds: 120, memory: "512MiB" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const uid = request.auth.uid;
    const salonId = String(request.data?.salonId ?? "").trim();
    const periodId = String(request.data?.periodId ?? "").trim();
    const employeeId = String(request.data?.employeeId ?? "").trim();

    if (!salonId || !periodId || !employeeId) {
      throw new HttpsError("invalid-argument", "salonId, periodId, employeeId required.");
    }

    const ym = parsePeriodYm(periodId);
    if (!ym) {
      throw new HttpsError("invalid-argument", "periodId must be YYYY-MM.");
    }

    const user = (await loadUser(uid)) as FireUser;
    const staff = await loadStaffPermissionsRow(db, salonId, uid);

    const canFinance =
      String(user.role ?? "").trim() === "owner" ||
      maySalonPermissionKey(user, salonId, "payroll.view", staff) ||
      maySalonPermissionKey(user, salonId, "payroll.manage", staff);

    if (canFinance) {
      assertPayslipFinanceAccess(user, salonId, staff);
    } else {
      assertEmployeeOwnPayslip(user, salonId, employeeId);
    }

    const slipId = payslipIdFor(employeeId, ym.year, ym.month);
    const slipRef = db.doc(`salons/${salonId}/payslips/${slipId}`);
    const slipSnap = await slipRef.get();
    if (!slipSnap.exists) {
      throw new HttpsError("not-found", "Payslip not found.");
    }
    const p = slipSnap.data() ?? {};

    const linesSnap = await slipRef.collection("lines").orderBy("displayOrder").get();
    const lineRows: { label: string; amount: string }[] = [];
    for (const ln of linesSnap.docs) {
      const l = ln.data();
      lineRows.push({
        label: String(l.elementName ?? l.elementCode ?? ln.id),
        amount: String(l.amount ?? ""),
      });
    }

    const pdfBytes = await buildPayslipPdfBuffer({
      salonName: String((await db.doc(`salons/${salonId}`).get()).data()?.name ?? "Salon"),
      employeeName: String(p.employeeName ?? ""),
      periodLabel: periodId,
      currency: String(p.currency ?? ""),
      status: String(p.status ?? ""),
      baseSalary: String(p.baseSalary ?? ""),
      commissionAmount: String(p.commissionAmount ?? ""),
      totalEarnings: String(p.totalEarnings ?? ""),
      totalDeductions: String(p.totalDeductions ?? ""),
      netPay: String(p.netPay ?? ""),
      lines: lineRows,
    });

    const timestamp = Date.now();
    const storagePath = `exports/${salonId}/${periodId}/payslips/${employeeId}_${periodId}_${timestamp}.pdf`;
    const bucket = getStorage().bucket();
    await bucket.file(storagePath).save(Buffer.from(pdfBytes), {
      contentType: "application/pdf",
      resumable: false,
    });

    const jobsCol = db.collection(`salons/${salonId}/${COL_EXPORT_JOBS}`);
    const jobRef = jobsCol.doc();
    const jobId = jobRef.id;
    const fileName = `payslip_${employeeId}_${periodId}.pdf`;

    await jobRef.set({
      salonId,
      exportType: "payslip",
      format: "pdf",
      periodId,
      dateFrom: null,
      dateTo: null,
      employeeId,
      status: "completed",
      fileName,
      storagePath,
      downloadUrl: null,
      requestedBy: uid,
      requestedByName: userDisplayName(user as Record<string, unknown>),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      completedAt: FieldValue.serverTimestamp(),
      failedAt: null,
      errorCode: null,
    });

    return { jobId, status: "completed", storagePath };
  },
);

async function buildPayslipPdfBuffer(params: {
  salonName: string;
  employeeName: string;
  periodLabel: string;
  currency: string;
  status: string;
  baseSalary: string;
  commissionAmount: string;
  totalEarnings: string;
  totalDeductions: string;
  netPay: string;
  lines: { label: string; amount: string }[];
}): Promise<Uint8Array> {
  const pdf = await PDFDocument.create();
  let page = pdf.addPage([595.28, 841.89]);
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  let y = 780;

  const line = (text: string, size = 11, useBold = false) => {
    if (y < 72) {
      page = pdf.addPage([595.28, 841.89]);
      y = 780;
    }
    page.drawText(text, {
      x: 50,
      y,
      size,
      font: useBold ? bold : font,
      color: rgb(0.1, 0.12, 0.12),
    });
    y -= size + 5;
  };

  line("Payslip", 18, true);
  line(params.salonName, 14, true);
  line(`Employee: ${params.employeeName}`);
  line(`Period: ${params.periodLabel}`);
  line(`Status: ${params.status}`);
  line(`Currency: ${params.currency}`);
  line("");
  line(`Base salary: ${params.baseSalary}`);
  line(`Commission: ${params.commissionAmount}`);
  line(`Total earnings: ${params.totalEarnings}`);
  line(`Total deductions: ${params.totalDeductions}`);
  line(`Net pay: ${params.netPay}`, 13, true);
  line("");
  line("Lines", 12, true);
  for (const row of params.lines.slice(0, 40)) {
    line(`${row.label}: ${row.amount}`);
  }

  return pdf.save();
}

export const getExportDownloadUrl = onCall(
  { region: REGION, enforceAppCheck: true, timeoutSeconds: 60 },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const uid = request.auth.uid;
    const salonId = String(request.data?.salonId ?? "").trim();
    const exportJobId = String(request.data?.exportJobId ?? "").trim();
    if (!salonId || !exportJobId) {
      throw new HttpsError("invalid-argument", "salonId and exportJobId required.");
    }

    const user = (await loadUser(uid)) as FireUser;
    const staff = await loadStaffPermissionsRow(db, salonId, uid);

    const jobRef = db.doc(`salons/${salonId}/${COL_EXPORT_JOBS}/${exportJobId}`);
    const jobSnap = await jobRef.get();
    if (!jobSnap.exists) {
      throw new HttpsError("not-found", "Export job not found.");
    }
    const job = jobSnap.data() ?? {};
    if (String(job.status) !== "completed") {
      throw new HttpsError("failed-precondition", "Export not ready.");
    }
    const path = String(job.storagePath ?? "").trim();
    if (!path) {
      throw new HttpsError("failed-precondition", "Missing storage path.");
    }

    assertCanDownloadExportJob(user, salonId, job as Record<string, unknown>, staff);

    const bucket = getStorage().bucket();
    const [url] = await bucket.file(path).getSignedUrl({
      action: "read",
      expires: Date.now() + 15 * 60 * 1000,
    });

    return { downloadUrl: url, storagePath: path, fileName: String(job.fileName ?? "") };
  },
);
