import { FieldValue, getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

/** Input for `salons/{salonId}/notifications` (in-app inbox; FCM is separate). */
export type SalonInAppNotificationInput = {
  salonId: string;
  recipientUserId: string;
  recipientRole: string;
  type: string;
  title: string;
  body: string;
  priority?: string;
  routeName?: string | null;
  entityId?: string | null;
  entityType?: string | null;
  data?: Record<string, unknown>;
  dedupeKey?: string | null;
  createdBy?: string | null;
  imageUrl?: string | null;
  /** Optional; defaults from [recipientRole]. */
  targetRole?: string;
};

function roleHintFromRecipientRole(role: string): string {
  const r = (role ?? "").toLowerCase().trim();
  if (r === "owner" || r === "admin") {
    return "owner_admin";
  }
  if (
    r === "barber" ||
    r === "employee" ||
    r === "readonly"
  ) {
    return "employee";
  }
  if (r === "customer") {
    return "customer";
  }
  return "all";
}

/**
 * Writes a salon-scoped in-app notification (idempotent when [dedupeKey] is set).
 * Returns new document id, or `null` when skipped as duplicate.
 *
 * Reuses [notificationTypes]-style event strings where possible; aligns with
 * Flutter [NotificationEventTypes] for new product notifications.
 */
export async function createSalonInAppNotification(
  input: SalonInAppNotificationInput,
): Promise<string | null> {
  const salonId = input.salonId.trim();
  const notificationsRef = db
    .collection("salons")
    .doc(salonId)
    .collection("notifications");

  if (input.dedupeKey != null && input.dedupeKey !== "") {
    const dup = await notificationsRef
      .where("dedupeKey", "==", input.dedupeKey)
      .limit(1)
      .get();
    if (!dup.empty) {
      return null;
    }
  }

  const docRef = notificationsRef.doc();
  const priority = input.priority ?? "normal";
  const targetRole =
    input.targetRole ?? roleHintFromRecipientRole(input.recipientRole);
  const route = input.routeName ?? null;

  await docRef.set({
    salonId,
    recipientUserId: input.recipientUserId,
    recipientRole: input.recipientRole,
    type: input.type,
    title: input.title,
    body: input.body,
    priority,
    isRead: false,
    readAt: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    status: "active",
    routeName: route,
    entityId: input.entityId ?? null,
    entityType: input.entityType ?? null,
    data: input.data ?? {},
    dedupeKey: input.dedupeKey ?? null,
    createdBy: input.createdBy ?? null,
    imageUrl: input.imageUrl ?? null,
    targetRole,
    targetUserId: input.recipientUserId,
    targetEmployeeId: null,
    targetCustomerId: null,
    customerPhoneNormalized: null,
    readBy: {},
    actionRoute: route,
  });

  return docRef.id;
}
