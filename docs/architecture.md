# Architecture Guide

## Goal

Use a `feature-first` structure with a single composition root to keep code modular, readable, and ready for multiple integrations.

## Current Base Structure

```text
lib/
  app/
    app.dart
    bootstrap.dart
    di/
      app_dependencies.dart
  core/
    config/
    network/
    theme/
  features/
    auth/
      application/
      data/
      domain/
    client_cards/
      application/
      data/
      domain/
    home/
      application/
      presentation/
  integrations/
    deep_links/
  main.dart
```

## Rules

1. `app/` is the composition root.
2. `core/` only contains shared technical primitives (theme, network, config).
3. Every business capability lives in `features/<feature_name>/`.
4. `application/` contains use cases that orchestrate feature behavior.
5. External SDK/providers go in `integrations/` behind an abstraction.
6. UI (`presentation`) should depend on use cases/contracts, not data services or SDK packages directly.

## Dependency Direction

`presentation` -> `application` -> `data` -> `core/integrations`

`domain` is shared by `application` and `data` but must not depend on framework or SDK details.

## Current Use Cases (Implemented)

- `auth`: `ConsumeMagicLinkUseCase`
- `client_cards`: `GetMyCardsUseCase`
- `home`: `ActivateSessionFromMagicLinkUseCase` (orchestrates auth + cards loading)

## How To Add A New Feature

1. Create `lib/features/<feature_name>/`.
2. Add at least:
   - `application/` for use cases.
   - `domain/` for entities/contracts.
   - `data/` for API/service implementations.
   - `presentation/` for pages/controllers/widgets.
3. Register wiring in `lib/app/di/app_dependencies.dart`.

## How To Add A New Integration

1. Create an abstraction first (interface/contract) in the feature or integration boundary.
2. Implement provider adapter in `lib/integrations/<provider_name>/`.
3. Inject adapter from `app_dependencies.dart`.
4. Keep provider-specific code isolated inside `integrations/`.
