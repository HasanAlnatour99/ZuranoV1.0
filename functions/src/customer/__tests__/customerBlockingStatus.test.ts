import { describe, expect, test } from "vitest";

import { isCustomerBlockingBookingStatus } from "../customerPortalCallables";

describe("customer booking blocking statuses", () => {
  test("treats legacy scheduled bookings as blocking", () => {
    expect(isCustomerBlockingBookingStatus("scheduled")).toBe(true);
    expect(isCustomerBlockingBookingStatus(" scheduled ")).toBe(true);
  });

  test("does not block completed or cancelled bookings", () => {
    expect(isCustomerBlockingBookingStatus("completed")).toBe(false);
    expect(isCustomerBlockingBookingStatus("cancelled")).toBe(false);
  });
});
