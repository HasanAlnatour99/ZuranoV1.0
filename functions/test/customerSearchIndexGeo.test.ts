import { describe, expect, it } from "vitest";

import { GeoPoint } from "firebase-admin/firestore";

import { serviceIndexGeoPayload } from "../src/customerSearchIndex";

describe("customerSearchIndex geo payload", () => {
  it("serviceIndexGeoPayload writes latitude, longitude, GeoPoint, geohash", () => {
    const p = serviceIndexGeoPayload(25.2780967661392, 51.50037411600351);
    expect(p.latitude).toBe(25.2780967661392);
    expect(p.longitude).toBe(51.50037411600351);
    expect(p.geohash).toMatch(/^[\w]+$/);
    expect(p.location).toBeInstanceOf(GeoPoint);
    const gp = p.location as GeoPoint;
    expect(gp.latitude).toBeCloseTo(25.2780967661392, 10);
    expect(gp.longitude).toBeCloseTo(51.50037411600351, 10);
  });
});
