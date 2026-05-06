import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

if (!getApps().length) {
  initializeApp();
}

export const db = getFirestore();

export const BookingStatuses = {
  pending: "pending",
  confirmed: "confirmed",
  completed: "completed",
  cancelled: "cancelled",
  noShow: "no_show",
  rescheduled: "rescheduled",
} as const;

/** Legacy `scheduled` is treated as pending everywhere. */
export function normalizeBookingStatus(raw: string): string {
  const s = raw.trim();
  if (!s || s === "scheduled") {
    return BookingStatuses.pending;
  }
  return s;
}

export type UserProfile = {
  role: string;
  salonId: string | null;
  employeeId: string | null;
};

export async function loadUserProfile(uid: string): Promise<UserProfile> {
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

export function requireString(data: Record<string, unknown>, key: string): string {
  const v = data[key];
  if (typeof v !== "string" || v.length === 0) {
    throw new HttpsError("invalid-argument", `Missing or invalid ${key}.`);
  }
  return v;
}

export function requireNumber(data: Record<string, unknown>, key: string): number {
  const v = data[key];
  const n = typeof v === "number" ? v : Number(v);
  if (!Number.isFinite(n)) {
    throw new HttpsError("invalid-argument", `Missing or invalid ${key}.`);
  }
  return n;
}

export function msToDate(ms: unknown): Date {
  const n = typeof ms === "number" ? ms : Number(ms);
  if (!Number.isFinite(n)) {
    throw new HttpsError("invalid-argument", "Invalid timestamp.");
  }
  return new Date(n);
}

export function assertSalonStaffBooking(
  user: UserProfile,
  uid: string,
  salonId: string,
  booking: Record<string, unknown>,
): void {
  const pathSalon = (booking.salonId as string) ?? "";
  if (pathSalon !== salonId) {
    throw new HttpsError("failed-precondition", "Booking salon mismatch.");
  }
  const barberId = (booking.barberId as string) ?? "";
  if (user.role === "customer") {
    throw new HttpsError(
      "permission-denied",
      "Unauthorized role: customers cannot perform this action.",
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
        "Unauthorized role: barbers may only act on their own bookings.",
      );
    }
    return;
  }
  throw new HttpsError("permission-denied", "Unauthorized role.");
}

export function roundMoney(n: number): number {
  return Math.round(n * 100) / 100;
}

/** Any signed-in user may read availability for an active salon; otherwise owner or member. */
export async function assertCanReadSalonAvailability(
  salonId: string,
  uid: string,
): Promise<void> {
  const salonSnap = await db.collection("salons").doc(salonId).get();
  if (!salonSnap.exists) {
    throw new HttpsError("not-found", "Salon not found.");
  }
  const isActive = salonSnap.get("isActive") === true;
  const ownerUid = salonSnap.get("ownerUid") as string | undefined;
  if (isActive) {
    return;
  }
  if (ownerUid === uid) {
    return;
  }
  const user = await loadUserProfile(uid);
  if (user.salonId === salonId) {
    return;
  }
  throw new HttpsError("permission-denied", "Salon not available.");
}
