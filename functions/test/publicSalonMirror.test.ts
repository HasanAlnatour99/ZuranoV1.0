import { describe, expect, it } from "vitest";

import { salonToPublicSalonPayload } from "../src/publicSalonMirror";

describe("public salon mirror visibility", () => {
  it("keeps app-published salons visible even when root isPublic is absent", () => {
    const payload = salonToPublicSalonPayload(
      "salon_visible",
      {
        name: "Visible Salon",
        isActive: true,
        isPublished: true,
      },
      null,
    );

    expect(payload.isPublished).toBe(true);
    expect(payload.isPublic).toBe(true);
  });

  it("keeps unpublished salons hidden even if a stale root isPublic flag is true", () => {
    const payload = salonToPublicSalonPayload(
      "salon_hidden",
      {
        name: "Hidden Salon",
        isActive: true,
        isPublished: false,
        isPublic: true,
      },
      null,
    );

    expect(payload.isPublished).toBe(false);
    expect(payload.isPublic).toBe(false);
  });
});
