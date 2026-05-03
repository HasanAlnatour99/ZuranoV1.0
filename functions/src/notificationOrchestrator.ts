import { getFirestore, type DocumentData } from "firebase-admin/firestore";

import {
  bookingDeepLinkData,
  deliverTemplatedNotification,
  expenseDeepLinkData,
  payrollDeepLinkData,
  saleDeepLinkData,
  violationDeepLinkData,
} from "./notificationDispatch";
import { getEmployeeAuthUid, listOwnerAdminUserIds } from "./notificationSalonUsers";

const db = getFirestore();

async function salonCurrencyCode(salonId: string): Promise<string> {
  const snap = await db.collection("salons").doc(salonId).get();
  const raw = snap.data()?.currencyCode;
  const s = typeof raw === "string" ? raw.trim() : "";
  return s.length > 0 ? s : "USD";
}

function saleSummaryFromDoc(d: DocumentData): string {
  const sn = d.serviceNames;
  if (Array.isArray(sn)) {
    const joined = sn
      .filter((x: unknown): x is string => typeof x === "string" && x.trim().length > 0)
      .join(", ")
      .trim();
    if (joined.length > 0) {
      return joined.slice(0, 140);
    }
  }
  const lines = d.lineItems;
  if (!Array.isArray(lines)) {
    return "services";
  }
  const parts: string[] = [];
  for (const entry of lines) {
    if (entry !== null && typeof entry === "object") {
      const name = typeof (entry as { serviceName?: string }).serviceName === "string"
        ? ((entry as { serviceName?: string }).serviceName ?? "").trim()
        : "";
      if (name.length > 0) {
        parts.push(name);
      }
    }
  }
  const out = [...new Set(parts)].join(", ").trim();
  return out.length > 0 ? out.slice(0, 140) : "services";
}

export async function notifyExpenseCreated(params: {
  salonId: string;
  expenseId: string;
  title?: string;
  amount?: number;
}): Promise<void> {
  const currency = await salonCurrencyCode(params.salonId);
  const title =
    typeof params.title === "string" && params.title.trim().length > 0
      ? params.title.trim()
      : "Expense";
  const amountLabel =
    typeof params.amount === "number" && Number.isFinite(params.amount)
      ? params.amount.toFixed(2)
      : "—";

  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: "expense_added",
      dedupeKey: `expense_added:${params.expenseId}:${userId}`,
      data: expenseDeepLinkData(params.salonId, params.expenseId),
      actorRole: "system",
      salonId: params.salonId,
      expenseId: params.expenseId,
      templateVars: {
        title,
        amount: amountLabel,
        currency,
      },
    });
  }
}

export async function notifySaleRecordedForOwners(params: {
  salonId: string;
  saleId: string;
  employeeName?: string;
  total?: number;
  documentData?: DocumentData;
}): Promise<void> {
  const currency = await salonCurrencyCode(params.salonId);
  const servicesLabel = params.documentData
    ? saleSummaryFromDoc(params.documentData)
    : "services";
  const emp =
    typeof params.employeeName === "string" && params.employeeName.trim().length > 0
      ? params.employeeName.trim()
      : "Team member";
  const totalLabel =
    typeof params.total === "number" && Number.isFinite(params.total)
      ? params.total.toFixed(2)
      : "—";

  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: "sale_recorded",
      dedupeKey: `sale_recorded:${params.saleId}:${userId}`,
      data: saleDeepLinkData(params.salonId, params.saleId),
      actorRole: "system",
      salonId: params.salonId,
      saleId: params.saleId,
      employeeId:
        typeof params.documentData?.employeeId === "string"
          ? (params.documentData.employeeId as string)
          : undefined,
      templateVars: {
        employeeName: emp,
        services: servicesLabel,
        total: totalLabel,
        currency,
      },
    });
  }
}

export async function notifyNewBookingAssigned(params: {
  salonId: string;
  bookingId: string;
  barberId: string;
}): Promise<void> {
  const uid = await getEmployeeAuthUid(params.salonId, params.barberId);
  if (!uid) {
    return;
  }
  await deliverTemplatedNotification({
    userId: uid,
    eventType: "new_booking_assigned",
    dedupeKey: `new_booking_assigned:${params.bookingId}:${uid}`,
    data: bookingDeepLinkData(params.salonId, params.bookingId),
    actorRole: "system",
    salonId: params.salonId,
    bookingId: params.bookingId,
    employeeId: params.barberId,
  });
}

