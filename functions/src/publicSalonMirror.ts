import { FieldValue, GeoPoint, type DocumentData } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as ngeohash from "ngeohash";

import { db, loadUserProfile } from "./bookingShared";
import { refreshPublicSalonStartingPrice } from "./publicStartingPrice";

const REGION = "us-central1" as const;

/** Matches `GeoFireCommon.geoHashPrecision` on the Flutter map client. */
const PUBLIC_SALON_GEOHASH_PRECISION = 10;

function str(data: DocumentData, key: string): string {
  const v = data[key];
  return typeof v === "string" ? v.trim() : "";
}

function strList(data: DocumentData, key: string): string[] {
  const v = data[key];
  if (!Array.isArray(v)) {
    return [];
  }
  return v.map((x: unknown) => `${x}`.trim()).filter((t: string) => t.length > 0);
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

/** Exported for customerSearchIndex geo mirroring and tests. */
export function geoFromSalonDoc(d: DocumentData): { latitude?: number; longitude?: number } {
  const lat = numOrNull(d.latitude);
  const lng = numOrNull(d.longitude);
  if (lat != null && lng != null) {
    return { latitude: lat, longitude: lng };
  }
  const loc = d.location;
  if (loc instanceof GeoPoint) {
    return { latitude: loc.latitude, longitude: loc.longitude };
  }
  const addr = d.address;
  if (addr && typeof addr === "object" && !Array.isArray(addr)) {
    const a = addr as Record<string, unknown>;
    const innerLoc = a.location;
    if (innerLoc instanceof GeoPoint) {
      return { latitude: innerLoc.latitude, longitude: innerLoc.longitude };
    }
    const alat = numOrNull(a.latitude ?? a.lat);
    const alng = numOrNull(a.longitude ?? a.lng);
    if (alat != null && alng != null) {
      return { latitude: alat, longitude: alng };
    }
  }
  return {};
}

/** Attendance punch zone — fallback only when root salon has no geo. */
export function geoFromAttendanceDoc(a: DocumentData): { latitude: number; longitude: number } | null {
  const zone = a.zone;
  const zoneObj =
    zone && typeof zone === "object" && !Array.isArray(zone)
      ? (zone as Record<string, unknown>)
      : null;
  const lat =
    numOrNull(a.salonLatitude) ??
    numOrNull(a.latitude) ??
    (zoneObj ? numOrNull(zoneObj.latitude) : null);
  const lng =
    numOrNull(a.salonLongitude) ??
    numOrNull(a.longitude) ??
    (zoneObj ? numOrNull(zoneObj.longitude) : null);
  if (lat != null && lng != null) {
    return { latitude: lat, longitude: lng };
  }
  return null;
}

/**
 * Prefer coordinates on `salons/{salonId}`; if missing, use punch zone under
 * `salons/{salonId}/settings/attendance`.
 */
export async function resolveGeoForPublicMirror(
  salonId: string,
  s: DocumentData,
): Promise<{ latitude: number; longitude: number } | null> {
  const root = geoFromSalonDoc(s);
  if (
    typeof root.latitude === "number" &&
    Number.isFinite(root.latitude) &&
    typeof root.longitude === "number" &&
    Number.isFinite(root.longitude)
  ) {
    return { latitude: root.latitude, longitude: root.longitude };
  }
  const attSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
  if (!attSnap.exists) {
    return null;
  }
  return geoFromAttendanceDoc(attSnap.data()!);
}

/** Maps private `salons/{salonId}` → customer-safe `publicSalons/{salonId}`. */
export function salonToPublicSalonPayload(
  salonId: string,
  s: DocumentData,
  resolvedGeo: { latitude: number; longitude: number } | null,
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
  const isPublishedFlag =
    typeof s.isPublished === "boolean" ? s.isPublished : true;
  // Customer clients query `publicSalons` with `isPublic == true`. The mobile
  // app sets `isPublished` on `salons/{id}` (there is no separate owner toggle
  // wired to `isPublic`). Mirror discovery visibility from `isPublished`, with
  // optional legacy `isPublic === true` on the private doc as an extra opt-in.
  const isPublic = isActive && (isPublishedFlag || s.isPublic === true);

  const rootGeo = geoFromSalonDoc(s);
  const latitude = resolvedGeo?.latitude ?? rootGeo.latitude;
  const longitude = resolvedGeo?.longitude ?? rootGeo.longitude;

  const hasValidGeo =
    typeof latitude === "number" &&
    Number.isFinite(latitude) &&
    typeof longitude === "number" &&
    Number.isFinite(longitude);

  let geoHashValue: string | null = null;
  if (hasValidGeo) {
    try {
      geoHashValue = ngeohash.encode(latitude, longitude, PUBLIC_SALON_GEOHASH_PRECISION);
    } catch (e) {
      console.warn(`[publicSalonMirror] geohash encode failed salon=${salonId}`, e);
    }
  }

  const ratingAverageRaw = numOrNull(s.ratingAverage);
  const ratingCountRaw = numOrNull(s.ratingCount);

  const customerAbout =
    str(s, "customerAbout") ||
    str(s, "about") ||
    str(s, "description") ||
    "";
  const ownerDisplayName = str(s, "ownerName");
  let formattedAddress = str(s, "formattedAddress");
  if (!formattedAddress) {
    const city = str(s, "city");
    const areaPart = str(s, "area");
    const addrRaw = s.address;
    const addrLine =
      typeof addrRaw === "string"
        ? addrRaw.trim()
        : "";
    const parts = [addrLine, areaPart, city].filter((p) => p.length > 0);
    formattedAddress = parts.join(", ");
  }

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
    photoUrls: strList(s, "photoUrls"),
    logoUrl: str(s, "logoUrl") || null,
    ...(hasValidGeo
      ? {
          latitude,
          longitude,
          location: new GeoPoint(latitude, longitude),
          ...(geoHashValue != null && geoHashValue.length > 0 ? { geohash: geoHashValue } : {}),
        }
      : {
          latitude: FieldValue.delete(),
          longitude: FieldValue.delete(),
          location: FieldValue.delete(),
          geohash: FieldValue.delete(),
        }),
    isPublic,
    isActive,
    isPublished: isPublishedFlag,
    isOpen: s.isOpen === true,
    isPromoted: s.isPromoted === true,
    ratingAverage: ratingAverageRaw != null ? Math.min(5, Math.max(0, ratingAverageRaw)) : 0,
    ratingCount: ratingCountRaw != null ? Math.max(0, Math.round(ratingCountRaw)) : 0,
    ...(customerAbout.length > 0 ? { customerAbout } : {}),
    ...(ownerDisplayName.length > 0 ? { ownerDisplayName } : {}),
    ...(formattedAddress.length > 0 ? { formattedAddress } : {}),
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
    updatedAt: FieldValue.serverTimestamp(),
  };

  const wh = s["workingHours"];
  if (wh != null && typeof wh === "object" && !Array.isArray(wh)) {
    payload.workingHours = wh as Record<string, unknown>;
  }

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

    const afterData = after.data()!;
    const resolvedGeo = await resolveGeoForPublicMirror(salonId, afterData);
    const payload = salonToPublicSalonPayload(salonId, afterData, resolvedGeo);
    await publicRef.set(payload, { merge: true });
    await refreshPublicSalonStartingPrice(salonId);
  },
);

