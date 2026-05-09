import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  auditActorProfile,
  diffBooleanPermissionMaps,
  writeAuditLog,
  writeAuditLogInBatch,
} from "../audit/auditLogger";
import { dataOrEmpty } from "../payrollShared";
import {
  allPermissionsTrue,
  assertCanGrantPermissions,
  sanitizePermissionsInput,
} from "./permissionKeys";
import { assertValidStaffClaimsTarget } from "./permissionsAuthz";

const db = getFirestore();
const auth = getAuth();
const REGION = "us-central1" as const;

async function userDoc(uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`users/${uid}`).get();
  return dataOrEmpty(snap);
}

async function salonDoc(salonId: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`salons/${salonId}`).get();
  return dataOrEmpty(snap);
}

async function staffDoc(salonId: string, uid: string): Promise<Record<string, unknown>> {
  const snap = await db.doc(`salons/${salonId}/staff/${uid}`).get();
  return dataOrEmpty(snap);
}

async function loadStaffClaimsTarget(
  salonId: string,
  targetUid: string,
): Promise<{ targetUser: Record<string, unknown>; targetStaff: Record<string, unknown>; role: string }> {
  const [userSnap, staffSnap] = await Promise.all([
    db.doc(`users/${targetUid}`).get(),
    db.doc(`salons/${salonId}/staff/${targetUid}`).get(),
  ]);
  const targetUser = dataOrEmpty(userSnap);
  const targetStaff = dataOrEmpty(staffSnap);
  const role = assertValidStaffClaimsTarget({
    salonId,
    targetUid,
    targetUserExists: userSnap.exists,
    targetUser,
    targetStaffExists: staffSnap.exists,
    targetStaff,
  });
  return { targetUser, targetStaff, role };
}

function callerActive(staff: Record<string, unknown>): boolean {
  return staff.isActive !== false;
}

function isSalonOwnerFromUsersDoc(caller: Record<string, unknown>, salonId: string): boolean {
  return String(caller.role ?? "").trim() === "owner" &&
    String(caller.salonId ?? "").trim() === salonId;
}

async function assertCallerCanManagePermissions(callerUid: string, salonId: string): Promise<{
  callerUser: Record<string, unknown>;
  callerStaff: Record<string, unknown>;
}> {
  const callerUser = await userDoc(callerUid);
  if (callerUser.isActive === false) {
    throw new HttpsError("permission-denied", "Inactive user");
  }
  if (isSalonOwnerFromUsersDoc(callerUser, salonId)) {
    return { callerUser, callerStaff: await staffDoc(salonId, callerUid) };
  }
  const cs = await staffDoc(salonId, callerUid);
  if (!callerActive(cs)) {
    throw new HttpsError("permission-denied", "Frozen staff cannot manage permissions");
  }
  if (cs && cs.permissions && (cs.permissions as Record<string, boolean>)["permissions.manage"] === true) {
    return { callerUser, callerStaff: cs };
  }
  throw new HttpsError("permission-denied", "permissions.manage required");
}

export const bootstrapSalonStaffForOwner = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    if (!salonId) throw new HttpsError("invalid-argument", "salonId required");

    const caller = await userDoc(request.auth.uid);
    if (!isSalonOwnerFromUsersDoc(caller, salonId)) {
      throw new HttpsError("permission-denied", "Owner only");
    }

    const salon = await salonDoc(salonId);
    const ownerUid = String(salon.ownerUid ?? "").trim();
    if (!ownerUid) throw new HttpsError("failed-precondition", "Salon missing ownerUid");

    const ref = db.doc(`salons/${salonId}/staff/${ownerUid}`);
    const snap = await ref.get();
    const ownerUser = await userDoc(ownerUid);
    const displayName = String(ownerUser.name ?? ownerUser.displayName ?? "Owner").trim() || "Owner";
    const email = String(ownerUser.email ?? "").trim();

    const payload: Record<string, unknown> = {
      uid: ownerUid,
      salonId,
      displayName,
      email,
      phone: ownerUser.phone ?? null,
      role: "owner",
      roleId: "owner",
      permissions: allPermissionsTrue(),
      isActive: true,
      invitedBy: request.auth.uid,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (!snap.exists) {
      payload.createdAt = FieldValue.serverTimestamp();
    }
    await ref.set(payload, { merge: true });
    const actor = await auditActorProfile(db, request.auth.uid);
    await writeAuditLog(db, {
      salonId,
      actionType: "staff.provisioned",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "staff",
      targetId: ownerUid,
      targetLabel: displayName,
      summary: "Initialized owner staff permissions row",
      metadata: { source: "callable" },
    });
    return { ok: true };
  },
);

