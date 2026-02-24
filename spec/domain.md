# Reglas de dominio cliente (MVP)

## Invariantes

- Un cliente puede tener múltiples memberships (una por empresa).
- `GET /client/me/cards` retorna una tarjeta por membership.
- `GET /client/me/ledger` retorna movimientos ordenados newest-first.
- Si se filtra por `membership_id`, debe pertenecer al cliente autenticado.
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
