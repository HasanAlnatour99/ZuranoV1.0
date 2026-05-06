import type { Transaction } from "firebase-admin/firestore";
import {
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  notifyBookingCancelled,
  notifyBookingRescheduled,
  notifyNewBookingAssigned,
} from "./notificationOrchestrator";

const db = getFirestore();

const BookingStatuses = {
  pending: "pending",
  confirmed: "confirmed",
  completed: "completed",
  cancelled: "cancelled",
  noShow: "no_show",
  rescheduled: "rescheduled",
} as const;

/** Legacy `scheduled` is treated as [BookingStatuses.pending] everywhere. */
function normalizeBookingStatus(raw: string): string {
  const s = raw.trim();
  if (!s || s === "scheduled") {
    return BookingStatuses.pending;
  }
  return s;
}

const ACTIVE_OVERLAP = new Set<string>([
  BookingStatuses.pending,
  BookingStatuses.confirmed,
]);

const NON_RESCHEDULABLE = new Set<string>([
  BookingStatuses.cancelled,
  BookingStatuses.completed,
  BookingStatuses.noShow,
  BookingStatuses.rescheduled,
]);

function requireString(data: Record<string, unknown>, key: string): string {
  const v = data[key];
  if (typeof v !== "string" || v.length === 0) {
    throw new HttpsError("invalid-argument", `Missing or invalid ${key}.`);
  }
  return v;
}

function requireNumber(data: Record<string, unknown>, key: string): number {
  const v = data[key];
  const n = typeof v === "number" ? v : Number(v);
  if (!Number.isFinite(n)) {
    throw new HttpsError("invalid-argument", `Missing or invalid ${key}.`);
  }
  return n;
}

function msToDate(ms: unknown): Date {
  const n = typeof ms === "number" ? ms : Number(ms);
  if (!Number.isFinite(n)) {
    throw new HttpsError("invalid-argument", "Invalid timestamp.");
  }
  return new Date(n);
}

function assertSlotStep(slotStepMinutes: number): void {
  if (slotStepMinutes !== 15 && slotStepMinutes !== 30) {
    throw new HttpsError(
      "invalid-argument",
      "slotStepMinutes must be 15 or 30.",
    );
  }
}

function isUtcSlotAligned(d: Date, slotStepMinutes: number): boolean {
  if (d.getUTCMilliseconds() !== 0) {
    return false;
  }
  const midnight = Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
  );
  const minutes = Math.floor((d.getTime() - midnight) / 60000);
  return minutes % slotStepMinutes === 0;
}

function assertSlotRange(
  startAt: Date,
  endAt: Date,
  slotStepMinutes: number,
): void {
  assertSlotStep(slotStepMinutes);
  if (!(endAt.getTime() > startAt.getTime())) {
    throw new HttpsError("invalid-argument", "endAt must be after startAt.");
  }
  if (!isUtcSlotAligned(startAt, slotStepMinutes) ||
    !isUtcSlotAligned(endAt, slotStepMinutes)) {
    throw new HttpsError(
      "invalid-argument",
      `startAt and endAt must align to ${slotStepMinutes}-minute UTC slots.`,
    );
  }
  const durationMin = (endAt.getTime() - startAt.getTime()) / 60000;
  if (durationMin % slotStepMinutes !== 0 || durationMin < slotStepMinutes) {
    throw new HttpsError(
      "invalid-argument",
      `Duration must be a positive multiple of ${slotStepMinutes} minutes.`,
    );
  }
}

function reportFieldsFromStart(startAt: Date): {
  reportYear: number;
  reportMonth: number;
  reportPeriodKey: string;
} {
  const reportYear = startAt.getUTCFullYear();
  const reportMonth = startAt.getUTCMonth() + 1;
  const reportPeriodKey =
    `${reportYear}-${String(reportMonth).padStart(2, "0")}`;
  return { reportYear, reportMonth, reportPeriodKey };
}

function intervalsOverlap(
  aStart: Date,
  aEnd: Date,
  bStart: Date,
  bEnd: Date,
): boolean {
  return aStart.getTime() < bEnd.getTime() &&
    aEnd.getTime() > bStart.getTime();
}

type UserProfile = {
  role: string;
  salonId: string | null;
  employeeId: string | null;
};

async function loadUserProfile(uid: string): Promise<UserProfile> {
  const u = await db.collection("users").doc(uid).get();
  if (!u.exists) {
    throw new HttpsError("permission-denied", "User profile not found.");
  }
  const role = (u.get("role") as string | undefined) ?? "";
  const salonRaw = u.get("salonId");
  const salonId = typeof salonRaw === "string" && salonRaw.length > 0
    ? salonRaw
    : null;
  const empRaw = u.get("employeeId");
  const employeeId = typeof empRaw === "string" && empRaw.length > 0
    ? empRaw
    : null;
  return { role, salonId, employeeId };
}