export const updateStaffPermissions = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const targetUid = String(request.data?.targetUid ?? "").trim();
    const perms = sanitizePermissionsInput(request.data?.permissions);
    if (!salonId || !targetUid) {
      throw new HttpsError("invalid-argument", "salonId and targetUid required");
    }

    const { callerUser, callerStaff } = await assertCallerCanManagePermissions(
      request.auth.uid,
      salonId,
    );

    const salon = await salonDoc(salonId);
    const ownerUid = String(salon.ownerUid ?? "").trim();
    if (targetUid === ownerUid && !isSalonOwnerFromUsersDoc(callerUser, salonId)) {
      throw new HttpsError("permission-denied", "Cannot edit salon owner permissions");
    }

    const callerPermMap =
      callerStaff && callerStaff.permissions && typeof callerStaff.permissions === "object"
        ? (callerStaff.permissions as Record<string, boolean>)
        : {};

    try {
      assertCanGrantPermissions({
        callerIsSalonOwnerFromUsersDoc: isSalonOwnerFromUsersDoc(callerUser, salonId),
        callerPermissions: callerPermMap,
        granted: perms,
      });
    } catch (e) {
      throw new HttpsError("permission-denied", e instanceof Error ? e.message : "cannot_grant");
    }

    const targetStaffPath = `salons/${salonId}/staff/${targetUid}`;
    const { targetStaff: ts, role } = await loadStaffClaimsTarget(salonId, targetUid);
    if (ts.isActive === false) {
      throw new HttpsError("failed-precondition", "target_frozen");
    }
    if (String(ts.role ?? "").trim() === "owner" && !isSalonOwnerFromUsersDoc(callerUser, salonId)) {
      throw new HttpsError("permission-denied", "Cannot edit owner staff row");
    }

    const beforePerm = sanitizePermissionsInput(ts.permissions);
    const diff = diffBooleanPermissionMaps(beforePerm, perms);
    const actor = await auditActorProfile(db, request.auth.uid);
    const batch = db.batch();
    batch.set(
      db.doc(targetStaffPath),
      {
        permissions: perms,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    writeAuditLogInBatch(batch, db, {
      salonId,
      actionType: "permissions.updated",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "staff",
      targetId: targetUid,
      targetLabel: String(ts.displayName ?? ts.email ?? "").trim() || targetUid,
      summary: "Updated staff permissions",
      before: diff.before,
      after: diff.after,
      metadata: { source: "callable" },
    });
    await batch.commit();

    await auth.setCustomUserClaims(targetUid, {
      salonIds: [salonId],
      activeSalonId: salonId,
      role,
    });

    return { ok: true };
  },
);

export const assignRolePresetToStaff = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const targetUid = String(request.data?.targetUid ?? "").trim();
    const roleId = String(request.data?.roleId ?? "").trim();
    if (!salonId || !targetUid || !roleId) {
      throw new HttpsError("invalid-argument", "salonId, targetUid, roleId required");
    }

    const { callerUser, callerStaff } = await assertCallerCanManagePermissions(
      request.auth.uid,
      salonId,
    );
    const salon = await salonDoc(salonId);
    const ownerUid = String(salon.ownerUid ?? "").trim();
    if (targetUid === ownerUid && !isSalonOwnerFromUsersDoc(callerUser, salonId)) {
      throw new HttpsError("permission-denied", "Cannot reassign salon owner role preset");
    }

    const presetSnap = await db.doc(`salons/${salonId}/roles/${roleId}`).get();
    if (!presetSnap.exists) throw new HttpsError("not-found", "Role preset not found");
    const preset = presetSnap.data() as Record<string, unknown>;
    const presetPerms = sanitizePermissionsInput(preset.permissions);

    const callerPermMap =
      callerStaff && callerStaff.permissions && typeof callerStaff.permissions === "object"
        ? (callerStaff.permissions as Record<string, boolean>)
        : {};

    try {
      assertCanGrantPermissions({
        callerIsSalonOwnerFromUsersDoc: isSalonOwnerFromUsersDoc(callerUser, salonId),
        callerPermissions: callerPermMap,
        granted: presetPerms,
      });
    } catch (e) {
      throw new HttpsError("permission-denied", e instanceof Error ? e.message : "cannot_grant");
    }

    const { targetStaff: st, role } = await loadStaffClaimsTarget(salonId, targetUid);
    const beforeRoleId = String(st.roleId ?? "").trim();
    const beforePerm = sanitizePermissionsInput(st.permissions);

    const actor = await auditActorProfile(db, request.auth.uid);
    const permDiff = diffBooleanPermissionMaps(beforePerm, presetPerms);
    const batch = db.batch();
    batch.set(
      db.doc(`salons/${salonId}/staff/${targetUid}`),
      {
        roleId,
        permissions: presetPerms,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    writeAuditLogInBatch(batch, db, {
      salonId,
      actionType: "permissions.updated",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "staff",
      targetId: targetUid,
      targetLabel: String(st.displayName ?? st.email ?? "").trim() || targetUid,
      summary: "Applied role preset",
      before: { roleId: beforeRoleId, permissions: permDiff.before },
      after: { roleId, permissions: permDiff.after },
      metadata: { source: "callable", presetId: roleId },
    });
    await batch.commit();

    await auth.setCustomUserClaims(targetUid, {
      salonIds: [salonId],
      activeSalonId: salonId,
      role,
    });

    return { ok: true };
  },
);

