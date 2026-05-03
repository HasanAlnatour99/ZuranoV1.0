import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";

import { BookingStatuses, normalizeBookingStatus } from "./bookingShared";
import {
  notifyBookingConfirmedForCustomer,
  notifyExpenseCreated,
  notifyPayrollCreated,
  notifySaleRecordedForOwners,
  notifyViolationCreated,
} from "./notificationOrchestrator";

export const onBookingUpdatedNotification = onDocumentUpdated(
  {
    document: "salons/{salonId}/bookings/{bookingId}",
    region: "us-central1",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after) {
      return;
    }
    const salonId = event.params.salonId;
    const bookingId = event.params.bookingId;
    const stBefore = normalizeBookingStatus(
      (before?.status as string | undefined) ?? "",
    );
    const stAfter = normalizeBookingStatus(
      (after.status as string | undefined) ?? "",
    );
    if (
      stBefore === BookingStatuses.pending &&
      stAfter === BookingStatuses.confirmed
    ) {
      const customerId = after.customerId;
      if (typeof customerId === "string" && customerId.length > 0) {
        await notifyBookingConfirmedForCustomer({
          salonId,
          bookingId,
          customerId,
        });
      }
    }
  },
);

export const onViolationCreatedNotification = onDocumentCreated(
  {
    document: "salons/{salonId}/violations/{violationId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const d = snap.data();
    const salonId = event.params.salonId;
    const violationId = event.params.violationId;
    const employeeId = typeof d.employeeId === "string" ? d.employeeId : "";
    const bookingId = typeof d.bookingId === "string" ? d.bookingId : "";
    if (!employeeId || !bookingId) {
      return;
    }
    await notifyViolationCreated({
      salonId,
      violationId,
      employeeId,
      bookingId,
    });
  },
);

export const onPayrollCreatedNotification = onDocumentCreated(
  {
    document: "salons/{salonId}/payroll/{payrollId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const d = snap.data();
    const salonId = event.params.salonId;
    const payrollId = event.params.payrollId;
    const employeeId = typeof d.employeeId === "string" ? d.employeeId : "";
    if (!employeeId) {
      return;
    }
    await notifyPayrollCreated({
      salonId,
      payrollId,
      employeeId,
    });
  },
);

export const onExpenseCreatedNotification = onDocumentCreated(
  {
    document: "salons/{salonId}/expenses/{expenseId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const salonId = event.params.salonId;
    const expenseId = event.params.expenseId;
    const d = snap.data();
    const title =
      typeof d.title === "string" && d.title.trim().length > 0
        ? d.title.trim()
        : undefined;
    const amount = typeof d.amount === "number" ? d.amount : undefined;
    await notifyExpenseCreated({
      salonId,
      expenseId,
      title,
      amount,
    });
  },
);

export const onSaleRecordedOwnerNotification = onDocumentCreated(
  {
    document: "salons/{salonId}/sales/{saleId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const d = snap.data();
    const status = typeof d.status === "string" ? d.status.trim() : "completed";
    if (status !== "completed") {
      return;
    }
    const salonId = event.params.salonId;
    const saleId = event.params.saleId;
    const employeeName =
      typeof d.employeeName === "string" && d.employeeName.trim().length > 0
        ? d.employeeName.trim()
        : undefined;
    const total =
      typeof d.total === "number" && Number.isFinite(d.total)
        ? d.total
        : undefined;
    await notifySaleRecordedForOwners({
      salonId,
      saleId,
      employeeName,
      total,
      documentData: d,
    });
  },
);
