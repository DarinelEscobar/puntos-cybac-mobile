# Spec Cliente Mobile (MVP)

Este folder contiene solo documentación relevante para la app mobile de **clientes**.

## Source of Truth

Estos archivos son la fuente de verdad para el contrato API de cliente móvil:

- `openapi.yaml`: contrato API canónico.
- `auth.md`: reglas de autenticación/sesión cliente.
- `errors.md`: códigos de error y manejo esperado.
- `domain.md`: reglas de dominio e invariantes.
- `examples/*.json`: ejemplos canónicos de request/response.

`client-api.md` se mantiene como guía rápida para desarrollo Flutter; si hay conflicto, manda `openapi.yaml`.

## Endpoints incluidos

- `POST /api/v1/auth/client/magic-links/consume`
- `GET /api/v1/client/me/profile`
- `GET /api/v1/client/me/cards`
- `GET /api/v1/client/me/rewards`
- `GET /api/v1/client/me/ledger`

## Archivos

- `openapi.yaml`: contrato OpenAPI enfocado en cliente móvil.
- `client-api.md`: guía rápida para Flutter con ejemplos de consumo.
- `auth.md`: flujo de autenticación por magic-link + bearer token.
- `errors.md`: errores estándar para cliente.
- `domain.md`: reglas de dominio/invariantes de cliente.
- `examples/`: payloads JSON listos para pruebas en Flutter.