export const createRolePreset = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const name = String(request.data?.name ?? "").trim();
    const description = String(request.data?.description ?? "").trim();
    const perms = sanitizePermissionsInput(request.data?.permissions);
    if (!salonId || !name) throw new HttpsError("invalid-argument", "salonId and name required");

    await assertCallerCanManagePermissions(request.auth.uid, salonId);

    const slug = name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "_")
      .replace(/^_|_$/g, "")
      .slice(0, 48) || "role";
    const roleId = `${slug}_${Date.now().toString(36)}`;

    await db.doc(`salons/${salonId}/roles/${roleId}`).set({
      salonId,
      roleId,
      name,
      description,
      permissions: perms,
      isSystem: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const actor = await auditActorProfile(db, request.auth.uid);
    await writeAuditLog(db, {
      salonId,
      actionType: "permissions.preset_created",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "role_preset",
      targetId: roleId,
      targetLabel: name,
      summary: "Created role preset",
      after: { name, description, keys: Object.keys(perms) },
      metadata: { source: "callable" },
    });

    return { ok: true, roleId };
  },
);

export const updateRolePreset = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const roleId = String(request.data?.roleId ?? "").trim();
    const perms = sanitizePermissionsInput(request.data?.permissions);
    if (!salonId || !roleId) throw new HttpsError("invalid-argument", "salonId and roleId required");

    await assertCallerCanManagePermissions(request.auth.uid, salonId);

    const ref = db.doc(`salons/${salonId}/roles/${roleId}`);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError("not-found", "Role preset not found");
    const data = snap.data() as Record<string, unknown>;
    if (data.isSystem === true) {
      throw new HttpsError("permission-denied", "Cannot edit system preset");
    }

    const oldPerms = sanitizePermissionsInput(data.permissions);
    const permDiff = diffBooleanPermissionMaps(oldPerms, perms);
    const patch: Record<string, unknown> = {
      permissions: perms,
      updatedAt: FieldValue.serverTimestamp(),
    };
    const name = request.data?.name != null ? String(request.data.name).trim() : null;
    const description = request.data?.description != null ? String(request.data.description).trim() : null;
    if (name != null && name.length > 0) patch.name = name;
    if (description != null) patch.description = description;

    await ref.set(patch, { merge: true });

    const actor = await auditActorProfile(db, request.auth.uid);
    const presetLabel = String(data.name ?? roleId).trim() || roleId;
    await writeAuditLog(db, {
      salonId,
      actionType: "permissions.preset_updated",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "role_preset",
      targetId: roleId,
      targetLabel: presetLabel,
      summary: "Updated role preset",
      before: {
        name: String(data.name ?? ""),
        permissions: permDiff.before,
      },
      after: {
        name: name ?? String(data.name ?? ""),
        permissions: permDiff.after,
      },
      metadata: { source: "callable" },
    });

    return { ok: true };
  },
);

