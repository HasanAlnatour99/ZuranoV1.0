import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from "firebase-functions/v2/firestore";
import type { DocumentData } from "firebase-admin/firestore";

import {
  notifyAttendanceCheckIn,
  notifyAttendanceCorrectionRequested,
  notifyAttendanceLate,
  notifyEmployeeLifecycle,
  notifyServiceCatalogChange,
} from "./notificationOrchestrator";

function hasFieldValue(data: DocumentData | undefined, key: string): boolean {
  if (!data) {
    return false;
  }
  return data[key] != null;
}

function str(data: DocumentData | undefined, key: string, fallback = ""): string {
  if (!data) {
    return fallback;
  }
  const v = data[key];
  return typeof v === "string" && v.length > 0 ? v : fallback;
}

export const onAttendanceRecordUpdatedNotification = onDocumentUpdated(
  {
    document: "salons/{salonId}/attendance/{attendanceId}",
    region: "us-central1",
  },
  async (event) => {
    const before = event.data?.before.data() as DocumentData | undefined;
    const after = event.data?.after.data() as DocumentData | undefined;
    if (!after) {
      return;
    }
    const salonId = event.params.salonId;
    const attendanceId = event.params.attendanceId;
    const employeeId = str(after, "employeeId");
    if (!employeeId) {
      return;
    }
    const employeeName = str(after, "employeeName", "Team member");

    const hadCheckIn = hasFieldValue(before, "checkInAt");
    const hasCheckIn = hasFieldValue(after, "checkInAt");
    if (!hadCheckIn && hasCheckIn) {
      await notifyAttendanceCheckIn({
        salonId,
        attendanceId,
        employeeId,
        employeeName,
      });
    }

    const stBefore = String(before?.status ?? "").toLowerCase();
    const stAfter = String(after.status ?? "").toLowerCase();
    if (stAfter === "late" && stBefore !== "late") {
      await notifyAttendanceLate({
        salonId,
        attendanceId,
        employeeId,
        employeeName,
      });
    }
  },
);

export const onAttendanceCorrectionRequestCreatedNotification = onDocumentCreated(
  {
    document: "salons/{salonId}/attendanceCorrectionRequests/{requestId}",
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      return;
    }
    const d = snap.data() as DocumentData;
    const salonId = event.params.salonId;
    const requestId = event.params.requestId;
    const employeeId = str(d, "employeeId");
    const attendanceId = str(d, "attendanceId");
    if (!employeeId || !attendanceId) {
      return;
    }
    await notifyAttendanceCorrectionRequested({
      salonId,
      requestId,
      employeeId,
      attendanceId,
    });
  },
);

export const onSalonServiceWrittenNotification = onDocumentWritten(
  {
    document: "salons/{salonId}/services/{serviceId}",
    region: "us-central1",
  },
  async (event) => {
    const data = event.data;
    if (!data) {
      return;
    }
    const salonId = event.params.salonId;
    const serviceId = event.params.serviceId;
    const before = data.before.exists ? data.before.data() : null;
    const after = data.after.exists ? data.after.data() : null;
    if (!before && !after) {
      return;
    }
    let eventType: "service_created" | "service_updated" | "service_deleted";
    if (!before && after) {
      eventType = "service_created";
    } else if (before && !after) {
      eventType = "service_deleted";
    } else {
      const b = before as DocumentData;
      const a = after as DocumentData;
      let meaningful = false;
      const keys = new Set([...Object.keys(b), ...Object.keys(a)]);
      for (const k of keys) {
        if (k === "updatedAt" || k === "createdAt") {
          continue;
        }
        if (JSON.stringify(b[k]) !== JSON.stringify(a[k])) {
          meaningful = true;
          break;
        }
      }
      if (!meaningful) {
        return;
      }
      eventType = "service_updated";
    }
    const nameRaw =
      (after?.name as string | undefined) ??
      (before?.name as string | undefined) ??
      "";
    const serviceName = typeof nameRaw === "string" ? nameRaw : "Service";
    await notifyServiceCatalogChange({
      salonId,
      serviceId,
      eventType,
      serviceName,
    });
  },
);

export const onSalonEmployeeWrittenNotification = onDocumentWritten(
  {
    document: "salons/{salonId}/employees/{employeeId}",
    region: "us-central1",
  },
  async (event) => {
    const data = event.data;
    if (!data) {
      return;
    }
    const salonId = event.params.salonId;
    const employeeId = event.params.employeeId;
    const beforeEx = data.before.exists;
    const afterEx = data.after.exists;
    const before = beforeEx ? data.before.data() : null;
    const after = afterEx ? data.after.data() : null;
    if (!before && !after) {
      return;
    }
    const name =
      str(after as DocumentData | undefined, "name") ||
      str(before as DocumentData | undefined, "name") ||
      "Team member";

    if (!beforeEx && afterEx && after) {
      await notifyEmployeeLifecycle({
        salonId,
        employeeId,
        eventType: "employee_created",
        name,
      });
      return;
    }
    if (beforeEx && afterEx && before && after) {
      const wasActive = before.isActive === true;
      const nowActive = after.isActive === true;
      if (!wasActive && nowActive) {
        await notifyEmployeeLifecycle({
          salonId,
          employeeId,
          eventType: "employee_reactivated",
          name,
        });
      } else if (wasActive && !nowActive) {
        await notifyEmployeeLifecycle({
          salonId,
          employeeId,
          eventType: "employee_frozen",
          name,
        });
      }
    }
  },
);
