# Zurano v1.0 Readiness Report

Date: 2026-05-27
Branch: `cursor/zurano-v1-readiness-audit-5588`

## Overall readiness

Estimated production readiness: **58%**

Zurano has a large, real Firebase-backed feature set and several strong foundations: owner onboarding, salon-scoped repositories, guest booking callables, App Check provider selection, localization infrastructure, Firestore indexes, and backend tests. It is **not ready for v1.0 go-live** until the critical blockers below are resolved and release builds are validated on proper Android/iOS release infrastructure.

The readiness score is lower than a code-unseen estimate because this audit found production-facing debug paths, missing Crashlytics, debug signing, incomplete release validation in the current environment, and a failing backend test.

## Critical blockers

1. **Firestore rules still contain dev-only `debugSeed` write branches**
   - `firestore.rules:399-401`, `409-424`, `544-549`, `577-598`, `632-637`
   - These branches allow authenticated clients to create/update demo/discovery data when `debugSeed == true`.
   - Action: remove or hard-gate all debug seed branches before production.

2. **Crashlytics is not integrated**
   - `pubspec.yaml:40-47` includes Firebase core/auth/firestore/storage/app_check/messaging, but no `firebase_crashlytics`.
   - `lib/main.dart:109-131` only logs errors with `debugPrint`; it does not call Crashlytics handlers.
   - `firebase.json:73` has iOS/macOS `uploadDebugSymbols: false`.
   - Action: add Crashlytics dependency and wire:
     - `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
     - `PlatformDispatcher.instance.onError = ... recordError(..., fatal: true)`
     - Enable symbol upload for release.

3. **Android release build uses debug signing**
   - `android/app/build.gradle.kts:45-50`
   - Release uses `signingConfigs.getByName("debug")`.
   - Action: configure a real release keystore/signing config before Play Store or production App Check validation.

4. **Customer booking details callable leaks booking data without identity verification**
   - `functions/src/customer/customerPortalCallables.ts:905-920`
   - `getCustomerBookingDetails` returns the full booking and public salon for any caller with App Check plus `salonId` and `bookingId`.
   - `cancelCustomerBooking` correctly calls `assertCustomerBookingIdentity` at `functions/src/customer/customerPortalCallables.ts:943-948`; details should use equivalent verification.

5. **Customer reschedule route is a production stub**
   - Route registered at `lib/router/app_router.dart:304-321`.
   - Screen renders hardcoded placeholder copy at `lib/features/customer/presentation/screens/customer_booking_reschedule_screen.dart:19-26`.
   - Details screen navigates to it from `lib/features/customer/presentation/screens/customer_booking_details_screen.dart:179-186` and `518-524`.
   - Action: reuse the real reschedule flow or remove this route/action for v1.0.

6. **Debug Maps route is wired into production routing**
   - Route registered at `lib/router/app_router.dart:745-751`.
   - Allowed by auth guards for owner/staff/customer paths at `lib/router/router_guards.dart:81`, `120`, and `174-175`.
   - Debug screen has hardcoded UI at `lib/features/debug/presentation/screens/google_maps_test_screen.dart:17-28`.
   - Action: remove route from release builds or wrap in debug-only routing.

7. **Cloud Functions test suite currently fails**
   - `npm run build` passed.
   - `npm test` failed in `functions/test/customerSearchIndexGeo.test.ts:9`.
   - Failure: `TypeError: serviceIndexGeoPayload is not a function`.
   - Action: restore/export the expected geo payload helper or update the test/source contract.

8. **Flutter toolchain is missing on this cloud machine**
   - `flutter clean && flutter pub get && flutter analyze` failed with `flutter: command not found`.
   - Android/iOS release builds, Flutter tests, and analyzer status could not be validated here.
   - Action: run validation in a Flutter-enabled environment before go-live.

## High priority issues

### Authentication, session, and logout

Positive:
- Session bootstrap uses Firebase Auth and user documents to resolve app session state.
- Logout clears onboarding/session flags, invalidates Riverpod state, and refreshes routing.
- Anonymous guest sign-in creates/updates `users/{uid}` and writes a stable `guestProfileId`.

Risks:
- `agentSessionLog` is called from auth/session paths and posts to localhost ingest on Android/iOS in `lib/core/debug/agent_session_log.dart:49-51`.
- It also contains a developer machine absolute path at `lib/core/debug/agent_session_log.dart:7-11`.
- Guest device identity is intentionally persistent in secure storage (`lib/features/customer_profile/data/guest_identity_repository.dart:10-23`) and is not cleared by `clearSessionBootstrapFlags` (`lib/providers/onboarding_providers.dart:286-296`). This helps booking continuity but should be reviewed as a privacy/session-boundary decision.

### Guest booking persistence

Positive:
- Stable local guest identity exists.
- Booking creation uses a callable with App Check (`functions/src/customer/customerPortalCallables.ts:25`).
- Server uses booking request locks and global booking-code locks.
- Recent bookings can be queried by `guestProfileId` using `collectionGroup('bookings')` (`lib/features/customer/presentation/screens/find_booking_screen.dart:45-49`).
- Phone plus booking-code lookup exists through backend callables.

Risks:
- `guestBookings/{bookingCode}` mirror is not the universal source of truth for every guest booking; some flows rely on `guestProfileId` on salon booking docs.
- Booking `customerId` semantics differ from the workspace schema: customer booking creation sets `customerId` to a salon-scoped CRM doc id, not always `users/{uid}` (`functions/src/customer/customerPortalCallables.ts:621`).
- Some legacy direct Firestore booking-create repository code still exists and is marked bypass/TODO.

### Salon setup

Positive:
- `createSalonForOwner` links user, salon, and first employee.
- The salon root includes public discovery fields such as `businessType`, rating fields, active/open flags, and location-related fields through models/functions.

Risks:
- Salon creation and first employee creation are not one single transaction; the code performs salon/user transaction first, then an employee batch with rollback on failure (`lib/features/salon/data/salon_repository.dart:49-164`).
- Owner employee id is the Firebase Auth uid (`lib/features/salon/data/salon_repository.dart:63-65`, `138-145`). This appears intentional but should stay consistent across staff rules and UI.

### App Check

Positive:
- Release provider selection uses Play Integrity on Android and DeviceCheck on Apple (`lib/core/firebase/firebase_bootstrap.dart:40-47`).
- Customer callables generally set `enforceAppCheck: true`.

Risks:
- App Check activation errors are swallowed and the app continues (`lib/core/firebase/firebase_bootstrap.dart:89-91`).
- Web release falls back to `WebDebugProvider` when no recaptcha key is provided (`lib/core/firebase/firebase_bootstrap.dart:65-70`).
- `staffLoginCallables` disables App Check (`functions/src/staffLoginCallables.ts:128-137`).

### Release configuration

Risks:
- iOS project has a named development provisioning profile in release settings (`ios/Runner.xcodeproj/project.pbxproj:738-741`).
- iOS permission descriptions for Contacts and Photo Library Add are empty (`ios/Runner/Info.plist:60-67`).
- Package metadata still says `name: barber_shop_app` and `description: "A new Flutter project."` (`pubspec.yaml:1-2`).
- Startup and feature code still contains unguarded `debugPrint` calls in production paths.

## Medium priority improvements

1. **Dependency hygiene**
   - `npm ci` reported 15 vulnerabilities: 1 low, 12 moderate, 2 high.
   - Node version mismatch: functions require Node 20, environment used Node v22.22.3.

2. **Storage rules**
   - `storage.rules:7-12`, `30-33`, and `49-52` validate auth, role, size, and content type.
   - They do not include App Check-specific enforcement in rules. Confirm Firebase App Check enforcement is enabled in the Firebase console for Storage.

3. **Firestore legacy surface**
   - Root `customers/{customerId}` match still exists in rules (`firestore.rules:1270-1283`) even though current Dart code mainly uses salon-scoped customers.
   - This should be removed or documented as legacy if unused.

4. **Data model documentation drift**
   - Workspace rules state no current `salons/{salonId}/customers` collection unless deliberately added later, but code has a salon-scoped CRM customer repository (`lib/core/firestore/firestore_paths.dart:89-90`).
   - User-provided checklist includes `salons/{salonId}/serviceCategories`, while current app uses `customerDiscovery/serviceCategories/items` for public category tiles and service `category` fields.

5. **Release hardening**
   - Android release config does not enable resource shrinking/minification.
   - No CI workflow was found during the audit.

## UI and theme inconsistencies

1. **Brand spec mismatch**
   - Workspace mandatory rule says teal plus calm neutrals.
   - Current code uses purple/lavender brand tokens:
     - `lib/core/theme/app_colors.dart:3-21`
     - `lib/core/theme/app_theme.dart:13-14`
   - Legacy gold exists at `lib/core/theme/app_colors.dart:170`.
   - Action: decide whether v1.0 is teal/mint or purple/lavender, then align code and rules.

2. **Theme is locked to light mode**
   - `lib/app.dart:146-147` uses `theme: AppTheme.data(locale)` and `themeMode: ThemeMode.light`.
   - Dark palette classes exist but are not wired for app-level theme mode.

3. **Hardcoded UI strings remain**
   - Owner booking filters: `lib/features/owner/presentation/screens/owner_bookings_screen.dart:103-123`.
   - Attendance admin screen: `lib/features/attendance_admin/presentation/screens/attendance_requests_admin_screen.dart:18-104`.
   - Barber photo errors: `lib/features/owner/presentation/screens/barber_details_screen.dart:279`, `291`.
   - Payslip PDF labels: `lib/features/payroll/presentation/services/payslip_pdf_exporter.dart:38-71`.
   - Reschedule stub: `lib/features/customer/presentation/screens/customer_booking_reschedule_screen.dart:20-23`.

4. **ARB parity gap**
   - `app_en.arb`: 3550 keys.
   - `app_ar.arb`: 3522 keys.
   - Missing Arabic keys: 28.
   - Sample missing keys: `customerCategoryBookNow`, `customerCategoryDistanceKmAway`, `customerCategoryFilterAvailableToday`, `ownerDiscoveryCategoryBeard`, `ownerDiscoveryCategoryCombo`, `ownerDiscoveryCategoryHaircut`.

5. **RTL and responsive risks**
   - There are many uses of `EdgeInsets.fromLTRB`, `Alignment.centerLeft`, and `Alignment.centerRight`.
   - Some newer widgets are RTL-aware, but coverage is inconsistent.
   - Small-device and Arabic visual QA still needs physical/emulator validation.

## Firebase, rules, and indexes

### Firestore structure

Observed:
- `users/{uid}` exists and is the user source.
- Salon-scoped paths are centralized in `lib/core/firestore/firestore_paths.dart`.
- Bookings are under `salons/{salonId}/bookings/{bookingId}` for app writes.
- Customer discovery uses `publicSalons`, `customerDiscovery`, `publicSpecialists`, and `customerSearchIndex`.
- Salon CRM customers exist under `salons/{salonId}/customers/{customerId}`.

Concerns:
- Current app intentionally extends beyond the minimal workspace schema with `guestProfiles`, `guestBookings`, `bookingCodes`, `publicSalons`, and `customerSearchIndex`.
- Keep schema docs, rules, and product expectations aligned before v1.0.

### Firestore rules

Positive:
- Default deny catch-all exists (`firestore.rules:1329-1330`).
- Collection-group booking reads are restricted to own guest booking (`firestore.rules:1323-1327`).
- Payroll writes are restricted to payroll permissions (`firestore.rules:990-1027`).
- Booking code docs deny client writes.

Blockers:
- Dev-only debug seed writes must be removed.
- `getCustomerBookingDetails` callable bypasses rules through Admin SDK and needs identity verification.

### Firestore indexes

Positive:
- `firestore.indexes.json` includes public discovery indexes for `publicSalons`.
- It includes collection-group booking indexes for `guestProfileId`, `guestUid`, `createdByAuthUid`, phone/code lookup, and public discovery/map fields.

Action:
- Validate all required indexes are built in Firebase before go-live. This environment could inspect the file but not confirm deployed build status.

## Release checklist

Required before v1.0:

- [ ] Remove Firestore `debugSeed` write/list allowances.
- [ ] Secure or remove `getCustomerBookingDetails` callable.
- [ ] Add and verify Firebase Crashlytics.
- [ ] Configure Android release signing.
- [ ] Configure iOS distribution signing/profiles.
- [ ] Fill or remove empty iOS permission strings.
- [ ] Remove/gate Debug Maps route.
- [ ] Replace customer reschedule placeholder with real flow or remove action.
- [ ] Remove/gate `agentSessionLog` from mobile release paths.
- [ ] Resolve theme direction: teal/mint per workspace rule or update rule/docs to purple.
- [ ] Fix missing Arabic ARB keys.
- [ ] Run Flutter analyzer/tests in a Flutter environment.
- [ ] Build Android APK and App Bundle release artifacts.
- [ ] Build iOS release/TestFlight artifact on macOS.
- [ ] Run Firestore rules emulator tests.
- [ ] Confirm App Check enforcement on Functions, Firestore, and Storage.
- [ ] Confirm Crashlytics receives a test crash from release/TestFlight.
- [ ] Confirm guest booking survives app close, sign-out, and continue-as-guest.
- [ ] Confirm no mock/demo/debug routes or data appear in production UI.

## Commands run

From `/workspace`:

```bash
flutter clean && flutter pub get && flutter analyze
```

Result: **failed** because Flutter is not installed in this environment.

```bash
firebase --version
```

Result: **failed** because Firebase CLI is not installed in this environment.

Firebase MCP security rules validation:

- `firebase_validate_security_rules` for Firestore: **not run** because Firebase MCP/CLI authentication is unavailable.
- `firebase_validate_security_rules` for Storage: **not run** because Firebase MCP/CLI authentication is unavailable.

From `/workspace/functions`:

```bash
npm ci && npm run build && npm test
```

Result:
- `npm ci`: passed with Node engine warning and vulnerability report.
- `npm run build`: passed.
- `npm test`: failed.
- Failure: `functions/test/customerSearchIndexGeo.test.ts` expects `serviceIndexGeoPayload`, but it is not exported by `functions/src/customerSearchIndex.ts`.

ARB parity check:

```bash
python3 - <<'PY'
import json
from pathlib import Path
for name in ['app_en.arb','app_ar.arb']:
    data=json.loads(Path('/workspace/lib/l10n/'+name).read_text())
    keys={k for k in data if not k.startswith('@')}
    print(name, len(keys))
