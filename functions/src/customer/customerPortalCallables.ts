/**
 * Customer HTTPS callables (App Check + Admin SDK).
 * Aligns with Flutter `FirestoreCustomerBooking*` repositories and `publicSalons` rules.
 */
import { randomInt } from "crypto";

import {
  FieldValue,
  Timestamp,
  type DocumentData,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  BookingStatuses,
  db,
  msToDate,
  normalizeBookingStatus,
  requireNumber,
  requireString,
} from "../bookingShared";

const REGION = "us-central1" as const;
const CALL = { region: REGION, enforceAppCheck: true } as const;

const BLOCKING = new Set([
  "pending",
  "confirmed",
  "checkedIn",
  "checked_in",
]);

type ParsedBookingSettings = {
  enabled: boolean;
  autoConfirmBookings: boolean;
  bufferMinutes: number;
  bookingSlotIntervalMinutes: number;
  requireBookingCodeForLookup: boolean;
  allowCustomerCancellation: boolean;
  cancellationCutoffMinutes: number;
  rescheduleCutoffMinutes: number;
  allowCustomerFeedback: boolean;
};

function normalizePublicBookingCode(raw: string): string {
  return `${raw ?? ""}`.trim().toUpperCase();
}

/** Matches [bookingNumber] or legacy [bookingCode], with optional ZR- prefix. */
function publicBookingCodesMatch(
  booking: Record<string, unknown>,
  enteredRaw: string,
): boolean {
  const entered = normalizePublicBookingCode(enteredRaw);
  if (!entered) {
    return false;
  }
  const num = `${booking.bookingNumber ?? ""}`.trim().toUpperCase();
  const leg = `${booking.bookingCode ?? ""}`.trim().toUpperCase();
  if (entered === num || entered === leg) {
    return true;
  }
  const digits = entered.startsWith("ZR-") ? entered.slice(3) : entered;
  if (digits.length === 6 && leg === digits) {
    return true;
  }
  if (leg.length === 6 && entered === `ZR-${leg}`) {
    return true;
  }
  return false;
}

function assertCustomerBookingIdentity(
  auth: { uid: string } | undefined,
  booking: Record<string, unknown>,
  phoneNormalized: string,
  bookingCodeUpper: string,
): void {
  const uid = auth?.uid != null ? `${auth.uid}`.trim() : "";
  const guestUid = `${booking.guestUid ?? ""}`.trim();
  const createdBy = `${booking.createdByAuthUid ?? ""}`.trim();
  const uidOk = uid.length > 0 && (uid === guestUid || uid === createdBy);

  if (uidOk) {
    return;
  }
  if (phoneNormalized.length === 0 || bookingCodeUpper.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "phone_and_booking_code_required",
    );
  }
  if (`${booking.customerPhoneNormalized ?? ""}`.trim() !== phoneNormalized) {
    throw new HttpsError("permission-denied", "Phone does not match booking.");
  }
  if (!publicBookingCodesMatch(booking, bookingCodeUpper)) {
    throw new HttpsError("permission-denied", "Booking code does not match.");
  }
}

function parseBookingSettings(raw: unknown): ParsedBookingSettings {
  const map = raw && typeof raw === "object"
    ? (raw as Record<string, unknown>)
    : {};
  const bool = (k: string, d: boolean) => (typeof map[k] === "boolean" ? (map[k] as boolean) : d);
  const int = (k: string, d: number) => {
    const n = typeof map[k] === "number" ? (map[k] as number) : Number(map[k]);
    return Number.isFinite(n) ? Math.trunc(n) : d;
  };
  const cancelHours = int("cancellationNoticeHours", 4);
  const slot = int("slotDurationMinutes", int("bookingSlotIntervalMinutes", 30));
  return {
    enabled: bool("customerBookingEnabled", bool("enabled", true)),
    autoConfirmBookings: bool("autoConfirmBookings", false),
    bufferMinutes: Math.min(240, Math.max(0, int("bufferMinutes", 10))),
    bookingSlotIntervalMinutes: slot > 0 ? slot : 30,
    requireBookingCodeForLookup: bool("requireBookingCodeForLookup", false),
    allowCustomerCancellation: bool("allowCustomerCancellation", true),
    cancellationCutoffMinutes: int("cancellationCutoffMinutes", cancelHours * 60),
    rescheduleCutoffMinutes: int("rescheduleCutoffMinutes", 120),
    allowCustomerFeedback: bool("allowCustomerFeedback", true),
  };
}

