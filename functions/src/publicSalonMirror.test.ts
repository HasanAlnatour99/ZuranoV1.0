import { FieldValue, GeoPoint } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";

import { salonToPublicSalonPayload } from "./publicSalonMirror";

describe("salonToPublicSalonPayload", () => {
  it("deletes mirrored geo fields when no valid coordinates remain", () => {
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

  it("writes GeoPoint and geohash when coordinates are valid", () => {
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
