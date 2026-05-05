# barber_shop_app

A new Flutter project.

## Collaborators and Cursor setup

For onboarding a new machine or Cursor account, read **[docs/CURSOR_HANDOFF.md](docs/CURSOR_HANDOFF.md)** (architecture, Firebase/Firestore rules, localization, and suggested prompts). A **full inventory of rules and skills** for copying to another account is in **[docs/CURSOR_RULES_AND_SKILLS_INDEX.md](docs/CURSOR_RULES_AND_SKILLS_INDEX.md)**. Project AI rules live under **`.cursor/rules/`**.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Push notifications (FCM)

Push is **on by default** (`ENABLE_PUSH_NOTIFICATIONS` defaults to true). Disable when you need to test without FCM:

```bash
flutter run --dart-define=ENABLE_PUSH_NOTIFICATIONS=false
```

Explicit enable (optional, same as default):

```bash
flutter run --dart-define=ENABLE_PUSH_NOTIFICATIONS=true
flutter build apk --dart-define=ENABLE_PUSH_NOTIFICATIONS=true
```

iOS also requires APNs configured in Firebase for device pushes.

When push is disabled via the define, the app does not request notification permission or register device tokens with Cloud Functions.

## Google Maps API key security

Google Maps keys must be restricted in Google Cloud and never committed as unrestricted secrets.

- Android key restrictions: `Android apps`, package `com.zurano.barbershop`, matching SHA-1 fingerprint(s), and `Maps SDK for Android` only.
- iOS key restrictions: `iOS apps`, bundle ID `com.zurano.barbershop`, and `Maps SDK for iOS` only.
# ZuranoV1.0
