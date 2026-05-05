/**
 * Rules for user devices (functions-only writes), notifications inbox, dispatch log.
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  doc,
  getDoc,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";
import { afterAll, beforeAll, describe, it } from "vitest";

const rulesPath = resolve(__dirname, "../../firestore.rules");
const hasFirestoreEmu = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

function firestoreEmulatorHostPort(): { host: string; port: number } {
  const raw = process.env.FIRESTORE_EMULATOR_HOST ?? "";
  const [host, portStr] = raw.split(":");
  return { host: host || "127.0.0.1", port: Number(portStr) || 8080 };
}

describe.skipIf(!hasFirestoreEmu)("firestore notifications rules", () => {
  let env: RulesTestEnvironment;

  beforeAll(async () => {
    const { host, port } = firestoreEmulatorHostPort();
    env = await initializeTestEnvironment({
      projectId: "demo-rules-notifications",
      firestore: {
        rules: readFileSync(rulesPath, "utf8"),
        host,
        port,
      },
    });
  });

  afterAll(async () => {
    await env.cleanup();
  });

  it("user can read own notifications; client create denied", async () => {
    const alice = env.authenticatedContext("user_a").firestore();
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, "users", "user_a"), { role: "customer" });
      await setDoc(doc(db, "users", "user_a", "notifications", "n1"), {
        type: "booking_confirmed",
        title: "T",
        body: "B",
        data: {},
        status: "unread",
        createdAt: Timestamp.now(),
        readAt: null,
        actorRole: "system",
      });
    });
    const snap = await assertSucceeds(
      getDoc(doc(alice, "users", "user_a", "notifications", "n1")),
    );
    expect(snap.exists()).toBe(true);
    await assertFails(
      setDoc(doc(alice, "users", "user_a", "notifications", "fake"), {
        type: "x",
        title: "t",
        body: "b",
        data: {},
        status: "unread",
        createdAt: Timestamp.now(),
      }),
    );
  });

  it("user can mark notification read with isRead + readAt only", async () => {
    const alice = env.authenticatedContext("user_a").firestore();
    await assertSucceeds(
      updateDoc(doc(alice, "users", "user_a", "notifications", "n1"), {
        isRead: true,
        readAt: Timestamp.now(),
      }),
    );
  });

  it("client cannot write devices subcollection", async () => {
    const alice = env.authenticatedContext("user_a").firestore();
    await assertFails(
      setDoc(doc(alice, "users", "user_a", "devices", "d1"), {
        token: "x",
        platform: "ios",
        appVersion: "1",
        locale: "en",
        timezone: "UTC",
        pushEnabled: true,
        lastSeenAt: Timestamp.now(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      }),
    );
  });

  it("notificationDispatches denied for clients", async () => {
    const alice = env.authenticatedContext("user_a").firestore();
    await assertFails(
      setDoc(doc(alice, "notificationDispatches", "x"), { x: 1 }),
    );
  });
});
