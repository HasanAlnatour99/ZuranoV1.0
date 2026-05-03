import {
  FieldValue,
  getFirestore,
  Timestamp,
  type DocumentReference,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

import {
  assertSalonOwnerOrAdmin,
  asNumber,
  dataOrEmpty,
  type FireUser,
} from "../payrollShared";

const db = getFirestore();

type StatusIn = "present" | "late" | "absent" | "dayOff";

type ReprocessRequest = {
  salonId?: string;
  employeeId?: string;
  attendanceDate?: string;
  shiftId?: string | null;
  status?: StatusIn | string;
  punchInAt?: string | null;
  breakOutAt?: string | null;
  breakInAt?: string | null;
  punchOutAt?: string | null;
  reason?: string;
  managerNote?: string | null;
};

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

function attendanceDocId(employeeId: string, d: DateTime): string {
  return `${employeeId}_${d.toFormat("yyyyMMdd")}`;
}

function scheduleDocId(employeeId: string, d: DateTime): string {
  return `${employeeId}_${d.year}${pad2(d.month)}${pad2(d.day)}`;
}

function monthKey(d: DateTime): string {
  return `${d.year}-${pad2(d.month)}`;
}

function isoDateOnly(d: DateTime): string {
  return d.toISODate() ?? "";
}

function parseIsoDate(s: string): DateTime | null {
  const t = DateTime.fromISO(String(s ?? "").trim(), { zone: "utc" });
  return t.isValid ? t.startOf("day") : null;
}

function parseOptionalIsoTs(s: string | null | undefined): Date | null {
  if (s == null || String(s).trim() === "") {
    return null;
  }
  const t = DateTime.fromISO(String(s).trim(), { setZone: true });
  return t.isValid ? t.toJSDate() : null;
}

function minutesBetween(a: Date, b: Date): number {
  return Math.round((b.getTime() - a.getTime()) / 60000);
}

/** Parse HH:mm on a calendar day using workDate's year/month/day. */
function combineTimeOnDay(day: DateTime, hhmm: string | undefined | null): Date | null {
  if (!hhmm || !hhmm.includes(":")) {
    return null;
  }
  const [hStr, mStr] = hhmm.split(":");
  const h = Number(hStr);
  const m = Number(mStr);
  if (!Number.isFinite(h) || !Number.isFinite(m)) {
    return null;
  }
  const local = DateTime.fromObject(
    { year: day.year, month: day.month, day: day.day, hour: h, minute: m },
    { zone: "utc" },
  );
  return local.toJSDate();
}

type CalcResult = {
  lateMinutes: number;
  earlyExitMinutes: number;
  missingCheckout: boolean;
  missingCheckoutMinutes: number;
  workedMinutes: number;
  breakMinutes: number;
  overtimeMinutes: number;
  storageStatus: string;
};

function recalculateAttendance(args: {
  status: StatusIn;
  punchIn: Date | null;
  punchOut: Date | null;
  breakOut: Date | null;
  breakIn: Date | null;
  scheduledStart: Date | null;
  scheduledEnd: Date | null;
  scheduledMinutesFallback: number;
  lateGrace: number;
  earlyExitGrace: number;
  missingCheckoutPenaltyMinutes: number;
}): CalcResult {
  const {
    status,
    punchIn,
    punchOut,
    breakOut,
    breakIn,
    scheduledStart,
    scheduledEnd,
    scheduledMinutesFallback,
    lateGrace,
    earlyExitGrace,
    missingCheckoutPenaltyMinutes,
  } = args;

  if (status === "absent" || status === "dayOff") {
    return {
      lateMinutes: 0,
      earlyExitMinutes: 0,
      missingCheckout: false,
      missingCheckoutMinutes: 0,
      workedMinutes: 0,
      breakMinutes: 0,
      overtimeMinutes: 0,
      storageStatus: status === "absent" ? "absent" : "dayOff",
    };
  }

  let breakMinutes = 0;
  if (breakOut && breakIn && breakIn.getTime() > breakOut.getTime()) {
    breakMinutes = minutesBetween(breakOut, breakIn);
  }

  let lateMinutes = 0;
  if (punchIn && scheduledStart && punchIn.getTime() > scheduledStart.getTime()) {
    lateMinutes = Math.max(0, minutesBetween(scheduledStart, punchIn) - lateGrace);
  }

  let earlyExitMinutes = 0;
  if (punchOut && scheduledEnd && punchOut.getTime() < scheduledEnd.getTime()) {
    earlyExitMinutes = Math.max(0, minutesBetween(punchOut, scheduledEnd) - earlyExitGrace);
  }

  const missingCheckout =
    punchIn != null && punchOut == null && (status === "present" || status === "late");

  const missingCheckoutMinutes = missingCheckout ? Math.max(0, missingCheckoutPenaltyMinutes) : 0;

  let workedMinutes = 0;
  if (punchIn && punchOut && punchOut.getTime() >= punchIn.getTime()) {
    workedMinutes = Math.max(0, minutesBetween(punchIn, punchOut) - breakMinutes);
  }

  let scheduledMinutes = scheduledMinutesFallback;
  if (scheduledStart && scheduledEnd && scheduledEnd.getTime() > scheduledStart.getTime()) {
    scheduledMinutes = minutesBetween(scheduledStart, scheduledEnd);
  }

  const overtimeMinutes =
    scheduledMinutes > 0 ? Math.max(0, workedMinutes - scheduledMinutes) : 0;

  let storageStatus = status === "late" ? "late" : "present";
  if (lateMinutes > 0 && status === "present") {
    storageStatus = "late";
  }

  return {
    lateMinutes,
    earlyExitMinutes,
    missingCheckout,
    missingCheckoutMinutes,
    workedMinutes,
    breakMinutes,
    overtimeMinutes,
    storageStatus,
  };
}

function snapshotDoc(data: Record<string, unknown> | undefined): Record<string, unknown> {
  return data ? { ...data } : {};
}

function firestoreTsToDate(v: unknown): Date | null {
  if (
    v &&
    typeof v === "object" &&
    "toDate" in v &&
    typeof (v as { toDate: () => Date }).toDate === "function"
  ) {
    return (v as { toDate: () => Date }).toDate();
  }
  return null;
}

function toTimestamp(d: Date | null): Timestamp | null {
  return d ? Timestamp.fromDate(d) : null;
}

function isoWeekLabel(d: DateTime): string {
  return `${d.weekYear}-W${pad2(d.weekNumber)}`;
}

export const reprocessAttendanceForEmployeeDate = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    const authUid = request.auth?.uid;
    if (!authUid) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    const body = (request.data ?? {}) as ReprocessRequest;
    const salonId = String(body.salonId ?? "").trim();
    const employeeId = String(body.employeeId ?? "").trim();
    const attendanceDateStr = String(body.attendanceDate ?? "").trim();
    const statusRaw = String(body.status ?? "").trim().toLowerCase();

    if (!salonId || !employeeId || !attendanceDateStr) {
      throw new HttpsError("invalid-argument", "salonId, employeeId, and attendanceDate are required.");
    }

    const reason = String(body.reason ?? "").trim();
    if (!reason) {
      throw new HttpsError("invalid-argument", "reason is required.");
    }

    const status: StatusIn =
      statusRaw === "dayoff" || statusRaw === "day_off"
        ? "dayOff"
        : (statusRaw as StatusIn);
    if (!["present", "late", "absent", "dayOff"].includes(status)) {
      throw new HttpsError("invalid-argument", "Invalid status.");
    }

    const workDay = parseIsoDate(attendanceDateStr);
    if (!workDay) {
      throw new HttpsError("invalid-argument", "attendanceDate must be ISO yyyy-MM-dd.");
    }

    const callerSnap = await db.doc(`users/${authUid}`).get();
    const caller = dataOrEmpty(callerSnap) as FireUser;
    assertSalonOwnerOrAdmin(caller, salonId);

    const punchInAt = parseOptionalIsoTs(body.punchInAt ?? null);
    const punchOutAt = parseOptionalIsoTs(body.punchOutAt ?? null);
    const breakOutAt = parseOptionalIsoTs(body.breakOutAt ?? null);
    const breakInAt = parseOptionalIsoTs(body.breakInAt ?? null);

    if (punchInAt && punchOutAt && punchOutAt.getTime() < punchInAt.getTime()) {
      throw new HttpsError("invalid-argument", "Punch out cannot be earlier than punch in.");
    }
    if (breakOutAt && breakInAt && breakInAt.getTime() < breakOutAt.getTime()) {
      throw new HttpsError("invalid-argument", "Break in cannot be earlier than break out.");
    }
    if ((breakOutAt || breakInAt) && !punchInAt) {
      throw new HttpsError("invalid-argument", "Break times require punch in.");
    }

    const employeeRef = db.doc(`salons/${salonId}/employees/${employeeId}`);
    const employeeSnap = await employeeRef.get();
    if (!employeeSnap.exists) {
      throw new HttpsError("not-found", "Employee not found.");
    }
    const employee = employeeSnap.data() as Record<string, unknown>;
    const employeeName = String(employee.name ?? "").trim() || "Team member";

    const settingsSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
    const settings = settingsSnap.exists ? (settingsSnap.data() as Record<string, unknown>) : {};
    const lateGrace = Math.max(0, asNumber(settings.lateGraceMinutes ?? settings.graceLateMinutes, 10));
    const earlyExitGrace = Math.max(
      0,
      asNumber(settings.earlyExitGraceMinutes ?? settings.graceEarlyExitMinutes, 10),
    );
    const missingCheckoutPenaltyMinutes = Math.max(
      0,
      asNumber(settings.missingCheckoutPenaltyMinutes, 120),
    );

    const scheduleId = body.shiftId?.trim() || scheduleDocId(employeeId, workDay);
    const scheduleSnap = await db.doc(`salons/${salonId}/employeeSchedules/${scheduleId}`).get();
    const sched = scheduleSnap.exists ? (scheduleSnap.data() as Record<string, unknown>) : {};

    let scheduledStart: Date | null = firestoreTsToDate(sched.startDateTime);
    let scheduledEnd: Date | null = firestoreTsToDate(sched.endDateTime);
    let scheduledMinutesFallback = Math.max(0, asNumber(sched.scheduledMinutes, 0));

    if (!scheduledStart) {
      scheduledStart = combineTimeOnDay(workDay, settings.standardShiftStart as string | undefined);
    }
    if (!scheduledEnd) {
      scheduledEnd = combineTimeOnDay(workDay, settings.standardShiftEnd as string | undefined);
    }

    const attendanceId = attendanceDocId(employeeId, workDay);
    const attendanceRef = db.doc(`salons/${salonId}/attendance/${attendanceId}`);

    const dayStart = workDay.startOf("day");
    const mk = monthKey(workDay);

    const monthQuery = await db
      .collection(`salons/${salonId}/attendance`)
      .where("employeeId", "==", employeeId)
      .where("monthKey", "==", mk)
      .get();

    const monthRefs: DocumentReference[] = monthQuery.docs.map((d) => d.ref);
    const hasTargetInMonthRollup = monthRefs.some((r) => r.id === attendanceId);
    if (!hasTargetInMonthRollup) {
      monthRefs.push(attendanceRef);
    }

    const result = await db.runTransaction(async (txn) => {
      const existingSnap = await txn.get(attendanceRef);
      const before = snapshotDoc(existingSnap.data() as Record<string, unknown> | undefined);

      const calc = recalculateAttendance({
        status,
        punchIn: status === "absent" || status === "dayOff" ? null : punchInAt,
        punchOut: status === "absent" || status === "dayOff" ? null : punchOutAt,
        breakOut: status === "absent" || status === "dayOff" ? null : breakOutAt,
        breakIn: status === "absent" || status === "dayOff" ? null : breakInAt,
        scheduledStart,
        scheduledEnd,
        scheduledMinutesFallback,
        lateGrace,
        earlyExitGrace,
        missingCheckoutPenaltyMinutes,
      });

      const dayNative = dayStart.toJSDate();
      const dateKeyNum = Number(workDay.toFormat("yyyyMMdd"));

      const attendancePayload: Record<string, unknown> = {
        id: attendanceId,
        salonId,
        employeeId,
        employeeName,
        ...(typeof employee.uid === "string" && employee.uid.trim() !== ""
          ? { employeeUid: employee.uid.trim() }
          : {}),
        attendanceDate: isoDateOnly(workDay),
        dateKey: dateKeyNum,
        weekKey: isoWeekLabel(workDay),
        monthKey: mk,
        workDate: Timestamp.fromDate(dayNative),
        status: calc.storageStatus,
        currentState:
          calc.storageStatus === "absent" || calc.storageStatus === "dayOff"
            ? "checkedOut"
            : punchOutAt
              ? "checkedOut"
              : punchInAt
                ? breakInAt
                  ? "backFromBreak"
                  : breakOutAt
                    ? "onBreak"
                    : "checkedIn"
                : "notStarted",
        punchInAt: toTimestamp(punchInAt),
        punchOutAt: toTimestamp(punchOutAt),
        lastBreakOutAt: toTimestamp(breakOutAt),
        lastBreakInAt: toTimestamp(breakInAt),
        breakOutAt: toTimestamp(breakOutAt),
        breakInAt: toTimestamp(breakInAt),
        checkInAt: toTimestamp(punchInAt),
        checkOutAt: toTimestamp(punchOutAt),
        lateMinutes: calc.lateMinutes,
        minutesLate: calc.lateMinutes,
        earlyExitMinutes: calc.earlyExitMinutes,
        missingCheckout: calc.missingCheckout,
        needsCorrection: calc.missingCheckout,
        missingCheckoutMinutes: calc.missingCheckoutMinutes,
        workedMinutes: calc.workedMinutes,
        totalWorkedMinutes: calc.workedMinutes,
        breakMinutes: calc.breakMinutes,
        totalBreakMinutes: calc.breakMinutes,
        overtimeMinutes: calc.overtimeMinutes,
        shiftTemplateId: body.shiftId?.trim() || sched.shiftTemplateId || null,
        scheduledStart: toTimestamp(scheduledStart),
        scheduledEnd: toTimestamp(scheduledEnd),
        manuallyAdjusted: true,
        manualEdited: true,
        source: "owner_admin_reprocess",
        adjustmentReason: reason,
        notes: body.managerNote?.trim() || FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: authUid,
      };

      if (!existingSnap.exists) {
        attendancePayload.createdAt = FieldValue.serverTimestamp();
        attendancePayload.createdBy = authUid;
      }

      txn.set(attendanceRef, attendancePayload, { merge: true });

      const adjustmentRef = db.collection(`salons/${salonId}/attendanceAdjustments`).doc();
      txn.set(adjustmentRef, {
        id: adjustmentRef.id,
        salonId,
        employeeId,
        attendanceDate: isoDateOnly(workDay),
        before,
        after: {
          ...calc,
          status: calc.storageStatus,
          attendanceDate: isoDateOnly(workDay),
          shiftTemplateId: body.shiftId?.trim() || sched.shiftTemplateId || null,
        },
        reason,
        note: body.managerNote?.trim() || null,
        adjustedByUserId: authUid,
        adjustedByRole: String(caller.role ?? ""),
        createdAt: FieldValue.serverTimestamp(),
      });

      const snaps = await Promise.all(monthRefs.map((r) => txn.get(r)));
      const mergedById = new Map<string, Record<string, unknown>>();
      for (const s of snaps) {
        if (s.exists) {
          mergedById.set(s.id, { ...(s.data() as Record<string, unknown>) });
        }
      }
      mergedById.set(attendanceId, { ...mergedById.get(attendanceId), ...attendancePayload });

      let presentDays = 0;
      let absentDays = 0;
      let lateDays = 0;
      let dayOffDays = 0;
      let totalLateMinutes = 0;
      let totalEarlyExitMinutes = 0;
      let totalMissingCheckoutMinutes = 0;
      let totalWorkedMinutes = 0;

      for (const [, row] of mergedById) {
        const st = String(row.status ?? "").toLowerCase();
        const lm = asNumber(row.lateMinutes ?? row.minutesLate, 0);
        const em = asNumber(row.earlyExitMinutes, 0);
        const mm = asNumber(row.missingCheckoutMinutes, 0);
        const wm = asNumber(row.workedMinutes ?? row.totalWorkedMinutes, 0);

        if (st === "absent") {
          absentDays += 1;
        } else if (st === "dayoff" || st === "day_off") {
          dayOffDays += 1;
        } else {
          presentDays += 1;
        }
        if (st === "late" || lm > 0) {
          lateDays += 1;
        }
        totalLateMinutes += lm;
        totalEarlyExitMinutes += em;
        totalMissingCheckoutMinutes += mm;
        totalWorkedMinutes += wm;
      }

      const totalDeductionMinutes = totalLateMinutes + totalEarlyExitMinutes + totalMissingCheckoutMinutes;

      const periodYm = `${workDay.year}${pad2(workDay.month)}`;
      const summaryRef = db.doc(
        `salons/${salonId}/payrollPeriods/${periodYm}/employeeSummaries/${employeeId}`,
      );

      txn.set(
        summaryRef,
        {
          salonId,
          employeeId,
          period: periodYm,
          presentDays,
          absentDays,
          lateDays,
          dayOffDays,
          totalLateMinutes,
          totalEarlyExitMinutes,
          totalMissingCheckoutMinutes,
          totalWorkedMinutes,
          totalDeductionMinutes,
          recalculatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return {
        attendanceId,
        recalculated: {
          status: calc.storageStatus,
          lateMinutes: calc.lateMinutes,
          earlyExitMinutes: calc.earlyExitMinutes,
          missingCheckoutMinutes: calc.missingCheckoutMinutes,
          workedMinutes: calc.workedMinutes,
          breakMinutes: calc.breakMinutes,
          overtimeMinutes: calc.overtimeMinutes,
          missingCheckout: calc.missingCheckout,
        },
      };
    });

    return { success: true as const, ...result };
  },
);
