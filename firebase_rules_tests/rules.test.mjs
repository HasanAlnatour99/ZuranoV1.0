import { readFileSync } from "node:fs";
import test, { after, before } from "node:test";
import assert from "node:assert/strict";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc, deleteDoc, runTransaction, collection, query, where, limit, getDocs } from "firebase/firestore";

const PROJECT_ID = "barber-shop-rules-test";
let testEnv;

const rules = readFileSync("../firestore.rules", "utf8");

const ownerUid = "owner-1";
const adminUid = "admin-1";
const adminNoPermUid = "admin-no-perm";
const barberUid = "barber-1";
const customerUid = "customer-1";
const salonA = "salon-a";
const salonB = "salon-b";

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules },
  });

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, `salons/${salonA}`), { ownerUid, isActive: true });
    await setDoc(doc(db, `salons/${salonB}`), { ownerUid: "owner-2", isActive: true });
    await setDoc(doc(db, `users/${ownerUid}`), {
      uid: ownerUid,
      role: "owner",
      salonId: salonA,
      isActive: true,
    });
    await setDoc(doc(db, `users/${adminUid}`), {
      uid: adminUid,
      role: "admin",
      salonId: salonA,
      isActive: true,
      permissions: { canViewCustomers: true },
    });
    await setDoc(doc(db, `users/${barberUid}`), {
      uid: barberUid,
      role: "barber",
      salonId: salonA,
      employeeId: barberUid,
      isActive: true,
      permissions: { canViewCustomers: false },
    });
    await setDoc(doc(db, `users/${adminNoPermUid}`), {
      uid: adminNoPermUid,
      role: "admin",
      salonId: salonA,
      isActive: true,
      permissions: { canViewCustomers: false },
    });
    await setDoc(doc(db, `users/${customerUid}`), {
      uid: customerUid,
      role: "customer",
      salonId: null,
      isActive: true,
    });
    await setDoc(doc(db, `salons/${salonA}/employees/${ownerUid}`), {
      id: ownerUid,
      uid: ownerUid,
      role: "owner",
      salonId: salonA,
    });
    await setDoc(doc(db, `salons/${salonA}/employees/${adminUid}`), {
      id: adminUid,
      uid: adminUid,
      role: "admin",
      salonId: salonA,
    });
    await setDoc(doc(db, `salons/${salonA}/employees/${adminNoPermUid}`), {
      id: adminNoPermUid,
      uid: adminNoPermUid,
      role: "admin",
      salonId: salonA,
    });
    await setDoc(doc(db, `salons/${salonA}/employees/${barberUid}`), {
      id: barberUid,
      uid: barberUid,
      role: "barber",
      salonId: salonA,
    });
    await setDoc(doc(db, `salons/${salonA}/customers/c1`), {
      id: "c1",
      salonId: salonA,
      fullName: "Ali",
      normalizedFullName: "ali",
      isActive: true,
    });
    await setDoc(doc(db, `publicSalons/${salonA}`), {
      salonId: salonA,
      name: "Salon A",
      isActive: true,
      isPublished: true,
      isPublic: true,
    });
  });
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

test("owner can access own salon", async () => {
  const db = testEnv.authenticatedContext(ownerUid).firestore();
  await assertSucceeds(getDoc(doc(db, `salons/${salonA}`)));
});

test("admin is limited by permissions", async () => {
  const db = testEnv.authenticatedContext(adminUid).firestore();
  await assertSucceeds(getDoc(doc(db, `salons/${salonA}/customers/c1`)));
  await assertFails(deleteDoc(doc(db, `salons/${salonA}/customers/c1`)));
});

test("barber has restricted access", async () => {
  const db = testEnv.authenticatedContext(barberUid).firestore();
  await assertFails(getDoc(doc(db, `salons/${salonA}/customers/c1`)));
});

test("cross-salon access is denied", async () => {
  const db = testEnv.authenticatedContext(ownerUid).firestore();
  await assertFails(getDoc(doc(db, `salons/${salonB}`)));
});

test("customer and booking rules are enforced", async () => {
  const db = testEnv.authenticatedContext(ownerUid).firestore();
  await assertSucceeds(
    setDoc(doc(db, `salons/${salonA}/bookings/b1`), {
      id: "b1",
      salonId: salonA,
      barberId: barberUid,
      customerId: "c1",
      customerName: "Ali",
      serviceId: "svc-1",
      startAt: new Date("2026-04-22T10:00:00.000Z"),
      endAt: new Date("2026-04-22T10:30:00.000Z"),
      status: "confirmed",
      createdAt: new Date("2026-04-22T09:00:00.000Z"),
      reportYear: 2026,
      reportMonth: 4,
      reportPeriodKey: "2026-04",
    }),
  );
  await assertFails(
    updateDoc(doc(db, `salons/${salonA}/bookings/b1`), {
      status: "completed",
    }),
  );
  assert.ok(true);
});

