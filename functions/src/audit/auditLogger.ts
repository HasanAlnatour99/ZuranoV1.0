import {
  FieldValue,
  type Firestore,
  type Transaction,
  type WriteBatch,
} from "firebase-admin/firestore";

/** Salon Activity Center — `salons/{salonId}/auditLogs/{auditId}` */
export const AUDIT_LOGS_COLLECTION = "auditLogs";

export type AuditLogPayload = {
  salonId: string;
  actionType: string;
  module: string;
  actorUid: string;
  actorName: string;
  actorRole: string;
  targetType?: string | null;
  targetId?: string | null;
  targetLabel?: string | null;
  summary: string;
  before?: Record<string, unknown>;
  after?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
};

const MAX_KEYS = 48;
const MAX_STRING = 800;

function pruneValue(v: unknown): unknown {
  if (v === null || v === undefined) return v;
  if (typeof v === "boolean" || typeof v === "number") return v;
  if (typeof v === "string") {
    const s = v.length > MAX_STRING ? `${v.slice(0, MAX_STRING)}…` : v;
    return s;
  }
  if (v instanceof Date) return v.toISOString();
  return "[omitted]";
}

/** Small maps only — no secrets / card data. */
export function sanitizeAuditMap(
  m?: Record<string, unknown> | null,
): Record<string, unknown> {
  if (!m || typeof m !== "object") return {};
  const out: Record<string, unknown> = {};
  let n = 0;
  for (const [k, v] of Object.entries(m)) {
    if (n >= MAX_KEYS) break;
    const key = String(k).slice(0, 120);
    if (
      /password|token|secret|pan|card/i.test(key)
    ) {
      continue;
    }
    out[key] = pruneValue(v);
    n++;
  }
  return out;
}

export async function writeAuditLog(
  db: Firestore,
  payload: AuditLogPayload,
): Promise<void> {
  const ref = db.collection(`salons/${payload.salonId}/${AUDIT_LOGS_COLLECTION}`).doc();
  await ref.set(auditDocumentFields(payload));
}

export function writeAuditLogInTransaction(
  tx: Transaction,
  db: Firestore,
  payload: AuditLogPayload,
): void {
  const ref = db.collection(`salons/${payload.salonId}/${AUDIT_LOGS_COLLECTION}`).doc();
  tx.set(ref, auditDocumentFields(payload));
}

export function writeAuditLogInBatch(
  batch: WriteBatch,
  db: Firestore,
  payload: AuditLogPayload,
): void {
  const ref = db.collection(`salons/${payload.salonId}/${AUDIT_LOGS_COLLECTION}`).doc();
  batch.set(ref, auditDocumentFields(payload));
}

function auditDocumentFields(payload: AuditLogPayload): Record<string, unknown> {
  return {
    salonId: payload.salonId,
    actionType: payload.actionType,
    module: payload.module,
    actorUid: payload.actorUid,
    actorName: payload.actorName,
    actorRole: payload.actorRole,
    targetType: payload.targetType ?? null,
    targetId: payload.targetId ?? null,
    targetLabel: payload.targetLabel ?? null,
    summary: payload.summary.slice(0, 500),
    before: sanitizeAuditMap(payload.before),
    after: sanitizeAuditMap(payload.after),
    metadata: sanitizeAuditMap(payload.metadata),
    createdAt: FieldValue.serverTimestamp(),
  };
}

/** Narrow permission maps to changed keys only. */
export async function auditActorProfile(
  db: Firestore,
  uid: string,
): Promise<{ name: string; role: string }> {
  const snap = await db.doc(`users/${uid}`).get();
  const d = snap.data() ?? {};
  const name = String(d.name ?? d.displayName ?? "").trim() || "User";
  const role = String(d.role ?? "").trim() || "unknown";
  return { name, role };
}

export function diffBooleanPermissionMaps(
  before: Record<string, boolean>,
  after: Record<string, boolean>,
): { before: Record<string, unknown>; after: Record<string, unknown> } {
  const bOut: Record<string, unknown> = {};
  const aOut: Record<string, unknown> = {};
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  for (const k of keys) {
    const bv = before[k] === true;
    const av = after[k] === true;
    if (bv !== av) {
      bOut[k] = bv;
      aOut[k] = av;
    }
  }
  return { before: bOut, after: aOut };
}
