# Cursor handoff: Barber Shop App

Use this document when onboarding a new machine, Cursor account, or collaborator on **`barber_shop_app`**. It complements repo rules under **`.cursor/rules/`** and optional agent skills under **`.cursor/skills/`**.

---

## 1. Environment

- **Stack:** Flutter (Dart SDK **^3.11.0** per `pubspec.yaml`), **Firebase** (Auth, Firestore, Storage, Messaging, App Check, Cloud Functions), **Riverpod**, **go_router**.
- **After clone:** run `flutter pub get`, open the **repository root** as the Cursor workspace, use a Flutter/Dart SDK that satisfies `environment.sdk` in `pubspec.yaml`.
- **Push notifications:** optional disable for local dev — see root **`README.md`** (`ENABLE_PUSH_NOTIFICATIONS=false`). iOS needs APNs configured for real device pushes.
- **Google Maps:** API keys must be restricted in Google Cloud — Android package `com.zurano.barbershop`, iOS bundle `com.zurano.barbershop`. Details in **`README.md`**.

---

## 2. Cursor-specific setup

- **Project rules:** **`.cursor/rules/`** — read before large changes:
  - **`DB.mdc`** — Firestore layout and naming (implementation-aligned).
  - **`VERY-IMPORTANT-RULES-DO-NOT-BREAK.mdc`** — required fields and paths.
  - **`flutter-barber-shop-architecture.mdc`** — features, Riverpod, go_router, Firebase structure.
  - **`Languages.mdc`** — English + Arabic, ARB only, RTL.
  - **`COLOR-SYSTEM-MANDATORY-RULE.mdc`** — brand colors (teal + neutrals); use theme tokens, not ad hoc hex in features.
- **Agent skills (optional):** **`.cursor/skills/`** — e.g. `firebase-flutter-expert`, `flutter-en-ar-localization`, `riverpod-state-management`, `flutter-ui-builder`, `debugging-and-fixing`.
- **Legacy vs canonical UI:** Some older rules mention gold/charcoal; **`COLOR-SYSTEM-MANDATORY-RULE.mdc`** is canonical for the current teal palette. Prefer **`Theme.of(context).colorScheme`** and **`lib/core/theme/app_colors.dart`**.

---

## 3. Architecture (non-negotiable)

- **Layering:** UI under `presentation/`, logic in providers/services, data in `models/` + repositories — each feature lives under **`lib/features/<feature>/`**.
- **State:** **Riverpod only** — do not use `setState` for business logic.
- **Routing:** **go_router only** — auth and `salonId` redirects are already wired; extend carefully.
- **Firestore paths:** **Do not hardcode collection strings in repositories** — use **`lib/core/firestore/firestore_paths.dart`**.
- **Writes:** use **`FieldValue.serverTimestamp()`** for `createdAt` / `updatedAt` where the codebase expects it (see `FirestoreWritePayload` patterns).

---

## 4. Firestore mental model (critical)

- **`users/{uid}`** — all personas; **customers** use **`role: customer`**. There is **no** global `customers` collection and **no** `salons/{salonId}/customers` subcollection in the current app.
- **`salons/{salonId}`** — salon root document.
- **Salon subcollections:** `employees`, `services`, `sales`, `attendance`, `payroll`, `expenses`, `bookings`, `violations` (optional feature).
- **Bookings:** **only** **`salons/{salonId}/bookings/{bookingId}`** — **not** a root-level `bookings` collection.
- **Naming:** match Dart models and rules — e.g. salon **`ownerUid`** (not `ownerId`), expense **`incurredAt`**, attendance **`checkInAt` / `checkOutAt`**, user documents use **`uid`** as the primary field (not **`id`** as the user key).

Per-entity field references: **`Database-Schema-*.mdc`** and **`salons-salonId-*.mdc`** in **`.cursor/rules/`**.

---

## 5. Localization (critical)

- **No hardcoded user-visible strings** — use ARB: **`lib/l10n/app_en.arb`**, **`lib/l10n/app_ar.arb`**.
- **English + Arabic**, RTL-safe layouts (**`start` / `end`**, **`Directionality`**), persisted locale as implemented in the app.

---

## 6. UI and components

- Reuse shared widgets (e.g. **`AppTextField`**, **`AppPrimaryButton`**, **`AppCard`**) and consistent spacing — see **`COMPONENT-RULE.mdc`**, **`LAYOUT-RULE-THIS-CREATES-LUXURY-FEEL.mdc`**, and the teal **`COLOR-SYSTEM-MANDATORY-RULE.mdc`**.

---

## 7. Working effectively in Cursor

- **Scope:** Change only what the task requires; match existing naming, imports, and file layout.
- **Before editing Firestore code:** confirm models under **`lib/features/**/data/models/`** and paths in **`firestore_paths.dart`**.
- **Verification:** run **`flutter analyze`** and relevant tests after substantive changes; run the app when touching UI or Firebase flows.

---

## 8. Suggested prompt for new Cursor chats

Paste or adapt this at the start of a session:

> You are working in the **barber_shop_app** Flutter repo. Follow **`.cursor/rules/`** (especially **DB.mdc**, **VERY-IMPORTANT-RULES-DO-NOT-BREAK.mdc**, **flutter-barber-shop-architecture.mdc**, **Languages.mdc**, **COLOR-SYSTEM-MANDATORY-RULE.mdc**). Use Riverpod + go_router + centralized Firestore paths in **`firestore_paths.dart`**. All UI strings via ARB (en/ar). Match **`lib/features/`** layout. Confirm Firestore field names with Dart models and rules before changing shapes.

---

## Quick links

| Topic | Location |
|--------|-----------|
| Firestore paths (code) | `lib/core/firestore/firestore_paths.dart` |
| User model | `lib/features/users/data/models/app_user.dart` |
| Salon model | `lib/features/salon/data/models/salon.dart` |
| Rules index | `.cursor/rules/` |
| Rules + skills transfer index | `docs/CURSOR_RULES_AND_SKILLS_INDEX.md` |
| This handoff | `docs/CURSOR_HANDOFF.md` |
