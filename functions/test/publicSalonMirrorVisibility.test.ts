import { describe, expect, it } from "vitest";

import { salonToPublicSalonPayload } from "../src/publicSalonMirror";

describe("salonToPublicSalonPayload visibility", () => {
  it("keeps legacy isPublished-only salons visible in the public mirror", () => {
    const payload = salonToPublicSalonPayload(
      "salon_1",
      {
        name: "Legacy Salon",
        countryCode: "QA",
        isActive: true,
        isPublished: true,
      },
      null,
    );

    expect(payload.isPublic).toBe(true);
    expect(payload.isPublished).toBe(true);
  });

  it("requires both explicit visibility flags when both are present", () => {
    const hiddenByPublic = salonToPublicSalonPayload(
      "salon_1",
      {
        name: "Hidden Salon",
        countryCode: "QA",
        isActive: true,
        isPublic: false,
        isPublished: true,
      },
      null,
    );
    const hiddenByPublished = salonToPublicSalonPayload(
      "salon_2",
      {
        name: "Unpublished Salon",
        countryCode: "QA",
        isActive: true,
        isPublic: true,
        isPublished: false,
      },
      null,
    );

    expect(hiddenByPublic.isPublic).toBe(false);
    expect(hiddenByPublic.isPublished).toBe(true);
    expect(hiddenByPublished.isPublic).toBe(true);
    expect(hiddenByPublished.isPublished).toBe(false);
  });

  it("marks inactive salons hidden even when visibility flags are true", () => {
    const payload = salonToPublicSalonPayload(
      "salon_1",
      {
        name: "Inactive Salon",
        countryCode: "QA",
        isActive: false,
        isPublic: true,
        isPublished: true,
      },
      null,
    );

    expect(payload.isPublic).toBe(false);
    expect(payload.isPublished).toBe(false);
  });
});
