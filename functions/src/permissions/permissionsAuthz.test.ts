import { HttpsError } from "firebase-functions/v2/https";
import { describe, expect, it } from "vitest";

import { assertValidStaffClaimsTarget } from "./permissionsAuthz";

describe("assertValidStaffClaimsTarget", () => {
  it("returns the target staff role for a same-salon staff row", () => {
    expect(
      assertValidStaffClaimsTarget({
        salonId: "salon_1",
        targetUid: "staff_1",
        targetUserExists: true,
        targetUser: { salonId: "salon_1", role: "admin" },
        targetStaffExists: true,
        targetStaff: { salonId: "salon_1", uid: "staff_1" },
      }),
    ).toBe("admin");
  });

  it("rejects cross-salon and non-staff claim targets", () => {
    expect(() =>
      assertValidStaffClaimsTarget({
        salonId: "salon_1",
        targetUid: "owner_2",
        targetUserExists: true,
        targetUser: { salonId: "salon_2", role: "owner" },
        targetStaffExists: true,
        targetStaff: { salonId: "salon_1", uid: "owner_2" },
      }),
    ).toThrowError(HttpsError);

    expect(() =>
      assertValidStaffClaimsTarget({
        salonId: "salon_1",
        targetUid: "customer_1",
        targetUserExists: true,
        targetUser: { salonId: "salon_1", role: "customer" },
        targetStaffExists: true,
        targetStaff: { salonId: "salon_1", uid: "customer_1" },
      }),
    ).toThrowError(HttpsError);
  });

  it("rejects missing or mismatched staff rows before claims are written", () => {
    expect(() =>
      assertValidStaffClaimsTarget({
        salonId: "salon_1",
        targetUid: "staff_1",
        targetUserExists: true,
        targetUser: { salonId: "salon_1", role: "barber" },
        targetStaffExists: false,
        targetStaff: {},
      }),
    ).toThrowError(HttpsError);

    expect(() =>
      assertValidStaffClaimsTarget({
        salonId: "salon_1",
        targetUid: "staff_1",
        targetUserExists: true,
        targetUser: { salonId: "salon_1", role: "barber" },
        targetStaffExists: true,
        targetStaff: { salonId: "salon_1", uid: "someone_else" },
      }),
    ).toThrowError(HttpsError);
  });
});