test("invalid booking write should fail", async () => {
  const db = testEnv.authenticatedContext(ownerUid).firestore();
  await assertFails(
    setDoc(doc(db, `salons/${salonA}/bookings/b-invalid`), {
      id: "b-invalid",
      salonId: salonA,
      barberId: barberUid,
      customerId: "c1",
      customerName: "Ali",
      serviceId: "svc-1",
      startAt: new Date("2026-04-22T10:30:00.000Z"),
      endAt: new Date("2026-04-22T10:00:00.000Z"),
      status: "confirmed",
      createdAt: new Date("2026-04-22T09:00:00.000Z"),
      reportYear: 2026,
      reportMonth: 4,
      reportPeriodKey: "2026-04",
    }),
  );
});

test("admin without permission should fail customer read", async () => {
  const db = testEnv.authenticatedContext(adminNoPermUid).firestore();
  await assertFails(getDoc(doc(db, `salons/${salonA}/customers/c1`)));
});

test("cross-salon write attempts should fail", async () => {
  const db = testEnv.authenticatedContext(ownerUid).firestore();
  await assertFails(
    setDoc(doc(db, `salons/${salonB}/customers/c2`), {
      id: "c2",
      salonId: salonB,
      fullName: "Cross Salon",
      normalizedFullName: "cross salon",
      isActive: true,
    }),
  );
});

test("signed-in clients cannot use debugSeed discovery writes", async () => {
  const db = testEnv.authenticatedContext(customerUid).firestore();

  await assertFails(
    setDoc(doc(db, "publicSalons/evil-salon"), {
      salonId: "evil-salon",
      name: "Defaced Salon",
      isActive: true,
      isPublished: true,
      isPublic: true,
      debugSeed: true,
    }),
  );
  await assertFails(
    updateDoc(doc(db, `publicSalons/${salonA}`), {
      name: "Defaced Salon",
      debugSeed: true,
    }),
  );
  await assertFails(
    setDoc(doc(db, "customerDiscovery/categories/items/evil-category"), {
      title: "Injected Category",
      isActive: true,
      debugSeed: true,
    }),
  );
  await assertFails(
    setDoc(doc(db, "salons/evil-salon"), {
      ownerUid: customerUid,
      name: "Injected Salon",
      isActive: true,
      debugSeed: true,
    }),
  );
});

test("emulator concurrency: parallel booking writes allow only one success", async () => {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const salonId = "salon-concurrency";
    const barberId = "barber-1";
    const dayKey = "2026-05-01";
    const startAt = new Date("2026-05-01T10:00:00.000Z");
    const endAt = new Date("2026-05-01T10:30:00.000Z");
    await setDoc(doc(db, `salons/${salonId}`), { ownerUid, isActive: true });
    await setDoc(doc(db, `salons/${salonId}/customers/c1`), {
      id: "c1",
      salonId,
      fullName: "Ali",
      normalizedFullName: "ali",
      isActive: true,
    });

    async function createBookingAtomic(bookingId) {
      const bookingRef = doc(db, `salons/${salonId}/bookings/${bookingId}`);
      const lockRef = doc(db, `salons/${salonId}/booking_locks/${barberId}_${dayKey}`);
      await runTransaction(db, async (tx) => {
        const lockSnap = await tx.get(lockRef);
        const lockData = lockSnap.data() || {};
        const activeIds = Array.isArray(lockData.activeBookingIds)
          ? lockData.activeBookingIds.filter((x) => typeof x === "string")
          : [];
        for (const id of activeIds) {
          const existingSnap = await tx.get(
            doc(db, `salons/${salonId}/bookings/${id}`),
          );
          const existing = existingSnap.data();
          if (!existing) continue;
          const existingEnd = existing.endAt?.toDate?.() || existing.endAt;
          const existingStart = existing.startAt?.toDate?.() || existing.startAt;
          if (existingStart < endAt && existingEnd > startAt) {
            throw new Error("overlap");
          }
        }

        const overlapQ = query(
          collection(db, `salons/${salonId}/bookings`),
          where("dayKey", "==", dayKey),
          where("barberId", "==", barberId),
          where("startAt", "<", endAt),
          limit(10),
        );
        const overlapSnap = await getDocs(overlapQ);
        for (const d of overlapSnap.docs) {
          const existing = d.data();
          const existingEnd = existing.endAt?.toDate?.() || existing.endAt;
          if (existingEnd > startAt && existing.status !== "cancelled") {
            throw new Error("overlap");
          }
        }

        tx.set(bookingRef, {
          id: bookingId,
          salonId,
          barberId,
          customerId: "c1",
          dayKey,
          startAt,
          endAt,
          status: "confirmed",
        });
        tx.set(
          lockRef,
          {
            barberId,
            dayKey,
            activeBookingIds: [...activeIds, bookingId],
          },
          { merge: true },
        );
      });
    }

    const results = await Promise.allSettled([
      createBookingAtomic("b-con-1"),
      createBookingAtomic("b-con-2"),
    ]);
    const successCount = results.filter((r) => r.status === "fulfilled").length;
    const failureCount = results.filter((r) => r.status === "rejected").length;
    assert.equal(successCount, 1);
    assert.equal(failureCount, 1);
  });
});
