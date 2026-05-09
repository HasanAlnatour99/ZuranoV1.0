import {
  FieldValue,
  Timestamp,
  type Transaction,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  BookingStatuses,
  assertSalonStaffBooking,
  db,
  loadUserProfile,
  normalizeBookingStatus,
  requireString,
  roundMoney,
} from "./bookingShared";
import {
  notifyBookingCompletedForCustomer,
  notifyNoShowToOwners,
} from "./notificationOrchestrator";
import { auditActorProfile, writeAuditLogInTransaction } from "./audit/auditLogger";

const OperationalStates = {
  waiting: "waiting",
  customerArrived: "customer_arrived",
  serviceStarted: "service_started",
  completed: "completed",
  noShowCustomer: "no_show_customer",
  noShowBarber: "no_show_barber",
} as const;

const ViolationTypes = {
  barberLate: "barber_late",
  barberNoShow: "barber_no_show",
} as const;

const ViolationStatuses = {
  pending: "pending",
  approved: "approved",
  rejected: "rejected",
  applied: "applied",
} as const;

const SourceTypes = {
  booking: "booking",
} as const;

const PenaltyCalc = {
  flat: "flat",
  percent: "percent",
  perMinute: "per_minute",
} as const;

const EARLY_OPEN_MS = 120 * 60 * 1000;
const NO_SHOW_GRACE_MS = 15 * 60 * 1000;
const COMPLETE_BUFFER_MS = 24 * 60 * 60 * 1000;

type PenaltySettings = {
  barberLateEnabled: boolean;
  barberLateGraceMinutes: number;
  barberLateCalculationType: string;
  barberLateValue: number;
  barberNoShowEnabled: boolean;
  barberNoShowCalculationType: string;
  barberNoShowValue: number;
};

function defaultPenaltySettings(): PenaltySettings {
  return {
    barberLateEnabled: false,
    barberLateGraceMinutes: 5,
    barberLateCalculationType: PenaltyCalc.flat,
    barberLateValue: 0,
    barberNoShowEnabled: false,
    barberNoShowCalculationType: PenaltyCalc.flat,
    barberNoShowValue: 0,
  };
}

function parsePenaltySettings(raw: unknown): PenaltySettings {
  const d = defaultPenaltySettings();
  if (!raw || typeof raw !== "object") {
    return d;
  }
  const m = raw as Record<string, unknown>;
  return {
    barberLateEnabled: Boolean(m.barberLateEnabled),
    barberLateGraceMinutes: typeof m.barberLateGraceMinutes === "number"
      ? Math.max(0, Math.min(24 * 60, m.barberLateGraceMinutes))
      : d.barberLateGraceMinutes,
    barberLateCalculationType:
      typeof m.barberLateCalculationType === "string" &&
        (m.barberLateCalculationType === PenaltyCalc.flat ||
          m.barberLateCalculationType === PenaltyCalc.percent ||
          m.barberLateCalculationType === PenaltyCalc.perMinute)
      ? m.barberLateCalculationType
      : PenaltyCalc.flat,
    barberLateValue: typeof m.barberLateValue === "number"
      ? m.barberLateValue
      : Number(m.barberLateValue) || 0,
    barberNoShowEnabled: Boolean(m.barberNoShowEnabled),
    barberNoShowCalculationType:
      typeof m.barberNoShowCalculationType === "string" &&
        (m.barberNoShowCalculationType === PenaltyCalc.flat ||
          m.barberNoShowCalculationType === PenaltyCalc.percent)
      ? m.barberNoShowCalculationType
      : PenaltyCalc.flat,
    barberNoShowValue: typeof m.barberNoShowValue === "number"
      ? m.barberNoShowValue
      : Number(m.barberNoShowValue) || 0,
  };
}

function normalizeOperationalState(raw: unknown): string {
  if (typeof raw !== "string" || !raw.trim()) {
    return OperationalStates.waiting;
  }
  const s = raw.trim();
  const ok = new Set<string>(Object.values(OperationalStates));
  return ok.has(s) ? s : OperationalStates.waiting;
}