async function loadPublicSalon(salonId: string): Promise<{ data: DocumentData }> {
  const ref = db.doc(`publicSalons/${salonId}`);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Salon not found.");
  }
  const data = snap.data()!;
  if (data.isPublic !== true || data.isActive !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Salon is not available for booking.",
    );
  }
  return { data };
}

/** Accepts epoch ms, ISO string, or Firestore Timestamp-shaped map from clients. */
function coerceToDate(key: string, draft: Record<string, unknown>): Date {
  const direct = draft[key];
  const msKey = key === "selectedStartAt"
    ? "selectedStartAtMs"
    : key === "selectedEndAt"
    ? "selectedEndAtMs"
    : null;
  const v = direct ?? (msKey ? draft[msKey] : undefined);
  if (v == null) {
    throw new HttpsError("invalid-argument", `Missing ${key}.`);
  }
  if (typeof v === "number" && Number.isFinite(v)) {
    return new Date(v);
  }
  if (typeof v === "string" && v.length > 0) {
    const d = new Date(v);
    if (!Number.isFinite(d.getTime())) {
      throw new HttpsError("invalid-argument", `Invalid ${key}.`);
    }
    return d;
  }
  if (v instanceof Timestamp) {
    return v.toDate();
  }
  if (typeof v === "object" && v !== null && "_seconds" in v) {
    const o = v as { _seconds: number; _nanoseconds?: number };
    return new Timestamp(o._seconds, o._nanoseconds ?? 0).toDate();
  }
  throw new HttpsError("invalid-argument", `Invalid ${key}.`);
}

function weekdayKey(d: Date): string {
  return [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ][d.getUTCDay()] ?? "monday";
}

function tsToDate(v: unknown): Date | null {
  if (v instanceof Timestamp) {
    return v.toDate();
  }
  return null;
}

function stableCustomerId(phoneNormalized: string, bookingId: string): string {
  const p = phoneNormalized.trim();
  if (p.length > 0) {
    const digits = p.replace(/\D/g, "");
    return `phone_${digits}`;
  }
  return `guest_${bookingId}`;
}

function blocksSlot(
  data: DocumentData,
  employeeId: string,
  startAt: Date,
  endAt: Date,
  bufferMinutes: number,
): boolean {
  const status = `${data.status ?? ""}`.trim();
  if (!BLOCKING.has(status)) {
    return false;
  }
  const bid =
    `${data.employeeId ?? data.barberId ?? ""}`.trim();
  if (bid !== employeeId) {
    return false;
  }
  const existingStart = tsToDate(data.startAt);
  const existingEnd = tsToDate(data.endAt);
  if (!existingStart || !existingEnd) {
    return false;
  }
  const bufferMs = Math.min(240, Math.max(0, bufferMinutes)) * 60_000;
  const existingEndBuffered = new Date(existingEnd.getTime() + bufferMs);
  return existingStart < endAt && existingEndBuffered > startAt;
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

/** Guest-safe availability: public salon + same-day busy blocks. */
export const getCustomerAvailability = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const dateRaw = data.dateMs ?? data.dayStartMs ?? Date.now();
  const day = msToDate(typeof dateRaw === "number" ? dateRaw : Number(dateRaw));

  const { data: pub } = await loadPublicSalon(salonId);
  const settings = parseBookingSettings(pub.customerBookingSettings);
  if (!settings.enabled) {
    throw new HttpsError("failed-precondition", "Online booking is disabled.");
  }

  const salonNamePublic =
    `${(pub as any)?.salonName ?? (pub as any)?.name ?? ""}`.trim() || salonId;
  const salonAreaPublic = `${(pub as any)?.area ?? ""}`.trim();
  const salonPhonePublic = `${(pub as any)?.phone ?? ""}`.trim();
  const salonWhatsappPublic = `${(pub as any)?.whatsapp ?? ""}`.trim();
  const salonLatitudePublic =
    typeof (pub as any)?.latitude === "number" ? (pub as any).latitude : null;
  const salonLongitudePublic =
    typeof (pub as any)?.longitude === "number" ? (pub as any).longitude : null;
  const dayStart = new Date(Date.UTC(day.getUTCFullYear(), day.getUTCMonth(), day.getUTCDate()));
  const dayEnd = new Date(dayStart.getTime() + 86400000);
  const startTs = Timestamp.fromDate(dayStart);
  const endTs = Timestamp.fromDate(dayEnd);

  const snap = await db
    .collection(`salons/${salonId}/bookings`)
    .where("startAt", ">=", startTs)
    .where("startAt", "<", endTs)
    .get();

  const busyBlocks = snap.docs
    .map((doc) => {
      const d = doc.data();
      const st = `${d.status ?? ""}`.trim();
      if (!BLOCKING.has(st)) {
        return null;
      }
      const s = tsToDate(d.startAt);
      const e = tsToDate(d.endAt);
      if (!s || !e) {
        return null;
      }
      const employeeId =
        `${d.employeeId ?? d.barberId ?? ""}`.trim();
      if (!employeeId) {
        return null;
      }
      return {
        employeeId,
        startAtMs: s.getTime(),
        endAtMs: e.getTime(),
        status: st,
      };
    })
    .filter((x): x is NonNullable<typeof x> => x != null);

  const workingHoursRaw = pub.workingHours;
  const wh =
    workingHoursRaw && typeof workingHoursRaw === "object"
      ? (workingHoursRaw as Record<string, unknown>)[weekdayKey(dayStart)]
      : undefined;

  return {
    salonId,
    dayStartMs: dayStart.getTime(),
    slotStepMinutes: settings.bookingSlotIntervalMinutes,
    bufferMinutes: settings.bufferMinutes,
    workingHoursForDay: wh && typeof wh === "object" ? wh : {
      open: true,
      start: "09:00",
      end: "21:00",
    },
    busyBlocks,
  };
});

