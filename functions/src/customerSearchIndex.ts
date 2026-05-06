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

/** Exported for backfill script — mirrors mobile `buildSalonSearchKeywords`. */
export function buildKeywords(values: Array<string | undefined | null>): string[] {
  const set = new Set<string>();

  for (const value of values) {
    if (!value) continue;
    const normalized = value
      .toLowerCase()
      .trim()
      .replace(/[^\p{L}\p{N}\s]/gu, "");

    if (!normalized) continue;
    const parts = normalized.split(/\s+/).filter(Boolean);
    for (const part of parts) {
      set.add(part);
    }
    set.add(normalized);
  }

  return Array.from(set).slice(0, 80);
}

function geoFromDoc(d: DocumentData): GeoPoint | null {
  const loc = d.location;
  if (loc instanceof GeoPoint) {
    return loc;
  }
  const lat = numOrNull(d.latitude);
  const lng = numOrNull(d.longitude);
  if (lat != null && lng != null) {
    return new GeoPoint(lat, lng);
  }
  return null;
}

function truthyBool(v: unknown, fallback: boolean): boolean {
  return typeof v === "boolean" ? v : fallback;
}

function normalizeAudience(v: unknown): string {
  const raw = typeof v === "string" ? v.trim().toLowerCase() : "";
  if (raw === "men" || raw === "ladies" || raw === "unisex") return raw;
  return "unisex";
}

function listStrings(v: unknown): string[] {
  if (!Array.isArray(v)) return [];
  return v.map((x) => `${x}`.trim()).filter((s) => s.length > 0);
}

/** ISO country on every index row — required for customer queries + rules. */
export function countryMetaFromSalon(salon: DocumentData): {
  countryCode: string;
  countryName: string;
} {
  let code = str(salon, "countryCode").trim().toUpperCase();
  const name = str(salon, "countryName") || str(salon, "country") || "";
  if (!code) {
    console.warn("[customerSearchIndex] missing salons.countryCode — defaulting QA");
    code = "QA";
  }
  return { countryCode: code, countryName: name.trim() || code };
}

export async function upsertSalonSearchIndexFromFirestore(salonId: string): Promise<void> {
  const ref = db.doc(`customerSearchIndex/salon_${salonId}`);
  const snap = await db.doc(`salons/${salonId}`).get();
  if (!snap.exists) {
    await ref.delete().catch(() => undefined);
    return;
  }
  const s = snap.data()!;
  const name = str(s, "name") || "Salon";
  const city = str(s, "city");
  const area = str(s, "area") || city;
  const businessType = str(s, "businessType");
  const isActive = truthyBool(s.isActive, true);
  const isPublic = truthyBool(s.isPublished, false) && isActive;

  const tags = listStrings(s.tags);
  const keywords = listStrings(s.searchKeywords);
  const audienceLabel = normalizeAudience(s.audience ?? s.customerAudience);
  const cm = countryMetaFromSalon(s);
  const derivedKeywords = buildKeywords([
    name,
    str(s, "publicName"),
    city,
    area,
    str(s, "country") || str(s, "countryName"),
    cm.countryCode,
    cm.countryName,
    businessType,
    audienceLabel,
    ...tags,
    ...keywords,
  ]);

  let serviceCount = 0;
  let teamCount = 0;
  try {
    const [svcSnap, empSnap] = await Promise.all([
      db.collection(`salons/${salonId}/services`).where("isActive", "==", true).get(),
      db.collection(`salons/${salonId}/employees`).where("isActive", "==", true).get(),
    ]);
    serviceCount = svcSnap.size;
    teamCount = empSnap.size;
  } catch (e) {
    console.warn(`[customerSearchIndex] subcollection counts failed salon=${salonId}`, e);
  }

  const payload: Record<string, unknown> = {
    type: "salon",
    salonId,
    targetId: salonId,
    title: name,
    subtitle: [businessType, area].filter(Boolean).join(" • "),
    imageUrl: str(s, "coverImageUrl") || str(s, "logoUrl") || null,
    city,
    area,
    countryCode: cm.countryCode,
    countryName: cm.countryName,
    audience: audienceLabel,
    ratingAvg: numOrNull(s.ratingAverage) ?? numOrNull(s.ratingAvg) ?? 0,
    ratingCount: Math.max(0, Math.round(numOrNull(s.ratingCount) ?? 0)),
    priceFrom: numOrNull(s.startingPrice) ?? numOrNull(s.minServicePrice) ?? null,
    hasOffer: truthyBool(s.hasOffer, false),
    isOpenNow: truthyBool(s.isOpen, false),
    isActive,
    isPublic,
    searchKeywords: derivedKeywords,
    location: geoFromDoc(s),
    serviceCount,
    teamCount,
    updatedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
  };

  await ref.set(payload, { merge: true });
}

