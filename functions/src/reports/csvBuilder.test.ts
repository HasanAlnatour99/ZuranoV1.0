import { describe, expect, it } from "vitest";

import { escapeCsvCell, toCsvDocument } from "./csvBuilder";

describe("csvBuilder", () => {
  it("escapes quotes and commas", () => {
    expect(escapeCsvCell('say "hi", ok')).toBe('"say ""hi"", ok"');
  });

  it("builds csv document", () => {
    const csv = toCsvDocument(
      ["a", "b"],
      [
        [1, "x"],
        ["y,z", null],
      ],
    );
    expect(csv).toContain("y,z");
    expect(csv.split("\n").length).toBeGreaterThanOrEqual(3);
  });
});