export const createCustomerBooking = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const callerAuthUid =
    request.auth?.uid != null && `${request.auth.uid}`.trim().length > 0
      ? `${request.auth.uid}`.trim()
      : "";
  const signInProvider =
    (request.auth?.token as any)?.firebase?.sign_in_provider != null
      ? `${(request.auth?.token as any).firebase.sign_in_provider}`.trim()
      : "";
  const isAnonymous = signInProvider === "anonymous";
  const guestProfileIdRaw = `${data.guestProfileId ?? ""}`.trim();
  const guestProfileId =
    isAnonymous && guestProfileIdRaw.length > 0 && guestProfileIdRaw.length <= 140
      ? guestProfileIdRaw
      : "";
  const draft = data.draft as Record<string, unknown> | undefined;
  if (!draft || typeof draft !== "object") {
    throw new HttpsError("invalid-argument", "draft is required.");
  }

  const { data: pub } = await loadPublicSalon(salonId);
  const settings = parseBookingSettings(pub.customerBookingSettings);
  if (!settings.enabled) {
    throw new HttpsError("failed-precondition", "Online booking is disabled.");
  }

  const services = draft.selectedServices;
  if (!Array.isArray(services) || services.length === 0) {
    throw new HttpsError("invalid-argument", "Select at least one service.");
  }

  const employeeId = requireString(draft, "selectedEmployeeId");
  const employeeName = `${draft.selectedEmployeeName ?? ""}`.trim();
  const startAt = coerceToDate("selectedStartAt", draft);
  const endAt = coerceToDate("selectedEndAt", draft);
  if (!(endAt.getTime() > startAt.getTime())) {
    throw new HttpsError("invalid-argument", "Invalid time range.");
  }

  const clientRequestIdRaw = `${draft.clientRequestId ?? ""}`.trim();
  const clientRequestId =
    clientRequestIdRaw.length > 0 && clientRequestIdRaw.length <= 120
      ? clientRequestIdRaw
      : "";

  const customerName = `${draft.customerName ?? ""}`.trim();
  const phoneNorm = `${draft.customerPhoneNormalized ?? ""}`.trim();
  const customerCountryIsoCode = `${draft.customerCountryIsoCode ?? ""}`.trim().toUpperCase();
  const customerDialCode = `${draft.customerDialCode ?? ""}`.trim();
  const customerPhoneNational = `${draft.customerPhoneNational ?? ""}`.trim();
  if (customerName.length === 0) {
    throw new HttpsError("invalid-argument", "Customer name is required.");
  }
  if (phoneNorm.length === 0) {
    throw new HttpsError("invalid-argument", "Customer phone is required.");
  }

  // Idempotency: if the client retries/double-taps, return existing booking.
  if (callerAuthUid.length > 0 && clientRequestId.length > 0) {
    const existing = await db
      .collection(`salons/${salonId}/bookings`)
      .where("createdByAuthUid", "==", callerAuthUid)
      .where("clientRequestId", "==", clientRequestId)
      .limit(1)
      .get();
    const first = existing.docs[0];
    if (first != null) {
      const d = first.data() as Record<string, any>;
      const startAtExisting: Date =
        d.startAt instanceof Timestamp ? d.startAt.toDate() : new Date(d.startAt);
      const endAtExisting: Date =
        d.endAt instanceof Timestamp ? d.endAt.toDate() : new Date(d.endAt);
      return {
        bookingId: first.id,
        salonId,
        customerId: `${d.customerId ?? ""}`,
        bookingCode: `${d.bookingCode ?? d.bookingNumber ?? ""}`,
        status: `${d.status ?? ""}`,
        startAtMs: startAtExisting.getTime(),
        endAtMs: endAtExisting.getTime(),
        idempotent: true,
      };
    }
  }

  const dayStart = new Date(
    Date.UTC(startAt.getUTCFullYear(), startAt.getUTCMonth(), startAt.getUTCDate()),
  );
  const dayEnd = new Date(dayStart.getTime() + 86400000);
  const startTs = Timestamp.fromDate(dayStart);
  const endTs = Timestamp.fromDate(dayEnd);

  const candidateSnap = await db
    .collection(`salons/${salonId}/bookings`)
    .where("startAt", ">=", startTs)
    .where("startAt", "<", endTs)
    .get();
  const candidateRefs = candidateSnap.docs.map((d) => d.ref);

  const bookingRef = db.collection(`salons/${salonId}/bookings`).doc();
  const customerDocId = stableCustomerId(phoneNorm, bookingRef.id);
  const stableCustomerRef = db.doc(`salons/${salonId}/customers/${customerDocId}`);

  const displayPhone = `${draft.customerPhone ?? ""}`.trim() ||
    phoneNorm;
  const now = FieldValue.serverTimestamp();
  const status = settings.autoConfirmBookings
    ? BookingStatuses.confirmed
    : BookingStatuses.pending;
  const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromStart(
    startAt,
  );

  const servicesPayload = services.map((raw) => {
    const s = raw as Record<string, unknown>;
    return {
      serviceId: `${s.id ?? s.serviceId ?? ""}`,
      serviceName: `${s.displayTitle ?? s.name ?? ""}`,
      price: typeof s.price === "number" ? s.price : Number(s.price) || 0,
      durationMinutes: typeof s.durationMinutes === "number"
        ? s.durationMinutes
        : Number(s.durationMinutes) || 0,
      category: `${s.category ?? ""}`,
    };
  });

  const serviceNames = servicesPayload.map((s) => s.serviceName).filter((n) => n.length > 0);
  const subtotal = typeof draft.subtotal === "number"
    ? draft.subtotal
    : Number(draft.subtotal) || 0;
  const discountAmount = typeof draft.discountAmount === "number"
    ? draft.discountAmount
    : Number(draft.discountAmount) || 0;
  const totalAmount = typeof draft.totalAmount === "number"
    ? draft.totalAmount
    : Number(draft.totalAmount) || 0;
  const durationMinutes = typeof draft.durationMinutes === "number"
    ? draft.durationMinutes
    : Number(draft.durationMinutes) || 0;

  let bookingCode = "";
  let bookingSearchKey = "";
  await db.runTransaction(async (tx) => {
    for (const ref of candidateRefs) {
      const snap = await tx.get(ref);
      if (!snap.exists) {
        continue;
      }
      const d = snap.data()!;
      if (blocksSlot(d, employeeId, startAt, endAt, settings.bufferMinutes)) {
        throw new HttpsError(
          "failed-precondition",
          "slot_unavailable",
        );
      }
    }

    for (let attempt = 0; attempt < 48; attempt++) {
      const digits = String(randomInt(100_000, 1_000_000));
      const candidate = `ZR-${digits}`;
      const lockRef = db.doc(`bookingCodes/${candidate}`);
      const lockSnap = await tx.get(lockRef);
      if (!lockSnap.exists) {
        bookingCode = candidate;
        bookingSearchKey = digits;
        tx.set(lockRef, {
          bookingNumber: candidate,
          salonId,
          bookingId: bookingRef.id,
          createdAt: now,
        });
        break;
      }
    }
    if (bookingCode.length === 0) {
      throw new HttpsError(
        "resource-exhausted",
        "Could not allocate a booking code. Try again.",
      );
    }

    const customerData: Record<string, unknown> = {
      salonId,
      fullName: customerName,
      phone: displayPhone,
      phoneNormalized: phoneNorm,
      countryIsoCode: customerCountryIsoCode,
      dialCode: customerDialCode,
      phoneNational: customerPhoneNational,
      gender: draft.customerGender ?? null,
      notes: draft.customerNote ?? null,
      type: "new",
      isVip: false,
      discountPercent: 0,
      totalVisits: 0,
      totalSpent: 0,
      lastVisitAt: null,
      isActive: false,
      source: "customer_app",
      createdAt: now,
      updatedAt: now,
    };
    if (callerAuthUid.length > 0) {
      customerData.createdByAuthUid = callerAuthUid;
    }
    tx.set(stableCustomerRef, customerData, { merge: true });

    const bookingWrite: Record<string, unknown> = {
      salonId,
      salonName: salonNamePublic,
      salonArea: salonAreaPublic,
      salonPhone: salonPhonePublic,
      salonWhatsapp: salonWhatsappPublic,
      salonLatitude: salonLatitudePublic,
      salonLongitude: salonLongitudePublic,
      createdActorType: "customer",
      customerId: customerDocId,
      customerName,
      customerPhone: displayPhone,
      customerPhoneNormalized: phoneNorm,
      customerCountryIsoCode,
      customerDialCode,
      customerPhoneNational,
      ...(clientRequestId.length > 0 ? { clientRequestId } : {}),
      ...(guestProfileId.length > 0 ? { guestProfileId, customerType: "guest" } : {}),
      employeeId,
      employeeName: employeeName,
      barberId: employeeId,
      barberName: employeeName,
      services: servicesPayload,
      serviceNames,
      subtotal,
      discountAmount,
      totalAmount,
      paymentStatus: "unpaid",
      paymentMethod: "not_selected",
      depositRequired: false,
      depositAmount: 0,
      paidAmount: 0,
      balanceAmount: totalAmount,
      durationMinutes,
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      status,
      ...(status === BookingStatuses.confirmed
        ? { confirmedAt: now, confirmedActorType: "system" }
        : {}),
      source: "customer_app",
      bookingCode,
      bookingNumber: bookingCode,
      bookingSearchKey,
      publicLookupEnabled: true,
      customerNote: draft.customerNote ?? null,
      customerGender: draft.customerGender ?? null,
      reportYear,
      reportMonth,
      reportPeriodKey,
      createdAt: now,
      updatedAt: now,
    };
    if (callerAuthUid.length > 0) {
      bookingWrite.createdByAuthUid = callerAuthUid;
      bookingWrite.guestUid = callerAuthUid;
    }
    tx.set(bookingRef, bookingWrite);
  });

  // Non-critical: notification docs for in-app inbox (best-effort).
  try {
    const notificationBase = {
      type: "booking_created",
      salonId,
      bookingId: bookingRef.id,
      bookingCode,
      customerName,
      startAt: Timestamp.fromDate(startAt),
      status,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    } as Record<string, unknown>;

    const notifId = db.collection("_").doc().id;
    await db.doc(`salons/${salonId}/notifications/${notifId}`).set(notificationBase);

    const ownerUid = `${(pub as any)?.ownerUid ?? ""}`.trim();
    if (ownerUid.length > 0) {
      await db.doc(`users/${ownerUid}/notifications/${notifId}`).set(notificationBase);
    }
  } catch (_) {}

  return {
    bookingId: bookingRef.id,
    salonId,
    customerId: customerDocId,
    bookingCode,
    status,
    startAtMs: startAt.getTime(),
    endAtMs: endAt.getTime(),
  };
});

