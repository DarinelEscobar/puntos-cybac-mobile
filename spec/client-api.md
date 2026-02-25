# Client API (MVP) - Flutter Guide

Esta guía resume el contrato cliente para implementar la app móvil Flutter sin depender de Swagger.

## Base URL y ambientes

- Base path versionado: `/api/v1`
- URL final por ambiente:
  - Local: `http://localhost/api/v1`
  - Staging/Prod: `https://<tu-dominio>/api/v1`
- Endpoints de cliente (MVP):
  - `POST /auth/client/magic-links/consume`
  - `GET /client/me/profile`
  - `GET /client/me/cards`
  - `GET /client/me/rewards`
  - `GET /client/me/ledger`

## Autenticación (MVP)

Método elegido: **Bearer token**.

Flujo:
1. El cliente recibe magic-link por email.
2. Flutter extrae el `token` del link.
3. Flutter consume `POST /auth/client/magic-links/consume`.
4. API responde `access_token`; guardar en almacenamiento seguro (ej. `flutter_secure_storage`).
5. En llamadas protegidas enviar `Authorization: Bearer <access_token>`.

Reglas del magic-link:
- Expira en **24 horas**.
- Es **single-use**.
- Errores esperados: `400`, `409`, `410`.

## Headers

Público (`POST /auth/client/magic-links/consume`):

```http
Content-Type: application/json
Accept: application/json
```

Privado (todos los `GET /client/me/*`):

```http
Authorization: Bearer <access_token>
Accept: application/json
```

## Endpoints y ejemplos

### 1) Consume magic-link

`POST /auth/client/magic-links/consume`

Request:

```json
{
  "token": "mlk_01JT7TQ3M2C8M4VQSKY9F1AJ9P",
  "device_name": "flutter-android"
}
```

Response `200`:

```json
{
  "status": "success",
  "message": "Client session created.",
  "data": {
    "access_token": "<SECRET>",
    "token_type": "Bearer",
    "profile": {
      "client_identity": {
        "id": "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee",
        "full_name": "Jane Client",
        "email": "jane.client@test.com",
        "phone": "+5215550000000"
      },
      "memberships": [
        {
          "membership": {
            "id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
            "company_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
            "client_identity_id": "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee",
            "status": "ACTIVE",
            "card_uid": "CARD-0001",
            "points_balance_cached": 480,
            "created_at": "2026-02-14T12:00:00Z"
          },
          "client_identity": {
            "id": "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee",
            "full_name": "Jane Client",
            "email": "jane.client@test.com",
            "phone": "+5215550000000",
            "created_at": "2026-02-10T10:00:00Z"
          }
        }
      ]
    },
    "cards": [
      {
        "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
        "company_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
        "company_name": "Glow Clinic",
        "card_uid": "CARD-0001",
        "status": "ACTIVE",
        "qr_payload": "CARD-0001",
        "points_balance": 480,
        "branding": {
          "logo_url": "https://cdn.example.com/glow/logo.png",
          "color_primary": "#0A2540",
          "color_secondary": "#5B7FFF",
          "color_accent": "#F9C846"
        }
      }
    ]
  },
  "meta": {
    "timestamp": "2026-02-16T10:20:00Z",
    "path": "api/v1/auth/client/magic-links/consume",
    "version": "v1"
  }
}
```

Errores (`error envelope` estándar):

`400` token inválido:

```json
{
  "error": {
    "code": "MAGIC_LINK_INVALID_FORMAT",
    "message": "Magic-link token format is invalid.",
    "details": {
      "token": "malformed"
    }
  }
}
```

`409` token ya consumido:

```json
{
  "error": {
    "code": "MAGIC_LINK_ALREADY_CONSUMED",
    "message": "Magic-link token was already consumed.",
    "details": {
      "consumed_at": "2026-02-16T09:55:00Z"
    }
  }
}
```

`410` token expirado:

```json
{
  "error": {
    "code": "MAGIC_LINK_EXPIRED",
    "message": "Magic-link token expired.",
    "details": {
      "expired_at": "2026-02-16T08:00:00Z"
    }
  }
}
```

### 2) Perfil del cliente

`GET /client/me/profile`

Response `200`:

```json
{
  "status": "success",
  "message": "Client profile fetched.",
  "data": {
    "client_identity": {
      "id": "eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee",
      "full_name": "Jane Client",
      "email": "jane.client@test.com",
      "phone": "+5215550000000",
      "created_at": "2026-02-10T10:00:00Z"
    },
    "memberships": []
  },
  "meta": {
    "timestamp": "2026-02-16T10:22:00Z",
    "path": "api/v1/client/me/profile",
    "version": "v1"
  }
}
```

### 3) Tarjetas del cliente (con branding embebido)

`GET /client/me/cards`

Response `200`:

```json
{
  "status": "success",
  "message": "Client cards fetched.",
  "data": [
    {
      "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
      "company_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
      "company_name": "Glow Clinic",
      "card_uid": "CARD-0001",
      "status": "ACTIVE",
      "qr_payload": "CARD-0001",
      "points_balance": 480,
      "branding": {
        "logo_url": "https://cdn.example.com/glow/logo.png",
        "color_primary": "#0A2540",
        "color_secondary": "#5B7FFF",
        "color_accent": "#F9C846"
      }
    }
  ],
  "meta": {
    "timestamp": "2026-02-16T10:22:30Z",
    "path": "api/v1/client/me/cards",
    "version": "v1"
  }
}
```

> Decisión MVP: `branding` va embebido en cada card. No hay endpoint extra de branding para cliente.

### 4) Rewards por tarjeta (por company de la membership)

`GET /client/me/rewards?membership_id=ffffffff-ffff-4fff-8fff-ffffffffffff`

Response `200`:

```json
{
  "status": "success",
  "message": "Client rewards fetched.",
  "data": {
    "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
    "rewards": [
      {
        "id": "dddddddd-dddd-4ddd-8ddd-dddddddddddd",
        "company_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
        "name": "Cafe gratis",
        "type": "FIXED_REWARD",
        "points_cost": 80,
        "is_active": true,
        "created_at": "2026-02-16T10:20:00Z"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-02-16T10:24:00Z",
    "path": "api/v1/client/me/rewards?membership_id=ffffffff-ffff-4fff-8fff-ffffffffffff",
    "version": "v1"
  }
}
```

Si `membership_id` es inválido o no viene:

```json
{
  "error": {
    "code": "INVALID_QUERY_PARAMS",
    "message": "Query parameters are invalid.",
    "details": {
      "membership_id": "invalid"
    }
  }
}
```

### 5) Ledger filtrado por membresía

`GET /client/me/ledger?membership_id=ffffffff-ffff-4fff-8fff-ffffffffffff&page=1&per_page=25`

Response `200` (ordenado newest first):

```json
{
  "status": "success",
  "message": "Client ledger fetched.",
  "data": [
    {
      "id": "3b9f5d26-4b12-4a78-bd50-92c9ca611111",
      "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
      "actor_user_id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc",
      "type": "EARN",
      "points_delta": 30,
      "purchase_amount_mxn": 450,
      "reward_id": null,
      "note": "Ticket #A-120",
      "related_entry_id": null,
      "created_at": "2026-02-16T09:30:00Z"
    }
  ],
  "meta": {
    "timestamp": "2026-02-16T10:23:00Z",
    "path": "api/v1/client/me/ledger?membership_id=ffffffff-ffff-4fff-8fff-ffffffffffff&page=1&per_page=25",
    "version": "v1",
    "pagination": {
      "total": 2,
      "count": 1,
      "per_page": 25,
      "current_page": 1,
      "total_pages": 1
    }
  }
}
```

