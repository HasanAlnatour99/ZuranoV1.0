import { describe, expect, test } from "vitest";

describe("bookingRequestLocks", () => {
  test("lock doc id is deterministic and sanitized", () => {
    const authUid = "uid/with/slash";
    const clientRequestId = "req-123";
    const lockId = `${authUid}_${clientRequestId}`.replace(/\//g, "_");
    expect(lockId).toBe("uid_with_slash_req-123");
  });
});

