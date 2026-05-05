import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import type { DocumentData } from "firebase-admin/firestore";

import { createEmployeeNotification } from "./notifications/employeeInAppNotificationService";

function str(d: DocumentData | undefined, key: string, fallback = ""): string {
  if (!d) {
    return fallback;
  }
  const v = d[key];
  return typeof v === "string" && v.length > 0 ? v : fallback;
}

/** Correction / missing-punch workflow (`attendanceCorrectionRequests`). */
export const onAttendanceCorrectionRequestUpdatedEmployeeInbox = onDocumentUpdated(
  {
    document: "salons/{salonId}/attendanceCorrectionRequests/{requestId}",
    region: "us-central1",
  },
  async (event) => {
    const before = event.data?.before.data() as DocumentData | undefined;
    const after = event.data?.after.data() as DocumentData | undefined;
    if (!before || !after) {
      return;
    }
    const stBefore = String(before.status ?? "").toLowerCase();
    const stAfter = String(after.status ?? "").toLowerCase();
    if (stBefore === stAfter) {
      return;
    }
    if (stAfter !== "approved" && stAfter !== "rejected") {
      return;
    }

    const recipientUid = str(after, "employeeUid");
    if (!recipientUid) {
      return;
    }

    const approved = stAfter === "approved";
    await createEmployeeNotification({
      recipientUid,
      salonId: event.params.salonId,
      employeeId: str(after, "employeeId"),
      type: "approval_requests",
      title: approved ? "Attendance correction approved" : "Attendance correction rejected",
      body: approved
        ? "Your attendance correction request was approved."
        : "Your attendance correction request was rejected.",
      route: "/employee/today",
      sourceCollection: "attendanceCorrectionRequests",
      sourceId: event.params.requestId,
      dedupeKey: `att_corr:${event.params.requestId}:${stAfter}:${recipientUid}`,
      metadata: {
        status: stAfter,
        attendanceDayId: str(after, "attendanceDayId"),
      },
    });
  },
);

/** Leave / punch requests stored under legacy `attendanceRequests`. */
export const onAttendanceRequestUpdatedEmployeeInbox = onDocumentUpdated(
  {
    document: "salons/{salonId}/attendanceRequests/{requestId}",
    region: "us-central1",
  },
  async (event) => {
    const before = event.data?.before.data() as DocumentData | undefined;
    const after = event.data?.after.data() as DocumentData | undefined;
    if (!before || !after) {
      return;
    }
    const leaveRaw = after.type ?? after.requestType ?? "";
    const leaveNorm = String(leaveRaw).toLowerCase();
    if (leaveNorm !== "leaverequest") {
      return;
    }

    const stBefore = String(before.status ?? "").toLowerCase();
    const stAfter = String(after.status ?? "").toLowerCase();
    if (stBefore === stAfter) {
      return;
    }
    if (stAfter !== "approved" && stAfter !== "rejected") {
      return;
    }

    const recipientUid = str(after, "employeeUid");
    if (!recipientUid) {
      return;
    }

    const approved = stAfter === "approved";
    await createEmployeeNotification({
      recipientUid,
      salonId: event.params.salonId,
      employeeId: str(after, "employeeId"),
      type: "approval_requests",
      title: approved ? "Leave request approved" : "Leave request rejected",
      body: approved
        ? "Your leave request was approved."
        : "Your leave request was rejected.",
      route: "/employee/attendance",
      sourceCollection: "attendanceRequests",
      sourceId: event.params.requestId,
      dedupeKey: `leave_req:${event.params.requestId}:${stAfter}:${recipientUid}`,
      metadata: {
        status: stAfter,
      },
    });
  },
);