function reportFieldsFromDate(d: Date): {
  reportYear: number;
  reportMonth: number;
  reportPeriodKey: string;
} {
  const reportYear = d.getUTCFullYear();
  const reportMonth = d.getUTCMonth() + 1;
  const reportPeriodKey =
    `${reportYear}-${String(reportMonth).padStart(2, "0")}`;
  return { reportYear, reportMonth, reportPeriodKey };
}

function violationDocId(bookingId: string, violationType: string): string {
  return `${bookingId}__${violationType}`;
}

function assertTerminalBookingStatus(st: string): void {
  if (
    st === BookingStatuses.cancelled ||
    st === BookingStatuses.completed ||
    st === BookingStatuses.noShow ||
    st === BookingStatuses.rescheduled
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Booking is in a terminal state.",
    );
  }
}

function assertOpsTimeWindow(
  now: Date,
  startAt: Date,
  endAt: Date,
  earlyOpenMs: number,
): void {
  const open = new Date(startAt.getTime() - earlyOpenMs);
  if (now.getTime() < open.getTime()) {
    throw new HttpsError(
      "failed-precondition",
      "Too early for this booking operation.",
    );
  }
  if (now.getTime() > endAt.getTime()) {
    throw new HttpsError(
      "failed-precondition",
      "Booking slot has already ended.",
    );
  }
}

function computeLatePenalty(
  settings: PenaltySettings,
  startAt: Date,
  now: Date,
): { minutesLate: number; amount: number; percent: number | null } {
  const graceMs = settings.barberLateGraceMinutes * 60 * 1000;
  const threshold = startAt.getTime() + graceMs;
  if (now.getTime() <= threshold) {
    return { minutesLate: 0, amount: 0, percent: null };
  }
  const minutesLate = Math.max(
    0,
    Math.floor((now.getTime() - startAt.getTime()) / 60000) -
      settings.barberLateGraceMinutes,
  );
  const t = settings.barberLateCalculationType;
  if (t === PenaltyCalc.flat) {
    return {
      minutesLate,
      amount: roundMoney(settings.barberLateValue),
      percent: null,
    };
  }
  if (t === PenaltyCalc.perMinute) {
    return {
      minutesLate,
      amount: roundMoney(settings.barberLateValue * minutesLate),
      percent: null,
    };
  }
  if (t === PenaltyCalc.percent) {
    return {
      minutesLate,
      amount: 0,
      percent: settings.barberLateValue,
    };
  }
  return { minutesLate, amount: 0, percent: null };
}

function computeNoShowPenalty(
  settings: PenaltySettings,
): { amount: number; percent: number | null } {
  const t = settings.barberNoShowCalculationType;
  if (t === PenaltyCalc.flat) {
    return { amount: roundMoney(settings.barberNoShowValue), percent: null };
  }
  return { amount: 0, percent: settings.barberNoShowValue };
}

async function employeeDisplayName(
  txn: Transaction,
  salonId: string,
  employeeId: string,
): Promise<string> {
  const ref = db
    .collection("salons")
    .doc(salonId)
    .collection("employees")
    .doc(employeeId);
  const snap = await txn.get(ref);
  if (!snap.exists) {
    return "";
  }
  const n = snap.get("name");
  return typeof n === "string" ? n : "";
}

function assertOwnerOrAdmin(user: Awaited<ReturnType<typeof loadUserProfile>>, salonId: string): void {
  if (user.salonId !== salonId) {
    throw new HttpsError("permission-denied", "Not a member of this salon.");
  }
  if (user.role !== "owner" && user.role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only owners and admins can review violations.",
    );
  }
}

