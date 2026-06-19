# Project Overview

## Purpose

`app-frex-v1` (`Puntos Cybac Mobile`) is the Flutter mobile client for the MVP.

This repository covers the end-user mobile experience for loyalty program clients. It is the companion application to `web-frex-v1` (`Puntos Cybac Web`).

## What this app does

The mobile app allows a registered client to:

- access the app through a magic-link login flow
- keep a client session on the device
- view profile information
- view one or more digital loyalty cards
- display QR/card information for in-store identification
- review points ledger history
- review available rewards inside each card detail
- request account deletion through the API flow

## Relationship to the MVP

The full MVP is split across two repositories:

- `web-frex-v1` (`Puntos Cybac Web`)
  - Laravel backend
  - admin/company web UI
  - database, business rules, and API
- `app-frex-v1` (`Puntos Cybac Mobile`)
  - Flutter mobile app for loyalty clients

This repo does not contain:

- PHP backend code
- database schema or migrations
- web admin modules
- deployment logic for the backend server

## Technology summary

- Flutter
- Dart `>=3.10.0 <4.0.0`
- HTTP API integration
- secure token storage
- app deep links for magic-link activation

Main packages used by the app:

- `http`
- `app_links`
- `flutter_secure_storage`
- `intl`
- `qr_flutter`
- `url_launcher`

## Main functional areas

The current app structure is feature-first and includes:

- `auth`
- `home`
- `client_cards`
- `profile`
- `rewards` support inside card detail

## Related documents

- [Scope of delivery](./scope-of-delivery.md)
- [Deployment guide](./deployment-guide.md)
- [User manual](./user-manual.md)
- [Architecture guide](./architecture.md)
- [Mobile API spec overview](../spec/README.md)
- Backend companion repo: `/README.md` in `web-frex-v1`
