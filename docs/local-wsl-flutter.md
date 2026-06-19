# Local WSL Flutter Runbook for `app-frex-v1` (`Puntos Cybac Mobile`)

This project is different from the Laravel repos.

The source code can stay in WSL for fast file access, but the Flutter and Android toolchain may still run from Windows if your SDKs are installed there.

- Repo name: `app-frex-v1`
- Windows/WSL path depends on where the repo is checked out.

## Special rule for this repo

For Laravel repos, the preferred flow is usually "run everything from WSL".

For this Flutter repo, use this split:

- WSL is good for Git, search, editing, and general code work
- Windows PowerShell is usually the correct place for `flutter run` when Flutter SDK and Android SDK are installed in `C:\...`

This repository already documents Windows-based emulator usage in:

- [emulator-setup.md](/docs/emulator-setup.md)

## Current local notes

- `pubspec.yaml` exists
- `.env.example` exists as a reference for `--dart-define` values
- the project uses `API_BASE_URL` and `TERMS_URL` through `--dart-define`

## Open the project

### Option 1: open from WSL in VS Code

```bash
wsl -d Ubuntu-24.04
cd ~/projects/app-frex-v1
code .
```

### Option 2: open from Windows

Open this folder:

```text
\\wsl$\Ubuntu-24.04\home\cybac\projects\app-frex-v1
```

This option is useful when your Flutter SDK, Android SDK, emulator, and device tooling are all installed on Windows.

## First-time setup

Use `.env.example` only as a reference. Pass the values explicitly with `--dart-define`:

- `API_BASE_URL`
- `TERMS_URL`

## Preferred run flow on Windows

Open PowerShell in:

```text
\\wsl$\Ubuntu-24.04\home\cybac\projects\app-frex-v1
```

Install packages:

```powershell
flutter pub get
```

Run with explicit environment values:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-api/api/v1 --dart-define=TERMS_URL=https://your-site/terms
```

## Emulator and device notes

This repo already assumes a Windows-based Android setup:

- Flutter SDK in `C:\src\flutter`
- Android SDK in `C:\Android`

If you use the documented emulator flow, follow:

- [emulator-setup.md](/docs/emulator-setup.md)

## Useful checks

```powershell
flutter --version
flutter doctor
flutter devices
flutter analyze
flutter test
```

## If something fails

### Flutter command is not found

Check that Windows has:

- `C:\src\flutter\bin` in `PATH`
- `C:\Android\platform-tools` in `PATH`

### App runs but cannot reach backend

Check your `--dart-define` values:

- `API_BASE_URL`
- `TERMS_URL`

### You want a pure WSL Flutter flow

Only do that if Flutter SDK, Android tooling, and connected devices are already configured inside WSL. If not, keep using Windows PowerShell for `flutter run`.

## Why this setup is different

Laravel repos benefit from moving both source and runtime into WSL.

Flutter mobile projects often depend on Windows-installed SDKs, Android emulators, ADB, and device tooling, so the fastest stable workflow is often:

- source in WSL
- Flutter run/build from Windows
