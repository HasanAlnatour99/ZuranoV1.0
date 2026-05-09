import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

import { auditActorProfile, writeAuditLog, writeAuditLogInTransaction } from "../audit/auditLogger";
import { dataOrEmpty } from "../payrollShared";
import {
  assertSalonPermissionKey,
  loadStaffPermissionsRow,
  type FireUser,
} from "../reports/exportPermissions";

const db = getFirestore();

const REGION = "us-central1" as const;

const ViolationStatuses = {
  pending: "pending",
  approved: "approved",
  rejected: "rejected",
  applied: "applied",
} as const;

const AttendanceViolationTypes = {
  absence: "attendance_absence",
  missingPunch: "attendance_missing_punch",
  breakExceeded: "attendance_break_limit_exceeded",
} as const;

type AttendanceSettings = {
  autoCreateViolations: boolean;
  maxBreakMinutesPerDay: number;
  absenceDeductionPercent: number;
  missingCheckoutDeductionPercent: number;
  earlyExitDeductionPercent: number;
  requireOwnerApprovalBeforePayroll: boolean;
};

function asNumber(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

function monthKeyFromPeriodId(periodId: string): { year: number; month: number; monthKey: string } {
  const trimmed = String(periodId ?? "").trim();
  const m = /^(\d{4})-(\d{2})$/.exec(trimmed);
  if (!m) {
    throw new HttpsError("invalid-argument", "periodId must be YYYY-MM");
  }
  const year = Number(m[1]);
  const month = Number(m[2]);
  if (!Number.isFinite(year) || !Number.isFinite(month) || month < 1 || month > 12) {
    throw new HttpsError("invalid-argument", "periodId must be YYYY-MM");
  }
  return { year, month, monthKey: `${m[1]}-${m[2]}` };
}

function parseSettings(raw: Record<string, unknown> | undefined): AttendanceSettings {
  return {
    autoCreateViolations: raw?.autoCreateViolations !== false,
    maxBreakMinutesPerDay: Math.max(0, Math.floor(asNumber(raw?.maxBreakMinutesPerDay, 15))),
    absenceDeductionPercent: Math.max(0, asNumber(raw?.absenceDeductionPercent, 100)),
    missingCheckoutDeductionPercent: Math.max(0, asNumber(raw?.missingCheckoutDeductionPercent, 5)),
    earlyExitDeductionPercent: Math.max(0, asNumber(raw?.earlyExitDeductionPercent, 5)),
    requireOwnerApprovalBeforePayroll: raw?.requireOwnerApprovalBeforePayroll === true,
  };
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

async function loadUser(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return dataOrEmpty(snap);
}

async function assertAttendancePermission(
  uid: string,
  caller: Record<string, unknown>,
  salonId: string,
): Promise<void> {
  const staff = await loadStaffPermissionsRow(db, salonId, uid);
  assertSalonPermissionKey(caller as FireUser, salonId, "attendance.manage", staff);
}

async function assertPayrollPermission(uid: string, caller: Record<string, unknown>, salonId: string): Promise<void> {
  const staff = await loadStaffPermissionsRow(db, salonId, uid);
  assertSalonPermissionKey(caller as FireUser, salonId, "payroll.manage", staff);
}

function violationIdFor(employeeId: string, compactDate: string, violationType: string): string {
  return `${employeeId}_${compactDate}_${violationType}`;
}

/**
 * Creates/updates a violation document only (no payroll adjustment here).
 * We use violations as the approval gate; posting creates `payroll_adjustments`.
 */
async function upsertViolationDraft(input: {
  salonId: string;
  employeeId: string;
  employeeName: string;
  compactDate: string; // yyyyMMdd (matches attendanceDays.dateKey)
  violationType: string;
  deductionAmount: number;
  percent: number;
  notes: string;
  autoApprove: boolean;
}): Promise<void> {
  const { year, month, monthKey } = {
    year: Number(input.compactDate.slice(0, 4)),
    month: Number(input.compactDate.slice(4, 6)),
    monthKey: `${input.compactDate.slice(0, 4)}-${input.compactDate.slice(4, 6)}`,
  };

  const occurredAt = Timestamp.fromDate(new Date(year, month - 1, Number(input.compactDate.slice(6, 8)), 12, 0, 0));
  const id = violationIdFor(input.employeeId, input.compactDate, input.violationType);
  const ref = db.doc(`salons/${input.salonId}/violations/${id}`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const existing = snap.exists ? (snap.data() as Record<string, unknown>) : null;
    const existingStatus = String(existing?.status ?? "");
    if (existingStatus === ViolationStatuses.applied) {
      return;
    }
    const nextStatus = input.autoApprove ? ViolationStatuses.approved : ViolationStatuses.pending;

    tx.set(
      ref,
      {
        id,
        salonId: input.salonId,
        employeeId: input.employeeId,
        employeeName: input.employeeName || null,
        sourceType: "attendance",
        violationType: input.violationType,
        status: nextStatus,
        occurredAt,
        reportYear: year,
        reportMonth: month,
        reportPeriodKey: monthKey,
        amount: roundMoney(input.deductionAmount),
        percent: input.percent,
        notes: input.notes,
        ...(input.autoApprove ? { approvedAt: FieldValue.serverTimestamp(), approvedByUid: "system" } : {}),
        createdByUid: "system:attendance",
        createdByRole: "system",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
}

export const calculateAttendanceViolationsForPeriod = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const periodId = String(request.data?.periodId ?? "").trim();
    await assertAttendancePermission(request.auth.uid, caller, salonId);

    const { year, month, monthKey } = monthKeyFromPeriodId(periodId);
    const start = DateTime.fromObject({ year, month, day: 1 }, { zone: "utc" }).startOf("day");
    const end = start.plus({ months: 1 });

    const settingsSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
    const settings = parseSettings(settingsSnap.data() as Record<string, unknown> | undefined);
    if (!settings.autoCreateViolations) {
      return { ok: true, created: 0, reason: "autoCreateViolations disabled" };
    }

    // We reuse existing computed fields on attendanceDays:
    // - status: absent
    // - hasMissingPunch + applyMissingCheckoutDeduction
    // - breakMinutes
    const daysSnap = await db
      .collection(`salons/${salonId}/attendanceDays`)
      .where("monthKey", "==", monthKey)
      .get();

    let created = 0;
    for (const doc of daysSnap.docs) {
      const d = doc.data() as Record<string, unknown>;
      const employeeId = String(d.employeeId ?? "").trim();
      const employeeName = String(d.employeeName ?? "Employee").trim() || "Employee";
      const dateKey = String(d.dateKey ?? "").trim(); // yyyyMMdd
      if (!employeeId || !dateKey || dateKey.length !== 8) {
        continue;
      }

      const status = String(d.status ?? "").trim();
      const breakMinutes = Math.max(0, Math.floor(asNumber(d.breakMinutes, 0)));
      const hasMissingPunch = d.hasMissingPunch === true && d.applyMissingCheckoutDeduction === true;

      const autoApprove = !settings.requireOwnerApprovalBeforePayroll;

      if (status === "absent") {
        await upsertViolationDraft({
          salonId,
          employeeId,
          employeeName,
          compactDate: dateKey,
          violationType: AttendanceViolationTypes.absence,
          // Deduction amount is computed later in posting based on base salary/day;
          // for now keep amount as 0 and percent stored.
          deductionAmount: 0,
          percent: settings.absenceDeductionPercent,
          notes: "Absent",
          autoApprove,
        });
        created += 1;
      }

      if (hasMissingPunch) {
        await upsertViolationDraft({
          salonId,
          employeeId,
          employeeName,
          compactDate: dateKey,
          violationType: AttendanceViolationTypes.missingPunch,
          deductionAmount: 0,
          percent: settings.missingCheckoutDeductionPercent,
          notes: "Missing punch in/out",
          autoApprove,
        });
        created += 1;
      }

      if (settings.maxBreakMinutesPerDay > 0 && breakMinutes > settings.maxBreakMinutesPerDay) {
        await upsertViolationDraft({
          salonId,
          employeeId,
          employeeName,
          compactDate: dateKey,
          violationType: AttendanceViolationTypes.breakExceeded,
          deductionAmount: 0,
          percent: settings.earlyExitDeductionPercent,
          notes: "Break time exceeded",
          autoApprove,
        });
        created += 1;
      }
    }

    return { ok: true, created };
  },
);

export const approveAttendanceViolation = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const violationId = String(request.data?.violationId ?? "").trim();
    await assertAttendancePermission(request.auth.uid, caller, salonId);
    if (!violationId) throw new HttpsError("invalid-argument", "violationId required");

    const ref = db.doc(`salons/${salonId}/violations/${violationId}`);
    const actor = await auditActorProfile(db, request.auth!.uid);
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) throw new HttpsError("not-found", "Violation not found");
      const d = snap.data() as Record<string, unknown>;
      const status = String(d.status ?? "");
      if (status === ViolationStatuses.applied) {
        throw new HttpsError("failed-precondition", "Violation already posted to payroll");
      }
      if (status !== ViolationStatuses.pending) {
        return;
      }
      tx.set(
        ref,
        {
          status: ViolationStatuses.approved,
          approvedAt: FieldValue.serverTimestamp(),
          approvedByUid: request.auth?.uid,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      writeAuditLogInTransaction(tx, db, {
        salonId,
        actionType: "attendance.violationApproved",
        module: "attendance",
        actorUid: request.auth!.uid,
        actorName: actor.name,
        actorRole: actor.role,
        targetType: "violation",
        targetId: violationId,
        targetLabel: String(d.employeeName ?? d.employeeId ?? violationId),
        summary: "Attendance violation approved",
        before: { status },
        after: { status: ViolationStatuses.approved },
        metadata: { source: "approveAttendanceViolation" },
      });
    });
    return { ok: true };
  },
);

