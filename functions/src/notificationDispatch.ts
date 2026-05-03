import { createHash } from "crypto";

import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { info } from "firebase-functions/logger";

import {
  allowsCategoryForEvent,
  allowsPushForEvent,
  applySalonNotificationSettings,
  mergeNotificationPrefs,
} from "./notificationPrefs";
import { getLocalizedCopy, normalizeLocale, type SupportedLocale } from "./notificationCopy";
import type {
  NotificationChannel,
  NotificationEventType,
  SendNotificationInput,
} from "./notificationTypes";
import { createSalonInAppNotification } from "./notifications/salonInAppNotificationService";

const db = getFirestore();

export function dispatchDocumentId(dedupeKey: string): string {
  return createHash("sha256").update(dedupeKey).digest("hex").substring(0, 40);
}

/**
 * Atomically claims a send slot. Returns false if this dedupe was already processed.
 */
export async function tryClaimDispatch(params: {
  dedupeKey: string;
  eventType: NotificationEventType;
  userId: string;
  bookingId?: string;
  channel: NotificationChannel;
}): Promise<boolean> {
  const id = dispatchDocumentId(params.dedupeKey);
  const ref = db.collection("notificationDispatches").doc(id);
  return await db.runTransaction(async (txn) => {
    const snap = await txn.get(ref);
    if (snap.exists) {
      return false;
    }
    txn.set(ref, {
      eventType: params.eventType,
      userId: params.userId,
      bookingId: params.bookingId ?? null,
      dedupeKey: params.dedupeKey,
      channel: params.channel,
      sentAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
}

/** User doc prefs merged with `salons/{salonId}/notificationSettings/{uid}` when present. */
export async function loadMergedNotificationPrefs(userId: string) {
  const userSnap = await db.collection("users").doc(userId).get();
  const base = mergeNotificationPrefs(
    userSnap.exists ? userSnap.get("notificationPrefs") : undefined,
  );
  const salonIdRaw = userSnap.exists ? userSnap.get("salonId") : undefined;
  const salonId = typeof salonIdRaw === "string" ? salonIdRaw.trim() : "";
  if (!salonId) {
    return base;
  }
  const salonSnap = await db
    .collection("salons")
    .doc(salonId)
    .collection("notificationSettings")
    .doc(userId)
    .get();
  if (!salonSnap.exists) {
    return base;
  }
  const data = salonSnap.data();
  return applySalonNotificationSettings(
    base,
    data && typeof data === "object" ? (data as Record<string, unknown>) : undefined,
  );
}

export async function getPrimaryLocaleForUser(userId: string): Promise<SupportedLocale> {
  const snap = await db
    .collection(`users/${userId}/devices`)
    .orderBy("lastSeenAt", "desc")
    .limit(1)
    .get();
  if (snap.empty) {
    return "en";
  }
  const loc = snap.docs[0].get("locale");
  return normalizeLocale(typeof loc === "string" ? loc : undefined);
}

async function persistInAppNotification(input: SendNotificationInput): Promise<void> {
  const ref = db.collection(`users/${input.userId}/notifications`).doc();
  await ref.set({
    type: input.eventType,
    title: input.title,
    body: input.body,
    data: input.data,
    status: "unread",
    createdAt: FieldValue.serverTimestamp(),
    readAt: null,
    actorRole: input.actorRole,
    salonId: input.salonId ?? null,
    bookingId: input.bookingId ?? null,
    employeeId: input.employeeId ?? null,
    payrollId: input.payrollId ?? null,
    violationId: input.violationId ?? null,
    expenseId: input.expenseId ?? null,
    saleId: input.saleId ?? null,
  });
}

function normalizeRecipientFirestoreRole(roleRaw: string): string {
  const x = roleRaw.trim().toLowerCase();
  if (x === "barber" || x === "employee" || x === "readonly") {
    return "employee";
  }
  if (x === "owner") {
    return "owner";
  }
  if (x === "admin") {
    return "admin";
  }
  return "customer";
}

function resolveSalonNotificationRoute(input: SendNotificationInput, recipientNormalized: string): string | null {
  const salonId = (input.salonId ?? "").trim();
  if (!salonId) {
    return null;
  }
  const et = input.eventType;

  if (et === "attendance_check_in" || et === "attendance_late") {
    return recipientNormalized === "employee" ? "/employee/today" : "/owner/overview";
  }
  if (et === "attendance_correction_requested") {
    return recipientNormalized === "employee"
      ? "/employee/attendance/request"
      : "/attendance-requests-review";
  }
  if (et === "service_created" || et === "service_updated" || et === "service_deleted") {
    return "/owner/services";
  }
  if (et === "employee_created" || et === "employee_reactivated" || et === "employee_frozen") {
    return "/owner/team";
  }
  if (et === "daily_summary" || et === "monthly_summary") {
    return "/owner/overview";
  }

  const route = input.data?.route ?? "";

  if (route === "booking" && typeof input.bookingId === "string" && input.bookingId.length > 0) {
    return recipientNormalized === "customer"
      ? `/customer/booking/${salonId}/${input.bookingId}`
      : `/bookings/${input.bookingId}`;
  }

  if (route === "payroll" || (typeof input.payrollId === "string" && input.payrollId.length > 0)) {
    if (input.eventType === "payroll_ready") {
      return "/employee/payroll";
    }
    if (input.eventType === "payroll_generated") {
      return "/owner-payroll";
    }
    return recipientNormalized === "employee" ? "/employee/payroll" : "/owner-payroll";
  }

  if (route === "violation" || (typeof input.violationId === "string" && input.violationId.length > 0)) {
    return recipientNormalized === "employee"
      ? "/employee/today"
      : "/owner/settings/hr-violations";
  }

  if (route === "expense" || (typeof input.expenseId === "string" && input.expenseId.length > 0)) {
    return "/owner-expenses";
  }

  if (route === "sale" || (typeof input.saleId === "string" && input.saleId.length > 0)) {
    return "/owner-sales";
  }

  return null;
}

function resolveEntityPayload(input: SendNotificationInput): {
  entityId: string | null;
  entityType: string | null;
} {
  if (typeof input.bookingId === "string" && input.bookingId.length > 0) {
    return { entityId: input.bookingId, entityType: "booking" };
  }
  if (typeof input.payrollId === "string" && input.payrollId.length > 0) {
    return { entityId: input.payrollId, entityType: "payroll" };
  }
  if (typeof input.violationId === "string" && input.violationId.length > 0) {
    return { entityId: input.violationId, entityType: "violation" };
  }
  if (typeof input.expenseId === "string" && input.expenseId.length > 0) {
    return { entityId: input.expenseId, entityType: "expense" };
  }
  if (typeof input.saleId === "string" && input.saleId.length > 0) {
    return { entityId: input.saleId, entityType: "sale" };
  }
  if (typeof input.attendanceId === "string" && input.attendanceId.length > 0) {
    return { entityId: input.attendanceId, entityType: "attendance" };
  }
  if (typeof input.serviceId === "string" && input.serviceId.length > 0) {
    return { entityId: input.serviceId, entityType: "service" };
  }
  if (typeof input.employeeId === "string" && input.employeeId.length > 0) {
    if (
      input.eventType === "employee_created" ||
      input.eventType === "employee_reactivated" ||
      input.eventType === "employee_frozen"
    ) {
      return { entityId: input.employeeId, entityType: "employee" };
    }
  }
  return { entityId: null, entityType: null };
}

type SalonNotificationExtras = {
  salonIdTrim: string;
  recipientNormalized: string;
  routeName: string | null;
  entityId: string | null;
  entityType: string | null;
};

async function computeSalonNotificationExtrasMaybe(
  input: SendNotificationInput,
): Promise<SalonNotificationExtras | null> {
  const salonIdTrim = (input.salonId ?? "").trim();
  if (!salonIdTrim) {
    return null;
  }
  const userSnap = await db.collection("users").doc(input.userId).get();
  const roleRaw =
    userSnap.exists && typeof userSnap.get("role") === "string"
      ? (userSnap.get("role") as string)
      : "customer";
  const recipientNormalized = normalizeRecipientFirestoreRole(roleRaw);
  const routeName = resolveSalonNotificationRoute(input, recipientNormalized);
  const { entityId, entityType } = resolveEntityPayload(input);
  return { salonIdTrim, recipientNormalized, routeName, entityId, entityType };
}

function deriveNotificationPriority(
  eventType: NotificationEventType,
): "low" | "normal" | "high" | "critical" {
  if (eventType === "violation_created" || eventType === "no_show_recorded") {
    return "high";
  }
  return "normal";
}

function mergePushDataPayload(
  input: SendNotificationInput,
  salonExtras: SalonNotificationExtras | null,
): Record<string, string> {
  const merged: Record<string, string | undefined> = {
    ...(input.data ?? {}),
    type: input.eventType,
  };
  if (salonExtras != null) {
    merged.salonId = salonExtras.salonIdTrim;
    if (salonExtras.routeName) merged.routeName = salonExtras.routeName;
    if (salonExtras.entityId) merged.entityId = salonExtras.entityId;
    if (salonExtras.entityType) merged.entityType = salonExtras.entityType;
  }
  if (typeof input.bookingId === "string" && input.bookingId.length > 0) {
    merged.bookingId = input.bookingId;
  }
  if (typeof input.payrollId === "string" && input.payrollId.length > 0) {
    merged.payrollId = input.payrollId;
  }
  if (typeof input.violationId === "string" && input.violationId.length > 0) {
    merged.violationId = input.violationId;
  }
  if (typeof input.expenseId === "string" && input.expenseId.length > 0) {
    merged.expenseId = input.expenseId;
  }
  if (typeof input.saleId === "string" && input.saleId.length > 0) {
    merged.saleId = input.saleId;
  }
  if (typeof input.attendanceId === "string" && input.attendanceId.length > 0) {
    merged.attendanceId = input.attendanceId;
  }
  if (typeof input.serviceId === "string" && input.serviceId.length > 0) {
    merged.serviceId = input.serviceId;
  }
  const data: Record<string, string> = {};
  for (const [key, val] of Object.entries(merged)) {
    if (typeof val === "string" && val.length > 0) {
      data[key] = val;
    }
  }
  return data;
}

/**
 * Canonical in-app inbox: `salons/{salonId}/notifications` when [salonId] is present.
 * Falls back to `users/{uid}/notifications` only when salon context is unknown.
 */
async function persistInAppForDispatch(
  input: SendNotificationInput,
  salonExtrasPrefetched: SalonNotificationExtras | null,
): Promise<void> {
  if (!salonExtrasPrefetched) {
    await persistInAppNotification(input);
    return;
  }

  await createSalonInAppNotification({
    salonId: salonExtrasPrefetched.salonIdTrim,
    recipientUserId: input.userId,
    recipientRole: salonExtrasPrefetched.recipientNormalized,
    type: input.eventType as string,
    title: input.title,
    body: input.body,
    dedupeKey: input.dedupeKey,
    routeName: salonExtrasPrefetched.routeName,
    entityId: salonExtrasPrefetched.entityId,
    entityType: salonExtrasPrefetched.entityType,
    data: { ...input.data, type: input.eventType },
    createdBy: "system",
    priority: deriveNotificationPriority(input.eventType),
  });
}

type FcmDeviceTokenEntry = { deviceId: string; token: string };

type PushMulticastLogContext = {
  recipientUserId: string;
  notificationType: string;
  dedupeKey: string;
  salonId?: string;
};

function salonIdForPushLog(input: SendNotificationInput): string | undefined {
  const s = input.salonId?.trim();
  return s && s.length > 0 ? s : undefined;
}

function shouldDeactivateDeviceForMessagingError(code: string | undefined): boolean {
  if (!code) {
    return false;
  }
  return (
    code === "messaging/registration-token-not-registered" ||
    code === "messaging/invalid-registration-token" ||
    code === "messaging/invalid-argument"
  );
}

async function deactivateInvalidDevice(
  userId: string,
  deviceId: string,
  invalidReason: string,
): Promise<void> {
  await db.doc(`users/${userId}/devices/${deviceId}`).set(
    {
      active: false,
      invalidatedAt: FieldValue.serverTimestamp(),
      invalidReason,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function collectFcmDeviceTokens(userId: string): Promise<FcmDeviceTokenEntry[]> {
  const snap = await db.collection(`users/${userId}/devices`).get();
  const out: FcmDeviceTokenEntry[] = [];
  const seenTokens = new Set<string>();
  for (const doc of snap.docs) {
    const push = doc.get("pushEnabled");
    const active = doc.get("active");
    if (push === false) {
      continue;
    }
    if (active === false) {
      continue;
    }
    const token = doc.get("token");
    if (typeof token !== "string" || token.length === 0) {
      continue;
    }
    if (seenTokens.has(token)) {
      continue;
    }
    seenTokens.add(token);
    out.push({ deviceId: doc.id, token });
  }
  return out;
}

async function sendMulticast(
  userId: string,
  entries: FcmDeviceTokenEntry[],
  title: string,
  body: string,
  data: Record<string, string>,
  ctx: PushMulticastLogContext,
): Promise<void> {
  if (entries.length === 0) {
    return;
  }
  const messaging = getMessaging();
  const chunkSize = 500;
  let aggregateSuccess = 0;
  let aggregateFailure = 0;
  const deactivatePromises: Promise<void>[] = [];

  for (let i = 0; i < entries.length; i += chunkSize) {
    const chunkEntries = entries.slice(i, i + chunkSize);
    const chunkTokens = chunkEntries.map((e) => e.token);
    const response = await messaging.sendEachForMulticast({
      tokens: chunkTokens,
      notification: { title, body },
      data,
    });

    aggregateSuccess += response.successCount;
    aggregateFailure += response.failureCount;

    response.responses.forEach((resp, idx) => {
      if (resp.success) {
        return;
      }
      const code = resp.error?.code;
      const entry = chunkEntries[idx];
      if (entry && shouldDeactivateDeviceForMessagingError(code)) {
        deactivatePromises.push(
          deactivateInvalidDevice(userId, entry.deviceId, code ?? "unknown"),
        );
      }
    });
  }

  await Promise.all(deactivatePromises);

  info("push.multicast.completed", {
    recipientUserId: ctx.recipientUserId,
    salonId: ctx.salonId ?? null,
    notificationType: ctx.notificationType,
    dedupeKey: ctx.dedupeKey,
    successCount: aggregateSuccess,
    failureCount: aggregateFailure,
    invalidTokenDeviceUpdates: deactivatePromises.length,
  });
}

export async function deliverTemplatedNotification(
  input: Omit<SendNotificationInput, "title" | "body"> & {
    templateVars?: Record<string, string>;
  },
): Promise<void> {
  const prefs = await loadMergedNotificationPrefs(input.userId);
  if (!allowsCategoryForEvent(prefs, input.eventType)) {
    return;
  }

  const locale = await getPrimaryLocaleForUser(input.userId);
  const { title, body } = getLocalizedCopy(
    input.eventType,
    locale,
    input.templateVars ?? {},
  );
  const resolved: SendNotificationInput = {
    ...input,
    title,
    body,
  };

  const salonExtras = await computeSalonNotificationExtrasMaybe(resolved);

  const inAppKey = `${input.dedupeKey}:in_app`;
  const claimedInApp = await tryClaimDispatch({
    dedupeKey: inAppKey,
    eventType: input.eventType,
    userId: input.userId,
    bookingId: input.bookingId,
    channel: "in_app",
  });
  if (claimedInApp) {
    await persistInAppForDispatch(resolved, salonExtras);
  }

  if (!allowsPushForEvent(prefs, input.eventType)) {
    return;
  }

  const pushKey = `${input.dedupeKey}:push`;
  const claimedPush = await tryClaimDispatch({
    dedupeKey: pushKey,
    eventType: input.eventType,
    userId: input.userId,
    bookingId: input.bookingId,
    channel: "push",
  });
  if (!claimedPush) {
    return;
  }

  const entries = await collectFcmDeviceTokens(input.userId);
  const data = mergePushDataPayload(resolved, salonExtras);
  await sendMulticast(input.userId, entries, title, body, data, {
    recipientUserId: input.userId,
    notificationType: input.eventType,
    dedupeKey: input.dedupeKey,
    salonId: salonIdForPushLog(resolved),
  });
}

export async function deliverNotificationWithCopy(
  input: SendNotificationInput,
): Promise<void> {
  const prefs = await loadMergedNotificationPrefs(input.userId);
  if (!allowsCategoryForEvent(prefs, input.eventType)) {
    return;
  }

  const salonExtras = await computeSalonNotificationExtrasMaybe(input);

  const inAppKey = `${input.dedupeKey}:in_app`;
  const claimedInApp = await tryClaimDispatch({
    dedupeKey: inAppKey,
    eventType: input.eventType,
    userId: input.userId,
    bookingId: input.bookingId,
    channel: "in_app",
  });
  if (claimedInApp) {
    await persistInAppForDispatch(input, salonExtras);
  }

  if (!allowsPushForEvent(prefs, input.eventType)) {
    return;
  }

  const pushKey = `${input.dedupeKey}:push`;
  const claimedPush = await tryClaimDispatch({
    dedupeKey: pushKey,
    eventType: input.eventType,
    userId: input.userId,
    bookingId: input.bookingId,
    channel: "push",
  });
  if (!claimedPush) {
    return;
  }

  const entries = await collectFcmDeviceTokens(input.userId);
  const data = mergePushDataPayload(input, salonExtras);
  await sendMulticast(input.userId, entries, input.title, input.body, data, {
    recipientUserId: input.userId,
    notificationType: input.eventType,
    dedupeKey: input.dedupeKey,
    salonId: salonIdForPushLog(input),
  });
}

export function bookingDeepLinkData(
  salonId: string,
  bookingId: string,
): Record<string, string> {
  return {
    route: "booking",
    salonId,
    bookingId,
  };
}

export function payrollDeepLinkData(
  salonId: string,
  payrollId: string,
): Record<string, string> {
  return {
    route: "payroll",
    salonId,
    payrollId,
  };
}

export function violationDeepLinkData(
  salonId: string,
  violationId: string,
): Record<string, string> {
  return {
    route: "violation",
    salonId,
    violationId,
  };
}

export function expenseDeepLinkData(
  salonId: string,
  expenseId: string,
): Record<string, string> {
  return {
    route: "expense",
    salonId,
    expenseId,
  };
}

export function saleDeepLinkData(salonId: string, saleId: string): Record<string, string> {
  return {
    route: "sale",
    salonId,
    saleId,
  };
}
