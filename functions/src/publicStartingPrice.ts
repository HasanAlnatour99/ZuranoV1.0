import { FieldValue } from "firebase-admin/firestore";

import { db } from "./bookingShared";

/**
 * Sets `publicSalons/{salonId}.startingPrice` to the minimum `price` among
 * `publicSalons/{salonId}/services/*` where isActive && isCustomerVisible && price > 0.
 * If none qualify, writes `startingPrice: 0`.
 */
export async function refreshPublicSalonStartingPrice(salonId: string): Promise<void> {
  const id = `${salonId ?? ""}`.trim();
  if (!id) {
    return;
  }

  const snap = await db.collection(`publicSalons/${id}/services`).get();
  let min: number | null = null;
  for (const doc of snap.docs) {
    const d = doc.data();
    if (d.isActive !== true || d.isCustomerVisible !== true) {
      continue;
    }
    const raw = d.price;
    const p = typeof raw === "number" ? raw : Number(raw);
    if (!Number.isFinite(p) || p <= 0) {
      continue;
    }
    if (min == null || p < min) {
      min = p;
    }
  }

  const startingPrice = min ?? 0;
  await db.doc(`publicSalons/${id}`).set(
    {
      startingPrice,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}
