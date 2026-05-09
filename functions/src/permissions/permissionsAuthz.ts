import { HttpsError } from "firebase-functions/v2/https";

export type ClaimsTargetValidationInput = {
  salonId: string;
  targetUid: string;
  targetUserExists: boolean;
  targetUser: Record<string, unknown>;
  targetStaffExists: boolean;
  targetStaff: Record<string, unknown>;
};

export function assertValidStaffClaimsTarget(input: ClaimsTargetValidationInput): string {
  if (!input.targetUserExists) {
    throw new HttpsError("not-found", "target_user_missing");
  }
  if (String(input.targetUser.salonId ?? "").trim() !== input.salonId) {
    throw new HttpsError("permission-denied", "Target not in salon");
  }

  const role = String(input.targetUser.role ?? "").trim();
  if (role !== "owner" && role !== "admin" && role !== "barber") {
    throw new HttpsError("invalid-argument", "Unsupported target role");
  }

  if (!input.targetStaffExists) {
    throw new HttpsError("failed-precondition", "target_staff_missing");
  }
  const staffSalonId = String(input.targetStaff.salonId ?? "").trim();
  if (staffSalonId && staffSalonId !== input.salonId) {
    throw new HttpsError("permission-denied", "Target staff salon mismatch");
  }
  const staffUid = String(input.targetStaff.uid ?? "").trim();
  if (staffUid && staffUid !== input.targetUid) {
    throw new HttpsError("permission-denied", "Target staff uid mismatch");
  }

  return role;
}
