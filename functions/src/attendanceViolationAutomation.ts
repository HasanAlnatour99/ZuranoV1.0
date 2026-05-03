import { FieldPath, FieldValue, Timestamp, type QueryDocumentSnapshot } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { db } from "./bookingShared";

const REGION = "us-central1" as const;
const SYSTEM_ACTOR = "system:attendance-automation";
const DEFAULT_MONTHLY_WORK_DAYS = 26;
const ABSENCE_GRACE_MINUTES = 15;

const ViolationStatuses = {
  pending: "pending",
} as const;

const ViolationSourceTypes = {
  attendance: "attendance",
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
  // Re-used for break over-limit since this is the closest "time discipline" policy knob today.
  earlyExitDeductionPercent: number;
};

type ShiftInfo = {
  employeeId: string;
  employeeName: string;
  scheduleDate: string;
  shiftType: string;
  scheduledMinutes: number;
  breakMinutes: number;
  endDateTime: Date | null;
};

function toNumber(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function toDateKeyFromCompact(compactDate: string): string {
  if (compactDate.length !== 8) {
    return compactDate;
  }
  return `${compactDate.slice(0, 4)}-${compactDate.slice(4, 6)}-${compactDate.slice(6, 8)}`;
}

function reportFieldsFromCompactDate(compactDate: string): {
  year: number;
  month: number;
  monthKey: string;
} {
  const year = Number(compactDate.slice(0, 4));
  const month = Number(compactDate.slice(4, 6));
  const monthKey = `${String(year).padStart(4, "0")}-${String(month).padStart(2, "0")}`;
  return { year, month, monthKey };
}

function parseSettings(raw: Record<string, unknown> | undefined): AttendanceSettings {
  return {
    autoCreateViolations: raw?.autoCreateViolations !== false,
    maxBreakMinutesPerDay: Math.max(0, Math.floor(toNumber(raw?.maxBreakMinutesPerDay, 15))),
    absenceDeductionPercent: Math.max(0, toNumber(raw?.absenceDeductionPercent, 100)),
    missingCheckoutDeductionPercent: Math.max(0, toNumber(raw?.missingCheckoutDeductionPercent, 5)),
    earlyExitDeductionPercent: Math.max(0, toNumber(raw?.earlyExitDeductionPercent, 5)),
  };
}

function parseShift(doc: QueryDocumentSnapshot): ShiftInfo {
  const d = doc.data();
  return {
    employeeId: typeof d.employeeId === "string" ? d.employeeId : "",
    employeeName: typeof d.employeeName === "string" ? d.employeeName : "Employee",
    scheduleDate: typeof d.scheduleDate === "string" ? d.scheduleDate : "",
    shiftType: typeof d.shiftType === "string" ? d.shiftType : "working",
    scheduledMinutes: Math.max(0, Math.floor(toNumber(d.scheduledMinutes, 0))),
    breakMinutes: Math.max(0, Math.floor(toNumber(d.breakMinutes, 0))),
    endDateTime: d.endDateTime instanceof Timestamp ? d.endDateTime.toDate() : null,
  };
}

async function fetchEmployeeCompensation(
  salonId: string,
  employeeId: string,
): Promise<{ hourlyRate: number; baseSalary: number }> {
  const employeeSnap = await db.doc(`salons/${salonId}/employees/${employeeId}`).get();
  const data = employeeSnap.data() as Record<string, unknown> | undefined;
  return {
    hourlyRate: Math.max(0, toNumber(data?.hourlyRate, 0)),
    baseSalary: Math.max(0, toNumber(data?.baseSalary, 0)),
  };
}

function computeShiftBaseAmount(input: {
  scheduledMinutes: number;
  hourlyRate: number;
  baseSalary: number;
}): number {
  const fromHourly = input.hourlyRate > 0 && input.scheduledMinutes > 0
    ? input.hourlyRate * (input.scheduledMinutes / 60)
    : 0;
  if (fromHourly > 0) {
    return roundMoney(fromHourly);
  }
  if (input.baseSalary > 0) {
    return roundMoney(input.baseSalary / DEFAULT_MONTHLY_WORK_DAYS);
  }
  return 0;
}

function computeDeductionAmount(baseAmount: number, percent: number): number {
  if (baseAmount <= 0 || percent <= 0) {
    return 0;
  }
  return roundMoney((baseAmount * percent) / 100);
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

async function getSalonCurrencyCode(salonId: string): Promise<string> {
  const salonSnap = await db.doc(`salons/${salonId}`).get();
  const d = salonSnap.data() as Record<string, unknown> | undefined;
  const direct = typeof d?.currencyCode === "string" ? d.currencyCode.trim().toUpperCase() : "";
  if (direct) {
    return direct;
  }
  const settings = d?.settings as Record<string, unknown> | undefined;
  const nested = typeof settings?.currencyCode === "string" ? settings.currencyCode.trim().toUpperCase() : "";
  return nested || "USD";
}

async function ensureViolationAndDeduction(input: {
  salonId: string;
  employeeId: string;
  employeeName: string;
  compactDate: string;
  violationType: string;
  reason: string;
  deductionPercent: number;
  scheduledMinutes: number;
  ruleSnapshot: Record<string, unknown>;
}): Promise<void> {
  const { year, month, monthKey } = reportFieldsFromCompactDate(input.compactDate);
  const occurredAt = Timestamp.fromDate(new Date(
    Number(input.compactDate.slice(0, 4)),
    Number(input.compactDate.slice(4, 6)) - 1,
    Number(input.compactDate.slice(6, 8)),
    12,
    0,
    0,
  ));
  const violationId = `${input.employeeId}_${input.compactDate}_${input.violationType}`;
  const reasonKey = input.reason.trim().toLowerCase().replace(/\s+/g, "_");
  const adjustmentId = `${input.employeeId}_${monthKey}_${reasonKey}`;

  const [{ hourlyRate, baseSalary }, currency] = await Promise.all([
    fetchEmployeeCompensation(input.salonId, input.employeeId),
    getSalonCurrencyCode(input.salonId),
  ]);
  const baseAmount = computeShiftBaseAmount({
    scheduledMinutes: input.scheduledMinutes,
    hourlyRate,
    baseSalary,
  });
  const deductionAmount = computeDeductionAmount(baseAmount, input.deductionPercent);

  const violationRef = db.doc(`salons/${input.salonId}/violations/${violationId}`);
  const adjustmentRef = db.doc(`salons/${input.salonId}/payrollAdjustments/${adjustmentId}`);

  await db.runTransaction(async (tx) => {
    const [existingViolation, existingAdjustment] = await Promise.all([
      tx.get(violationRef),
      tx.get(adjustmentRef),
    ]);

    if (!existingViolation.exists) {
      tx.set(violationRef, {
        id: violationId,
        salonId: input.salonId,
        employeeId: input.employeeId,
        employeeName: input.employeeName || null,
        sourceType: ViolationSourceTypes.attendance,
        violationType: input.violationType,
        status: ViolationStatuses.pending,
        occurredAt,
        reportYear: year,
        reportMonth: month,
        reportPeriodKey: monthKey,
        amount: deductionAmount,
        percent: input.deductionPercent,
        currency,
        ruleSnapshot: {
          ...input.ruleSnapshot,
          computedBaseAmount: baseAmount,
          computedDeductionAmount: deductionAmount,
          scheduledMinutes: input.scheduledMinutes,
          capturedBy: SYSTEM_ACTOR,
        },
        notes: input.reason,
        createdByUid: SYSTEM_ACTOR,
        createdByRole: "system",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    if (deductionAmount > 0) {
      if (existingAdjustment.exists) {
        tx.set(adjustmentRef, {
          amount: deductionAmount,
          reason: input.reason,
          reasonKey,
          updatedBy: SYSTEM_ACTOR,
          updatedAt: FieldValue.serverTimestamp(),
          note: `Auto from attendance violation (${input.violationType}) on ${toDateKeyFromCompact(input.compactDate)}.`,
        }, { merge: true });
      } else {
        tx.set(adjustmentRef, {
          id: adjustmentId,
          salonId: input.salonId,
          employeeId: input.employeeId,
          monthKey,
          type: "deduction",
          amount: deductionAmount,
          reason: input.reason,
          reasonKey,
          note: `Auto from attendance violation (${input.violationType}) on ${toDateKeyFromCompact(input.compactDate)}.`,
          status: "active",
          isRecurring: false,
          createdBy: SYSTEM_ACTOR,
          updatedBy: SYSTEM_ACTOR,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }
    }
  });
}

export const onAttendanceDayViolationAutomation = onDocumentWritten(
  {
    document: "salons/{salonId}/attendanceDays/{attendanceDayId}",
    region: REGION,
  },
  async (event) => {
    const salonId = String(event.params.salonId ?? "").trim();
    const after = event.data?.after;
    if (!salonId || !after?.exists) {
      return;
    }
    const day = after.data() as Record<string, unknown>;
    const employeeId = typeof day.employeeId === "string" ? day.employeeId : "";
    const employeeName = typeof day.employeeName === "string" ? day.employeeName : "Employee";
    const dateKey = typeof day.dateKey === "string" ? day.dateKey : "";
    if (!employeeId || !dateKey) {
      return;
    }

    const [settingsSnap, scheduleSnap] = await Promise.all([
      db.doc(`salons/${salonId}/settings/attendance`).get(),
      db.doc(`salons/${salonId}/employeeSchedules/${employeeId}_${dateKey}`).get(),
    ]);
    const settings = parseSettings(settingsSnap.data() as Record<string, unknown> | undefined);
    if (!settings.autoCreateViolations) {
      return;
    }

    const schedule = scheduleSnap.exists ? parseShift(scheduleSnap as QueryDocumentSnapshot) : null;
    if (schedule == null || schedule.shiftType === "off") {
      return;
    }

    const hasMissingPunch = day.hasMissingPunch === true;
    const applyMissingCheckoutDeduction = day.applyMissingCheckoutDeduction === true;
    const breakMinutes = Math.max(0, Math.floor(toNumber(day.breakMinutes, 0)));
    const breakExceeded = settings.maxBreakMinutesPerDay > 0 && breakMinutes > settings.maxBreakMinutesPerDay;

    if (hasMissingPunch && applyMissingCheckoutDeduction) {
      await ensureViolationAndDeduction({
        salonId,
        employeeId,
        employeeName,
        compactDate: dateKey,
        violationType: AttendanceViolationTypes.missingPunch,
        reason: "Missing punch in/out",
        deductionPercent: settings.missingCheckoutDeductionPercent,
        scheduledMinutes: schedule.scheduledMinutes,
        ruleSnapshot: {
          policy: "attendance_settings",
          appliesWhen: "applyMissingCheckoutDeduction == true",
          hasMissingPunch,
          breakMinutes,
          maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
        },
      });
    }

    if (breakExceeded) {
      await ensureViolationAndDeduction({
        salonId,
        employeeId,
        employeeName,
        compactDate: dateKey,
        violationType: AttendanceViolationTypes.breakExceeded,
        reason: "Exceeded break limit",
        deductionPercent: settings.earlyExitDeductionPercent,
        scheduledMinutes: schedule.scheduledMinutes,
        ruleSnapshot: {
          policy: "attendance_settings",
          breakMinutes,
          maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
          deductionPercentSource: "earlyExitDeductionPercent",
        },
      });
    }
  },
);

export const applyAbsenceViolationsForEndedShifts = onSchedule(
  {
    schedule: "every 30 minutes",
    region: REGION,
    timeZone: "UTC",
  },
  async () => {
    let salonCursor: QueryDocumentSnapshot | undefined;
    const salonPageSize = 25;
    const now = new Date();

    for (;;) {
      let q = db.collection("salons").orderBy(FieldPath.documentId()).limit(salonPageSize);
      if (salonCursor) {
        q = q.startAfter(salonCursor);
      }
      const salons = await q.get();
      if (salons.empty) {
        break;
      }

      for (const salon of salons.docs) {
        const salonId = salon.id;
        await processAbsenceForSalon(salonId, now);
      }

      salonCursor = salons.docs[salons.docs.length - 1];
      if (salons.size < salonPageSize) {
        break;
      }
    }
  },
);

async function processAbsenceForSalon(salonId: string, now: Date): Promise<void> {
  const settingsSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
  const settings = parseSettings(settingsSnap.data() as Record<string, unknown> | undefined);
  if (!settings.autoCreateViolations || settings.absenceDeductionPercent <= 0) {
    return;
  }

  const dateKey = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}${String(now.getUTCDate()).padStart(2, "0")}`;
  const scheduleDate = toDateKeyFromCompact(dateKey);

  const schedules = await db.collection(`salons/${salonId}/employeeSchedules`)
    .where("scheduleDate", "==", scheduleDate)
    .where("shiftType", "==", "working")
    .get();
  if (schedules.empty) {
    return;
  }

  for (const scheduleDoc of schedules.docs) {
    const shift = parseShift(scheduleDoc);
    if (!shift.employeeId || shift.shiftType === "off") {
      continue;
    }
    if (!shift.endDateTime) {
      continue;
    }
    const shiftEndWithGrace = new Date(shift.endDateTime.getTime() + ABSENCE_GRACE_MINUTES * 60 * 1000);
    if (now.getTime() < shiftEndWithGrace.getTime()) {
      continue;
    }

    const attendanceDayId = `${dateKey}_${shift.employeeId}`;
    const daySnap = await db.doc(`salons/${salonId}/attendanceDays/${attendanceDayId}`).get();
    if (daySnap.exists) {
      const day = daySnap.data() as Record<string, unknown>;
      const totalPunches = Math.floor(toNumber(day.totalPunches, 0));
      const firstPunchInAt = day.firstPunchInAt;
      if (totalPunches > 0 || firstPunchInAt instanceof Timestamp) {
        continue;
      }
    }

    await ensureViolationAndDeduction({
      salonId,
      employeeId: shift.employeeId,
      employeeName: shift.employeeName,
      compactDate: dateKey,
      violationType: AttendanceViolationTypes.absence,
      reason: "Absence",
      deductionPercent: settings.absenceDeductionPercent,
      scheduledMinutes: shift.scheduledMinutes,
      ruleSnapshot: {
        policy: "attendance_settings",
        source: "employeeSchedules + attendanceDays",
        shiftEndWithGraceIso: shiftEndWithGrace.toISOString(),
      },
    });
  }
}