/** Customers may book without `users.salonId`; staff must belong to the salon. */
async function assertCanCreateBooking(
  uid: string,
  salonId: string,
  bookingBarberId: string,
  bookingCustomerId: string,
): Promise<UserProfile> {
  const user = await loadUserProfile(uid);
  if (user.role === "customer") {
    if (bookingCustomerId !== uid) {
      throw new HttpsError(
        "permission-denied",
        "Customers may only create bookings for themselves.",
      );
    }
    return user;
  }
  if (user.salonId !== salonId) {
    throw new HttpsError(
      "permission-denied",
      "User does not belong to this salon.",
    );
  }
  if (user.role === "owner" || user.role === "admin") {
    return user;
  }
  if (user.role === "barber") {
    if (!user.employeeId || user.employeeId !== bookingBarberId) {
      throw new HttpsError(
        "permission-denied",
        "Barbers may only create bookings for their own chair.",
      );
    }
    return user;
  }
  throw new HttpsError("permission-denied", "Not allowed to create bookings.");
}

function assertCanCancelBooking(
  user: UserProfile,
  uid: string,
  salonId: string,
  booking: Record<string, unknown>,
): void {
  const pathSalon = (booking.salonId as string) ?? "";
  if (pathSalon !== salonId) {
    throw new HttpsError("failed-precondition", "Booking salon mismatch.");
  }
  const customerId = (booking.customerId as string) ?? "";
  const barberId = (booking.barberId as string) ?? "";

  if (user.role === "customer") {
    const createdBy = `${booking.createdByAuthUid ?? ""}`.trim();
    const guestUid = `${booking.guestUid ?? ""}`.trim();
    if (customerId === uid || createdBy === uid || guestUid === uid) {
      return;
    }
    throw new HttpsError(
      "permission-denied",
      "Unauthorized role: not your booking.",
    );
  }
  if (user.salonId !== salonId) {
    throw new HttpsError(
      "permission-denied",
      "Unauthorized role: not a member of this salon.",
    );
  }
  if (user.role === "owner" || user.role === "admin") {
    return;
  }
  if (user.role === "barber") {
    if (!user.employeeId || user.employeeId !== barberId) {
      throw new HttpsError(
        "permission-denied",
        "Unauthorized role: barbers may only cancel bookings for their chair.",
      );
    }
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Unauthorized role: not allowed to cancel bookings.",
  );
}

function assertCanRescheduleBooking(
  user: UserProfile,
  uid: string,
  salonId: string,
  booking: Record<string, unknown>,
): void {
  const pathSalon = (booking.salonId as string) ?? "";
  if (pathSalon !== salonId) {
    throw new HttpsError("failed-precondition", "Booking salon mismatch.");
  }
  const customerId = (booking.customerId as string) ?? "";
  const barberId = (booking.barberId as string) ?? "";

  if (user.role === "customer") {
    const createdBy = `${booking.createdByAuthUid ?? ""}`.trim();
    const guestUid = `${booking.guestUid ?? ""}`.trim();
    if (customerId === uid || createdBy === uid || guestUid === uid) {
      return;
    }
    throw new HttpsError(
      "permission-denied",
      "Unauthorized role: not your booking.",
    );
  }
  if (user.salonId !== salonId) {
    throw new HttpsError(
      "permission-denied",
      "Unauthorized role: not a member of this salon.",
    );
  }
  if (user.role === "owner" || user.role === "admin") {
    return;
  }
  if (user.role === "barber") {
    if (!user.employeeId || user.employeeId !== barberId) {
      throw new HttpsError(
        "permission-denied",
        "Unauthorized role: barbers may only reschedule their own bookings.",
      );
    }
    return;
  }
  throw new HttpsError(
    "permission-denied",
    "Unauthorized role: not allowed to reschedule bookings.",
  );
}

function assertCancelStatusTransition(from: string): void {
  if (
    from !== BookingStatuses.pending && from !== BookingStatuses.confirmed
  ) {
    throw new HttpsError(
      "failed-precondition",
      `Cannot cancel booking with status "${from}".`,
    );
  }
}

function assertRescheduleStatusTransition(from: string): void {
  if (
    from !== BookingStatuses.pending && from !== BookingStatuses.confirmed
  ) {
    throw new HttpsError(
      "failed-precondition",
      `Cannot reschedule booking with status "${from}".`,
    );
  }
}

/** Domain errors for cancel/reschedule — keep messages stable for client mapping. */
const MSG_ALREADY_ENDED = "Booking already ended.";
const MSG_ALREADY_CANCELLED = "Booking already cancelled.";
const MSG_ALREADY_RESCHEDULED = "Booking already rescheduled.";
const MSG_STALE_STATE = "Booking state changed; refresh and try again.";

