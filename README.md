# puntos_cybac_mobile

Flutter app for Puntos Cybac client mobile experience.

## Project Architecture

- `docs/architecture.md` (folder structure + modularity rules)

## API Contract (Source of Truth)

Client API documentation lives in:

- `spec/openapi.yaml` (canonical API contract)
- `spec/auth.md`
- `spec/errors.md`
- `spec/domain.md`
- `spec/examples/*.json`

Quick Flutter guide:

- `spec/client-api.md`

## Client Mobile MVP - Implementation Status

### Screen Map
1. **MagicLinkEntry** (`Screen 4`): Initial authentication screen.
   - Route: `/` (initial if no session)
   - Features: Token input, error handling (`400`, `409`, `410`).
2. **SessionBootstrap** (`Screen 1`): Splash and session validation.
   - Route: `/bootstrap` (internal)
   - Features: Checks token, loads profile/cards, redirects to Main or Login.
3. **HomeCards** (`Screen 5`): Main dashboard (Tab 1).
   - Route: `/main` -> Tab 0
   - Features: List of active cards, "Add Card" placeholder.
4. **CardDetail** (`Screen 3` + `Screen 2`): Detailed view.
   - Route: `/card-detail`
   - Features: Flip animation (Front/QR), section switch `Historial | Rewards` by selected card.
5. **Profile** (`Screen 6`): User profile (Tab 2).
   - Route: `/main` -> Tab 1
   - Features: User info, active cards count, Logout.

### Endpoint Mapping
- `POST /auth/client/magic-links/consume`: `ConsumeMagicLinkUseCase`
- `GET /client/me/profile`: `GetProfileUseCase` -> `ClientRepository`
- `GET /client/me/cards`: `GetMyCardsUseCase` -> `ClientCardsService`
- `GET /client/me/ledger`: `GetClientLedgerUseCase` -> `ClientCardsService`
- `GET /client/me/rewards`: `GetClientRewardsUseCase` -> `ClientCardsService`

### Known Backend Gaps / Assumptions
- QR rendering is generated locally on-device from `qr_payload` using `qr_flutter` (no third-party QR API calls).
- "Add Card" feature is mocked with a Snackbar.
- Branding colors fallback to defaults if parsing fails.
- `flutter_secure_storage` is used for token persistence.
