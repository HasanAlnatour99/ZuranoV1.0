import { DocumentData, DocumentSnapshot, Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

export type FireUser = {
  salonId?: string;
  role?: string;
  isActive?: boolean;
};

export function assertSalonOwnerOrAdmin(
  caller: FireUser,
  salonId: string,
): void {
  const sid = salonId.trim();
  if (!sid) {
    throw new HttpsError("invalid-argument", "salonId is required.");
  }
  if (caller.isActive === false) {
    throw new HttpsError("permission-denied", "Inactive user.");
  }
  const role = String(caller.role ?? "").trim();
  if (role !== "owner" && role !== "admin") {
    throw new HttpsError("permission-denied", "Owner or admin only.");
  }
  if (String(caller.salonId ?? "").trim() !== sid) {
    throw new HttpsError("permission-denied", "Salon mismatch.");
  }
}

export function padYm(year: number, month: number): string {
  return `${year}${String(month).padStart(2, "0")}`;
}

export function payslipIdFor(employeeId: string, year: number, month: number): string {
  return `${employeeId.trim()}_${padYm(year, month)}`;
}

export function asNumber(v: unknown, fallback = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

export function dataOrEmpty(snap: DocumentSnapshot): DocumentData {
  return snap.data() ?? {};
}

/** Parses Firestore Timestamp or SDK-compatible `{ toDate() }`. */
export function parseFirestoreTimestamp(v: unknown): Date | null {
  if (v == null || v === undefined) {
    return null;
  }
  if (v instanceof Timestamp) {
    return v.toDate();
  }
  const conv = v as { toDate?: () => Date };
  if (typeof conv.toDate === "function") {
    return conv.toDate();
  }
  return null;
}

/**
 * Prorates a monthly contract amount by UTC calendar days in [year]-[month]
 * from hire date through month end (inclusive). Missing hire date => full month.
 */
export function prorateMonthlySalaryUtc(params: {
  monthlyAmount: number;
  hireDateUtc: Date | null;
  year: number;
  month: number;
}): { appliedAmount: number; ratio: number; monthDays: number; eligibleDays: number } {
  const { monthlyAmount, hireDateUtc, year, month } = params;
  const monthStart = DateTime.fromObject({ year, month, day: 1 }, { zone: "utc" }).startOf("day");
  const daysInMonth = monthStart.daysInMonth ?? 31;
  const monthEnd = monthStart.plus({ days: daysInMonth - 1 }).startOf("day");

  if (monthlyAmount <= 0) {
    return { appliedAmount: 0, ratio: 0, monthDays: daysInMonth, eligibleDays: 0 };
  }

  if (hireDateUtc == null) {
    return {
      appliedAmount: monthlyAmount,
      ratio: 1,
      monthDays: daysInMonth,
      eligibleDays: daysInMonth,
    };
  }

  const hire = DateTime.fromJSDate(hireDateUtc, { zone: "utc" }).startOf("day");

  if (hire > monthEnd) {
    return { appliedAmount: 0, ratio: 0, monthDays: daysInMonth, eligibleDays: 0 };
  }

  if (hire <= monthStart) {
    return {
      appliedAmount: monthlyAmount,
      ratio: 1,
      monthDays: daysInMonth,
      eligibleDays: daysInMonth,
    };
  }

  const eligibleDays = Math.floor(monthEnd.diff(hire, "days").days) + 1;
  const ratio = Math.min(1, Math.max(0, eligibleDays / daysInMonth));
  return {
    appliedAmount: monthlyAmount * ratio,
    ratio,
    monthDays: daysInMonth,
    eligibleDays,
  };
}