async function assertNoOverlapInTransaction(
  txn: Transaction,
  salonId: string,
  barberId: string,
  startAt: Date,
  endAt: Date,
  excludeBookingId: string | undefined,
): Promise<void> {
  if (!barberId) {
    return;
  }
  const windowStart = new Date(startAt.getTime() - 7 * 86400000);
  const windowEnd = new Date(endAt.getTime() + 7 * 86400000);
  const q = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .where("barberId", "==", barberId)
    .where("startAt", ">=", Timestamp.fromDate(windowStart))
    .where("startAt", "<=", Timestamp.fromDate(windowEnd))
    .orderBy("startAt")
    .limit(500);

  const snap = await txn.get(q);
  for (const doc of snap.docs) {
    if (excludeBookingId && doc.id === excludeBookingId) {
      continue;
    }
    const data = doc.data();
    const status = normalizeBookingStatus((data.status as string) ?? "");
    if (!ACTIVE_OVERLAP.has(status)) {
      continue;
    }
    const s = (data.startAt as Timestamp | undefined)?.toDate();
    const e = (data.endAt as Timestamp | undefined)?.toDate();
    if (!s || !e) {
      continue;
    }
    if (intervalsOverlap(startAt, endAt, s, e)) {
      throw new HttpsError(
        "failed-precondition",
        "Booking overlap: this time conflicts with another active booking for that barber.",
      );
    }
  }
}

function bookingEndAt(booking: Record<string, unknown>): Date | null {
  const t = booking.endAt as Timestamp | undefined;
  return t ? t.toDate() : null;
}

export const bookingCreate = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");

  const slotStepMinutes = requireNumber(data, "slotStepMinutes");
  assertSlotStep(slotStepMinutes);

  const bookingRaw = data.booking as Record<string, unknown>;
  if (!bookingRaw || typeof bookingRaw !== "object") {
    throw new HttpsError("invalid-argument", "booking payload required.");
  }

  const startAt = msToDate(bookingRaw.startAtMs);
  const endAt = msToDate(bookingRaw.endAtMs);
  assertSlotRange(startAt, endAt, slotStepMinutes);

  const barberId = requireString(bookingRaw, "barberId");
  const customerId = requireString(bookingRaw, "customerId");
  await assertCanCreateBooking(uid, salonId, barberId, customerId);

  const statusRaw = bookingRaw.status;
  const requested = typeof statusRaw === "string" ? statusRaw : "";
  const normalizedRequest = normalizeBookingStatus(requested);
  if (normalizedRequest !== BookingStatuses.pending) {
    throw new HttpsError(
      "invalid-argument",
      "New bookings must start as pending.",
    );
  }
  const status = BookingStatuses.pending;

  const idHint = typeof bookingRaw.id === "string" ? bookingRaw.id : "";
  const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromStart(
    startAt,
  );

  const bookingId = await db.runTransaction(async (txn) => {
    await assertNoOverlapInTransaction(
      txn,
      salonId,
      barberId,
      startAt,
      endAt,
      undefined,
    );

    const col = db.collection("salons").doc(salonId).collection("bookings");
    const docRef = idHint.length > 0 ? col.doc(idHint) : col.doc();

    const payload: Record<string, unknown> = {
      id: docRef.id,
      salonId,
      barberId,
      customerId,
      status,
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      reportYear,
      reportMonth,
      reportPeriodKey,
      slotStepMinutes,
      barberName: bookingRaw.barberName ?? null,
      customerName: bookingRaw.customerName ?? null,
      serviceId: bookingRaw.serviceId ?? null,
      serviceName: bookingRaw.serviceName ?? null,
      notes: bookingRaw.notes ?? null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    txn.set(docRef, payload);
    return docRef.id;
  });

  void notifyNewBookingAssigned({
    salonId,
    bookingId,
    barberId,
  }).catch((err) => console.error("notifyNewBookingAssigned", err));

  return { bookingId };
});

