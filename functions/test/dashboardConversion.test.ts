import { describe, expect, it } from "vitest";

function monthlyConversionRate(bookingsCount: number, completed: number): number {
  if (bookingsCount <= 0) return 0;
  return Math.round(((completed / bookingsCount) * 100) * 100) / 100;
}

describe("dashboard snapshot conversionRate", () => {
  it("matches booking completion ratio", () => {
    expect(monthlyConversionRate(420, 300)).toBe(71.43);
    expect(monthlyConversionRate(0, 5)).toBe(0);
  });
});
