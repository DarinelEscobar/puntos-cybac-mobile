# Repository Guidelines

## Project Structure & Module Organization
- App bootstrap and dependency wiring live in `lib/app/` (`app.dart`, `bootstrap.dart`, `di/app_dependencies.dart`).
- Shared technical primitives live in `lib/core/` (`config`, `network`, `theme`, shared widgets/services).
- Product features follow `feature-first` structure under `lib/features/<feature_name>/` with `application`, `data`, `domain`, and `presentation` layers when needed.
- External platform integrations stay isolated in `lib/integrations/`.
- Architecture notes and guardrails live in `docs/architecture.md`.
- API contracts and examples live in `spec/`.

## Build, Test, and Development Commands
- `flutter pub get` - install Dart and Flutter dependencies.
- `flutter run` - run the app locally.
- `flutter test` - run the test suite.
- `flutter analyze` - run static analysis.
- `.\run_wireless.ps1` - start with `.env`-driven `--dart-define` values on Windows PowerShell.

## Coding Style & Architecture Rules
- Keep widgets focused on rendering and user interaction.
- Put orchestration in `application/` use cases and keep provider/API details in `data/` or `integrations/`.
- Register new dependencies in `lib/app/di/app_dependencies.dart`.
- Preserve dependency direction: `presentation -> application -> data`, with `domain` free from framework details.

## Testing Guidelines
- Put UI and behavior flows under `test/features/...`.
- Put app wiring and shared helpers under `test/app/...` and `test/core/...`.
- Run `flutter analyze` and `flutter test` before merging mobile changes.

## CodeGraph Workflow
- Use CodeGraph first for structural questions: symbol lookup, callers/callees, feature wiring, and impact analysis.
- Use regular file reads/search only for literal text, UX copy, comments, or once you already know which file to inspect.
- This repo keeps its local index in `.codegraph/`. Treat it as local machine state and do not commit it.
- One-time machine install:
  - `npx -y @colbymchenry/codegraph install -y --location global --target auto`
- Repo bootstrap:
  - `cd C:\Users\Cybac\Documents\New_folder\puntos-cybac-mobile`
  - `npx -y @colbymchenry/codegraph init -i`
- Daily commands:
  - `npx -y @colbymchenry/codegraph status`
  - `npx -y @colbymchenry/codegraph query "HomeController"`
  - `npx -y @colbymchenry/codegraph context "trace magic link login flow"`
  - `npx -y @colbymchenry/codegraph sync`
- Recommended edit flow:
  1. Run `status`.
  2. Query the feature or page you are about to change.
  3. Inspect related use cases, services, and models before editing shared flows.
  4. Make the code change.
  5. Run `sync` if several files changed, then re-query if you need updated context.
- Useful repo-specific searches:
  - `npx -y @colbymchenry/codegraph query "ConsumeMagicLinkUseCase"`
  - `npx -y @colbymchenry/codegraph query "HomeController"`
  - `npx -y @colbymchenry/codegraph query "ClientCardsService"`
  - `npx -y @colbymchenry/codegraph context "follow app bootstrap and dependency wiring"`
- If the index is missing or stale, re-run `init -i` or `sync` and continue with manual inspection only if needed.
