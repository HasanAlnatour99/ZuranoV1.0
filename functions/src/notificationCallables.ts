import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireString } from "./bookingShared";
import { defaultNotificationPrefs, mergeNotificationPrefs } from "./notificationPrefs";

const db = getFirestore();

function requireBool(data: Record<string, unknown>, key: string): boolean {
  const v = data[key];
  if (typeof v !== "boolean") {
    throw new HttpsError("invalid-argument", `Missing or invalid ${key}.`);
  }
  return v;
}

export const registerDeviceToken = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const deviceId = requireString(data, "deviceId");
  const token = requireString(data, "token");
  const platform = requireString(data, "platform");
  const appVersion = requireString(data, "appVersion");
  const locale = requireString(data, "locale");
  const timezone = requireString(data, "timezone");
  const pushEnabled = data.pushEnabled === false ? false : true;

  const ref = db.doc(`users/${uid}/devices/${deviceId}`);
  const snap = await ref.get();
  const payload: Record<string, unknown> = {
    token,
    platform,
    appVersion,
    locale,
    timezone,
    pushEnabled,
    active: true,
    invalidatedAt: FieldValue.delete(),
    invalidReason: FieldValue.delete(),
    lastSeenAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (!snap.exists) {
    payload.createdAt = FieldValue.serverTimestamp();
  }
  await ref.set(payload, { merge: true });

  const userRef = db.doc(`users/${uid}`);
  const uSnap = await userRef.get();
  if (!uSnap.exists || !uSnap.get("notificationPrefs")) {
    await userRef.set(
      { notificationPrefs: defaultNotificationPrefs() },
      { merge: true },
    );
  }

  return { ok: true };
});

export const unregisterDeviceToken = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const deviceId = requireString(data, "deviceId");
  await db.doc(`users/${uid}/devices/${deviceId}`).delete();
  return { ok: true };
});

export const updateNotificationPreferences = onCall({ region: "us-central1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const data = request.data as Record<string, unknown>;
  const prefsRaw = data.notificationPrefs;
  if (!prefsRaw || typeof prefsRaw !== "object") {
    throw new HttpsError("invalid-argument", "notificationPrefs map required.");
  }
  const incoming = prefsRaw as Record<string, unknown>;
  const currentSnap = await db.doc(`users/${uid}`).get();
  const merged = mergeNotificationPrefs(
    currentSnap.exists ? currentSnap.get("notificationPrefs") : undefined,
  );

  if ("pushEnabled" in incoming) {
    merged.pushEnabled = requireBool(incoming, "pushEnabled");
  }
  if ("bookingReminders" in incoming) {
    merged.bookingReminders = requireBool(incoming, "bookingReminders");
  }
  if ("bookingChanges" in incoming) {
    merged.bookingChanges = requireBool(incoming, "bookingChanges");
  }
  if ("payrollAlerts" in incoming) {
    merged.payrollAlerts = requireBool(incoming, "payrollAlerts");
  }
  if ("violationAlerts" in incoming) {
    merged.violationAlerts = requireBool(incoming, "violationAlerts");
  }
  if ("marketingEnabled" in incoming) {
    merged.marketingEnabled = requireBool(incoming, "marketingEnabled");
  }
  if ("attendanceAlerts" in incoming) {
    merged.attendanceAlerts = requireBool(incoming, "attendanceAlerts");
  }
  if ("approvalAlerts" in incoming) {
    merged.approvalAlerts = requireBool(incoming, "approvalAlerts");
  }
  if ("systemAlerts" in incoming) {
    merged.systemAlerts = requireBool(incoming, "systemAlerts");
  }

  await db.doc(`users/${uid}`).set(
    {
      notificationPrefs: merged,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return { ok: true };
});
