import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { DateTime } from "luxon";

import { assertSalonOwnerOrAdmin, asNumber, dataOrEmpty } from "../payrollShared";

const db = getFirestore();
const REGION = "us-central1" as const;

async function loadUser(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return dataOrEmpty(snap);
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

function dateKeyUtc(d: DateTime): string {
  return `${d.year}-${pad2(d.month)}-${pad2(d.day)}`;
}

function periodIdUtc(d: DateTime): string {
  return `${d.year}-${pad2(d.month)}`;
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

export const generateOwnerDashboardSnapshot = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    try {
      if (!request.auth?.uid) {
        throw new HttpsError("unauthenticated", "Login required");
      }
      const caller = await loadUser(request.auth.uid);
      const salonId = String(request.data?.salonId ?? "").trim();
      if (!salonId) throw new HttpsError("invalid-argument", "salonId required");
      assertSalonOwnerOrAdmin(caller as never, salonId);

      const nowUtc = DateTime.utc();
      const todayStart = nowUtc.startOf("day");
      const tomorrowStart = todayStart.plus({ days: 1 });
      const dateKey = dateKeyUtc(todayStart);
      const periodId = periodIdUtc(todayStart);
      const year = todayStart.year;
      const month = todayStart.month;
      const bookingsSnap = await db
        .collection(`salons/${salonId}/bookings`)
        .where("startAt", ">=", todayStart.toJSDate())
        .where("startAt", "<", tomorrowStart.toJSDate())
        .get();

      let bookingsToday = 0;
      let pendingBookings = 0;
      let completedBookings = 0;
      let cancelledBookings = 0;
      let unpaidCompletedToday = 0;
      for (const doc of bookingsSnap.docs) {
        bookingsToday += 1;
        const st = String(doc.get("status") ?? "").trim();
        if (st === "pending") pendingBookings += 1;
        if (st === "completed") completedBookings += 1;
        if (st === "cancelled") cancelledBookings += 1;

        if (st === "completed") {
          const paymentStatus = String(doc.get("paymentStatus") ?? "").trim().toLowerCase();
          const balanceAmount = asNumber(doc.get("balanceAmount") ?? doc.get("balance") ?? 0, 0);
          const paidAmount = asNumber(doc.get("paidAmount") ?? 0, 0);
          const totalAmount = asNumber(doc.get("totalAmount") ?? doc.get("totalPrice") ?? 0, 0);
          const unpaid =
            paymentStatus === "unpaid" ||
            paymentStatus === "partial" ||
            paymentStatus === "pending" ||
            (balanceAmount > 0.009) ||
            (totalAmount > 0 && paidAmount + 0.009 < totalAmount);
          if (unpaid) unpaidCompletedToday += 1;
        }
      }

      const salesSnap = await db
        .collection(`salons/${salonId}/sales`)
        .where("soldAt", ">=", todayStart.toJSDate())
        .where("soldAt", "<", tomorrowStart.toJSDate())
        .where("status", "==", "completed")
        .get();

      let revenueToday = 0;
      let salesCount = 0;
      for (const doc of salesSnap.docs) {
        const d = doc.data() as Record<string, unknown>;
        revenueToday += asNumber(d.total ?? d.totalAmountAfterDiscount ?? d.totalAmount ?? d.subtotal, 0);
        salesCount += 1;
      }
      revenueToday = roundMoney(revenueToday);
      const averageTicket = salesCount > 0 ? roundMoney(revenueToday / salesCount) : 0;

      let checkedInEmployees = 0;
      let absentEmployees = 0;
      let attendanceIssues = 0;
      try {
        const attSnap = await db
          .collection(`salons/${salonId}/attendanceDays`)
          .where("salonId", "==", salonId)
          .where("date", ">=", todayStart.toJSDate())
          .where("date", "<", tomorrowStart.toJSDate())
          .get();

        for (const doc of attSnap.docs) {
          const day = doc.data() as Record<string, unknown>;
          const st = String(day.status ?? "").trim();
          if (st === "checkedIn" || st === "checkedOut" || st === "present" || st === "late") {
            checkedInEmployees += 1;
          }
          if (st === "absent") absentEmployees += 1;
          if (day.hasMissingPunch === true) attendanceIssues += 1;
        }
      } catch (_) {
        /* attendance schema may vary — keep zeros */
      }

      const analyticsRef = db.doc(`salons/${salonId}/analytics/monthly/${periodId}`);
      const analyticsSnap = await analyticsRef.get();
      const analytics = analyticsSnap.exists ? (analyticsSnap.data() as Record<string, unknown>) : null;

      let monthlyRevenue = roundMoney(asNumber(analytics?.grossRevenue, 0));
      let monthlyPayrollCost = roundMoney(asNumber(analytics?.payrollCost, 0));
      let monthlyExpenses = roundMoney(asNumber(analytics?.expensesTotal, 0));
      let monthlyNetProfit = roundMoney(asNumber(analytics?.netProfit, 0));
      let monthBookingsCount = Math.max(0, Math.floor(asNumber(analytics?.bookingsCount, 0)));
      let monthCompletedBookingsCount = Math.max(0, Math.floor(asNumber(analytics?.completedBookingsCount, 0)));

      let topEmployeeName = "";
      let topEmployeeRevenue = 0;
      let topServiceName = "";
      let topServiceRevenue = 0;

      const topEmployees = Array.isArray((analytics as any)?.topEmployees)
        ? ((analytics as any).topEmployees as Array<any>)
        : [];
      if (topEmployees.length > 0) {
        topEmployeeName = String(topEmployees[0]?.employeeName ?? "").trim();
        topEmployeeRevenue = roundMoney(asNumber(topEmployees[0]?.salesTotal, 0));
      }

      const topServices = Array.isArray((analytics as any)?.topServices)
        ? ((analytics as any).topServices as Array<any>)
        : [];
      if (topServices.length > 0) {
        topServiceName = String(topServices[0]?.serviceName ?? "").trim();
        topServiceRevenue = roundMoney(asNumber(topServices[0]?.revenue, 0));
      }

      if (!analyticsSnap.exists) {
        const salesMonthSnap = await db
          .collection(`salons/${salonId}/sales`)
          .where("reportYear", "==", year)
          .where("reportMonth", "==", month)
          .where("status", "==", "completed")
          .get();
        let gross = 0;
        for (const doc of salesMonthSnap.docs) {
          const d = doc.data() as Record<string, unknown>;
          gross += asNumber(d.total ?? d.totalAmountAfterDiscount ?? d.totalAmount ?? d.subtotal, 0);
        }
        monthlyRevenue = roundMoney(gross);

        const expensesSnap = await db
          .collection(`salons/${salonId}/expenses`)
          .where("reportYear", "==", year)
          .where("reportMonth", "==", month)
          .get();
        let exp = 0;
        for (const doc of expensesSnap.docs) {
          exp += asNumber(doc.get("amount") ?? 0, 0);
        }
        monthlyExpenses = roundMoney(exp);

        const payslipsSnap = await db
          .collection(`salons/${salonId}/payslips`)
          .where("year", "==", year)
          .where("month", "==", month)
          .where("status", "==", "paid")
          .get();
        let payroll = 0;
        for (const doc of payslipsSnap.docs) {
          payroll += asNumber(doc.get("netPay") ?? 0, 0);
        }
        monthlyPayrollCost = roundMoney(payroll);

        monthlyNetProfit = roundMoney(monthlyRevenue - monthlyPayrollCost - monthlyExpenses);

        const bookingsMonthSnap = await db
          .collection(`salons/${salonId}/bookings`)
          .where("reportYear", "==", year)
          .where("reportMonth", "==", month)
          .get();
        monthBookingsCount = bookingsMonthSnap.size;
        monthCompletedBookingsCount = 0;
        for (const doc of bookingsMonthSnap.docs) {
          const st = String(doc.get("status") ?? "").trim();
          if (st === "completed") monthCompletedBookingsCount += 1;
        }
      }

      const conversionRate =
        monthBookingsCount > 0
          ? roundMoney((monthCompletedBookingsCount / monthBookingsCount) * 100)
          : 0;

      let payrollDraftCount = 0;
      try {
        const draftRuns = await db
          .collection(`salons/${salonId}/payroll_runs`)
          .where("year", "==", year)
          .where("month", "==", month)
          .where("status", "==", "draft")
          .limit(5)
          .get();
        payrollDraftCount = draftRuns.size;
      } catch (_) {
        payrollDraftCount = 0;
      }

      const alertMissingCheckouts = attendanceIssues;
      const alertUnpaidCompletedBookings = unpaidCompletedToday;
      const alertPayrollNeedsApproval = payrollDraftCount > 0 ? 1 : 0;
      const alertLowBookingConversion =
        monthBookingsCount >= 10 && conversionRate < 25 ? 1 : 0;

      const dailyDocId = `daily_${dateKey}`;
      const monthlyDocId = `monthly_${periodId}`;
      const dailyRef = db.doc(`salons/${salonId}/dashboardSnapshots/${dailyDocId}`);
      const monthlyRef = db.doc(`salons/${salonId}/dashboardSnapshots/${monthlyDocId}`);

      const now = FieldValue.serverTimestamp();

      const dailyPayload: Record<string, unknown> = {
        salonId,
        snapshotType: "daily",
        dateKey,
        revenueToday,
        bookingsToday,
        pendingBookings,
        completedBookings,
        cancelledBookings,
        checkedInEmployees,
        absentEmployees,
        attendanceIssues,
        salesCount,
        averageTicket,
        alertMissingCheckouts,
        alertUnpaidCompletedBookings,
        generatedAt: now,
        updatedAt: now,
      };

      const monthlyPayload: Record<string, unknown> = {
        salonId,
        snapshotType: "monthly",
        periodId,
        monthlyRevenue,
        monthlyPayrollCost,
        monthlyExpenses,
        monthlyNetProfit,
        bookingsCount: monthBookingsCount,
        completedBookingsCount: monthCompletedBookingsCount,
        conversionRate,
        topEmployeeName,
        topEmployeeRevenue,
        topServiceName,
        topServiceRevenue,
        alertPayrollNeedsApproval,
        alertLowBookingConversion,
        generatedAt: now,
        updatedAt: now,
      };

      await Promise.all([
        dailyRef.set(dailyPayload, { merge: true }),
        monthlyRef.set(monthlyPayload, { merge: true }),
      ]);

      const dailyRead = await dailyRef.get();
      const monthlyRead = await monthlyRef.get();

      return {
        ok: true,
        dailyId: dailyDocId,
        monthlyId: monthlyDocId,
        daily: dailyRead.data() ?? {},
        monthly: monthlyRead.data() ?? {},
      };
    } catch (e: unknown) {
      if (e instanceof HttpsError) throw e;
      console.error("generateOwnerDashboardSnapshot failed", e);
      throw new HttpsError("internal", "Snapshot generation failed");
    }
  },
);
