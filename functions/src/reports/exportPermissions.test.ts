import { HttpsError } from "firebase-functions/v2/https";
import { describe, expect, it } from "vitest";

import { assertSalonPermissionKey } from "./exportPermissions";

function staff(permissions: Record<string, boolean>, exists = true) {
  return { exists, permissions };
}

describe("assertSalonPermissionKey", () => {
  it("keeps legacy owner/admin access only while no staff row exists", () => {
    expect(() =>
      assertSalonPermissionKey(
        { role: "admin", salonId: "salon_1", isActive: true },
        "salon_1",
        "payroll.manage",
        staff({}, false),
      ),
    ).not.toThrow();

    expect(() =>
      assertSalonPermissionKey(
        { role: "admin", salonId: "salon_1", isActive: true },
        "salon_1",
        "payroll.manage",
        staff({ "payroll.manage": false }),
      ),
    ).toThrowError(HttpsError);
  });

  it("allows explicit staff permissions and denies cross-salon calls", () => {
    expect(() =>
      assertSalonPermissionKey(
        { role: "barber", salonId: "salon_1", isActive: true },
        "salon_1",
        "attendance.manage",
        staff({ "attendance.manage": true }),
      ),
    ).not.toThrow();

    expect(() =>
      assertSalonPermissionKey(
        { role: "owner", salonId: "salon_2", isActive: true },
        "salon_1",
        "attendance.manage",
        staff({}),
      ),
    ).toThrowError(HttpsError);
  });
});
