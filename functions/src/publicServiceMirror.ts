import { FieldValue, type DocumentData } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { HttpsError, onCall, type CallableRequest } from "firebase-functions/v2/https";

import { db, requireString } from "./bookingShared";

const REGION = "us-central1" as const;

/** Maps private `services/{id}` → `publicSalons/{id}/services/{id}` for guest browse. */
export function serviceToPublicServicePayload(
  salonId: string,
  serviceId: string,
  s: DocumentData,
): Record<string, unknown> {
  const nameRaw = `${s.name ?? ""}`.trim();
  const name = nameRaw.length > 0 ? nameRaw : "Service";
  const nameAr = `${s.nameAr ?? ""}`.trim();
  const displayNameRaw = `${s.displayName ?? ""}`.trim();
  const displayName = displayNameRaw.length > 0 ? displayNameRaw : name;

  const categoryRaw = `${s.category ?? ""}`.trim();
  const categoryLabelRaw = `${s.categoryLabel ?? ""}`.trim();
  const category = categoryRaw.length > 0 ? categoryRaw : "Other";
  const categoryLabel = categoryLabelRaw.length > 0 ? categoryLabelRaw : category;

  const vis = s.isCustomerVisible;
  const isCustomerVisible = typeof vis === "boolean" ? vis : true;

  let duration = typeof s.durationMinutes === "number"
    ? s.durationMinutes
    : Number(s.durationMinutes);
  if (!Number.isFinite(duration) || duration <= 0) {
    duration = typeof s.duration === "number" ? s.duration : Number(s.duration);
  }
  if (!Number.isFinite(duration) || duration <= 0) {
    duration = 30;
  }

  const searchKeywords = Array.isArray(s.searchKeywords)
    ? s.searchKeywords
      .map((x) => `${x}`.trim().toLowerCase())
      .filter((k) => k.length > 0)
    : [];

  const sortOrder = typeof s.sortOrder === "number" ? s.sortOrder : 999;

  return {
    salonId,
    name,
    nameAr,
    displayName,
    category,
    categoryLabel,
    description: `${s.description ?? ""}`.trim() || null,
    price: typeof s.price === "number" ? s.price : Number(s.price) || 0,
    durationMinutes: Math.round(duration),
    imageUrl: `${s.imageUrl ?? ""}`.trim() || null,
    isActive: s.isActive === true,
    isCustomerVisible,
    sortOrder,
    searchKeywords,
    updatedAt: FieldValue.serverTimestamp(),
  };
}

async function assertSalonOwnerOrAdmin(
  request: CallableRequest,
  salonId: string,
): Promise<void> {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const uid = request.auth.uid;
  const u = await db.collection("users").doc(uid).get();
  if (!u.exists) {
    throw new HttpsError("permission-denied", "User profile not found.");
  }
  const role = `${u.get("role") ?? ""}`.trim().toLowerCase();
  const sid = `${u.get("salonId") ?? ""}`.trim();
  if (sid !== salonId) {
    throw new HttpsError("permission-denied", "Wrong salon.");
  }
  if (role !== "owner" && role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only salon owner or admin can run this.",
    );
  }
}

export const onServiceWriteSyncPublicService = onDocumentWritten(
  {
    document: "salons/{salonId}/services/{serviceId}",
    region: REGION,
  },
  async (event) => {
    const salonId = event.params.salonId as string;
    const serviceId = event.params.serviceId as string;
    const after = event.data?.after;
    const publicRef = db.doc(`publicSalons/${salonId}/services/${serviceId}`);

    if (!after?.exists) {
      await publicRef.delete().catch(() => undefined);
      return;
    }

    const payload = serviceToPublicServicePayload(
      salonId,
      serviceId,
      after.data()!,
    );
    await publicRef.set(payload, { merge: true });
  },
);

export const backfillPublicServicesForSalon = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request: CallableRequest) => {
    const data = request.data as Record<string, unknown>;
    const salonId = requireString(data, "salonId");
    await assertSalonOwnerOrAdmin(request, salonId);

    const svcSnap = await db.collection(`salons/${salonId}/services`).get();
    let synced = 0;
    for (const doc of svcSnap.docs) {
      const payload = serviceToPublicServicePayload(salonId, doc.id, doc.data());
      await db.doc(`publicSalons/${salonId}/services/${doc.id}`).set(payload, {
        merge: true,
      });
      synced++;
    }
    return { ok: true, synced };
  },
);