/** When only attendance zone changes, refresh public mirror geo without requiring a salon doc edit. */
export const onAttendanceSettingsWriteSyncPublicSalon = onDocumentWritten(
  {
    document: "salons/{salonId}/settings/attendance",
    region: REGION,
  },
  async (event) => {
    const salonId = event.params.salonId as string;
    const salonSnap = await db.doc(`salons/${salonId}`).get();
    if (!salonSnap.exists) {
      return;
    }
    const s = salonSnap.data()!;
    const resolvedGeo = await resolveGeoForPublicMirror(salonId, s);
    const payload = salonToPublicSalonPayload(salonId, s, resolvedGeo);
    await db.doc(`publicSalons/${salonId}`).set(payload, { merge: true });
    await refreshPublicSalonStartingPrice(salonId);
  },
);

/**
 * Backfill root salon geo from attendance settings and refresh `publicSalons` geo fields.
 * Callable: owner or admin of the salon.
 */
export const repairPublicSalonGeoForSalon = onCall(
  { region: REGION },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const raw = request.data as Record<string, unknown> | undefined;
    const salonId = typeof raw?.salonId === "string" ? raw.salonId.trim() : "";
    if (!salonId) {
      throw new HttpsError("invalid-argument", "salonId required.");
    }

    const salonRef = db.doc(`salons/${salonId}`);
    const salonSnap = await salonRef.get();
    if (!salonSnap.exists) {
      throw new HttpsError("not-found", "Salon not found.");
    }

    const salonData = salonSnap.data()!;
    const ownerUid = (salonData.ownerUid as string | undefined) ?? "";
    const profile = await loadUserProfile(uid);
    const isOwner = ownerUid === uid;
    const isStaffAdmin =
      profile.salonId === salonId && (profile.role === "owner" || profile.role === "admin");
    if (!isOwner && !isStaffAdmin) {
      throw new HttpsError("permission-denied", "Not authorized for this salon.");
    }

    let repairedRoot = false;
    const rootGeo = geoFromSalonDoc(salonData);
    if (rootGeo.latitude == null || rootGeo.longitude == null) {
      const attSnap = await db.doc(`salons/${salonId}/settings/attendance`).get();
      const attGeo = attSnap.exists ? geoFromAttendanceDoc(attSnap.data()!) : null;
      if (attGeo != null) {
        await salonRef.set(
          {
            latitude: attGeo.latitude,
            longitude: attGeo.longitude,
            location: new GeoPoint(attGeo.latitude, attGeo.longitude),
            businessLocationUpdatedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        repairedRoot = true;
      }
    }

    const freshSnap = await salonRef.get();
    const freshData = freshSnap.data()!;
    const resolvedGeo = await resolveGeoForPublicMirror(salonId, freshData);
    const payload = salonToPublicSalonPayload(salonId, freshData, resolvedGeo);
    await db.doc(`publicSalons/${salonId}`).set(payload, { merge: true });
    await refreshPublicSalonStartingPrice(salonId);

    return {
      success: true,
      repairedRoot,
      hasGeo: resolvedGeo != null,
    };
  },
);
