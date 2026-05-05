import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

import { tryClaimDispatch } from "../notificationDispatch";
import type { NotificationEventType } from "../notificationTypes";

const db = getFirestore();

export type EmployeeNotificationType =
  | "booking_updates"
  | "attendance_updates"
  | "payroll_updates"
  | "approval_requests"
  | "system_alerts";

export type CreateEmployeeNotificationInput = {
  recipientUid: string;
  salonId: string;
  employeeId?: string;
  type: EmployeeNotificationType;
  title: string;
  body: string;
  route?: string;
  sourceCollection?: string;
  sourceId?: string;
  metadata?: Record<string, unknown>;
  /** Idempotent retries (Firestore trigger “at least once”). */
  dedupeKey?: string;
};

function settingKeyForType(type: EmployeeNotificationType): string {
  switch (type) {
    case "booking_updates":
      return "bookingUpdates";
    case "attendance_updates":
      return "attendanceUpdates";
    case "payroll_updates":
      return "payrollUpdates";
    case "approval_requests":
      return "approvalRequests";
    case "system_alerts":
      return "systemAlerts";
  }
}

function legacyEventType(type: EmployeeNotificationType): NotificationEventType {
  switch (type) {
    case "booking_updates":
      return "new_booking_assigned";
    case "payroll_updates":
      return "payroll_ready";
    case "approval_requests":
      return "attendance_correction_requested";
    case "attendance_updates":
      return "attendance_check_in";
    case "system_alerts":
      return "employee_frozen";
  }
}

async function collectPushTokens(userId: string): Promise<string[]> {
  const userSnap = await db.collection("users").doc(userId).get();
  const out = new Set<string>();
  const tokensMap = userSnap.get("fcmTokens");
  if (tokensMap && typeof tokensMap === "object") {
    for (const [k, v] of Object.entries(tokensMap as Record<string, unknown>)) {
      if (v === true && typeof k === "string" && k.length > 0) {
        out.add(k);
      }
    }
  }
  const devices = await db.collection(`users/${userId}/devices`).get();
  for (const doc of devices.docs) {
    if (doc.get("pushEnabled") === false || doc.get("active") === false) {
      continue;
    }
    const token = doc.get("token");
    if (typeof token === "string" && token.length > 0) {
      out.add(token);
    }
  }
  return [...out];
}

/**
 * Writes `users/{uid}/notifications/*`, optionally sends FCM using
 * `users/{uid}/notificationSettings/main` + push toggle + token maps.
 */
export async function createEmployeeNotification(
  input: CreateEmployeeNotificationInput,
): Promise<void> {
  const recipientUid = input.recipientUid.trim();
  const salonId = input.salonId.trim();
  if (!recipientUid || !salonId) {
    return;
  }

  const userRef = db.collection("users").doc(recipientUid);
  const settingsRef = userRef.collection("notificationSettings").doc("main");

  const [userSnap, settingsSnap] = await Promise.all([
    userRef.get(),
    settingsRef.get(),
  ]);

  if (!userSnap.exists) {
    return;
  }

  const settings = settingsSnap.data() ?? {};
  const typeKey = settingKeyForType(input.type);
  const typeEnabled = settings[typeKey] !== false;
  if (!typeEnabled) {
    return;
  }

  const dedupeBase =
    input.dedupeKey != null && input.dedupeKey.trim() !== ""
      ? `emp_inbox:${input.dedupeKey.trim()}`
      : `emp_inbox:${input.type}:${salonId}:${input.sourceCollection ?? "na"}:${input.sourceId ?? "na"}:${recipientUid}`;

  const claimedInApp = await tryClaimDispatch({
    dedupeKey: `${dedupeBase}:in_app`,
    eventType: legacyEventType(input.type),
    userId: recipientUid,
    channel: "in_app",
  });
  if (!claimedInApp) {
    return;
  }

  const notificationRef = userRef.collection("notifications").doc();
  await notificationRef.set({
    id: notificationRef.id,
    recipientUid,
    salonId,
    employeeId: input.employeeId ?? null,
    type: input.type,
    title: input.title,
    body: input.body,
    isRead: false,
    route: input.route ?? null,
    sourceCollection: input.sourceCollection ?? null,
    sourceId: input.sourceId ?? null,
    metadata: input.metadata ?? {},
    dedupeKey: input.dedupeKey ?? null,
    createdAt: FieldValue.serverTimestamp(),
  });

  const pushEnabled = settings.pushNotifications !== false;
  if (!pushEnabled) {
    return;
  }

  const claimedPush = await tryClaimDispatch({
    dedupeKey: `${dedupeBase}:push`,
    eventType: legacyEventType(input.type),
    userId: recipientUid,
    channel: "push",
  });
  if (!claimedPush) {
    return;
  }

  const tokens = await collectPushTokens(recipientUid);
  if (tokens.length === 0) {
    return;
  }

  const messaging = getMessaging();
  const data = {
    notificationId: notificationRef.id,
    type: input.type,
    routeName: input.route ?? "",
    salonId,
    sourceId: input.sourceId ?? "",
  };
  const stringData: Record<string, string> = {};
  for (const [k, v] of Object.entries(data)) {
    stringData[k] = typeof v === "string" ? v : String(v);
  }

  const chunkSize = 500;
  for (let i = 0; i < tokens.length; i += chunkSize) {
    const chunk = tokens.slice(i, i + chunkSize);
    await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: {
        title: input.title,
        body: input.body,
      },
      data: stringData,
    });
  }
}

/**
 * Records the raw FCM token on the user doc for Functions that send via
 * [collectPushTokens].
 */
export async function mergeUserFcmToken(userId: string, token: string): Promise<void> {
  const t = token.trim();
  if (!userId || !t) {
    return;
  }
  await db.collection("users").doc(userId).set(
    {
      fcmTokens: { [t]: true },
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}