en=json.loads(Path('/workspace/lib/l10n/app_en.arb').read_text())
ar=json.loads(Path('/workspace/lib/l10n/app_ar.arb').read_text())
en_keys={k for k in en if not k.startswith('@')}
ar_keys={k for k in ar if not k.startswith('@')}
print('missing_in_ar', len(en_keys-ar_keys))
print('missing_in_en', len(ar_keys-en_keys))
print('sample_missing_in_ar', sorted(en_keys-ar_keys)[:20])
PY
```

Result: 28 English keys missing from Arabic, 0 Arabic keys missing from English.

## Files changed

- `ZURANO_V1_READINESS_REPORT.md`

No application code was changed in this audit pass.

## Remaining risks

- Flutter analyzer, Flutter tests, Android release build, Android App Bundle build, and iOS release build were not executable in this machine because the Flutter SDK is missing.
- Firebase rules syntax validation and deployed index status could not be confirmed because Firebase CLI/MCP authentication was unavailable and `firebase` CLI is not installed.
- No screenshots/device runs were available, so UI overflow, Arabic rendering, keyboard behavior, and small-device behavior remain unverified.
- App Check production behavior must be tested on real signed Android/iOS builds, not just by reading provider selection code.
- Crashlytics cannot be considered ready until dependency, handlers, symbol upload, and test crash receipt are verified.

## Final recommendation

Do **not** launch Zurano v1.0 yet. Freeze new features and clear the critical blockers first. The safest v1.0 scope remains owner onboarding, salon setup, employees, services, guest booking, booking management, basic sales/POS, dashboard/revenue, real Firebase rules/indexes, App Check, Crashlytics, and verified Android/iOS release builds.
