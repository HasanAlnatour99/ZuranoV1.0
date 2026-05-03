import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const db = getFirestore();

/**
 * Placeholder: builds a readable policy from `settings/attendance` without Gemini.
 * Replace body with Vertex/Gemini when ready — API keys stay server-side only.
 */
export const generateAttendancePolicyReadable = onCall(
  { region: "us-central1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }
    const salonIdRaw = (request.data as { salonId?: unknown })?.salonId;
    const salonId = typeof salonIdRaw === "string" ? salonIdRaw.trim() : "";
    if (!salonId) {
      throw new HttpsError("invalid-argument", "salonId is required.");
    }

    const uid = request.auth.uid;
    const userSnap = await db.doc(`users/${uid}`).get();
    const u = userSnap.data() ?? {};
    const role = String(u.role ?? "");
    const userSalon = u.salonId as string | undefined;
    if (userSalon !== salonId || !["owner", "admin"].includes(role)) {
      throw new HttpsError("permission-denied", "Owner or admin only.");
    }

    const settingsSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
    const s = settingsSnap.data() ?? {};
    const maxBreaks = typeof s.maxBreaksPerDay === "number" ? s.maxBreaksPerDay : 15;
    const lateGrace = typeof s.graceLateMinutes === "number" ? s.graceLateMinutes : 10;
    const earlyGrace =
      typeof s.graceEarlyExitMinutes === "number" ? s.graceEarlyExitMinutes : 10;
    const lateAllow =
      typeof s.monthlyLateAllowanceAfterGrace === "number"
        ? s.monthlyLateAllowanceAfterGrace
        : 3;
    const earlyAllow =
      typeof s.monthlyEarlyExitAllowanceAfterGrace === "number"
        ? s.monthlyEarlyExitAllowanceAfterGrace
        : 3;

    const payload = {
      salonId,
      title: "Attendance Policy",
      summary:
        "Policy summary: follow salon punch rules, stay inside the GPS zone when required, and use correction requests if you miss a punch.",
      employeeRules: [
        "You must punch in when your shift starts.",
        "You record one punch in and one punch out per day (breaks are separate).",
        `You can take up to ${maxBreaks} breaks per day.`,
        "Break Out must always be followed by Break In.",
      ],
      violationRules: [
        "Late arrival is counted only after the grace period.",
        `You are allowed ${lateAllow} late arrivals per month after grace before violations apply.`,
        "Early exit is counted only after the grace period.",
        `You are allowed ${earlyAllow} early exits per month after grace before violations apply.`,
      ],
      correctionRules: [
        "If you forget a punch, submit an attendance correction request.",
        "Approved requests will be added to your attendance record.",
        "Rejected requests will not affect your attendance.",
      ],
      generatedBy: "gemini",
      generatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    await db
      .doc(`salons/${salonId}/settings/attendancePolicyReadable`)
      .set(payload, { merge: true });

    return { ok: true };
  },
);
