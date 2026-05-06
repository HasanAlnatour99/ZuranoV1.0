/**
 * One-time / ops backfill: rebuild `customerSearchIndex/*` from salon/service/employee docs.
 *
 * Usage (from repo root, with Application Default Credentials):
 *   cd functions && npm run build && node lib/scripts/runBackfillCustomerSearchIndex.js
 *
 * Requires Firebase Admin credentials (e.g. GOOGLE_APPLICATION_CREDENTIALS or gcloud auth).
 */
import { getFirestore } from "firebase-admin/firestore";

import {
  upsertEmployeeSearchIndexFromFirestore,
  upsertSalonSearchIndexFromFirestore,
  upsertServiceSearchIndexFromFirestore,
} from "../customerSearchIndex";

const db = getFirestore();

async function main(): Promise<void> {
  const salonsSnap = await db.collection("salons").where("isActive", "==", true).get();
  console.log(`[backfill customerSearchIndex] active salons=${salonsSnap.size}`);

  for (const doc of salonsSnap.docs) {
    const salonId = doc.id;
    await upsertSalonSearchIndexFromFirestore(salonId);

    const services = await db.collection(`salons/${salonId}/services`).get();
    for (const s of services.docs) {
      await upsertServiceSearchIndexFromFirestore(salonId, s.id);
    }

    const employees = await db.collection(`salons/${salonId}/employees`).get();
    for (const e of employees.docs) {
      await upsertEmployeeSearchIndexFromFirestore(salonId, e.id);
    }
  }

  console.log("[backfill customerSearchIndex] done");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