export async function notifyBookingCancelled(params: {
  salonId: string;
  bookingId: string;
  customerId: string;
  barberId: string;
}): Promise<void> {
  const barberUid = await getEmployeeAuthUid(params.salonId, params.barberId);
  const targets = new Set<string>([params.customerId]);
  if (barberUid) {
    targets.add(barberUid);
  }
  for (const userId of targets) {
    await deliverTemplatedNotification({
      userId,
      eventType: "booking_cancelled",
      dedupeKey: `booking_cancelled:${params.bookingId}:${userId}`,
      data: bookingDeepLinkData(params.salonId, params.bookingId),
      actorRole: "system",
      salonId: params.salonId,
      bookingId: params.bookingId,
      employeeId: params.barberId,
    });
  }
}

export async function notifyBookingRescheduled(params: {
  salonId: string;
  oldBookingId: string;
  newBookingId: string;
  customerId: string;
  barberId: string;
}): Promise<void> {
  const barberUid = await getEmployeeAuthUid(params.salonId, params.barberId);
  const targets = new Set<string>([params.customerId]);
  if (barberUid) {
    targets.add(barberUid);
  }
  for (const userId of targets) {
    await deliverTemplatedNotification({
      userId,
      eventType: "booking_rescheduled",
      dedupeKey:
        `booking_rescheduled:${params.oldBookingId}:${params.newBookingId}:${userId}`,
      data: bookingDeepLinkData(params.salonId, params.newBookingId),
      actorRole: "system",
      salonId: params.salonId,
      bookingId: params.newBookingId,
      employeeId: params.barberId,
    });
  }
}

export async function notifyBookingCompletedForCustomer(params: {
  salonId: string;
  bookingId: string;
  customerId: string;
}): Promise<void> {
  await deliverTemplatedNotification({
    userId: params.customerId,
    eventType: "booking_completed",
    dedupeKey: `booking_completed:${params.bookingId}:${params.customerId}`,
    data: bookingDeepLinkData(params.salonId, params.bookingId),
    actorRole: "system",
    salonId: params.salonId,
    bookingId: params.bookingId,
  });
}

export async function notifyNoShowToOwners(params: {
  salonId: string;
  bookingId: string;
}): Promise<void> {
  const ids = await listOwnerAdminUserIds(params.salonId);
  for (const userId of ids) {
    await deliverTemplatedNotification({
      userId,
      eventType: "no_show_recorded",
      dedupeKey: `no_show_recorded:${params.bookingId}:${userId}`,
      data: bookingDeepLinkData(params.salonId, params.bookingId),
      actorRole: "system",
      salonId: params.salonId,
      bookingId: params.bookingId,
    });
  }
}

export async function notifyBookingConfirmedForCustomer(params: {
  salonId: string;
  bookingId: string;
  customerId: string;
}): Promise<void> {
  await deliverTemplatedNotification({
    userId: params.customerId,
    eventType: "booking_confirmed",
    dedupeKey: `booking_confirmed:${params.bookingId}:${params.customerId}`,
    data: bookingDeepLinkData(params.salonId, params.bookingId),
    actorRole: "system",
    salonId: params.salonId,
    bookingId: params.bookingId,
  });
}

export async function notifyViolationCreated(params: {
  salonId: string;
  violationId: string;
  employeeId: string;
  bookingId: string;
}): Promise<void> {
  const barberUid = await getEmployeeAuthUid(params.salonId, params.employeeId);
  if (barberUid) {
    await deliverTemplatedNotification({
      userId: barberUid,
      eventType: "violation_created",
      dedupeKey: `violation_created:${params.violationId}:${barberUid}`,
      data: violationDeepLinkData(params.salonId, params.violationId),
      actorRole: "system",
      salonId: params.salonId,
      bookingId: params.bookingId,
      employeeId: params.employeeId,
      violationId: params.violationId,
    });
  }
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    if (barberUid && userId === barberUid) {
      continue;
    }
    await deliverTemplatedNotification({
      userId,
      eventType: "violation_created",
      dedupeKey: `violation_created:${params.violationId}:${userId}:admin`,
      data: violationDeepLinkData(params.salonId, params.violationId),
      actorRole: "system",
      salonId: params.salonId,
      bookingId: params.bookingId,
      employeeId: params.employeeId,
      violationId: params.violationId,
    });
  }
}

export async function notifyPayrollCreated(params: {
  salonId: string;
  payrollId: string;
  employeeId: string;
}): Promise<void> {
  const barberUid = await getEmployeeAuthUid(params.salonId, params.employeeId);
  if (barberUid) {
    await deliverTemplatedNotification({
      userId: barberUid,
      eventType: "payroll_ready",
      dedupeKey: `payroll_ready:${params.payrollId}:${barberUid}`,
      data: payrollDeepLinkData(params.salonId, params.payrollId),
      actorRole: "system",
      salonId: params.salonId,
      payrollId: params.payrollId,
      employeeId: params.employeeId,
    });
  }
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: "payroll_generated",
      dedupeKey: `payroll_generated:${params.payrollId}:${userId}`,
      data: payrollDeepLinkData(params.salonId, params.payrollId),
      actorRole: "system",
      salonId: params.salonId,
      payrollId: params.payrollId,
      employeeId: params.employeeId,
    });
  }
}

