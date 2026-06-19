# Scope of Delivery

## Delivery objective

This repository delivers `app-frex-v1` (`Puntos Cybac Mobile`).

Its responsibility is to provide the loyalty client experience on mobile devices while consuming the API exposed by the backend repository.

## Included in this mobile MVP

### Client access

- deep-link based magic-link entry
- token consumption against `/api/v1/auth/client/magic-links/consume`
- persistent authenticated client session on device

### Client experience

- profile retrieval
- loyalty cards retrieval
- QR/card display for store identification
- rewards retrieval inside card detail
- ledger/history retrieval
- account deletion request flow

### Mobile technical delivery

- Flutter source code
- Android and iOS project runners
- environment configuration via `--dart-define`
- build and release guidance
- API contract references and sample payloads

## Explicitly out of scope

- backend business logic
- database ownership
- company admin dashboards
- staff operational screens
- payment/subscription management
- backend hosting and server deployment
- app store publishing accounts and business-side release assets

## Delivery assumptions

- the backend API is provided by `web-frex-v1` (`Puntos Cybac Web`)
- the mobile app consumes the `/api/v1` contract documented in `spec/`
- the client must already exist in the backend before mobile access works
- magic-link emails are issued by backend/company operations, not by the app itself

## Acceptance reference

The mobile delivery should be considered functional when:

- the app can be configured with a valid `API_BASE_URL`
- a client can enter through a valid magic link
- the app stores the session securely
- the app can load profile, cards, card detail rewards, and ledger data
- the app can open the terms URL and submit account deletion requests

## Related documents

- [Project overview](./project-overview.md)
- [Deployment guide](./deployment-guide.md)
- [User manual](./user-manual.md)
- [Client API quick guide](../spec/client-api.md)
- Backend companion repo: `/README.md` in `web-frex-v1`
