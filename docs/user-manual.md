# User Manual

## Purpose

This manual explains the client-facing mobile flows included in `app-frex-v1` (`Puntos Cybac Mobile`).

This app is for loyalty program clients only. Company admins and staff use `web-frex-v1` (`Puntos Cybac Web`).

## Access flow

1. A company admin or staff user registers the client in the backend.
2. The backend issues a magic-link to the client email.
3. The client opens the link on a device with the app installed.
4. The app consumes the token and creates the local authenticated session.

## Main screens and actions

### Session entry

- accepts the deep link or token-driven magic-link flow
- exchanges the token for a client access token

### Home

- resolves the active session
- loads the initial client experience after authentication

### Cards

- shows one or more client loyalty cards
- exposes QR/card data for identification at store level

### Card detail rewards

- shows the rewards catalog returned by the backend for the selected card/company
- lives inside the card detail view next to ledger/history

### Profile

- shows client profile information
- exposes account-related actions such as terms navigation and account deletion

### Ledger/history

- shows the client points history returned by the backend

## Expected client journey

### 1. First access

- install or open the app
- open the received magic link
- allow the app to consume the token
- verify that the home/cards experience loads

### 2. Daily use

- open the app
- review current card and points status
- present QR/card at the business when needed
- review card detail rewards and history

### 3. Account deletion request

- open the profile or account management area
- submit the account deletion request
- confirm the result shown by the app/backend response

## Operating notes

- this app depends on backend availability and a valid API base URL
- the app does not create clients by itself
- session access depends on a valid, non-expired, non-consumed magic link
- terms and account deletion rely on backend URLs and endpoints

## Related documents

- [Project overview](./project-overview.md)
- [Scope of delivery](./scope-of-delivery.md)
- [Deployment guide](./deployment-guide.md)
- [Client API quick guide](../spec/client-api.md)
- Backend companion repo: `/README.md` in `web-frex-v1`