export const lookupCustomerBookings = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const phoneNormalized = requireString(data, "phoneNormalized").trim();
  const bookingCodeRaw = requireString(data, "bookingCode").trim();
  const bookingCodeUp = bookingCodeRaw.toUpperCase();

  if (phoneNormalized.length === 0) {
    throw new HttpsError("invalid-argument", "phone_normalized_required");
  }
  if (bookingCodeUp.length === 0) {
    throw new HttpsError("invalid-argument", "booking_code_required");
  }

  async function firstMatch(
    field: "bookingNumber" | "bookingCode",
    value: string,
  ): Promise<QueryDocumentSnapshot<DocumentData> | null> {
    const snap = await db
      .collectionGroup("bookings")
      .where("customerPhoneNormalized", "==", phoneNormalized)
      .where(field, "==", value)
      .limit(1)
      .get();
    return snap.empty ? null : (snap.docs[0] ?? null);
  }

  let doc: QueryDocumentSnapshot<DocumentData> | null = await firstMatch(
    "bookingNumber",
    bookingCodeUp,
  );
  if (!doc) {
    doc = await firstMatch("bookingCode", bookingCodeUp);
  }
  if (!doc && bookingCodeUp.startsWith("ZR-")) {
    const digits = bookingCodeUp.slice(3);
    doc = await firstMatch("bookingCode", digits);
  }
  if (!doc && /^[0-9]{6}$/.test(bookingCodeUp)) {
    doc = await firstMatch("bookingNumber", `ZR-${bookingCodeUp}`);
    if (!doc) {
      doc = await firstMatch("bookingCode", `ZR-${bookingCodeUp}`);
    }
  }

  if (!doc) {
    return { bookings: [] };
  }

  const d = doc.data();
  const src = `${d.source ?? ""}`.trim();
  if (src !== "customer_app") {
    return { bookings: [] };
  }
  if (d.publicLookupEnabled === false) {
    return { bookings: [] };
  }
  if (!publicBookingCodesMatch(d as Record<string, unknown>, bookingCodeRaw)) {
    return { bookings: [] };
  }

  const salonId = `${d.salonId ?? ""}`.trim();
  if (!salonId) {
    return { bookings: [] };
  }

  const pubSnap = await db.doc(`publicSalons/${salonId}`).get();
  const salonName = pubSnap.exists
    ? `${pubSnap.data()?.name ?? ""}`.trim()
    : "";

  const serviceNames = Array.isArray(d.serviceNames)
    ? (d.serviceNames as unknown[]).filter((x): x is string =>
      typeof x === "string"
    )
    : [];
  const displayCode =
    `${d.bookingNumber ?? d.bookingCode ?? ""}`.trim().toUpperCase();
  const totalRaw = d.totalAmount;
  const totalAmount = typeof totalRaw === "number"
    ? totalRaw
    : Number(totalRaw) || 0;

  const bookingPayload = {
    bookingId: doc.id,
    salonId,
    salonName,
    bookingCode: displayCode,
    status: `${d.status ?? ""}`.trim(),
    customerName: `${d.customerName ?? ""}`.trim(),
    customerPhone: `${d.customerPhone ?? ""}`.trim(),
    customerPhoneNormalized: `${d.customerPhoneNormalized ?? ""}`.trim(),
    employeeId: `${d.employeeId ?? d.barberId ?? ""}`.trim(),
    employeeName: `${d.employeeName ?? d.barberName ?? ""}`.trim(),
    serviceNames,
    totalAmount,
    startAtMs: tsToDate(d.startAt)?.getTime() ?? 0,
    endAtMs: tsToDate(d.endAt)?.getTime() ?? 0,
    createdAtMs: tsToDate(d.createdAt)?.getTime(),
  };

  return { bookings: [bookingPayload] };
});

