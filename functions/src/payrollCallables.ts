import { GoogleGenerativeAI } from "@google/generative-ai";
import {
  FieldValue,
  getFirestore,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

import {
  assertSalonOwnerOrAdmin,
  asNumber,
  dataOrEmpty,
  parseFirestoreTimestamp,
  payslipIdFor,
  prorateMonthlySalaryUtc,
} from "./payrollShared";

const db = getFirestore();

const CODES = {
  BASE_SALARY: "BASE_SALARY",
  SERVICE_COMMISSION: "SERVICE_COMMISSION",
  BONUS: "BONUS",
  LATE_PENALTY: "LATE_PENALTY",
  ABSENCE_DEDUCTION: "ABSENCE_DEDUCTION",
  MISSING_CHECKOUT_DEDUCTION: "MISSING_CHECKOUT_DEDUCTION",
  ADVANCE: "ADVANCE",
  MANUAL_EARNING: "MANUAL_EARNING",
  MANUAL_DEDUCTION: "MANUAL_DEDUCTION",
} as const;

const PAYROLL_PENDING = "pending_approval";
const PAYROLL_APPROVED = "approved";
const PAYROLL_PAID = "paid";

async function loadUser(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return dataOrEmpty(snap);
}

async function fetchViolationRules(salonId: string): Promise<Map<string, Record<string, unknown>>> {
  const snap = await db.collection(`salons/${salonId}/violation_rules`).get();
  const map = new Map<string, Record<string, unknown>>();
  snap.docs.forEach((d) => {
    const c = String(d.data().code ?? d.id).trim().toUpperCase();
    if (c) {
      map.set(c, d.data() as Record<string, unknown>);
    }
  });
  return map;
}

function ruleNumber(r: Record<string, unknown> | undefined, key: string, fallback: number): number {
  if (!r) {
    return fallback;
  }
  return asNumber(r[key], fallback);
}

export const generateMonthlyPayroll = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const year = Number(request.data?.year);
    const month = Number(request.data?.month);
    assertSalonOwnerOrAdmin(caller as never, salonId);
    if (!Number.isFinite(year) || !Number.isFinite(month) || month < 1 || month > 12) {
      throw new HttpsError("invalid-argument", "year and month required");
    }

    const start = DateTime.fromObject({ year, month, day: 1 }, { zone: "utc" }).startOf("day");
    const end = start.plus({ months: 1 });
    const periodStart = start.toJSDate();
    const periodEnd = end.minus({ days: 1 }).endOf("day").toJSDate();

    const settingsSnap = await db.doc(`salons/${salonId}/payroll_settings/main`).get();
    const settings = settingsSnap.exists ? (settingsSnap.data() as Record<string, unknown>) : {};
    const currency = String(settings.currency ?? "QAR").trim() || "QAR";
    const defaultRequiredDays = Math.max(1, asNumber(settings.defaultRequiredWorkDays, 26));
    const allowNegativeNetPay = settings.allowNegativeNetPay === true;

    const rules = await fetchViolationRules(salonId);
    const lateRule = rules.get("LATE");
    const absenceRule = rules.get("ABSENCE");
    const missingRule = rules.get("MISSING_CHECKOUT");

    const employeesSnap = await db.collection(`salons/${salonId}/employees`).get();

    for (const empDoc of employeesSnap.docs) {
      const emp = empDoc.data() as Record<string, unknown>;
      const employeeId = empDoc.id;
      if (emp.isActive === false) {
        continue;
      }
      if (emp.isPayrollEnabled === false) {
        continue;
      }

      const payslipId = payslipIdFor(employeeId, year, month);
      const payslipRef = db.doc(`salons/${salonId}/payslips/${payslipId}`);
      const existing = await payslipRef.get();
      const prev = existing.exists ? (existing.data() as Record<string, unknown>) : null;
      const prevStatus = String(prev?.status ?? "");
      if (prevStatus === PAYROLL_PAID || prevStatus === PAYROLL_APPROVED) {
        continue;
      }

      const monthlyContractBase = asNumber(emp.baseSalary, 0);
      const hireDateUtc = parseFirestoreTimestamp(emp.hiredAt);
      const salaryProration = prorateMonthlySalaryUtc({
        monthlyAmount: monthlyContractBase,
        hireDateUtc,
        year,
        month,
      });
      const baseSalaryApplied = salaryProration.appliedAmount;
      const commissionPercent = asNumber(emp.commissionPercentage ?? emp.commissionRate, 0);

      let serviceRevenue = 0;
      let servicesCount = 0;
      let last: QueryDocumentSnapshot | undefined;
      // eslint-disable-next-line no-constant-condition
      while (true) {
        let q = db
          .collection(`salons/${salonId}/sales`)
          .where("employeeId", "==", employeeId)
          .where("reportYear", "==", year)
          .where("reportMonth", "==", month)
          .where("status", "==", "completed")
          .limit(300);
        if (last) {
          q = q.startAfter(last);
        }
        const salesSnap = await q.get();
        if (salesSnap.empty) {
          break;
        }
        for (const s of salesSnap.docs) {
          const d = s.data() as Record<string, unknown>;
          serviceRevenue += asNumber(d.total ?? d.subtotal, 0);
          servicesCount += 1;
        }
        last = salesSnap.docs[salesSnap.docs.length - 1];
        if (salesSnap.size < 300) {
          break;
        }
      }

      const commissionAmount = (serviceRevenue * commissionPercent) / 100;

      const daysSnap = await db
        .collection(`salons/${salonId}/attendanceDays`)
        .where("salonId", "==", salonId)
        .where("employeeId", "==", employeeId)
        .where("date", ">=", periodStart)
        .where("date", "<", end.toJSDate())
        .get();

      let attendanceDaysPresent = 0;
      let lateCount = 0;
      let absenceCount = 0;
      let missingCheckoutCount = 0;
      for (const d of daysSnap.docs) {
        const day = d.data() as Record<string, unknown>;
        const worked = asNumber(day.workedMinutes, 0);
        const status = String(day.status ?? "");
        if (worked > 0 || status === "checkedOut" || status === "checkedIn") {
          attendanceDaysPresent += 1;
        }
        if (day.isLateAfterGrace === true) {
          lateCount += 1;
        }
        if (status === "absent") {
          absenceCount += 1;
        }
        if (day.hasMissingPunch === true) {
          missingCheckoutCount += 1;
        }
      }

      const attendanceRequiredDays = defaultRequiredDays;

      const dailySalary = monthlyContractBase / Math.max(1, attendanceRequiredDays);

      const lateActive = lateRule == null || lateRule.isActive !== false;
      const lateAllowed = Math.max(0, Math.floor(ruleNumber(lateRule, "monthlyAllowedCount", 2)));
      const lateChargeable = lateActive ? Math.max(0, lateCount - lateAllowed) : 0;
      const lateUnit = ruleNumber(lateRule, "deductionValue", 50);
      const latePenalty = lateChargeable * lateUnit;

      const absenceActive = absenceRule == null || absenceRule.isActive !== false;
      const absenceDeduction = absenceActive ? absenceCount * dailySalary * ruleNumber(absenceRule, "deductionValue", 1) : 0;

      const missingActive = missingRule == null || missingRule.isActive !== false;
      const missingDeduction = missingActive
        ? missingCheckoutCount * dailySalary * (ruleNumber(missingRule, "deductionValue", 5) / 100)
        : 0;

      const adjSnap = await db
        .collection(`salons/${salonId}/payroll_adjustments`)
        .where("employeeId", "==", employeeId)
        .where("year", "==", year)
        .where("month", "==", month)
        .where("status", "==", "approved")
        .get();

      let adjustmentEarnings = 0;
      let adjustmentDeductions = 0;
      const extraLines: Array<{
        id: string;
        code: string;
        name: string;
        type: "earning" | "deduction";
        amount: number;
        sourceType: string;
        order: number;
      }> = [];

      let order = 100;
      for (const a of adjSnap.docs) {
        const ad = a.data() as Record<string, unknown>;
        const typ = String(ad.type ?? "").toLowerCase();
        const amt = asNumber(ad.amount, 0);
        const code = String(ad.elementCode ?? "").toUpperCase();
        const title = String(ad.title ?? code);
        if (typ === "earning") {
          adjustmentEarnings += amt;
          extraLines.push({
            id: `adj_${a.id}`,
            code: code || CODES.MANUAL_EARNING,
            name: title,
            type: "earning",
            amount: amt,
            sourceType: "adjustment",
            order: order++,
          });
        } else if (typ === "deduction") {
          adjustmentDeductions += amt;
          extraLines.push({
            id: `adj_${a.id}`,
            code: code || CODES.MANUAL_DEDUCTION,
            name: title,
            type: "deduction",
            amount: amt,
            sourceType: "adjustment",
            order: order++,
          });
        }
      }

      const violationsSnap = await db
        .collection(`salons/${salonId}/violations`)
        .where("employeeId", "==", employeeId)
        .where("reportYear", "==", year)
        .where("reportMonth", "==", month)
        .where("status", "==", "approved")
        .get();
      let violationDeduction = 0;
      for (const v of violationsSnap.docs) {
        const vd = v.data() as Record<string, unknown>;
        violationDeduction += asNumber(vd.amount, 0);
      }

      const totalEarnings = baseSalaryApplied + commissionAmount + adjustmentEarnings;
      const totalDeductions =
        latePenalty +
        absenceDeduction +
        missingDeduction +
        adjustmentDeductions +
        violationDeduction;
      let netPay = totalEarnings - totalDeductions;
      if (!allowNegativeNetPay && netPay < 0) {
        netPay = 0;
      }

      const employeeName = String(emp.name ?? "").trim() || "Employee";
      const employeeRole = String(emp.role ?? "barber");
      const employeePhotoUrl = emp.avatarUrl ? String(emp.avatarUrl) : null;

      const batch = db.batch();
      const payslipPayload: Record<string, unknown> = {
        salonId,
        employeeId,
        employeeName,
        employeeRole,
        employeePhotoUrl,
        year,
        month,
        periodStart,
        periodEnd,
        currency,
        status: PAYROLL_PENDING,
        employeeVisible: false,
        baseSalary: baseSalaryApplied,
        baseSalaryNominal: monthlyContractBase,
        baseSalaryProrationRatio: salaryProration.ratio,
        serviceRevenue,
        commissionPercent,
        commissionAmount,
        totalEarnings,
        totalDeductions,
        netPay,
        servicesCount,
        attendanceDaysPresent,
        attendanceRequiredDays,
        lateCount,
        absenceCount,
        missingCheckoutCount,
        generatedBy: "system",
        generatedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (!existing.exists) {
        payslipPayload.createdAt = FieldValue.serverTimestamp();
      }
      batch.set(payslipRef, payslipPayload, { merge: true });

      const linesCol = payslipRef.collection("lines");
      const existingLines = await linesCol.get();
      existingLines.docs.forEach((d) => batch.delete(d.ref));

      const pushLine = (id: string, payload: Record<string, unknown>) => {
        batch.set(linesCol.doc(id), {
          salonId,
          payslipId,
          employeeId,
          createdAt: FieldValue.serverTimestamp(),
          ...payload,
        });
      };

      let lineOrder = 10;
      if (baseSalaryApplied > 0) {
        pushLine(`line_${CODES.BASE_SALARY}`, {
          elementCode: CODES.BASE_SALARY,
          elementName: "Base salary",
          type: "earning",
          amount: baseSalaryApplied,
          sourceType: "policy",
          sourceRef: null,
          displayOrder: lineOrder++,
        });
      }
      if (commissionAmount > 0) {
        pushLine(`line_${CODES.SERVICE_COMMISSION}`, {
          elementCode: CODES.SERVICE_COMMISSION,
          elementName: "Service commission",
          type: "earning",
          amount: commissionAmount,
          sourceType: "sales",
          sourceRef: null,
          displayOrder: lineOrder++,
        });
      }
      for (const ex of extraLines) {
        pushLine(ex.id, {
          elementCode: ex.code,
          elementName: ex.name,
          type: ex.type,
          amount: ex.amount,
          sourceType: ex.sourceType,
          sourceRef: null,
          displayOrder: ex.order,
        });
      }
      if (latePenalty > 0) {
        pushLine(`line_${CODES.LATE_PENALTY}`, {
          elementCode: CODES.LATE_PENALTY,
          elementName: "Late penalty",
          type: "deduction",
          amount: latePenalty,
          sourceType: "attendance",
          sourceRef: null,
          displayOrder: 40,
        });
      }
      if (absenceDeduction > 0) {
        pushLine(`line_${CODES.ABSENCE_DEDUCTION}`, {
          elementCode: CODES.ABSENCE_DEDUCTION,
          elementName: "Absence deduction",
          type: "deduction",
          amount: absenceDeduction,
          sourceType: "attendance",
          sourceRef: null,
          displayOrder: 50,
        });
      }
      if (missingDeduction > 0) {
        pushLine(`line_${CODES.MISSING_CHECKOUT_DEDUCTION}`, {
          elementCode: CODES.MISSING_CHECKOUT_DEDUCTION,
          elementName: "Missing checkout",
          type: "deduction",
          amount: missingDeduction,
          sourceType: "attendance",
          sourceRef: null,
          displayOrder: 55,
        });
      }
      if (violationDeduction > 0) {
        pushLine("line_VIOLATIONS", {
          elementCode: "VIOLATION_TOTAL",
          elementName: "HR violations",
          type: "deduction",
          amount: violationDeduction,
          sourceType: "violation",
          sourceRef: null,
          displayOrder: 70,
        });
      }

      await batch.commit();
    }

    return { success: true, salonId, year, month };
  },
);

