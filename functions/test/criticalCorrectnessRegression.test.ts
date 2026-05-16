import { FieldValue, GeoPoint } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { describe, expect, it } from "vitest";

import { salonToPublicSalonPayload } from "../src/publicSalonMirror";
import {
  assertSalonPermissionKey,
  type StaffPermissionsRow,
} from "../src/reports/exportPermissions";

function staff(
  permissions: Record<string, boolean>,
  exists = true,
  isActive = true,
): StaffPermissionsRow {
  return { exists, isActive, permissions };
}

describe("critical correctness regressions", () => {
  it("denies frozen staff even when granular permissions remain enabled", () => {
    expect(() =>
      assertSalonPermissionKey(
        { role: "admin", salonId: "salon_1", isActive: true },
        "salon_1",
        "payroll.manage",
        staff({ "payroll.manage": true }, true, false),
      ),
    ).toThrowError(HttpsError);
  });

  it("deletes mirrored public geo fields when no valid coordinates remain", () => {
    const payload = salonToPublicSalonPayload(
      "salon_1",
      {
        name: "Precision",
        countryCode: "QA",
        isActive: true,
        isPublic: true,
        isPublished: true,
      },
      null,
    );

    expect(payload.latitude).toBe(FieldValue.delete());
    expect(payload.longitude).toBe(FieldValue.delete());
    expect(payload.location).toBe(FieldValue.delete());
    expect(payload.geohash).toBe(FieldValue.delete());
  });

  it("keeps mirrored public geo fields when coordinates are valid", () => {
    const payload = salonToPublicSalonPayload(
      "salon_1",
      {
        name: "Precision",
        countryCode: "QA",
        isActive: true,
        isPublic: true,
        isPublished: true,
      },
      { latitude: 25.2780967661392, longitude: 51.50037411600351 },
    );

    expect(payload.latitude).toBe(25.2780967661392);
    expect(payload.longitude).toBe(51.50037411600351);
    expect(payload.location).toBeInstanceOf(GeoPoint);
    expect(payload.geohash).toMatch(/^[\w]+$/);
  });
});