export const getCustomerBookingDetails = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  await loadPublicSalon(salonId);

  const bookingSnap = await db.doc(`salons/${salonId}/bookings/${bookingId}`).get();
  if (!bookingSnap.exists) {
    throw new HttpsError("not-found", "Booking not found.");
  }
  const booking = bookingSnap.data()!;
  const pubSnap = await db.doc(`publicSalons/${salonId}`).get();
  const publicSalon = pubSnap.exists ? pubSnap.data()! : {};

  return { bookingId, salonId, booking, publicSalon };
});

export const cancelCustomerBooking = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const phoneNormalized = `${data.phoneNormalized ?? ""}`.trim();
  const bookingCode = `${data.bookingCode ?? ""}`.trim().toUpperCase();
  const cancelReason = `${data.cancelReason ?? ""}`.trim();

  const { data: pub } = await loadPublicSalon(salonId);
  const settings = parseBookingSettings(pub.customerBookingSettings);
  if (!settings.allowCustomerCancellation) {
    throw new HttpsError("failed-precondition", "Cancellation is not allowed.");
  }

  const ref = db.doc(`salons/${salonId}/bookings/${bookingId}`);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Booking not found.");
  }
  const b = snap.data()!;
  assertCustomerBookingIdentity(
    request.auth,
    b as Record<string, unknown>,
    phoneNormalized,
    bookingCode,
  );

  const st = normalizeBookingStatus(`${b.status ?? ""}`);
  if (st !== BookingStatuses.pending && st !== BookingStatuses.confirmed) {
    throw new HttpsError("failed-precondition", "invalid_status");
  }

  const endAt = tsToDate(b.endAt);
  if (!endAt || endAt.getTime() <= Date.now()) {
    throw new HttpsError("failed-precondition", "Booking already ended.");
  }

  const startAt = tsToDate(b.startAt);
  if (startAt) {
    const cutoffMs = Math.max(0, settings.cancellationCutoffMinutes) * 60_000;
    if (Date.now() > startAt.getTime() - cutoffMs) {
      throw new HttpsError("failed-precondition", "cutoff");
    }
  }

  await ref.update({
    status: BookingStatuses.cancelled,
    cancelReason: cancelReason || null,
    cancelledAt: FieldValue.serverTimestamp(),
    cancelledBy: "customer",
    cancelledActorType: "customer",
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { ok: true };
});