export const bookingMarkArrived = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  const user = await loadUserProfile(uid);
  const bookingRef = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);
  const salonRef = db.collection("salons").doc(salonId);

  const result = await db.runTransaction(async (txn) => {
    const [bSnap, salonSnap] = await Promise.all([
      txn.get(bookingRef),
      txn.get(salonRef),
    ]);
    if (!bSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = bSnap.data()!;
    const booking = b as Record<string, unknown>;
    assertSalonStaffBooking(user, uid, salonId, booking);

    const st = normalizeBookingStatus((b.status as string) ?? "");
    assertTerminalBookingStatus(st);
    if (st !== BookingStatuses.confirmed) {
      throw new HttpsError(
        "failed-precondition",
        "Booking must be confirmed to mark arrival.",
      );
    }

    const startAt = (b.startAt as Timestamp).toDate();
    const endAt = (b.endAt as Timestamp).toDate();
    const now = new Date();
    assertOpsTimeWindow(now, startAt, endAt, EARLY_OPEN_MS);

    const op = normalizeOperationalState(b.operationalState);
    if (op !== OperationalStates.waiting) {
      if (op === OperationalStates.customerArrived) {
        return { ok: true as const, idempotent: true as const };
      }
      throw new HttpsError(
        "failed-precondition",
        "Invalid operational state for mark arrived.",
      );
    }

    const penaltySettings = parsePenaltySettings(
      salonSnap.exists ? salonSnap.get("penaltySettings") : undefined,
    );

    const empId = (b.barberId as string) ?? "";
    const empName = empId
      ? await employeeDisplayName(txn, salonId, empId)
      : "";

    const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromDate(
      now,
    );

    const updates: Record<string, unknown> = {
      operationalState: OperationalStates.customerArrived,
      customerArrivedAt: FieldValue.serverTimestamp(),
      operationalMarkedByUid: uid,
      operationalMarkedByRole: user.role,
      updatedAt: FieldValue.serverTimestamp(),
    };

    txn.update(bookingRef, updates);

    if (
      penaltySettings.barberLateEnabled && empId.length > 0
    ) {
      const { minutesLate, amount, percent } = computeLatePenalty(
        penaltySettings,
        startAt,
        now,
      );
      if (minutesLate > 0) {
        const vId = violationDocId(bookingId, ViolationTypes.barberLate);
        const vRef = db
          .collection("salons")
          .doc(salonId)
          .collection("violations")
          .doc(vId);
        const vSnap = await txn.get(vRef);
        if (!vSnap.exists) {
          const currency = typeof salonSnap.get("currencyCode") === "string"
            ? salonSnap.get("currencyCode")
            : "USD";
          txn.set(vRef, {
            id: vId,
            salonId,
            employeeId: empId,
            employeeName: empName || null,
            bookingId,
            sourceType: SourceTypes.booking,
            violationType: ViolationTypes.barberLate,
            status: ViolationStatuses.pending,
            occurredAt: Timestamp.fromDate(now),
            reportYear,
            reportMonth,
            reportPeriodKey,
            minutesLate,
            amount,
            percent: percent === null ? null : percent,
            currency,
            ruleSnapshot: { ...penaltySettings, capturedAt: now.toISOString() },
            notes: null,
            createdByUid: uid,
            createdByRole: user.role,
            approvedByUid: null,
            approvedAt: null,
            payrollRunId: null,
            appliedAt: null,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }

    return { ok: true as const, idempotent: false as const };
  });

  return result.idempotent
    ? { ok: true, idempotent: true }
    : { ok: true };
});

// ---- New unified owner/admin booking operations (production) ----

function assertOwnerOrAdminRole(user: Awaited<ReturnType<typeof loadUserProfile>>, salonId: string): void {
  if (user.salonId !== salonId) {
    throw new HttpsError("permission-denied", "Not a member of this salon.");
  }
  if (user.role !== "owner" && user.role !== "admin") {
    throw new HttpsError("permission-denied", "Only owners and admins can perform this action.");
  }
}

function isNonEmptyString(v: unknown): v is string {
  return typeof v === "string" && v.trim().length > 0;
}

function bookingAuditActionType(nextStatusRaw: string, nextNormalized: string): string {
  const raw = nextStatusRaw.trim().toLowerCase().replace(/[\s_]/g, "");
  if (raw === "checkedin") return "bookings.checked_in";
  if (nextNormalized === BookingStatuses.confirmed) return "bookings.confirmed";
  if (nextNormalized === BookingStatuses.cancelled) return "bookings.cancelled";
  if (nextNormalized === BookingStatuses.completed) return "bookings.completed";
  if (nextNormalized === BookingStatuses.noShow) return "bookings.no_show";
  return "bookings.updated";
}

function transitionAllowed(current: string, next: string): boolean {
  // `checkedIn` is an operational step, not a Firestore status here.
  if (next === "checkedIn") {
    return current === BookingStatuses.confirmed;
  }
  if (current === BookingStatuses.pending) {
    return next === BookingStatuses.confirmed || next === BookingStatuses.cancelled;
  }
  if (current === BookingStatuses.confirmed) {
    return next === BookingStatuses.cancelled || next === BookingStatuses.noShow || next === BookingStatuses.completed;
  }
  if (current === BookingStatuses.completed) {
    return false;
  }
  if (current === BookingStatuses.cancelled) {
    return false;
  }
  if (current === BookingStatuses.noShow) {
    return false;
  }
  return false;
}

export const updateBookingStatus = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const nextStatusRaw = requireString(data, "nextStatus");
  const reason = isNonEmptyString(data.reason) ? data.reason.trim() : "";

  const nextStatus = normalizeBookingStatus(nextStatusRaw);
  const user = await loadUserProfile(uid);
  assertOwnerOrAdminRole(user, salonId);

  const bookingRef = db.collection("salons").doc(salonId).collection("bookings").doc(bookingId);
  const now = FieldValue.serverTimestamp();
  const actor = await auditActorProfile(db, uid);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(bookingRef);
    if (!snap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const d = snap.data() as Record<string, unknown>;
    const currentStatus = normalizeBookingStatus((d as any).status);

    if (!transitionAllowed(currentStatus, nextStatus)) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid status transition.",
        { currentStatus, nextStatus },
      );
    }

    const timelineEvent = {
      status: nextStatus,
      actorType: user.role === "owner" || user.role === "admin" ? user.role : "system",
      actorUid: uid,
      reason: reason || null,
      at: now,
    };

    const patch: Record<string, unknown> = {
      updatedAt: now,
      timeline: FieldValue.arrayUnion(timelineEvent),
    };

    // `checkedIn` is stored as operationalState for now.
    if (nextStatus === "checkedIn") {
      patch.operationalState = OperationalStates.customerArrived;
      patch.checkedInAt = now;
    } else {
      patch.status = nextStatus;
      if (nextStatus === BookingStatuses.confirmed) {
        patch.confirmedAt = now;
        patch.confirmedActorType = user.role;
      }
      if (nextStatus === BookingStatuses.cancelled) {
        patch.cancelledAt = now;
        patch.cancelledActorType = user.role;
        if (reason) patch.cancelReason = reason;
      }
      if (nextStatus === BookingStatuses.noShow) {
        patch.noShowAt = now;
        patch.noShowActorType = user.role;
        if (reason) patch.noShowReason = reason;
      }
      if (nextStatus === BookingStatuses.completed) {
        patch.serviceCompletedAt = now;
        patch.completedActorType = user.role;
      }
    }

    tx.set(bookingRef, patch, { merge: true });

    const bookingLabel =
      `${String((d as any).bookingCode ?? (d as any).bookingNumber ?? "").trim() ||
        String((d as any).customerName ?? "").trim() ||
        bookingId}`;
    writeAuditLogInTransaction(tx, db, {
      salonId,
      actionType: bookingAuditActionType(nextStatusRaw, nextStatus),
      module: "bookings",
      actorUid: uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "booking",
      targetId: bookingId,
      targetLabel: bookingLabel,
      summary: "Booking status updated",
      before: { status: currentStatus },
      after: {
        status: patch.status != null ? nextStatus : currentStatus,
        operationalState: patch.operationalState ?? (d as any).operationalState ?? null,
      },
      metadata: {
        reason: reason || null,
        nextStatusRaw: nextStatusRaw.trim(),
      },
    });
  });

  return { ok: true };
});

