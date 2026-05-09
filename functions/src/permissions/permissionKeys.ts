/** Firestore permission keys — keep in sync with Dart `PermissionKey`. */
export const PERMISSION_KEYS = [
  "bookings.view",
  "bookings.manage",
  "sales.view",
  "sales.manage",
  "customers.view",
  "customers.manage",
  "team.view",
  "team.manage",
  "attendance.view",
  "attendance.manage",
  "payroll.view",
  "payroll.manage",
  "expenses.view",
  "expenses.manage",
  "analytics.view",
  "settings.manage",
  "permissions.manage",
] as const;

export type PermissionKey = (typeof PERMISSION_KEYS)[number];

export const PERMISSION_KEY_SET = new Set<string>(PERMISSION_KEYS);

export function allPermissionsTrue(): Record<string, boolean> {
  const m: Record<string, boolean> = {};
  for (const k of PERMISSION_KEYS) {
    m[k] = true;
  }
  return m;
}

export function sanitizePermissionsInput(raw: unknown): Record<string, boolean> {
  if (raw == null || typeof raw !== "object") return {};
  const out: Record<string, boolean> = {};
  for (const [k, v] of Object.entries(raw as Record<string, unknown>)) {
    if (!PERMISSION_KEY_SET.has(k)) continue;
    out[k] = Boolean(v);
  }
  return out;
}

/** Caller cannot grant keys they do not have (unless caller is salon owner on users doc). */
export function assertCanGrantPermissions(params: {
  callerIsSalonOwnerFromUsersDoc: boolean;
  callerPermissions: Record<string, boolean> | null;
  granted: Record<string, boolean>;
}): void {
  if (params.callerIsSalonOwnerFromUsersDoc) return;
  const caller = params.callerPermissions ?? {};
  for (const [key, want] of Object.entries(params.granted)) {
    if (!want) continue;
    if (caller[key] !== true) {
      throw new Error(`cannot_grant_permission:${key}`);
    }
  }
}
