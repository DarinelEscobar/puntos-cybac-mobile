# Auth cliente (MVP)

## Método de autenticación

- Flujo inicial: `POST /api/v1/auth/client/magic-links/consume`
- Sesión posterior: `Authorization: Bearer <access_token>`
- Endpoints protegidos:
  - `GET /api/v1/client/me/profile`
  - `GET /api/v1/client/me/cards`
  - `GET /api/v1/client/me/rewards`
  - `GET /api/v1/client/me/ledger/latest`

## Flujo recomendado para mobile

1. Cliente recibe magic-link por email.
2. La app extrae `token` (deep link o captura manual).
3. La app consume `POST /api/v1/auth/client/magic-links/consume`.
4. Guardar `access_token` en secure storage.
5. Consumir endpoints `client/me/*` con bearer token.

## Reglas de magic-link

- Validez: 24 horas.
- Uso: único (single-use).
- Errores esperados:
  - `400 MAGIC_LINK_INVALID_FORMAT`
  - `409 MAGIC_LINK_ALREADY_CONSUMED`
  - `410 MAGIC_LINK_EXPIRED`

## Expiración de sesión

Cuando la API retorne `401 CLIENT_UNAUTHENTICATED`:

1. Limpiar token local.
2. Redirigir a flujo de magic-link.
