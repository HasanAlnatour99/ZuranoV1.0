import { getFirestore } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { auditActorProfile, writeAuditLog } from "./auditLogger";

const db = getFirestore();

function expenseAuditAction(params: {
  beforeExists: boolean;
  afterExists: boolean;
  before?: FirebaseFirestore.DocumentData | undefined;
  after?: FirebaseFirestore.DocumentData | undefined;
}): { actionType: string; summary: string } | null {
  const { beforeExists, afterExists, before, after } = params;
  if (!afterExists && beforeExists) {
    return { actionType: "expenses.deleted", summary: "Expense deleted" };
  }
  if (afterExists && !beforeExists) {
    return { actionType: "expenses.created", summary: "Expense created" };
  }
  if (afterExists && beforeExists) {
    const wasDeleted = before?.isDeleted === true;
    const nowDeleted = after?.isDeleted === true;
    if (!wasDeleted && nowDeleted) {
      return { actionType: "expenses.deleted", summary: "Expense removed" };
    }
    return { actionType: "expenses.updated", summary: "Expense updated" };
  }
  return null;
}

/** Client-written expenses → immutable Activity Center audit rows (Admin SDK). */
export const auditSalonExpenseWrite = onDocumentWritten(
  {
    document: "salons/{salonId}/expenses/{expenseId}",
    region: "us-central1",
  },
  async (event) => {
    const salonId = event.params.salonId as string;
    const expenseId = event.params.expenseId as string;
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    const before = beforeSnap?.data();
    const after = afterSnap?.data();
    const decision = expenseAuditAction({
      beforeExists: beforeSnap?.exists === true,
      afterExists: afterSnap?.exists === true,
      before,
      after,
    });
    if (!decision) return;

    const actorUid = String(after?.createdByUid ?? before?.createdByUid ?? "").trim();
    let actorName = String(after?.createdByName ?? before?.createdByName ?? "").trim() || "User";
    let actorRole = "unknown";
    if (actorUid.length > 0) {
      try {
        const a = await auditActorProfile(db, actorUid);
        actorName = a.name;
        actorRole = a.role;
      } catch {
        // keep fallback label
      }
    }

    const title = String(after?.title ?? before?.title ?? "").trim() || expenseId;
    await writeAuditLog(db, {
      salonId,
      actionType: decision.actionType,
      module: "expenses",
      actorUid: actorUid || "unknown",
      actorName,
      actorRole,
      targetType: "expense",
      targetId: expenseId,
      targetLabel: title,
      summary: decision.summary,
      before: before
        ? {
            title: before.title,
            amount: before.amount,
            category: before.category,
            isDeleted: before.isDeleted,
          }
        : {},
      after: after
        ? {
            title: after.title,
            amount: after.amount,
            category: after.category,
            isDeleted: after.isDeleted,
          }
        : {},
      metadata: { source: "firestore_trigger", expenseId },
    });
  },
);

/** Salon settings docs (`settings/*`) — attendance, sales, customer booking, payroll cadence, etc. */
export const auditSalonSettingsWrite = onDocumentWritten(
  {
    document: "salons/{salonId}/settings/{settingId}",
    region: "us-central1",
  },
  async (event) => {
    const salonId = event.params.salonId as string;
    const settingId = event.params.settingId as string;
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after && !before) return;

    const actorUid = String(after?.updatedByUid ?? after?.lastUpdatedByUid ?? before?.updatedByUid ?? "").trim();
    let actorName = "System";
    let actorRole = "unknown";
    if (actorUid.length > 0) {
      try {
        const a = await auditActorProfile(db, actorUid);
        actorName = a.name;
        actorRole = a.role;
      } catch {
        actorName = "User";
      }
    }

    const beforeKeys = before && typeof before === "object" ? Object.keys(before).sort().join(",") : "";
    const afterKeys = after && typeof after === "object" ? Object.keys(after).sort().join(",") : "";
    if (beforeKeys === afterKeys && JSON.stringify(before) === JSON.stringify(after)) {
      return;
    }

    await writeAuditLog(db, {
      salonId,
      actionType: "settings.updated",
      module: "settings",
      actorUid: actorUid || "unknown",
      actorName,
      actorRole,
      targetType: "settings",
      targetId: settingId,
      targetLabel: settingId,
      summary: `Settings updated (${settingId})`,
      before: sanitizeSettingsSnap(before),
      after: sanitizeSettingsSnap(after),
      metadata: { source: "firestore_trigger", settingId },
    });
  },
);

function sanitizeSettingsSnap(
  raw: FirebaseFirestore.DocumentData | undefined,
): Record<string, unknown> {
  if (!raw || typeof raw !== "object") return {};
  const out: Record<string, unknown> = {};
  let n = 0;
  for (const [k, v] of Object.entries(raw)) {
    if (n >= 40) break;
    if (/password|token|secret/i.test(k)) continue;
    if (typeof v === "object" && v !== null && !Array.isArray(v)) {
      out[k] = "[object]";
    } else {
      out[k] = v;
    }
    n++;
  }
  return out;
}
