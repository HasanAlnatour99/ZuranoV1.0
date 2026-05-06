import { FieldValue, GeoPoint, type DocumentData } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { db } from "./bookingShared";

const REGION = "us-central1" as const;

function str(data: DocumentData, key: string): string {
  const v = data[key];
  return typeof v === "string" ? v.trim() : "";
}

function numOrNull(v: unknown): number | null {
  if (typeof v === "number" && Number.isFinite(v)) {
    return v;
  }
  if (typeof v === "string") {
    const n = Number(v);
    return Number.isFinite(n) ? n : null;
  }
  return null;
}

function geoFromSalonDoc(d: DocumentData): { latitude?: number; longitude?: number } {
  const lat = numOrNull(d.latitude);
  const lng = numOrNull(d.longitude);
  if (lat != null && lng != null) {
    return { latitude: lat, longitude: lng };
  }
  const loc = d.location;
  if (loc instanceof GeoPoint) {
    return { latitude: loc.latitude, longitude: loc.longitude };
  }
  return {};
}

/** Maps private `salons/{salonId}` → customer-safe `publicSalons/{salonId}`. */
export function salonToPublicSalonPayload(
  salonId: string,
  s: DocumentData,
): Record<string, unknown> {
  const name = str(s, "name") || "Salon";
  const city = str(s, "city");
  const area = str(s, "area") || city;
  const countryName = str(s, "countryName") || str(s, "country");
  let countryCode = str(s, "countryCode").toUpperCase();
  if (!countryCode) {
    console.warn(`[publicSalonMirror] salon ${salonId} missing countryCode — defaulting QA`);
    countryCode = "QA";
  }

  const isActive = s.isActive !== false;
  const isPublic = s.isPublished === true && isActive;

  const { latitude, longitude } = geoFromSalonDoc(s);

  const ratingAverageRaw = numOrNull(s.ratingAverage);
  const ratingCountRaw = numOrNull(s.ratingCount);

  const payload: Record<string, unknown> = {
    salonId,
    id: salonId,
    salonName: name,
    area,
    city,
    countryName,
    country: countryName,
    countryCode,
    phone: str(s, "phone") || null,
    whatsapp: str(s, "whatsapp") || null,
    coverImageUrl: str(s, "coverImageUrl") || null,
    logoUrl: str(s, "logoUrl") || null,
    ...(latitude != null ? { latitude } : {}),
    ...(longitude != null ? { longitude } : {}),
    isPublic,
    isActive,
    isOpen: s.isOpen === true,
    isPromoted: s.isPromoted === true,
    ratingAverage: ratingAverageRaw != null ? Math.min(5, Math.max(0, ratingAverageRaw)) : 0,
    ratingCount: ratingCountRaw != null ? Math.max(0, Math.round(ratingCountRaw)) : 0,
    currencyCode: str(s, "currencyCode") || "USD",
    // Optional discovery fields (present in customer home models)
    tags: Array.isArray(s.tags) ? s.tags.map((x: unknown) => `${x}`.trim()).filter((t: string) => t) : [],
    categoryIds: Array.isArray(s.categoryIds)
      ? s.categoryIds.map((x: unknown) => `${x}`.trim()).filter((t: string) => t)
      : [],
    searchKeywords: Array.isArray(s.searchKeywords)
      ? s.searchKeywords
          .map((x: unknown) => `${x}`.trim().toLowerCase())
          .filter((t: string) => t)
      : [],
    startingPrice: typeof s.startingPrice === "number" ? s.startingPrice : 0,
    updatedAt: FieldValue.serverTimestamp(),
  };

  // Preserve debug seed flag if present (dev only rules use this).
  if (s.debugSeed === true) {
    payload.debugSeed = true;
  }

  // Set createdAt only once if missing on public doc; safe to send on every write with merge.
  payload.createdAt = FieldValue.serverTimestamp();

  return payload;
}

export const onSalonWriteSyncPublicSalon = onDocumentWritten(
  {
    document: "salons/{salonId}",
    region: REGION,
  },
  async (event) => {
    const salonId = event.params.salonId as string;
    const after = event.data?.after;
    const publicRef = db.doc(`publicSalons/${salonId}`);

    if (!after?.exists) {
      await publicRef.delete().catch(() => undefined);
      return;
    }

    const payload = salonToPublicSalonPayload(salonId, after.data()!);
    await publicRef.set(payload, { merge: true });
  },
);