export const waiveAttendanceViolation = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const violationId = String(request.data?.violationId ?? "").trim();
    const reason = String(request.data?.reason ?? "").trim();
    await assertAttendancePermission(request.auth.uid, caller, salonId);
    if (!violationId) throw new HttpsError("invalid-argument", "violationId required");

    const ref = db.doc(`salons/${salonId}/violations/${violationId}`);
    const waiveActor = await auditActorProfile(db, request.auth!.uid);
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) throw new HttpsError("not-found", "Violation not found");
      const d = snap.data() as Record<string, unknown>;
      const status = String(d.status ?? "");
      if (status === ViolationStatuses.applied) {
        throw new HttpsError("failed-precondition", "Violation already posted to payroll");
      }
      tx.set(
        ref,
        {
          status: ViolationStatuses.rejected,
          notes: reason || String(d.notes ?? ""),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      writeAuditLogInTransaction(tx, db, {
        salonId,
        actionType: "attendance.violationWaived",
        module: "attendance",
        actorUid: request.auth!.uid,
        actorName: waiveActor.name,
        actorRole: waiveActor.role,
        targetType: "violation",
        targetId: violationId,
        targetLabel: String(d.employeeName ?? d.employeeId ?? violationId),
        summary: "Attendance violation waived",
        before: { status },
        after: { status: ViolationStatuses.rejected },
        metadata: { reason: reason || null, source: "waiveAttendanceViolation" },
      });
    });
    return { ok: true };
  },
);

