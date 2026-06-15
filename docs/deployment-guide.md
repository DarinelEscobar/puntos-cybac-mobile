# Deployment Guide

## Purpose

This guide explains how to prepare, configure, build, and deliver the Flutter mobile app for the Puntos Cybac MVP.

For backend/server deployment, use the companion repository `../puntos-cybac`.

## Requirements

- Flutter SDK installed
- Dart SDK compatible with `>=3.10.0 <4.0.0`
- `flutter doctor` without blocking issues

Platform-specific requirements:

- Android: Java 17, Android SDK, ADB, emulator or device
- iOS: macOS, Xcode, CocoaPods, valid Apple signing setup

## Environment configuration

1. Copy `.env.example` to `.env`.
2. Define:
   - `API_BASE_URL`
   - `TERMS_URL`

Example:

```env
API_BASE_URL=https://your-backend.example/api/v1
TERMS_URL=https://your-backend.example/terms
```

Important:

- release builds should use `https://`
- the API base URL must point to the backend app in `../puntos-cybac`

## Install dependencies

```bash
flutter pub get
```

## Local run

Manual example:

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.example/api/v1 --dart-define=TERMS_URL=https://your-backend.example/terms
```

Windows PowerShell helper:

```powershell
.\run_wireless.ps1
```

## Validation commands

```bash
flutter doctor
flutter analyze
flutter test
```

## Build outputs

### Android APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend.example/api/v1 --dart-define=TERMS_URL=https://your-backend.example/terms
```

### Android App Bundle

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-backend.example/api/v1 --dart-define=TERMS_URL=https://your-backend.example/terms
```

### iOS

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://your-backend.example/api/v1 --dart-define=TERMS_URL=https://your-backend.example/terms
flutter build ipa --release --dart-define=API_BASE_URL=https://your-backend.example/api/v1 --dart-define=TERMS_URL=https://your-backend.example/terms
```

## Delivery checks

- the app launches successfully
- deep links are configured and open the app
- magic-link authentication works against the target backend
- cards, profile, rewards, and ledger load correctly
- logout/session recovery behaves as expected
- terms link opens the correct environment URL

## Reference documents

- [Project overview](./project-overview.md)
- [Scope of delivery](./scope-of-delivery.md)
- [User manual](./user-manual.md)
- [Build and release guide](./deploy-build.md)
- [Backend deployment guide](../../puntos-cybac/docs/deployment-guide.md)