export const completeBookingAndCreateSale = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  const paymentMethod = requireString(data, "paymentMethod").trim();
  const paidAmountRaw = data.paidAmount;
  const paidAmount = typeof paidAmountRaw === "number" ? paidAmountRaw : Number(paidAmountRaw) || 0;

  const user = await loadUserProfile(uid);
  assertOwnerOrAdminRole(user, salonId);

  const bookingRef = db.collection("salons").doc(salonId).collection("bookings").doc(bookingId);
  const salesCol = db.collection("salons").doc(salonId).collection("sales");
  const now = FieldValue.serverTimestamp();
  const actor = await auditActorProfile(db, uid);

  const result = await db.runTransaction(async (tx) => {
    const bookingSnap = await tx.get(bookingRef);
    if (!bookingSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = bookingSnap.data() as Record<string, unknown>;
    const currentStatus = normalizeBookingStatus((b as any).status);

    if (currentStatus !== BookingStatuses.confirmed) {
      // We accept `checkedIn` as operational state while status remains confirmed.
      // If a future model introduces a dedicated status, normalizeBookingStatus can include it.
      throw new HttpsError("failed-precondition", "Booking must be confirmed/checked-in before completion.");
    }

    const saleCreated = Boolean((b as any).saleCreated);
    const existingSaleId = isNonEmptyString((b as any).saleId) ? String((b as any).saleId).trim() : "";
    if (saleCreated && existingSaleId.length > 0) {
      return { saleId: existingSaleId, alreadyExisted: true };
    }

    const totalAmount = typeof (b as any).totalAmount === "number"
      ? (b as any).totalAmount
      : Number((b as any).totalAmount) || 0;

    const safePaid = Math.max(0, roundMoney(paidAmount));
    const safeTotal = Math.max(0, roundMoney(totalAmount));
    const balanceAmount = roundMoney(Math.max(0, safeTotal - safePaid));

    const paymentStatus =
      safePaid <= 0
        ? "unpaid"
        : safePaid + 1e-9 < safeTotal
          ? "partial"
          : "paid";

    const bookingCode = `${(b as any).bookingCode ?? (b as any).bookingNumber ?? ""}`.trim();
    const customerId = `${(b as any).customerId ?? ""}`.trim();
    const customerName = `${(b as any).customerName ?? ""}`.trim();
    const employeeId = `${(b as any).employeeId ?? (b as any).barberId ?? ""}`.trim();
    const employeeName = `${(b as any).employeeName ?? (b as any).barberName ?? ""}`.trim();

    const services = Array.isArray((b as any).services) ? (b as any).services : [];
    const subtotal = typeof (b as any).subtotal === "number" ? (b as any).subtotal : Number((b as any).subtotal) || safeTotal;
    const discountAmount = typeof (b as any).discountAmount === "number" ? (b as any).discountAmount : Number((b as any).discountAmount) || 0;

    const saleRef = salesCol.doc();
    const soldAt = new Date();
    const reportYear = soldAt.getUTCFullYear();
    const reportMonth = soldAt.getUTCMonth() + 1;
    const reportPeriodKey = `${reportYear}-${String(reportMonth).padStart(2, "0")}`;

    const normalizedPaymentMethod = (() => {
      const raw = (paymentMethod || "").trim().toLowerCase();
      if (raw === "online") return "digital_wallet";
      if (raw === "cash" || raw === "card" || raw === "digital_wallet" || raw === "other") return raw;
      return "not_selected";
    })();

    const saleWrite: Record<string, unknown> = {
      id: saleRef.id,
      salonId,
      source: "booking",
      bookingId,
      bookingCode,
      customerId,
      customerName,
      employeeId,
      employeeName,
      // Align with existing Sale model fields used across the app.
      lineItems: Array.isArray((b as any).lineItems) ? (b as any).lineItems : [],
      serviceNames: Array.isArray((b as any).serviceNames)
        ? (b as any).serviceNames
        : (Array.isArray(services) ? services.map((s: any) => String(s?.serviceName ?? s?.name ?? "").trim()).filter(Boolean) : []),
      // keep legacy/compat fields
      services,
      subtotal: roundMoney(subtotal),
      subtotalAmount: roundMoney(subtotal),
      tax: 0,
      discount: roundMoney(discountAmount),
      discountAmount: roundMoney(discountAmount),
      total: safeTotal,
      totalAmountAfterDiscount: safeTotal,
      paymentStatus,
      paymentMethod: normalizedPaymentMethod,
      paidAmount: safePaid,
      balanceAmount,
      status: "completed",
      soldAt,
      saleDate: soldAt,
      reportYear,
      reportMonth,
      reportPeriodKey,
      commissionEligible: true,
      commissionBaseAmount: safeTotal,
      createdAt: now,
      updatedAt: now,
    };

    tx.set(saleRef, saleWrite);

    const timelineEvent = {
      status: BookingStatuses.completed,
      actorType: user.role,
      actorUid: uid,
      reason: null,
      at: now,
    };

    tx.set(bookingRef, {
      status: BookingStatuses.completed,
      serviceCompletedAt: now,
      saleCreated: true,
      saleId: saleRef.id,
      completedAt: now,
      updatedAt: now,
      timeline: FieldValue.arrayUnion(timelineEvent),
      paymentStatus,
      paymentMethod: paymentMethod || "not_selected",
      paidAmount: safePaid,
      balanceAmount,
    }, { merge: true });

    writeAuditLogInTransaction(tx, db, {
      salonId,
      actionType: "sales.created",
      module: "sales",
      actorUid: uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "sale",
      targetId: saleRef.id,
      targetLabel: bookingCode || saleRef.id,
      summary: "Sale created from booking",
      after: {
        total: safeTotal,
        paymentMethod: normalizedPaymentMethod,
        bookingId,
      },
      metadata: { source: "booking_complete_callable" },
    });
    writeAuditLogInTransaction(tx, db, {
      salonId,
      actionType: "bookings.completed",
      module: "bookings",
      actorUid: uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "booking",
      targetId: bookingId,
      targetLabel: bookingCode || bookingId,
      summary: "Booking completed with sale",
      before: { status: currentStatus },
      after: { status: BookingStatuses.completed, saleId: saleRef.id },
      metadata: { saleId: saleRef.id },
    });

    return { saleId: saleRef.id, alreadyExisted: false };
  });

  return { ok: true, ...result };
});

