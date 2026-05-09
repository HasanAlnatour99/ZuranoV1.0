import { Firestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

export type FireUser = {
  salonId?: string;
  role?: string;
  isActive?: boolean;
  employeeId?: string;
};

export type ExportType = "sales" | "payroll" | "attendance" | "expenses" | "audit";

function sameSalon(user: FireUser, salonId: string): boolean {
  return String(user.salonId ?? "").trim() === salonId.trim();
}

export async function loadStaffPermissionsRow(
  db: Firestore,
  salonId: string,
  uid: string,
): Promise<{ exists: boolean; permissions: Record<string, boolean> }> {
  const snap = await db.doc(`salons/${salonId}/staff/${uid}`).get();
  if (!snap.exists) {
    return { exists: false, permissions: {} };
  }
  const raw = snap.data()?.permissions;
  const permissions: Record<string, boolean> = {};
  if (raw && typeof raw === "object") {
    for (const [k, v] of Object.entries(raw as Record<string, unknown>)) {
      permissions[k] = Boolean(v);
    }
  }
  return { exists: true, permissions };
}

export function assertActiveSalonMember(user: FireUser, salonId: string): void {
  if (user.isActive === false) {
    throw new HttpsError("permission-denied", "Inactive user.");
  }
  if (!sameSalon(user, salonId)) {
    throw new HttpsError("permission-denied", "Salon mismatch.");
  }
}

/** Mirrors Firestore `maySalonPermission` for callable-side checks. */
export function maySalonPermissionKey(
  user: FireUser,
  salonId: string,
  key: string,
  staff: { exists: boolean; permissions: Record<string, boolean> },
): boolean {
  const role = String(user.role ?? "").trim();
  if (role === "owner" && sameSalon(user, salonId)) {
    return true;
  }
  if ((role === "admin" || role === "owner") && sameSalon(user, salonId) && !staff.exists) {
    return true;
  }
  return staff.permissions[key] === true;
}

export function assertExportTypeAllowed(
  user: FireUser,
  salonId: string,
  exportType: ExportType,
  staff: { exists: boolean; permissions: Record<string, boolean> },
): void {
  assertActiveSalonMember(user, salonId);
  const role = String(user.role ?? "").trim();
  if (role === "customer") {
    throw new HttpsError("permission-denied", "Not allowed.");
  }

  if (exportType === "audit") {
    const ok =
      maySalonPermissionKey(user, salonId, "permissions.manage", staff) ||
      maySalonPermissionKey(user, salonId, "settings.manage", staff);
    if (!ok) {
      throw new HttpsError("permission-denied", "permissions.manage or settings.manage required.");
    }
    return;
  }

  const key =
    exportType === "sales"
      ? "sales.view"
      : exportType === "payroll"
        ? "payroll.view"
        : exportType === "attendance"
          ? "attendance.view"
          : "expenses.view";

  if (!maySalonPermissionKey(user, salonId, key, staff)) {
    throw new HttpsError("permission-denied", `${key} required.`);
  }
}

export function assertPayslipFinanceAccess(
  user: FireUser,
  salonId: string,
  staff: { exists: boolean; permissions: Record<string, boolean> },
): void {
  assertActiveSalonMember(user, salonId);
  const role = String(user.role ?? "").trim();
  if (role === "customer") {
    throw new HttpsError("permission-denied", "Not allowed.");
  }
  if (role === "owner") {
    return;
  }
  const ok =
    maySalonPermissionKey(user, salonId, "payroll.view", staff) ||
    maySalonPermissionKey(user, salonId, "payroll.manage", staff);
  if (!ok) {
    throw new HttpsError("permission-denied", "payroll.view required.");
  }
}

export function assertEmployeeOwnPayslip(
  user: FireUser,
  salonId: string,
  employeeId: string,
): void {
  assertActiveSalonMember(user, salonId);
  const eid = employeeId.trim();
  if (!eid) {
    throw new HttpsError("invalid-argument", "employeeId required.");
  }
  const mine = String(user.employeeId ?? "").trim();
  if (mine !== eid) {
    throw new HttpsError("permission-denied", "You can only export your own payslip.");
  }
}

/** Validates caller may obtain a download URL for an export job document. */
export function assertCanDownloadExportJob(
  user: FireUser,
  salonId: string,
  job: Record<string, unknown>,
  staff: { exists: boolean; permissions: Record<string, boolean> },
): void {
  assertActiveSalonMember(user, salonId);
  const role = String(user.role ?? "").trim();
  if (role === "customer") {
    throw new HttpsError("permission-denied", "Not allowed.");
  }
  if (role === "owner") {
    return;
  }

  const exportType = String(job.exportType ?? "").trim();
  if (exportType === "payslip") {
    const finance =
      maySalonPermissionKey(user, salonId, "payroll.view", staff) ||
      maySalonPermissionKey(user, salonId, "payroll.manage", staff);
    const jobEmp = String(job.employeeId ?? "").trim();
    const mine = String(user.employeeId ?? "").trim();
    const own = jobEmp.length > 0 && mine === jobEmp;
    if (finance || own) {
      return;
    }
    throw new HttpsError("permission-denied", "payroll.view required.");
  }

  assertExportTypeAllowed(user, salonId, exportType as ExportType, staff);
}
