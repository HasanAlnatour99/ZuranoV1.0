import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  assertValidStaffAuthEmail,
  assertValidStaffRole,
  assertValidStaffUsername,
  authSafeDisplayName,
  normalizeStaffUsername,
  requireValidProvisioningPassword,
} from "./staffProvisioningShared";

const db = getFirestore();
const auth = getAuth();

type CreateStaffInput = {
  salonId: string;
  /** Preferred; `fullName` kept for backward-compatible clients. */
  displayName?: string;
  fullName?: string;
  email: string;
  username: string;
  role?: string;
  password: string;
  phone?: string | null;
  commissionPercent?: number;
  attendanceRequired?: boolean;
  isBookable?: boolean;
  isActive?: boolean;
  permissions?: Record<string, boolean>;
  photoUrl?: string | null;
};

/**
 * Creates Firebase Auth + `users/{uid}` + `salons/{salonId}/employees/{employeeId}`.
 * Callable name: `salonStaffCreateWithAuth`.
 */
export const salonStaffCreateWithAuth = onCall(
  {
    region: "us-central1",
    enforceAppCheck: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required.");
    }

    const callerUid = request.auth.uid;
    const data = request.data as CreateStaffInput;

    const salonId = String(data.salonId ?? "").trim();
    const rawDisplay = String(data.displayName ?? data.fullName ?? "");
    const displayName = rawDisplay.trim();
    const hasDisplayNameKey = Object.prototype.hasOwnProperty.call(
      data,
      "displayName",
    );
    const hasFullNameKey = Object.prototype.hasOwnProperty.call(data, "fullName");

    const rawEmail = String(data.email ?? "");
    const rawUsername = String(data.username ?? "");
    const rawRole = String(data.role ?? "");
    const password = String(data.password ?? "");
    const phone = data.phone ? String(data.phone).trim() : null;
    const commissionPercent = Number(data.commissionPercent ?? 0);
    const attendanceRequired = data.attendanceRequired ?? true;
    const isActive = data.isActive ?? true;
    const photoUrl =
      data.photoUrl == null ? null : String(data.photoUrl).trim() || null;
    const permissions =
      data.permissions && typeof data.permissions === "object"
        ? data.permissions
        : {};

    if (!salonId) {
      throw new HttpsError("invalid-argument", "salonId is required", {
        field: "salonId",
        reason: "missing",
      });
    }

    if (!displayName) {
      const missingBothKeys = !hasDisplayNameKey && !hasFullNameKey;
      throw new HttpsError(
        "invalid-argument",
        missingBothKeys ? "displayName is required" : "displayName is empty",
        {
          field: "displayName",
          reason: missingBothKeys ? "missing" : "empty",
        },
      );
    }
    if (displayName.length < 2) {
      throw new HttpsError("invalid-argument", "displayName is too short", {
        field: "displayName",
        reason: "too_short",
        minLength: 2,
      });
    }

    const trimmedEmail = rawEmail.trim();
    if (!trimmedEmail) {
      throw new HttpsError("invalid-argument", "email is required", {
        field: "email",
        reason: "missing",
      });
    }
    const authEmail = assertValidStaffAuthEmail(trimmedEmail);

    if (!String(rawUsername).trim()) {
      throw new HttpsError("invalid-argument", "username is required", {
        field: "username",
        reason: "missing",
      });
    }
    assertValidStaffUsername(rawUsername);
    const usernameLower = normalizeStaffUsername(rawUsername);
    const role = rawRole.trim().toLowerCase();
    if (!role) {
      throw new HttpsError("invalid-argument", "Missing or invalid role.", {
        field: "role",
        reason: "missing",
      });
    }
    assertValidStaffRole(role);
    const isBookable = data.isBookable ?? role === "barber";

    if (!password) {
      throw new HttpsError("invalid-argument", "password is required", {
        field: "password",
        reason: "missing",
      });
    }
    requireValidProvisioningPassword(password);

    const callerUserRef = db.collection("users").doc(callerUid);
    const callerUserSnap = await callerUserRef.get();

    if (!callerUserSnap.exists) {
      throw new HttpsError(
        "permission-denied",
        "Caller user document not found.",
      );
    }

    const callerUser = callerUserSnap.data()!;
    if (callerUser.role !== "owner" || callerUser.isActive !== true) {
      throw new HttpsError(
        "permission-denied",
        "Only active owners can create staff.",
      );
    }

    if (callerUser.salonId !== salonId) {
      throw new HttpsError(
        "permission-denied",
        "You can only create staff in your own salon.",
      );
    }

    const existingUsernameSnap = await db
      .collection("users")
      .where("usernameLower", "==", usernameLower)
      .limit(1)
      .get();

    if (!existingUsernameSnap.empty) {
      throw new HttpsError("already-exists", "Username already exists.");
    }

    let createdAuthUser: { uid: string } | null = null;
    const safeName = authSafeDisplayName(displayName);

    try {
      const createWithOptionalDisplayName = (includeDisplayName: boolean) =>
        auth.createUser({
          email: authEmail,
          password,
          ...(includeDisplayName && safeName ? { displayName: safeName } : {}),
          disabled: !isActive,
        });

      try {
        createdAuthUser = await createWithOptionalDisplayName(true);
      } catch (firstError: unknown) {
        const firstCode = (firstError as { code?: string })?.code;
        if (firstCode === "auth/invalid-display-name" && safeName) {
          createdAuthUser = await createWithOptionalDisplayName(false);
        } else {
          throw firstError;
        }
      }

      const uid = createdAuthUser.uid;
      /** Auth uid must match `employees/{uid}` for consistent staff login + rules. */
      const employeeId = uid;
      const userRef = db.collection("users").doc(uid);
      const employeeRef = db
        .collection("salons")
        .doc(salonId)
        .collection("employees")
        .doc(uid);

      const batch = db.batch();

      batch.set(userRef, {
        uid,
        fullName: displayName,
        email: authEmail,
        role,
        salonId,
        employeeId,
        phone,
        photoUrl,
        isActive,
        username: usernameLower,
        usernameLower,
        mustChangePassword: true,
        displayName: safeName ?? displayName,
        createdBy: callerUid,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      batch.set(employeeRef, {
        id: employeeId,
        uid,
        salonId,
        username: usernameLower,
        usernameLower,
        name: displayName,
        email: authEmail,
        role,
        photoUrl,
        phone,
        initials: displayName
          .split(/\s+/)
          .slice(0, 2)
          .map((part) => part[0]?.toUpperCase() ?? "")
          .join(""),
        isActive,
        attendanceRequired,
        isBookable,
        commissionPercent: Number.isFinite(commissionPercent)
          ? Math.max(0, Math.min(100, commissionPercent))
          : 0,
        permissions,
        mustChangePassword: true,
        hiredAt: FieldValue.serverTimestamp(),
        createdBy: callerUid,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return {
        success: true,
        uid,
        employeeId,
        username: usernameLower,
        email: authEmail,
      };
    } catch (error) {
      if (createdAuthUser) {
        await auth.deleteUser(createdAuthUser.uid).catch(() => {});
      }
      if (error instanceof HttpsError) {
        throw error;
      }
      const code = (error as { code?: string })?.code;
      if (code === "auth/invalid-email") {
        throw new HttpsError("invalid-argument", "Missing or invalid email.");
      }
      if (code === "auth/invalid-display-name") {
        throw new HttpsError("invalid-argument", "Invalid name format");
      }
      if (code === "auth/email-already-exists") {
        throw new HttpsError(
          "already-exists",
          "This email is already registered.",
        );
      }
      throw new HttpsError(
        "internal",
        "Unable to create staff account. Please try again.",
      );
    }
  },
);