export const bookingStartService = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  const user = await loadUserProfile(uid);
  const bookingRef = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);

  await db.runTransaction(async (txn) => {
    const bSnap = await txn.get(bookingRef);
    if (!bSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = bSnap.data()!;
    const booking = b as Record<string, unknown>;
    assertSalonStaffBooking(user, uid, salonId, booking);

    const st = normalizeBookingStatus((b.status as string) ?? "");
    assertTerminalBookingStatus(st);
    if (st !== BookingStatuses.confirmed) {
      throw new HttpsError(
        "failed-precondition",
        "Booking must be confirmed to start service.",
      );
    }

    const startAt = (b.startAt as Timestamp).toDate();
    const endAt = (b.endAt as Timestamp).toDate();
    const now = new Date();
    assertOpsTimeWindow(now, startAt, endAt, EARLY_OPEN_MS);

    const op = normalizeOperationalState(b.operationalState);
    if (op === OperationalStates.serviceStarted) {
      return;
    }
    if (op !== OperationalStates.customerArrived) {
      throw new HttpsError(
        "failed-precondition",
        "Customer must be marked arrived first.",
      );
    }

    txn.update(bookingRef, {
      operationalState: OperationalStates.serviceStarted,
      serviceStartedAt: FieldValue.serverTimestamp(),
      operationalMarkedByUid: uid,
      operationalMarkedByRole: user.role,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

export const bookingCompleteService = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");

  const user = await loadUserProfile(uid);
  const bookingRef = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);

  await db.runTransaction(async (txn) => {
    const bSnap = await txn.get(bookingRef);
    if (!bSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = bSnap.data()!;
    const booking = b as Record<string, unknown>;
    assertSalonStaffBooking(user, uid, salonId, booking);

    const st = normalizeBookingStatus((b.status as string) ?? "");
    if (st === BookingStatuses.completed) {
      return;
    }
    assertTerminalBookingStatus(st);
    if (st !== BookingStatuses.confirmed) {
      throw new HttpsError(
        "failed-precondition",
        "Booking must be confirmed to complete.",
      );
    }

    const startAt = (b.startAt as Timestamp).toDate();
    const endAt = (b.endAt as Timestamp).toDate();
    const now = new Date();
    if (now.getTime() > endAt.getTime() + COMPLETE_BUFFER_MS) {
      throw new HttpsError(
        "failed-precondition",
        "Too late to complete this booking.",
      );
    }

    const op = normalizeOperationalState(b.operationalState);
    if (op === OperationalStates.completed) {
      return;
    }
    if (op !== OperationalStates.serviceStarted) {
      throw new HttpsError(
        "failed-precondition",
        "Service must be started before completion.",
      );
    }

    txn.update(bookingRef, {
      status: BookingStatuses.completed,
      operationalState: OperationalStates.completed,
      serviceCompletedAt: FieldValue.serverTimestamp(),
      operationalMarkedByUid: uid,
      operationalMarkedByRole: user.role,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  const done = await bookingRef.get();
  const bd = done.data();
  const customerId = typeof bd?.customerId === "string" ? bd.customerId : "";
  if (customerId.length > 0) {
    void notifyBookingCompletedForCustomer({
      salonId,
      bookingId,
      customerId,
    }).catch((err) => console.error("notifyBookingCompletedForCustomer", err));
  }

  return { ok: true };
});

export const bookingMarkNoShow = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const bookingId = requireString(data, "bookingId");
  const partyRaw = requireString(data, "party").toLowerCase();
  if (partyRaw !== "customer" && partyRaw !== "barber") {
    throw new HttpsError("invalid-argument", "party must be customer or barber.");
  }

  const user = await loadUserProfile(uid);
  const bookingRef = db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .doc(bookingId);
  const salonRef = db.collection("salons").doc(salonId);

  await db.runTransaction(async (txn) => {
    const [bSnap, salonSnap] = await Promise.all([
      txn.get(bookingRef),
      txn.get(salonRef),
    ]);
    if (!bSnap.exists) {
      throw new HttpsError("not-found", "Booking not found.");
    }
    const b = bSnap.data()!;
    const booking = b as Record<string, unknown>;
    assertSalonStaffBooking(user, uid, salonId, booking);

    const st = normalizeBookingStatus((b.status as string) ?? "");
    if (st === BookingStatuses.noShow) {
      return;
    }
    assertTerminalBookingStatus(st);
    if (st !== BookingStatuses.confirmed) {
      throw new HttpsError(
        "failed-precondition",
        "Booking must be confirmed to mark no-show.",
      );
    }

    const startAt = (b.startAt as Timestamp).toDate();
    const now = new Date();
    if (now.getTime() < startAt.getTime() + NO_SHOW_GRACE_MS) {
      throw new HttpsError(
        "failed-precondition",
        "No-show cannot be marked yet (grace period).",
      );
    }

    const op = normalizeOperationalState(b.operationalState);
    if (op !== OperationalStates.waiting) {
      throw new HttpsError(
        "failed-precondition",
        "No-show is only allowed from waiting state.",
      );
    }

    const penaltySettings = parsePenaltySettings(
      salonSnap.exists ? salonSnap.get("penaltySettings") : undefined,
    );

    const empId = (b.barberId as string) ?? "";
    const empName = empId
      ? await employeeDisplayName(txn, salonId, empId)
      : "";

    const isBarber = partyRaw === "barber";
    const nextOp = isBarber
      ? OperationalStates.noShowBarber
      : OperationalStates.noShowCustomer;

    const { reportYear, reportMonth, reportPeriodKey } = reportFieldsFromDate(
      now,
    );

    txn.update(bookingRef, {
      status: BookingStatuses.noShow,
      operationalState: nextOp,
      noShowParty: partyRaw,
      noShowMarkedAt: FieldValue.serverTimestamp(),
      operationalMarkedByUid: uid,
      operationalMarkedByRole: user.role,
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (isBarber && penaltySettings.barberNoShowEnabled && empId.length > 0) {
      const vId = violationDocId(bookingId, ViolationTypes.barberNoShow);
      const vRef = db
        .collection("salons")
        .doc(salonId)
        .collection("violations")
        .doc(vId);
      const vSnap = await txn.get(vRef);
      if (!vSnap.exists) {
        const { amount, percent } = computeNoShowPenalty(penaltySettings);
        const currency = typeof salonSnap.get("currencyCode") === "string"
          ? salonSnap.get("currencyCode")
          : "USD";
        txn.set(vRef, {
          id: vId,
          salonId,
          employeeId: empId,
          employeeName: empName || null,
          bookingId,
          sourceType: SourceTypes.booking,
          violationType: ViolationTypes.barberNoShow,
          status: ViolationStatuses.pending,
          occurredAt: Timestamp.fromDate(now),
          reportYear,
          reportMonth,
          reportPeriodKey,
          minutesLate: null,
          amount,
          percent: percent === null ? null : percent,
          currency,
          ruleSnapshot: { ...penaltySettings, capturedAt: now.toISOString() },
          notes: null,
          createdByUid: uid,
          createdByRole: user.role,
          approvedByUid: null,
          approvedAt: null,
          payrollRunId: null,
          appliedAt: null,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }
  });

  void notifyNoShowToOwners({ salonId, bookingId }).catch((err) =>
    console.error("notifyNoShowToOwners", err),
  );

  return { ok: true };
});

export const violationReview = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const salonId = requireString(data, "salonId");
  const violationId = requireString(data, "violationId");
  const decision = requireString(data, "decision").toLowerCase();
  if (decision !== "approve" && decision !== "reject") {
    throw new HttpsError(
      "invalid-argument",
      "decision must be approve or reject.",
    );
  }
  const notes = typeof data.notes === "string" ? data.notes : null;

  const user = await loadUserProfile(uid);
  assertOwnerOrAdmin(user, salonId);

  const vRef = db
    .collection("salons")
    .doc(salonId)
    .collection("violations")
    .doc(violationId);

  await db.runTransaction(async (txn) => {
    const snap = await txn.get(vRef);
    if (!snap.exists) {
      throw new HttpsError("not-found", "Violation not found.");
    }
    const st = (snap.get("status") as string) ?? "";
    if (st !== ViolationStatuses.pending) {
      if (decision === "approve" && st === ViolationStatuses.approved) {
        return;
      }
      if (decision === "reject" && st === ViolationStatuses.rejected) {
        return;
      }
      throw new HttpsError(
        "failed-precondition",
        "Violation is not pending.",
      );
    }

    if (decision === "approve") {
      txn.update(vRef, {
        status: ViolationStatuses.approved,
        approvedByUid: uid,
        approvedAt: FieldValue.serverTimestamp(),
        notes: notes ?? snap.get("notes") ?? null,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      txn.update(vRef, {
        status: ViolationStatuses.rejected,
        notes: notes ?? snap.get("notes") ?? null,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  });

  return { ok: true };
});