export async function upsertServiceSearchIndexFromFirestore(
  salonId: string,
  serviceId: string,
): Promise<void> {
  const ref = db.doc(`customerSearchIndex/service_${salonId}_${serviceId}`);
  const svcSnap = await db.doc(`salons/${salonId}/services/${serviceId}`).get();
  if (!svcSnap.exists) {
    await ref.delete().catch(() => undefined);
    return;
  }

  const svc = svcSnap.data()!;
  const salonSnap = await db.doc(`salons/${salonId}`).get();
  const salon = salonSnap.exists ? salonSnap.data()! : {};

  const isSalonActive = truthyBool(salon.isActive, true);
  const isSalonPublic = truthyBool(salon.isPublished, false) && isSalonActive;

  const title = str(svc, "serviceName") || str(svc, "name") || "Service";
  const salonName = str(salon, "name") || "Salon";
  const city = str(salon, "city");
  const area = str(salon, "area") || city;
  const priceFrom = numOrNull(svc.price) ?? null;

  const keywords = [...listStrings(svc.searchKeywords), ...listStrings(salon.searchKeywords)];
  const cm = countryMetaFromSalon(salon);
  const derivedKeywords = buildKeywords([
    title,
    salonName,
    city,
    area,
    cm.countryCode,
    cm.countryName,
    ...keywords,
  ]);

  const payload: Record<string, unknown> = {
    type: "service",
    salonId,
    targetId: serviceId,
    title,
    subtitle: [salonName, priceFrom != null ? `${priceFrom}` : ""].filter(Boolean).join(" • "),
    imageUrl: str(svc, "imageUrl") || str(salon, "coverImageUrl") || null,
    city,
    area,
    countryCode: cm.countryCode,
    countryName: cm.countryName,
    audience: normalizeAudience(svc.audience ?? salon.audience),
    ratingAvg: numOrNull(salon.ratingAverage) ?? 0,
    ratingCount: Math.max(0, Math.round(numOrNull(salon.ratingCount) ?? 0)),
    priceFrom,
    hasOffer: truthyBool(svc.hasOffer, false) || truthyBool(salon.hasOffer, false),
    isOpenNow: truthyBool(salon.isOpen, false),
    isActive: truthyBool(svc.isActive, true),
    isPublic: isSalonPublic,
    searchKeywords: derivedKeywords,
    location: geoFromDoc(salon),
    updatedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
  };

  await ref.set(payload, { merge: true });
}

export async function upsertEmployeeSearchIndexFromFirestore(
  salonId: string,
  employeeId: string,
): Promise<void> {
  const ref = db.doc(`customerSearchIndex/specialist_${salonId}_${employeeId}`);
  const empSnap = await db.doc(`salons/${salonId}/employees/${employeeId}`).get();
  if (!empSnap.exists) {
    await ref.delete().catch(() => undefined);
    return;
  }

  const e = empSnap.data()!;
  const isBookable = truthyBool(e.isBookable, false) || truthyBool(e.allowCustomerBooking, false);
  const isActive = truthyBool(e.isActive, true);
  if (!isBookable || !isActive) {
    await ref.delete().catch(() => undefined);
    return;
  }

  const salonSnap = await db.doc(`salons/${salonId}`).get();
  const salon = salonSnap.exists ? salonSnap.data()! : {};

  const isSalonActive = truthyBool(salon.isActive, true);
  const isSalonPublic = truthyBool(salon.isPublished, false) && isSalonActive;

  const title = str(e, "publicDisplayName") || str(e, "displayName") || str(e, "name") || "Specialist";
  const roleTitle = str(e, "roleTitle") || str(e, "role") || "Specialist";
  const salonName = str(salon, "name") || "Salon";
  const city = str(salon, "city");
  const area = str(salon, "area") || city;

  const specialties = listStrings(e.specialties);
  const keywords = [...listStrings(e.searchKeywords), ...listStrings(salon.searchKeywords)];

  const cm = countryMetaFromSalon(salon);
  const derivedKeywords = buildKeywords([
    title,
    roleTitle,
    salonName,
    city,
    area,
    cm.countryCode,
    cm.countryName,
    ...specialties,
    ...keywords,
  ]);

  const payload: Record<string, unknown> = {
    type: "specialist",
    salonId,
    targetId: employeeId,
    title,
    subtitle: [roleTitle, salonName].filter(Boolean).join(" • "),
    imageUrl: str(e, "profileImageUrl") || str(e, "avatarUrl") || null,
    city,
    area,
    countryCode: cm.countryCode,
    countryName: cm.countryName,
    audience: normalizeAudience(e.audience ?? salon.audience),
    ratingAvg: numOrNull(e.ratingAverage) ?? numOrNull(e.ratingAvg) ?? 0,
    ratingCount: Math.max(0, Math.round(numOrNull(e.ratingCount) ?? 0)),
    hasOffer: truthyBool(salon.hasOffer, false),
    isOpenNow: truthyBool(salon.isOpen, false),
    isActive,
    isPublic: isSalonPublic,
    searchKeywords: derivedKeywords,
    location: geoFromDoc(salon),
    updatedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
  };

  await ref.set(payload, { merge: true });
}

export const syncSalonSearchIndex = onDocumentWritten(
  { document: "salons/{salonId}", region: REGION },
  async (event) => {
    const salonId = event.params.salonId as string;
    const after = event.data?.after;
    const ref = db.doc(`customerSearchIndex/salon_${salonId}`);

    if (!after?.exists) {
      await ref.delete().catch(() => undefined);
      return;
    }

    await upsertSalonSearchIndexFromFirestore(salonId);
  },
);

export const syncServiceSearchIndex = onDocumentWritten(
  { document: "salons/{salonId}/services/{serviceId}", region: REGION },
  async (event) => {
    const salonId = event.params.salonId as string;
    const serviceId = event.params.serviceId as string;
    const after = event.data?.after;
    const ref = db.doc(`customerSearchIndex/service_${salonId}_${serviceId}`);

    if (!after?.exists) {
      await ref.delete().catch(() => undefined);
      return;
    }

    await upsertServiceSearchIndexFromFirestore(salonId, serviceId);
  },
);

export const syncEmployeeSearchIndex = onDocumentWritten(
  { document: "salons/{salonId}/employees/{employeeId}", region: REGION },
  async (event) => {
    const salonId = event.params.salonId as string;
    const employeeId = event.params.employeeId as string;
    const after = event.data?.after;
    const ref = db.doc(`customerSearchIndex/specialist_${salonId}_${employeeId}`);

    if (!after?.exists) {
      await ref.delete().catch(() => undefined);
      return;
    }

    await upsertEmployeeSearchIndexFromFirestore(salonId, employeeId);
  },
);
