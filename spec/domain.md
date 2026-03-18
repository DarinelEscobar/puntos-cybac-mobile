# Reglas de dominio cliente (MVP)

## Invariantes

- Un cliente puede tener múltiples memberships (una por empresa).
- `GET /client/me/cards` retorna una tarjeta por membership.
- `GET /client/me/rewards` retorna rewards activas solo de la company asociada a una membership.
- `GET /client/me/ledger/latest` retorna solo ultimos movimientos esenciales de una tarjeta.
- `membership_id` es obligatorio y debe pertenecer al cliente autenticado.
- La sesión de cliente se crea solo consumiendo magic-link válido.

## Datos clave para UI mobile

- `cards[].branding` se usa para tematizar cada tarjeta en la app.
- `cards[].qr_payload` se muestra en reverso de tarjeta (QR).
- `cards[].points_balance` es el saldo visible principal.
- `profile.client_identity` alimenta pantalla de perfil.

## Fuera de alcance MVP cliente

- CRUD de clientes.
- Operaciones de caja (`earn`, `redeem`, `adjust`, `reverse`).
- Módulos administrativos (super admin, admin company, staff).
