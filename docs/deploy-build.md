# Build and Deploy Guide

This document explains what is required to build distributable artifacts for Android and iOS, which files matter for deployment, and what must be configured before publishing.

## Scope

This repository produces the mobile client binaries only:

- Android APK
- Android App Bundle (`.aab`)
- iOS app archive / IPA

This repository does not contain backend deployment, server infrastructure, or store credentials.

## Common requirements

- Flutter SDK installed
- Dart SDK compatible with `>=3.10.0 <4.0.0`
- `flutter doctor` without blocking issues
- project dependencies installed with:

```bash
flutter pub get
```

- local `.env` created from `.env.example` when you want to run helper scripts

Required runtime values:

- `API_BASE_URL`
- `TERMS_URL`

Example:

```env
API_BASE_URL=https://puntos-cybac.vercel.app/api/v1
TERMS_URL=https://puntos-cybac.vercel.app/terms
```

For release builds, `API_BASE_URL` should use `https://`.

## Files and secrets required for deployment

These are the main inputs a release build may need outside normal source code:

- `.env` or explicit `--dart-define` values for `API_BASE_URL` and `TERMS_URL`
- Android release keystore file for Play Store builds
- Android keystore passwords and key alias
- Apple signing team, certificates, and provisioning access for iOS

Do not commit production signing secrets to the repository.

## Android requirements

- Java 17
- Android SDK
- Android platform tools / ADB
- Gradle wrapper included in the repo
- release keystore for production publishing

Current Android configuration in this repo:

- `applicationId`: `com.cybac.puntos`
- signing for `release` currently uses the debug keystore
- this is acceptable for local `--release` testing, but not for Google Play publishing

Relevant files:

- [android/app/build.gradle.kts](/home/cybac/projects/puntos-cybac-mobile/android/app/build.gradle.kts)
- [android/build.gradle.kts](/home/cybac/projects/puntos-cybac-mobile/android/build.gradle.kts)
- [android/gradle.properties](/home/cybac/projects/puntos-cybac-mobile/android/gradle.properties)
- [android/app/src/main/AndroidManifest.xml](/home/cybac/projects/puntos-cybac-mobile/android/app/src/main/AndroidManifest.xml)

## iOS requirements

- macOS
- Xcode
- CocoaPods
- Apple Developer account
- signing team / provisioning configured in Xcode for distribution

Current iOS configuration in this repo:

- bundle identifier: `com.cybac.puntos`
- deployment target: `iOS 13.0`
- code signing style: automatic

Relevant files:

- [ios/Runner.xcodeproj/project.pbxproj](/home/cybac/projects/puntos-cybac-mobile/ios/Runner.xcodeproj/project.pbxproj)
- [ios/Runner/Info.plist](/home/cybac/projects/puntos-cybac-mobile/ios/Runner/Info.plist)
- [ios/Flutter/Release.xcconfig](/home/cybac/projects/puntos-cybac-mobile/ios/Flutter/Release.xcconfig)

## Pre-build checks

Run these before generating release artifacts:

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
```

If you want an explicit clean build:

```bash
flutter clean
flutter pub get
```

## Android build outputs

## 1. Build a release APK

Use this when you need a directly installable Android package for QA or manual distribution.

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-api/api/v1 \
  --dart-define=TERMS_URL=https://your-site/terms
```

Expected output:

- `build/app/outputs/flutter-apk/app-release.apk`

## 2. Build a release App Bundle

Use this for Google Play submission.

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-api/api/v1 \
  --dart-define=TERMS_URL=https://your-site/terms
```

Expected output:

- `build/app/outputs/bundle/release/app-release.aab`

## Android signing setup required for production

Before publishing to Google Play, replace the current debug signing with a real release keystore.

What is typically required:

- a `.jks` or `.keystore` file
- keystore password
- key alias
- key password
- secure storage for those secrets

Typical files involved:

- `android/app/build.gradle.kts`
- optional `key.properties` kept outside version control

Minimum expected implementation:

1. Create or obtain the production keystore.
2. Store passwords outside the repo.
3. Load those values in Gradle.
4. Point the `release` build type to the real signing config.
5. Verify the signed artifact before upload.

Important:

- do not commit production keystores
- do not commit plaintext signing secrets
- do not publish the current debug-signed release to Play Store

## iOS build outputs

## 1. Build the iOS release app

This compiles the iOS release app for device deployment and Xcode archive flows.

```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://your-api/api/v1 \
  --dart-define=TERMS_URL=https://your-site/terms
```

Typical output location:

- `build/ios/iphoneos/Runner.app`

## 2. Build an IPA

Use this when you want Flutter to produce an archive/export flow for distribution.

```bash
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://your-api/api/v1 \
  --dart-define=TERMS_URL=https://your-site/terms
```

Typical output location:

- `build/ios/ipa/*.ipa`

Depending on your signing/export setup, you may still need to open Xcode and validate archive/export settings.

## iOS signing setup required for production

Before App Store or TestFlight distribution, confirm:

- correct Apple Developer team selected
- bundle identifier registered in Apple Developer
- signing certificate available
- provisioning profile resolved by Xcode
- archive/export succeeds in Xcode

Recommended verification flow:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` target.
3. Confirm Signing & Capabilities for the release configuration.
4. Confirm bundle identifier and team.
5. Run Product > Archive.
6. Validate and export through Organizer if needed.

## Deployment checklist

Before handing a build to QA or publishing:

1. Confirm `API_BASE_URL` points to the correct environment.
2. Confirm `TERMS_URL` points to the correct legal page.
3. Confirm app version and build number are correct.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Build the target artifact (`apk`, `aab`, or `ipa`).
7. Verify signing is production-ready.
8. Smoke test the artifact on a real device when possible.

## Versioning

Current project version source:

- [pubspec.yaml](/home/cybac/projects/puntos-cybac-mobile/pubspec.yaml)

Current value:

- `version: 1.0.0+1`

You can override at build time if needed:

```bash
flutter build appbundle --release \
  --build-name=1.0.1 \
  --build-number=2 \
  --dart-define=API_BASE_URL=https://your-api/api/v1 \
  --dart-define=TERMS_URL=https://your-site/terms
```

The same `--build-name` and `--build-number` pattern applies to iOS builds.

## Local helper scripts and related docs

- [README.md](/home/cybac/projects/puntos-cybac-mobile/README.md)
- [docs/local-wsl-flutter.md](/home/cybac/projects/puntos-cybac-mobile/docs/local-wsl-flutter.md)
- [docs/emulator-setup.md](/home/cybac/projects/puntos-cybac-mobile/docs/emulator-setup.md)
- [run_wireless.ps1](/home/cybac/projects/puntos-cybac-mobile/run_wireless.ps1)

## Current gaps to resolve before store deployment

- Android release signing is still using the debug key
- iOS distribution depends on local Apple signing/team setup outside this repo
- store metadata, screenshots, privacy declarations, and release notes are not managed here