export const rescheduleCustomerBooking = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const phoneNormalized = `${data.phoneNormalized ?? ""}`.trim();
  const bookingCode = `${data.bookingCode ?? ""}`.trim().toUpperCase();
  const startAt = msToDate(data.startAtMs ?? data.startAt);
  const endAt = msToDate(data.endAtMs ?? data.endAt);

  const { data: pub } = await loadPublicSalon(salonId);
  const settings = parseBookingSettings(pub.customerBookingSettings);

  const ref = db.doc(`salons/${salonId}/bookings/${bookingId}`);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Booking not found.");
  }
  const b = snap.data()!;
  assertCustomerBookingIdentity(
    request.auth,
    b as Record<string, unknown>,
    phoneNormalized,
    bookingCode,
  );

  const st = normalizeBookingStatus(`${b.status ?? ""}`);
  if (st !== BookingStatuses.pending && st !== BookingStatuses.confirmed) {
    throw new HttpsError("failed-precondition", "invalid_status");
  }

  const prevEnd = tsToDate(b.endAt);
  if (!prevEnd || prevEnd.getTime() <= Date.now()) {
    throw new HttpsError("failed-precondition", "Booking already ended.");
  }
  const prevStart = tsToDate(b.startAt);
  if (prevStart) {
    const cutoffMs = Math.max(0, settings.rescheduleCutoffMinutes) * 60_000;
    if (Date.now() > prevStart.getTime() - cutoffMs) {
      throw new HttpsError("failed-precondition", "cutoff");
    }
  }

  const employeeId = `${b.employeeId ?? b.barberId ?? ""}`.trim();
  if (!employeeId) {
    throw new HttpsError("failed-precondition", "Missing specialist on booking.");
  }

  const dayStart = new Date(
    Date.UTC(startAt.getUTCFullYear(), startAt.getUTCMonth(), startAt.getUTCDate()),
  );
  const dayEnd = new Date(dayStart.getTime() + 86400000);
  const startTs = Timestamp.fromDate(dayStart);
  const endTs = Timestamp.fromDate(dayEnd);

  const candidateSnap = await db
    .collection(`salons/${salonId}/bookings`)
    .where("startAt", ">=", startTs)
    .where("startAt", "<", endTs)
    .get();

  await db.runTransaction(async (tx) => {
    const cur = await tx.get(ref);
    if (!cur.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const current = cur.data() ?? {};
    const prevStart = tsToDate((current as any).startAt);
    const prevEnd = tsToDate((current as any).endAt);
    for (const doc of candidateSnap.docs) {
      if (doc.id === bookingId) {
        continue;
      }
      const d = doc.data();
      if (blocksSlot(d, employeeId, startAt, endAt, settings.bufferMinutes)) {
        throw new HttpsError("failed-precondition", "slot_unavailable");
      }
    }
    const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromStart(
      startAt,
    );
    tx.update(ref, {
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      reportYear,
      reportMonth,
      reportPeriodKey,
      rescheduledAt: FieldValue.serverTimestamp(),
      rescheduledActorType: "customer",
      ...(prevStart ? { rescheduledFromStartAt: Timestamp.fromDate(prevStart) } : {}),
      ...(prevEnd ? { rescheduledFromEndAt: Timestamp.fromDate(prevEnd) } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { ok: true, bookingId };
});

export const submitCustomerFeedback = onCall(CALL, async (request) => {
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const ratingRaw = requireNumber(data, "rating");
  const rating = Math.round(ratingRaw);
  if (!Number.isFinite(ratingRaw) || rating < 1 || rating > 5) {
    throw new HttpsError("invalid-argument", "rating must be between 1 and 5.");
  }

  const { data: pub } = await loadPublicSalon(salonId);
  const settings = parseBookingSettings(pub.customerBookingSettings);
  if (!settings.allowCustomerFeedback) {
    throw new HttpsError("failed-precondition", "Feedback is disabled.");
  }

  const phoneNormalized = `${data.phoneNormalized ?? ""}`.trim();
  const bookingCode = `${data.bookingCode ?? ""}`.trim().toUpperCase();
  const comment = `${data.comment ?? ""}`.trim().slice(0, 2000);

  const bookingRef = db.doc(`salons/${salonId}/bookings/${bookingId}`);
  const snap = await bookingRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Booking not found.");
  }
  const b = snap.data()!;
  if (b.feedbackSubmitted === true) {
    return { ok: true, idempotent: true };
  }

  const bookingStatus = normalizeBookingStatus(`${b.status ?? ""}`);
  if (bookingStatus !== BookingStatuses.completed) {
    throw new HttpsError(
      "failed-precondition",
      "booking_not_completed",
    );
  }

  assertCustomerBookingIdentity(
    request.auth,
    b as Record<string, unknown>,
    phoneNormalized,
    bookingCode,
  );

  const salonRef = db.doc(`salons/${salonId}`);
  const reviewRef = db.doc(`salons/${salonId}/reviews/${bookingId}`);

  let skippedDuplicate = false;
  await db.runTransaction(async (tx) => {
    const bSnap = await tx.get(bookingRef);
    if (!bSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const booking = bSnap.data()!;
    if (booking.feedbackSubmitted === true) {
      skippedDuplicate = true;
      return;
    }
    const st = normalizeBookingStatus(`${booking.status ?? ""}`);
    if (st !== BookingStatuses.completed) {
      throw new HttpsError(
        "failed-precondition",
        "booking_not_completed",
      );
    }

    const salonSnap = await tx.get(salonRef);
    if (!salonSnap.exists) {
      throw new HttpsError("not-found", "Salon not found.");
    }
    const salon = salonSnap.data()!;
    const oldCount = Math.max(0, Math.round(Number(salon.ratingCount) || 0));
    const oldAvg = Number(salon.ratingAverage) || 0;
    const newCount = oldCount + 1;
    const newAvg =
      Math.round(((oldAvg * oldCount + rating) / newCount) * 100) / 100;

    const customerName =
      `${booking.customerName ?? ""}`.trim() || "Customer";
    const customerId = `${booking.customerId ?? ""}`.trim();

    tx.set(reviewRef, {
      salonId,
      bookingId,
      customerId: customerId.length > 0 ? customerId : null,
      customerName,
      rating,
      comment: comment.length > 0 ? comment : null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.update(salonRef, {
      ratingAverage: newAvg,
      ratingCount: newCount,
      updatedAt: FieldValue.serverTimestamp(),
    });

    tx.update(bookingRef, {
      feedbackSubmitted: true,
      feedbackSubmittedAt: FieldValue.serverTimestamp(),
      customerRating: rating,
      customerFeedback: comment.length > 0 ? comment : null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  if (skippedDuplicate) {
    return { ok: true, idempotent: true };
  }

  return { ok: true };
});