export const approvePayslip = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const payslipId = String(request.data?.payslipId ?? "").trim();
    assertSalonOwnerOrAdmin(caller as never, salonId);
    if (!payslipId) {
      throw new HttpsError("invalid-argument", "payslipId required");
    }
    const ref = db.doc(`salons/${salonId}/payslips/${payslipId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Payslip not found");
    }
    const data = snap.data() as Record<string, unknown>;
    if (String(data.status) === PAYROLL_PAID) {
      throw new HttpsError("failed-precondition", "Paid payslip cannot change");
    }
    await ref.set(
      {
        status: PAYROLL_APPROVED,
        employeeVisible: true,
        approvedBy: request.auth.uid,
        approvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { success: true };
  },
);

export const markPayslipPaid = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const payslipId = String(request.data?.payslipId ?? "").trim();
    assertSalonOwnerOrAdmin(caller as never, salonId);
    if (!payslipId) {
      throw new HttpsError("invalid-argument", "payslipId required");
    }
    const ref = db.doc(`salons/${salonId}/payslips/${payslipId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Payslip not found");
    }
    const cur = snap.data() as Record<string, unknown>;
    if (String(cur.status) !== PAYROLL_APPROVED) {
      throw new HttpsError("failed-precondition", "Approve payslip before marking paid");
    }
    await ref.set(
      {
        status: PAYROLL_PAID,
        employeeVisible: true,
        paidBy: request.auth.uid,
        paidAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { success: true };
  },
);

export const generatePayslipSummary = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const payslipId = String(request.data?.payslipId ?? "").trim();
    assertSalonOwnerOrAdmin(caller as never, salonId);
    if (!payslipId) {
      throw new HttpsError("invalid-argument", "payslipId required");
    }
    const ref = db.doc(`salons/${salonId}/payslips/${payslipId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Payslip not found");
    }
    const p = snap.data() as Record<string, unknown>;
    const linesSnap = await ref.collection("lines").orderBy("displayOrder").get();
    const deductions = linesSnap.docs
      .filter((d) => String(d.data().type) === "deduction")
      .map((d) => ({
        name: String(d.data().elementName ?? ""),
        amount: asNumber(d.data().amount, 0),
      }));

    const monthLabel = DateTime.fromObject({
      year: asNumber(p.year, 0),
      month: asNumber(p.month, 1),
      day: 1,
    }).toFormat("LLLL yyyy");

    const payload = {
      month: monthLabel,
      currency: String(p.currency ?? "QAR"),
      netPay: asNumber(p.netPay, 0),
      totalEarnings: asNumber(p.totalEarnings, 0),
      totalDeductions: asNumber(p.totalDeductions, 0),
      servicesCount: asNumber(p.servicesCount, 0),
      attendanceDaysPresent: asNumber(p.attendanceDaysPresent, 0),
      requiredDays: asNumber(p.attendanceRequiredDays, 0),
      deductions,
    };

    const apiKey = process.env.GEMINI_API_KEY ?? "";
    let summary = `Net salary for ${monthLabel} is ${String(p.currency)} ${asNumber(p.netPay, 0).toFixed(2)}.`;
    const highlights: string[] = [];
    const warnings: string[] = [];

    highlights.push(`Services recorded: ${payload.servicesCount}.`);
    highlights.push(
      `Attendance: ${payload.attendanceDaysPresent} / ${payload.requiredDays} days.`,
    );

    for (const d of deductions) {
      if (d.amount > 0 && d.name.toLowerCase().includes("late")) {
        warnings.push(`${d.name} reduced pay by ${String(p.currency)} ${d.amount.toFixed(2)}.`);
      }
    }

    if (apiKey) {
      try {
        const gen = new GoogleGenerativeAI(apiKey).getGenerativeModel({
          model: "gemini-2.0-flash",
        });
        const prompt = `You are an HR assistant. Given JSON payroll facts, return ONLY valid JSON with keys summary (string), highlights (string array), warnings (string array). No markdown. Facts: ${JSON.stringify(payload)}`;
        const result = await gen.generateContent(prompt);
        const text = result.response.text().trim();
        const jsonStart = text.indexOf("{");
        const jsonEnd = text.lastIndexOf("}");
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          const parsed = JSON.parse(text.slice(jsonStart, jsonEnd + 1)) as {
            summary?: string;
            highlights?: string[];
            warnings?: string[];
          };
          if (parsed.summary) {
            summary = parsed.summary;
          }
          if (Array.isArray(parsed.highlights) && parsed.highlights.length) {
            highlights.splice(0, highlights.length, ...parsed.highlights);
          }
          if (Array.isArray(parsed.warnings)) {
            warnings.splice(0, warnings.length, ...parsed.warnings);
          }
        }
      } catch {
        // deterministic fallback kept
      }
    }

    const employeeId = String(p.employeeId ?? "");
    await db.doc(`salons/${salonId}/payslips/${payslipId}/aiAnalysis/main`).set(
      {
        salonId,
        payslipId,
        employeeId,
        summary,
        highlights,
        warnings,
        generatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { success: true };
  },
);