export const bookingCancel = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  const user = await loadUserProfile(uid);
  const ref = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);

  const txResult = await db.runTransaction(async (txn) => {
    const snap = await txn.get(ref);
    if (!snap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = snap.data()!;
    assertCanCancelBooking(user, uid, salonId, b as Record<string, unknown>);
    const st = normalizeBookingStatus((b.status as string) ?? "");

    if (st === BookingStatuses.cancelled) {
      return { kind: "idempotent" as const };
    }
    if (st === BookingStatuses.rescheduled) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_RESCHEDULED);
    }
    if (st === BookingStatuses.completed || st === BookingStatuses.noShow) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_ENDED);
    }
    assertCancelStatusTransition(st);

    const endPrev = bookingEndAt(b as Record<string, unknown>);
    if (!endPrev || endPrev.getTime() <= Date.now()) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_ENDED);
    }

    txn.update(ref, {
      status: BookingStatuses.cancelled,
      cancelledAt: FieldValue.serverTimestamp(),
      cancelledByRole: user.role,
      cancelledByUserId: uid,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { kind: "ok" as const };
  });

  if (txResult.kind === "idempotent") {
    return { ok: true, idempotent: true };
  }
  const after = await ref.get();
  const bd = after.data();
  if (bd) {
    const customerId = (bd.customerId as string) ?? "";
    const barberId = (bd.barberId as string) ?? "";
    if (customerId && barberId) {
      void notifyBookingCancelled({
        salonId,
        bookingId,
        customerId,
        barberId,
      }).catch((err) => console.error("notifyBookingCancelled", err));
    }
  }
  return { ok: true };
});

export const bookingReschedule = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const slotStepMinutes = requireNumber(data, "slotStepMinutes");
  const startAt = msToDate(data.startAtMs);
  const endAt = msToDate(data.endAtMs);
  assertSlotRange(startAt, endAt, slotStepMinutes);

  const user = await loadUserProfile(uid);
  const oldRef = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);

  const txResult = await db.runTransaction(async (txn) => {
    const oldSnap = await txn.get(oldRef);
    if (!oldSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = oldSnap.data()!;
    const bookingMap = b as Record<string, unknown>;
    assertCanRescheduleBooking(user, uid, salonId, bookingMap);

    const st = normalizeBookingStatus((b.status as string) ?? "");
    if (st === BookingStatuses.rescheduled) {
      const toRaw = b.rescheduledToBookingId;
      const toId = typeof toRaw === "string" ? toRaw : "";
      if (toId.length > 0) {
        return { kind: "idempotent" as const, newBookingId: toId };
      }
      throw new HttpsError("failed-precondition", MSG_ALREADY_RESCHEDULED);
    }
    if (st === BookingStatuses.cancelled) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_CANCELLED);
    }
    if (st === BookingStatuses.completed || st === BookingStatuses.noShow) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_ENDED);
    }
    if (NON_RESCHEDULABLE.has(st)) {
      throw new HttpsError(
        "failed-precondition",
        `Cannot reschedule booking with status "${st}".`,
      );
    }
    assertRescheduleStatusTransition(st);

    const endPrev = bookingEndAt(bookingMap);
    if (!endPrev || endPrev.getTime() <= Date.now()) {
      throw new HttpsError("failed-precondition", MSG_ALREADY_ENDED);
    }

    const barberId = (b.barberId as string) ?? "";
    await assertNoOverlapInTransaction(
      txn,
      salonId,
      barberId,
      startAt,
      endAt,
      bookingId,
    );

    const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromStart(
      startAt,
    );

    const col = db.collection("salons").doc(salonId).collection("bookings");
    const newRef = col.doc();

    const newPayload: Record<string, unknown> = {
      id: newRef.id,
      salonId,
      barberId: b.barberId ?? null,
      customerId: b.customerId ?? null,
      status: BookingStatuses.pending,
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      reportYear,
      reportMonth,
      reportPeriodKey,
      slotStepMinutes,
      barberName: b.barberName ?? null,
      customerName: b.customerName ?? null,
      serviceId: b.serviceId ?? null,
      serviceName: b.serviceName ?? null,
      notes: b.notes ?? null,
      rescheduledFromBookingId: bookingId,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    const recheck = await txn.get(oldRef);
    if (!recheck.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b2 = recheck.data()!;
    const st2 = normalizeBookingStatus((b2.status as string) ?? "");
    if (
      st2 !== BookingStatuses.pending && st2 !== BookingStatuses.confirmed
    ) {
      throw new HttpsError("failed-precondition", MSG_STALE_STATE);
    }

    txn.set(newRef, newPayload);
    txn.update(oldRef, {
      status: BookingStatuses.rescheduled,
      rescheduledToBookingId: newRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { kind: "ok" as const, newBookingId: newRef.id };
  });

  if (txResult.kind === "idempotent") {
    return {
      ok: true,
      newBookingId: txResult.newBookingId,
      idempotent: true,
    };
  }
  const oldSnap = await oldRef.get();
  const b = oldSnap.data();
  const newId = txResult.newBookingId;
  if (b && newId) {
    const customerId = (b.customerId as string) ?? "";
    const barberId = (b.barberId as string) ?? "";
    if (customerId && barberId) {
      void notifyBookingRescheduled({
        salonId,
        oldBookingId: bookingId,
        newBookingId: newId,
        customerId,
        barberId,
      }).catch((err) => console.error("notifyBookingRescheduled", err));
    }
  }
  return { ok: true, newBookingId: txResult.newBookingId };
});
