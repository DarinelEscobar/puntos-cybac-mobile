# Project Overview

## Purpose

`puntos-cybac-mobile` is the Flutter mobile client for the Puntos Cybac MVP.

This repository covers the end-user mobile experience for loyalty program clients. It is the companion application to the Laravel backend and admin platform in `../puntos-cybac`.

## What this app does

The mobile app allows a registered client to:

- access the app through a magic-link login flow
- keep a client session on the device
- view profile information
- view one or more digital loyalty cards
- display QR/card information for in-store identification
- review points ledger history
- review available rewards
- request account deletion through the API flow

## Relationship to the MVP

The full MVP is split across two repositories:

- `../puntos-cybac`
  - Laravel backend
  - admin/company web UI
  - database, business rules, and API
- `../puntos-cybac-mobile`
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
- `rewards`

## Related documents

- [Scope of delivery](./scope-of-delivery.md)
- [Deployment guide](./deployment-guide.md)
- [User manual](./user-manual.md)
- [Architecture guide](./architecture.md)
- [Mobile API spec overview](../spec/README.md)
- [Backend companion repo](../../puntos-cybac/README.md)
