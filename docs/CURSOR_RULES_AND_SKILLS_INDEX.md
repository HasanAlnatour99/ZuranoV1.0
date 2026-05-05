# Barber Shop app — Cursor rules, skills, and docs (transfer index)

Use this list when **copying project AI configuration** to another machine or Cursor account. The canonical copy is the repo: clone or copy the project and you get everything under **`.cursor/`** and **`docs/`**.

---

## What to copy (minimum)

| Path | Purpose |
|------|--------|
| **`.cursor/rules/`** | All `*.mdc` Cursor rules (always-applied and context rules). |
| **`.cursor/skills/`** | Project agent skills (each feature folder + `SKILL.md`). |
| **`.cursor/settings.json`** | Optional: workspace plugin toggles (see note below). |
| **`docs/`** | Project documentation including handoff and this index. |
| **`README.md`** (root) | Links to **`docs/CURSOR_HANDOFF.md`**. |

**Note on skills:** Folders like **`ui-ux-pro-max/`** include large **`data/`** and **`scripts/`** trees. Transfer the **entire** skill directory if you want skills to behave the same offline.

**Note on `.cursor/settings.json`:** This file only lists which Cursor plugins are enabled for *this* workspace. The other account can keep it, edit it, or omit it; it does not contain barber rules.

---

## Rules (`.cursor/rules/`) — 24 files

### Core / architecture / safety

| File | Summary |
|------|--------|
| `DB.mdc` | Firestore layout, field naming, models vs planned fields. |
| `VERY-IMPORTANT-RULES-DO-NOT-BREAK.mdc` | Required fields, `users` vs `customers`, bookings path. |
| `flutter-barber-shop-architecture.mdc` | Clean architecture, Firebase structure, Riverpod, go_router. |
| `Languages.mdc` | English + Arabic, ARB, RTL, no hardcoded UI strings. |
| `COLOR-SYSTEM-MANDATORY-RULE.mdc` | Teal brand, theme tokens, no legacy gold as brand. |

### UI / design (may overlap; read COLOR-SYSTEM as canonical for colors)

| File | Summary |
|------|--------|
| `COMPONENT-RULE.mdc` | AppTextField, AppPrimaryButton, AppCard usage. |
| `LAYOUT-RULE-THIS-CREATES-LUXURY-FEEL.mdc` | Padding, radii, cards, spacing. |
| `LUXURY-DESIGN-PRINCIPLES.mdc` | Minimal premium UI. |
| `ONT-RULE-VERY-IMPORTANT.mdc` | Typography (Inter/Roboto, sizes). |
| `ANIMATION-RULE.mdc` | Subtle animations. |
| `UI-UX-Inspiration-Engine.mdc` | Product-design-style UI guidance. |
| `FINAL-CURSOR-UI-RULE.mdc` | Dark luxury palette (legacy; cross-check with COLOR-SYSTEM). |
| `BRAND-FEEL-RULE.mdc` | Premium barber, fresh, not clinical. |
| `Templates.mdc` | Code Market templates as inspiration only. |

### Entity / Firestore schema (per collection or path)

| File | Path / topic |
|------|----------------|
| `Database-Schema-Users.mdc` | `users/{uid}` |
| `Database-Schema-Salons.mdc` | `salons/{salonId}` |
| `salons-salonId-employees-employeeId.mdc` | Employees |
| `salons-salonId-services-serviceId.mdc` | Services |
| `salons-salonId-sales-saleId.mdc` | Sales |
| `salons-salonId-bookings-bookingId.mdc` | Bookings |
| `salons-salonId-attendance-attendanceId.mdc` | Attendance |
| `salons-salonId-payroll-payrollId.mdc` | Payroll |
| `salons-salonId-expenses-expenseId.mdc` | Expenses |
| `salons-salonId-violations-violationId.mdc` | Violations |

---

## Skills (`.cursor/skills/`) — entrypoints

Each skill is a folder; the agent reads **`SKILL.md`**. Supporting files are listed.

| Skill folder | `SKILL.md` | Other notable files |
|--------------|------------|---------------------|
| `debugging-and-fixing/` | Yes | — |
| `firebase-flutter-expert/` | Yes | — |
| `flutter-en-ar-localization/` | Yes | — |
| `flutter-ui-builder/` | Yes | — |
| `riverpod-state-management/` | Yes | — |
| `seo-expert/` | Yes | `SEO-CHECKLIST.md`, `TEMPLATES.md` |
| `ui-ux-pro-max/` | Yes | `data/**/*.csv`, `scripts/*.py` (large) |

---

## Docs (`docs/`)

| File | Purpose |
|------|--------|
| `CURSOR_HANDOFF.md` | Onboarding for new collaborators / Cursor sessions. |
| `CURSOR_RULES_AND_SKILLS_INDEX.md` | **This file** — inventory for transferring rules and skills. |
| `firestore-customer-migration.md` | Firestore migration notes (if present). |
| `notifications-deployment.md` | Notifications deployment notes (if present). |
| `qa_testing_foundation.md` | QA / testing foundation notes (if present). |

---

## Quick transfer checklist

1. Copy or clone the **entire repository** (simplest: rules + skills + docs stay in sync with code).
2. If you only move AI config: copy **`.cursor/rules/`** and **`.cursor/skills/`** (full trees) and **`docs/`**.
3. Open **`docs/CURSOR_HANDOFF.md`** on the new account before major work.
4. Run **`flutter pub get`** and use the same Dart/Flutter SDK constraint as **`pubspec.yaml`**.

---

## File counts (approximate)

- **Rules:** 24 × `.mdc` in `.cursor/rules/`
- **Skills:** 7 × `SKILL.md` under `.cursor/skills/` (plus bundled data/scripts under `ui-ux-pro-max/` and extras under `seo-expert/`)