Si `membership_id` no pertenece al cliente autenticado:

```json
{
  "error": {
    "code": "MEMBERSHIP_NOT_OWNED",
    "message": "The selected membership does not belong to the authenticated client.",
    "details": {
      "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff"
    }
  }
}
```

### 6) Ledger combinado (sin filtro)

`GET /client/me/ledger?page=1&per_page=25`

Response `200` (combina todas las memberships, newest first):

```json
{
  "status": "success",
  "message": "Client ledger fetched.",
  "data": [
    {
      "id": "3b9f5d26-4b12-4a78-bd50-92c9ca611111",
      "membership_id": "ffffffff-ffff-4fff-8fff-ffffffffffff",
      "actor_user_id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc",
      "type": "EARN",
      "points_delta": 30,
      "purchase_amount_mxn": 450,
      "reward_id": null,
      "note": "Ticket #A-120",
      "related_entry_id": null,
      "created_at": "2026-02-16T09:30:00Z"
    },
    {
      "id": "32196ac2-244a-4487-b4be-4f2013333333",
      "membership_id": "11111111-1111-4111-8111-111111111111",
      "actor_user_id": "cccccccc-cccc-4ccc-8ccc-cccccccccccc",
      "type": "EARN",
      "points_delta": 15,
      "purchase_amount_mxn": 220,
      "reward_id": null,
      "note": "Ticket #B-905",
      "related_entry_id": null,
      "created_at": "2026-02-16T08:50:00Z"
    }
  ],
  "meta": {
    "timestamp": "2026-02-16T10:23:30Z",
    "path": "api/v1/client/me/ledger?page=1&per_page=25",
    "version": "v1",
    "pagination": {
      "total": 14,
      "count": 2,
      "per_page": 25,
      "current_page": 1,
      "total_pages": 1
    }
  }
}
```

## Notas UX para Flutter

### Branding en Card UI

- Usar `branding.logo_url` como logo del negocio en cada tarjeta.
- Usar `color_primary`, `color_secondary`, `color_accent` para temas visuales de cada card.
- Definir fallback local si alguna propiedad viene `null`.

### Manejo de errores (`error.code` -> UX message)

- `CLIENT_UNAUTHENTICATED`: “Tu sesión expiró. Inicia sesión de nuevo.”
- `MEMBERSHIP_NOT_OWNED`: “No tienes acceso a esa tarjeta.”
- `MAGIC_LINK_INVALID_FORMAT`: “El enlace no es válido.”
- `MAGIC_LINK_ALREADY_CONSUMED`: “Este enlace ya fue usado.”
- `MAGIC_LINK_EXPIRED`: “Este enlace expiró. Solicita uno nuevo.”

### Paginación de ledger

- Estilo MVP: `page` + `per_page`.
- Estrategia recomendada:
  - iniciar `page=1`, `per_page=25`;
  - append en scroll infinito;
  - detener cuando `current_page >= total_pages`.

## Tabla resumen

| Endpoint | Propósito | Requiere sesión | Errores comunes |
| --- | --- | --- | --- |
| `POST /auth/client/magic-links/consume` | Consumir magic-link y crear sesión persistente | No | `400`, `409`, `410` |
| `GET /client/me/profile` | Traer perfil + memberships del cliente | Sí | `401` |
| `GET /client/me/cards` | Traer cards con `points_balance` + branding embebido | Sí | `401` |
| `GET /client/me/rewards` | Traer rewards activas de la company de una tarjeta (`membership_id`) | Sí | `400`, `401`, `403` |
| `GET /client/me/ledger` | Historial append-only de puntos (todas o una membership) | Sí | `401`, `403` |

## Contrato fuera de MVP (no usar)

- `GET /clients/profile`
- `GET /clients/card`
- `GET /clients/balance`
- `GET /clients/history`
- `GET /clients/memberships`
- `GET /clients/memberships/{membership_id}/history`
