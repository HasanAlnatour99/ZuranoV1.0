import { FieldPath, Timestamp } from "firebase-admin/firestore";
import type { QueryDocumentSnapshot } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { db } from "./bookingShared";
import { notifyOwnerDigest } from "./notificationOrchestrator";

function utcYesterdayBounds(): { start: Date; end: Date; dayKey: string } {
  const now = new Date();
  const yday = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 1),
  );
  const start = new Date(
    Date.UTC(yday.getUTCFullYear(), yday.getUTCMonth(), yday.getUTCDate(), 0, 0, 0),
  );
  const end = new Date(
    Date.UTC(yday.getUTCFullYear(), yday.getUTCMonth(), yday.getUTCDate() + 1, 0, 0, 0),
  );
  const dayKey = `${start.getUTCFullYear()}-${String(start.getUTCMonth() + 1).padStart(2, "0")}-${String(start.getUTCDate()).padStart(2, "0")}`;
  return { start, end, dayKey };
}

async function countBookingsStartAtRange(
  salonId: string,
  start: Date,
  end: Date,
): Promise<number> {
  const agg = await db
    .collection("salons")
    .doc(salonId)
    .collection("bookings")
    .where("startAt", ">=", Timestamp.fromDate(start))
    .where("startAt", "<", Timestamp.fromDate(end))
    .count()
    .get();
  return agg.data().count;
}

/** UTC 07:00 — digest for the previous UTC day. */
export const sendDailyOwnerSummaries = onSchedule(
  {
    schedule: "0 7 * * *",
    region: "us-central1",
    timeZone: "UTC",
  },
  async () => {
    const { start, end, dayKey } = utcYesterdayBounds();

    let cursor: QueryDocumentSnapshot | undefined;
    const page = 25;

    for (;;) {
      let q = db.collection("salons").orderBy(FieldPath.documentId()).limit(page);
      if (cursor) {
        q = q.startAfter(cursor);
      }
      const salonSnap = await q.get();
      if (salonSnap.empty) {
        break;
      }

      for (const doc of salonSnap.docs) {
        const salonId = doc.id;
        const ownerUid = doc.get("ownerUid");
        if (typeof ownerUid !== "string" || ownerUid.length === 0) {
          continue;
        }

        const count = await countBookingsStartAtRange(salonId, start, end);
        const summary = `Bookings on ${dayKey}: ${count}. Open the app for details.`;
        await notifyOwnerDigest({
          salonId,
          ownerUid,
          eventType: "daily_summary",
          summary,
          dedupeKey: `daily_summary:${salonId}:${dayKey}`,
        });
      }

      cursor = salonSnap.docs[salonSnap.docs.length - 1];
      if (salonSnap.size < page) {
        break;
      }
    }
  },
);

/** UTC 08:00 on the 1st — previous calendar month (UTC). */
export const sendMonthlyOwnerSummaries = onSchedule(
  {
    schedule: "0 8 1 * *",
    region: "us-central1",
    timeZone: "UTC",
  },
  async () => {
    const now = new Date();
    const prevMonthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 1, 1));
    const thisMonthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1));
    const y = prevMonthStart.getUTCFullYear();
    const m = prevMonthStart.getUTCMonth() + 1;
    const periodLabel = `${y}-${String(m).padStart(2, "0")}`;

    let cursor: QueryDocumentSnapshot | undefined;
    const page = 25;

    for (;;) {
      let q = db.collection("salons").orderBy(FieldPath.documentId()).limit(page);
      if (cursor) {
        q = q.startAfter(cursor);
      }
      const salonSnap = await q.get();
      if (salonSnap.empty) {
        break;
      }

      for (const doc of salonSnap.docs) {
        const salonId = doc.id;
        const ownerUid = doc.get("ownerUid");
        if (typeof ownerUid !== "string" || ownerUid.length === 0) {
          continue;
        }

        const count = await countBookingsStartAtRange(salonId, prevMonthStart, thisMonthStart);
        const summary = `Monthly recap (${periodLabel}): ${count} bookings with start times in this period.`;
        await notifyOwnerDigest({
          salonId,
          ownerUid,
          eventType: "monthly_summary",
          summary,
          dedupeKey: `monthly_summary:${salonId}:${periodLabel}`,
        });
      }

      cursor = salonSnap.docs[salonSnap.docs.length - 1];
      if (salonSnap.size < page) {
        break;
      }
    }
  },
);