export async function notifyAttendanceCheckIn(params: {
  salonId: string;
  attendanceId: string;
  employeeId: string;
  employeeName: string;
}): Promise<void> {
  const name = params.employeeName.trim() || "Team member";
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: "attendance_check_in",
      dedupeKey: `attendance_check_in:${params.attendanceId}:${userId}`,
      data: { route: "attendance", salonId: params.salonId },
      actorRole: "system",
      salonId: params.salonId,
      employeeId: params.employeeId,
      attendanceId: params.attendanceId,
      templateVars: { employeeName: name },
    });
  }
}

export async function notifyAttendanceLate(params: {
  salonId: string;
  attendanceId: string;
  employeeId: string;
  employeeName: string;
}): Promise<void> {
  const name = params.employeeName.trim() || "Team member";
  const targets = new Set<string>(await listOwnerAdminUserIds(params.salonId));
  const barberUid = await getEmployeeAuthUid(params.salonId, params.employeeId);
  if (barberUid) {
    targets.add(barberUid);
  }
  for (const userId of targets) {
    await deliverTemplatedNotification({
      userId,
      eventType: "attendance_late",
      dedupeKey: `attendance_late:${params.attendanceId}:${userId}`,
      data: { route: "attendance", salonId: params.salonId },
      actorRole: "system",
      salonId: params.salonId,
      employeeId: params.employeeId,
      attendanceId: params.attendanceId,
      templateVars: { employeeName: name },
    });
  }
}

export async function notifyAttendanceCorrectionRequested(params: {
  salonId: string;
  requestId: string;
  employeeId: string;
  attendanceId: string;
}): Promise<void> {
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: "attendance_correction_requested",
      dedupeKey: `attendance_correction:${params.requestId}:${userId}`,
      data: { route: "approval", salonId: params.salonId },
      actorRole: "system",
      salonId: params.salonId,
      employeeId: params.employeeId,
      attendanceId: params.attendanceId,
      templateVars: {},
    });
  }
}

export async function notifyServiceCatalogChange(params: {
  salonId: string;
  serviceId: string;
  eventType: "service_created" | "service_updated" | "service_deleted";
  serviceName: string;
}): Promise<void> {
  const label = params.serviceName.trim() || "Service";
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: params.eventType,
      dedupeKey: `${params.eventType}:${params.serviceId}:${userId}`,
      data: { route: "service", salonId: params.salonId },
      actorRole: "system",
      salonId: params.salonId,
      serviceId: params.serviceId,
      templateVars: { serviceName: label },
    });
  }
}

export async function notifyEmployeeLifecycle(params: {
  salonId: string;
  employeeId: string;
  eventType: "employee_created" | "employee_reactivated" | "employee_frozen";
  name: string;
}): Promise<void> {
  const label = params.name.trim() || "Team member";
  const staff = await listOwnerAdminUserIds(params.salonId);
  for (const userId of staff) {
    await deliverTemplatedNotification({
      userId,
      eventType: params.eventType,
      dedupeKey: `${params.eventType}:${params.employeeId}:${userId}`,
      data: { route: "employee", salonId: params.salonId },
      actorRole: "system",
      salonId: params.salonId,
      employeeId: params.employeeId,
      templateVars: { name: label },
    });
  }
}

export async function notifyOwnerDigest(params: {
  salonId: string;
  ownerUid: string;
  eventType: "daily_summary" | "monthly_summary";
  summary: string;
  dedupeKey: string;
}): Promise<void> {
  await deliverTemplatedNotification({
    userId: params.ownerUid,
    eventType: params.eventType,
    dedupeKey: params.dedupeKey,
    data: { route: "summary", salonId: params.salonId },
    actorRole: "system",
    salonId: params.salonId,
    templateVars: { summary: params.summary },
  });
}

export async function loadBookingParticipants(
  salonId: string,
  bookingId: string,
): Promise<{ customerId: string; barberId: string } | null> {
  const snap = await db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId)
    .get();
  if (!snap.exists) {
    return null;
  }
  const customerId = snap.get("customerId");
  const barberId = snap.get("barberId");
  if (typeof customerId !== "string" || typeof barberId !== "string") {
    return null;
  }
  return { customerId, barberId };
}