export const postAttendanceViolationsToPayroll = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const periodId = String(request.data?.periodId ?? "").trim();
    await assertPayrollPermission(request.auth.uid, caller, salonId);

    const { year, month } = monthKeyFromPeriodId(periodId);

    const violationsSnap = await db
      .collection(`salons/${salonId}/violations`)
      .where("sourceType", "==", "attendance")
      .where("reportYear", "==", year)
      .where("reportMonth", "==", month)
      .where("status", "==", ViolationStatuses.approved)
      .limit(500)
      .get();

    if (violationsSnap.empty) {
      return { ok: true, posted: 0 };
    }

    const batch = db.batch();
    let posted = 0;
    for (const vDoc of violationsSnap.docs) {
      const v = vDoc.data() as Record<string, unknown>;
      const violationId = vDoc.id;
      const employeeId = String(v.employeeId ?? "").trim();
      if (!employeeId) continue;

      // Deterministic adjustment id prevents duplicates.
      const adjId = `att_${violationId}`;
      const adjRef = db.doc(`salons/${salonId}/payroll_adjustments/${adjId}`);
      const amount = Math.max(0, roundMoney(asNumber(v.amount, 0)));
      if (amount <= 0) {
        continue;
      }
      const violationType = String(v.violationType ?? "attendance_violation");
      const title = "Attendance deduction";
      const reason = String(v.notes ?? violationType).trim() || violationType;

      batch.set(
        adjRef,
        {
          id: adjId,
          salonId,
          employeeId,
          year,
          month,
          type: "deduction",
          elementCode: "ATTENDANCE_DEDUCTION",
          title,
          amount,
          reason,
          status: "approved",
          source: "attendance_violation",
          sourceViolationId: violationId,
          createdBy: request.auth.uid,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      batch.set(
        vDoc.ref,
        {
          status: ViolationStatuses.applied,
          payrollRunId: periodId,
          appliedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      posted += 1;
    }

    await batch.commit();
    const postActor = await auditActorProfile(db, request.auth!.uid);
    await writeAuditLog(db, {
      salonId,
      actionType: "payroll.violationsPosted",
      module: "payroll",
      actorUid: request.auth!.uid,
      actorName: postActor.name,
      actorRole: postActor.role,
      summary: `Posted ${posted} attendance violations to payroll adjustments`,
      metadata: { periodId, posted, source: "postAttendanceViolationsToPayroll" },
    });
    return { ok: true, posted };
  },
);

