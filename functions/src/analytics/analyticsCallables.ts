import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

import { dataOrEmpty } from "../payrollShared";
import {
  assertSalonPermissionKey,
  loadStaffPermissionsRow,
  type FireUser,
} from "../reports/exportPermissions";

const db = getFirestore();
const REGION = "us-central1" as const;

async function loadUser(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return dataOrEmpty(snap);
}

async function assertAnalyticsPermission(uid: string, caller: Record<string, unknown>, salonId: string): Promise<void> {
  const staff = await loadStaffPermissionsRow(db, salonId, uid);
  assertSalonPermissionKey(caller as FireUser, salonId, "analytics.view", staff);
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

function periodIdFor(year: number, month: number): string {
  return `${String(year).padStart(4, "0")}-${pad2(month)}`;
}

function asNumber(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

type TopEmployeeRow = {
  employeeId: string;
  employeeName: string;
  salesTotal: number;
  salesCount: number;
  commissionAmount: number;
  servicesCount: number;
};

type TopServiceRow = {
  serviceId: string;
  serviceName: string;
  revenue: number;
  count: number;
};

export const generateMonthlyAnalytics = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }
    const caller = await loadUser(request.auth.uid);
    const salonId = String(request.data?.salonId ?? "").trim();
    const year = Number(request.data?.year);
    const month = Number(request.data?.month);
    if (!salonId) throw new HttpsError("invalid-argument", "salonId required");
    if (!Number.isFinite(year) || !Number.isFinite(month) || month < 1 || month > 12) {
      throw new HttpsError("invalid-argument", "year and month required");
    }
    await assertAnalyticsPermission(request.auth.uid, caller, salonId);

    const pid = periodIdFor(year, month);
    const start = DateTime.fromObject({ year, month, day: 1 }, { zone: "utc" }).startOf("day");
    const end = start.plus({ months: 1 });
    const monthStart = start.toJSDate();
    const monthEnd = end.toJSDate();

    // --- Sales ---
    const salesSnap = await db
      .collection(`salons/${salonId}/sales`)
      .where("reportYear", "==", year)
      .where("reportMonth", "==", month)
      .where("status", "==", "completed")
      .get();

    let grossRevenue = 0;
    let salesCount = 0;
    let servicesCount = 0;
    const employeeAgg = new Map<string, TopEmployeeRow>();
    const serviceAgg = new Map<string, TopServiceRow>();
    const customerIds = new Set<string>();

    for (const doc of salesSnap.docs) {
      const d = doc.data() as Record<string, unknown>;
      const total = asNumber(d.total ?? d.totalAmountAfterDiscount ?? d.totalAmount ?? d.subtotal ?? d.subtotalAmount, 0);
      grossRevenue += total;
      salesCount += 1;

      const employeeId = String(d.employeeId ?? "").trim();
      const employeeName = String(d.employeeName ?? employeeId).trim() || employeeId;
      const commission = asNumber(d.commissionAmount ?? 0, 0);
      const customerId = String(d.customerId ?? "").trim();
      if (customerId) customerIds.add(customerId);

      if (employeeId) {
        const prev = employeeAgg.get(employeeId);
        employeeAgg.set(employeeId, {
          employeeId,
          employeeName: prev?.employeeName ?? employeeName,
          salesTotal: (prev?.salesTotal ?? 0) + total,
          salesCount: (prev?.salesCount ?? 0) + 1,
          commissionAmount: (prev?.commissionAmount ?? 0) + commission,
          servicesCount: prev?.servicesCount ?? 0,
        });
      }

      const lineItems = Array.isArray((d as any).lineItems) ? (d as any).lineItems as Array<any> : [];
      if (lineItems.length > 0) {
        for (const li of lineItems) {
          const sid = String(li?.serviceId ?? "").trim();
          const sname = String(li?.serviceName ?? "").trim() || sid || "Service";
          const qty = Math.max(1, Math.floor(asNumber(li?.quantity ?? 1, 1)));
          const liTotal = asNumber(li?.total ?? 0, 0);
          servicesCount += qty;
          if (employeeId) {
            const prev = employeeAgg.get(employeeId);
            if (prev) {
              prev.servicesCount += qty;
              employeeAgg.set(employeeId, prev);
            }
          }
          const key = sid || sname;
          const prevS = serviceAgg.get(key);
          serviceAgg.set(key, {
            serviceId: sid || key,
            serviceName: prevS?.serviceName ?? sname,
            revenue: (prevS?.revenue ?? 0) + liTotal,
            count: (prevS?.count ?? 0) + qty,
          });
        }
      } else {
        const names = Array.isArray((d as any).serviceNames) ? (d as any).serviceNames as Array<any> : [];
        if (names.length > 0) {
          for (const n of names) {
            const sname = String(n ?? "").trim();
            if (!sname) continue;
            servicesCount += 1;
            const prevS = serviceAgg.get(sname);
            serviceAgg.set(sname, {
              serviceId: sname,
              serviceName: sname,
              revenue: (prevS?.revenue ?? 0) + (total / Math.max(1, names.length)),
              count: (prevS?.count ?? 0) + 1,
            });
          }
        }
      }
    }

    grossRevenue = roundMoney(grossRevenue);
    const averageTicket = salesCount > 0 ? roundMoney(grossRevenue / salesCount) : 0;

    const topEmployees = Array.from(employeeAgg.values())
      .sort((a, b) => (b.salesTotal - a.salesTotal) || a.employeeId.localeCompare(b.employeeId))
      .slice(0, 8)
      .map((e) => ({
        employeeId: e.employeeId,
        employeeName: e.employeeName,
        salesTotal: roundMoney(e.salesTotal),
        salesCount: e.salesCount,
        commissionAmount: roundMoney(e.commissionAmount),
        servicesCount: e.servicesCount,
      }));

    const topServices = Array.from(serviceAgg.values())
      .sort((a, b) => (b.revenue - a.revenue) || a.serviceId.localeCompare(b.serviceId))
      .slice(0, 10)
      .map((s) => ({
        serviceId: s.serviceId,
        serviceName: s.serviceName,
        revenue: roundMoney(s.revenue),
        count: s.count,
      }));

    // --- Bookings (conversion) ---
    const bookingsSnap = await db
      .collection(`salons/${salonId}/bookings`)
      .where("reportYear", "==", year)
      .where("reportMonth", "==", month)
      .get();
    const bookingsCount = bookingsSnap.size;
    let completedBookingsCount = 0;
    for (const doc of bookingsSnap.docs) {
      const st = String(doc.get("status") ?? "").trim();
      if (st === "completed") completedBookingsCount += 1;
    }

    // --- Expenses ---
    const expensesSnap = await db
      .collection(`salons/${salonId}/expenses`)
      .where("reportYear", "==", year)
      .where("reportMonth", "==", month)
      .get();
    let expensesTotal = 0;
    for (const doc of expensesSnap.docs) {
      expensesTotal += asNumber(doc.get("amount") ?? 0, 0);
    }
    expensesTotal = roundMoney(expensesTotal);

    // --- Payroll cost (paid only) ---
    const payslipsSnap = await db
      .collection(`salons/${salonId}/payslips`)
      .where("year", "==", year)
      .where("month", "==", month)
      .where("status", "==", "paid")
      .get();
    let payrollCost = 0;
    for (const doc of payslipsSnap.docs) {
      payrollCost += asNumber(doc.get("netPay") ?? 0, 0);
    }
    payrollCost = roundMoney(payrollCost);

    const netProfit = roundMoney(grossRevenue - payrollCost - expensesTotal);

    const docRef = db.doc(`salons/${salonId}/analytics/monthly/${pid}`);
    const payload: Record<string, unknown> = {
      salonId,
      periodId: pid,
      year,
      month,
      grossRevenue,
      salesCount,
      bookingsCount,
      completedBookingsCount,
      payrollCost,
      expensesTotal,
      netProfit,
      averageTicket,
      servicesCount,
      customersCount: customerIds.size,
      newCustomersCount: 0,
      topEmployees,
      topServices,
      generatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      monthStartAt: Timestamp.fromDate(monthStart),
      monthEndAt: Timestamp.fromDate(monthEnd),
    };

    await docRef.set(payload, { merge: true });
    return { ok: true, periodId: pid, grossRevenue, payrollCost, expensesTotal, netProfit };
  },
);