export const setStaffActiveStatus = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const targetUid = String(request.data?.targetUid ?? "").trim();
    const isActive = Boolean(request.data?.isActive);
    if (!salonId || !targetUid) throw new HttpsError("invalid-argument", "salonId and targetUid required");

    const { callerUser } = await assertCallerCanManagePermissions(request.auth.uid, salonId);
    const salon = await salonDoc(salonId);
    const ownerUid = String(salon.ownerUid ?? "").trim();
    if (targetUid === ownerUid) {
      throw new HttpsError("permission-denied", "Cannot freeze salon owner");
    }

    const { targetStaff: ts, role } = await loadStaffClaimsTarget(salonId, targetUid);
    if (String(ts.role ?? "").trim() === "owner" && !isSalonOwnerFromUsersDoc(callerUser, salonId)) {
      throw new HttpsError("permission-denied", "Cannot change owner staff status");
    }

    const wasActive = ts.isActive !== false;
    const actor = await auditActorProfile(db, request.auth.uid);
    const batch = db.batch();
    batch.set(
      db.doc(`salons/${salonId}/staff/${targetUid}`),
      {
        isActive,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    writeAuditLogInBatch(batch, db, {
      salonId,
      actionType: isActive ? "staff.unfrozen" : "staff.frozen",
      module: "permissions",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "staff",
      targetId: targetUid,
      targetLabel: String(ts.displayName ?? ts.email ?? "").trim() || targetUid,
      summary: isActive ? "Unfroze staff account" : "Froze staff account",
      before: { isActive: wasActive },
      after: { isActive },
      metadata: { source: "callable" },
    });
    await batch.commit();

    await auth.setCustomUserClaims(targetUid, {
      salonIds: [salonId],
      activeSalonId: salonId,
      role,
    });

    return { ok: true };
  },
);

/** Creates `staff/{uid}` from `users/{uid}` when missing (owner-only). Needed before granular rules apply. */
export const provisionSalonStaffMember = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const targetUid = String(request.data?.targetUid ?? "").trim();
    if (!salonId || !targetUid) throw new HttpsError("invalid-argument", "salonId and targetUid required");

    const caller = await userDoc(request.auth.uid);
    if (!isSalonOwnerFromUsersDoc(caller, salonId)) {
      throw new HttpsError("permission-denied", "Owner only");
    }

    const tu = await userDoc(targetUid);
    if (String(tu.salonId ?? "").trim() !== salonId) {
      throw new HttpsError("permission-denied", "Target not in salon");
    }
    const role = String(tu.role ?? "").trim();
    if (role != "admin" && role != "barber" && role != "owner") {
      throw new HttpsError("invalid-argument", "Unsupported role");
    }

    const perms =
      role === "owner" || role === "admin"
        ? allPermissionsTrue()
        : {
            "bookings.view": true,
            "bookings.manage": true,
            "sales.view": true,
            "sales.manage": true,
            "customers.view": true,
            "customers.manage": false,
            "team.view": true,
            "team.manage": false,
            "attendance.view": true,
            "attendance.manage": false,
            "payroll.view": true,
            "payroll.manage": false,
            "expenses.view": true,
            "expenses.manage": false,
            "analytics.view": false,
            "settings.manage": false,
            "permissions.manage": false,
          };

    const displayName = String(tu.name ?? tu.displayName ?? "Staff").trim() || "Staff";
    const email = String(tu.email ?? "").trim();

    await db.doc(`salons/${salonId}/staff/${targetUid}`).set(
      {
        uid: targetUid,
        salonId,
        displayName,
        email,
        phone: tu.phone ?? null,
        role,
        roleId: role === "barber" ? "barber" : "manager",
        permissions: perms,
        isActive: tu.isActive !== false,
        invitedBy: request.auth.uid,
        updatedAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    const actor = await auditActorProfile(db, request.auth.uid);
    await writeAuditLog(db, {
      salonId,
      actionType: "staff.provisioned",
      module: "team",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "staff",
      targetId: targetUid,
      targetLabel: displayName,
      summary: "Provisioned salon staff row",
      after: { role },
      metadata: { source: "callable" },
    });

    await auth.setCustomUserClaims(targetUid, {
      salonIds: [salonId],
      activeSalonId: salonId,
      role,
    });

    return { ok: true };
  },
);

export const syncUserClaimsForStaff = onCall(
  { region: REGION, enforceAppCheck: true },
  async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Login required");
    const salonId = String(request.data?.salonId ?? "").trim();
    const targetUid = String(request.data?.targetUid ?? "").trim();
    if (!salonId || !targetUid) throw new HttpsError("invalid-argument", "salonId and targetUid required");

    await assertCallerCanManagePermissions(request.auth.uid, salonId);

    const { targetUser: u, role } = await loadStaffClaimsTarget(salonId, targetUid);
    await auth.setCustomUserClaims(targetUid, {
      salonIds: [salonId],
      activeSalonId: salonId,
      role,
    });

    const actor = await auditActorProfile(db, request.auth.uid);
    await writeAuditLog(db, {
      salonId,
      actionType: "auth.claims_synced",
      module: "auth",
      actorUid: request.auth.uid,
      actorName: actor.name,
      actorRole: actor.role,
      targetType: "user",
      targetId: targetUid,
      targetLabel: String(u.name ?? "").trim() || targetUid,
      summary: "Synced auth custom claims for staff member",
      metadata: { source: "callable" },
    });

    return { ok: true };
  },
);
