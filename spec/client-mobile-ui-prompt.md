# Client Mobile UI Prompt (MVP)

Este archivo define solo la interfaz mobile del cliente para construir vistas en Flutter segun requerimientos MVP.
No cubre vistas de Super Admin, Admin Company ni Staff.

## 1) Alcance de interfaz (solo cliente mobile)

Incluye:
- Acceso por magic-link (consumo de token).
- Sesion persistente en telefono.
- Vista de tarjetas digitales (una por membership/empresa).
- Lista principal de cards con informacion esencial y minima (sin saturacion visual).
- Detalle de tarjeta con secciones por card: historial y rewards de esa company.
- Tarjeta reversible (frente/reverso) para mostrar QR en el reverso.
- Perfil basico de cliente (solo lectura).
- Estados UX: loading, vacio, error, sin conexion, sesion expirada.

No incluye:
- Registro de cliente (lo hace staff/admin en web).
- Operacion de caja (earn/redeem en staff web).
- CRUD de catalogo, reglas o branding.
- Modulos admin, facturacion, planes o reportes empresariales.
- Flujo de request/revision de canje (en MVP la solicitud es verbal en caja).

## 2) Navegacion mobile requerida

- Flujo inicial:
  - `MagicLinkEntry` (o deep-link directo)
  - `SessionBootstrap`
  - `HomeCards`
- App autenticada:
  - `Tarjetas` (principal)
  - `Profile`
- Flujo desde `HomeCards`:
  - Tap en card -> `CardDetail` (incluye historial y rewards filtrados por esa tarjeta)

## 3) Pantallas y contenido minimo

### A. MagicLinkEntry
Objetivo: iniciar sesion de cliente con token validado.

Componentes:
- Header corto con contexto de marca del producto (no de empresa aun).
- Campo token (visible solo si no llega por deep-link).
- Boton primario: `Continuar`.
- Estado loading bloqueando doble submit.

Estados:
- Exito: navegar a `SessionBootstrap`.
- Error `MAGIC_LINK_INVALID_FORMAT`: mensaje "El enlace no es valido".
- Error `MAGIC_LINK_ALREADY_CONSUMED`: mensaje "Este enlace ya fue usado".
- Error `MAGIC_LINK_EXPIRED`: mensaje "Este enlace expiro. Solicita uno nuevo".

### B. SessionBootstrap
Objetivo: cargar datos iniciales (profile + cards) y decidir primera vista.

Componentes:
- Splash/loader centrado.
- Texto de progreso: "Preparando tu tarjeta...".

Estados:
- Si hay cards: navegar a `HomeCards` con la primera card activa.
- Si no hay cards: estado vacio guiado (mensaje + CTA de soporte).
- Si `401/CLIENT_UNAUTHENTICATED`: limpiar token y volver a `MagicLinkEntry`.

### C. HomeCards (principal)
Objetivo: mostrar todas las tarjetas del cliente en formato simple tipo wallet.

Componentes:
- Lista simple de cards (una card por bloque, foco en lectura rapida).
- Cada card en lista muestra solo:
  - `company_name`
  - `points_balance`
  - `card_uid` corto (ej. ultimos 4-6 caracteres)
  - branding base (`logo_url`, `color_primary`, `color_secondary`, `color_accent`)
- Sin QR en la lista principal.
- Pull-to-refresh.
- Tap en card para abrir detalle.

Estados:
- Loading skeleton de cards.
- Empty: "Aun no tienes tarjetas activas".
- Error de red con retry.

### D. CardDetail (detalle + movimientos)
Objetivo: mostrar la tarjeta seleccionada y su historial de movimientos.

Componentes:
- Card grande con frente/reverso.
- Frente:
  - `company_name`
  - `points_balance`
  - `card_uid` legible
- Reverso:
  - QR principal (payload = `qr_payload`)
  - `card_uid` para fallback manual
- Boton/gesto `Voltear tarjeta` con animacion de flip.
- Seccion "Movimientos de esta tarjeta" debajo de la card:
- Selector de seccion `Historial | Rewards` debajo de la card.
- Seccion "Movimientos de esta tarjeta":
  - lista newest-first
  - tipo (`EARN`, `REDEEM`, `ADJUST`)
  - `points_delta`
  - fecha/hora
  - nota opcional
  - paginacion/infinite scroll
- Seccion "Rewards de esta tarjeta":
  - lista de rewards activas de la misma company
  - `name`, `type`, `points_cost`
  - estado vacio claro cuando no haya rewards

Estados:
- Loading inicial de detalle.
- Loading incremental de movimientos.
- Empty movimientos: "Aun no tienes movimientos en esta tarjeta".
- Si membership no pertenece al cliente (`MEMBERSHIP_NOT_OWNED`): bloquear vista + volver a tarjetas.

### E. Profile
Objetivo: mostrar identidad del cliente autenticado.

Componentes:
- Nombre completo, email, telefono.
- Resumen rapido: total de tarjetas activas.
- Accion: `Cerrar sesion`.

Estados:
- `401`: expulsar a login y limpiar almacenamiento seguro.

## 4) Reglas visuales y UX

- Referencia de estilo: experiencia simple tipo Google Wallet / Steren Card (limpia, directa, sin ruido visual).
- Mobile-first real: objetivo 360x800 como base; adaptable a iOS/Android.
- Lista principal minimalista:
  - Solo informacion esencial de cada card.
  - Sin bloques extras ni texto largo en HomeCards.
- Jerarquia clara:
  - Una accion primaria por pantalla.
  - Tipografia legible para uso rapido en caja.
- Branding por card:
  - Aplicar colores del API por tarjeta.
  - Definir fallback local cuando branding venga null.
- Interaccion card:
  - Flip frente/reverso con animacion corta y fluida.
  - Reverso reservado para QR y datos de escaneo.
- Accesibilidad:
  - Contraste minimo AA en texto sobre colores de marca.
  - Touch targets >= 44px.
  - Soporte lector de pantalla en botones clave (`Voltear tarjeta`, `Cerrar sesion`).
- Feedback:
  - Error copy corto + accion clara (Retry/Reintentar).
  - Loading visible en llamadas criticas.

## 5) Endpoints cliente (MVP)

Usar estos endpoints para poblar UI:
- `POST /api/v1/auth/client/magic-links/consume`
- `GET /api/v1/client/me/profile`
- `GET /api/v1/client/me/cards`
- `GET /api/v1/client/me/rewards`
- `GET /api/v1/client/me/ledger`

Documento de referencia del contrato:
- `docs/client-api.md`

## 6) Como recibe datos el cliente y que debe mostrar

### 6.1 `POST /api/v1/auth/client/magic-links/consume`
Request esperado:
- `token`
- `device_name`

Datos clave de respuesta (`data`):
- `access_token`: guardar en secure storage.
- `profile.client_identity.full_name|email|phone`: usar en Profile.
- `cards[]`: bootstrap inicial de HomeCards y CardDetail.

UI a mostrar con esta respuesta:
- Si `cards.length > 0`: abrir HomeCards.
- Si `cards.length == 0`: estado vacio guiado.

### 6.2 `GET /api/v1/client/me/profile`
Datos clave de respuesta (`data`):
- `client_identity`: nombre, email, telefono, created_at.
- `memberships[]`: membresias del cliente.

UI a mostrar:
- Pantalla Profile.
- Conteo total de tarjetas activas (desde memberships/cards segun estrategia de app).

### 6.3 `GET /api/v1/client/me/cards`
Datos clave por card:
- `membership_id`
- `company_name`
- `card_uid`
- `status`
- `points_balance`
- `qr_payload`
- `branding.logo_url`
- `branding.color_primary|color_secondary|color_accent`

UI a mostrar:
- HomeCards (solo datos esenciales: company_name, points_balance, card_uid corto, branding).
- CardDetail (datos completos + QR en reverso).

### 6.4 `GET /api/v1/client/me/ledger`
Query recomendada para detalle por tarjeta:
- `membership_id=<id>&page=1&per_page=25`

### 6.5 `GET /api/v1/client/me/rewards`
Query requerida para detalle por tarjeta:
- `membership_id=<id>`

Datos clave:
- `data.membership_id`
- `data.rewards[]` con `name`, `type`, `points_cost`, `is_active`

UI a mostrar:
- CardDetail en la seccion `Rewards`.
- Nunca mezclar rewards de multiples tarjetas/companies.

Datos clave por movimiento:
- `id`
- `membership_id`
- `type` (`EARN`, `REDEEM`, `ADJUST`)
- `points_delta`
- `purchase_amount_mxn` (si aplica)
- `note`
- `created_at`

UI a mostrar:
- Lista de movimientos en `CardDetail`.
- Orden newest-first.
- Paginacion con `meta.pagination`.

## 7) Prompt maestro (copiar/pegar)

```text
Actua como Senior Mobile Product Designer + Flutter UX Architect.

Necesito disenar SOLO la interfaz mobile del rol CLIENTE para un MVP de lealtad.
No incluyas pantallas admin/staff ni logica de backoffice.

Contexto funcional:
- El cliente entra por magic-link (token, 24h, single-use).
- Tras autenticarse, ve sus tarjetas digitales por empresa.
- La lista principal de tarjetas debe ser simple y minimalista, mostrando solo informacion esencial.
- Al tocar una tarjeta, se abre detalle con historial de movimientos de esa tarjeta.
- La tarjeta del detalle debe poder voltearse (frente/reverso) para mostrar QR en el reverso.
- Puede ver perfil basico y cerrar sesion.
- Redencion en MVP es verbal en caja; no hay flujo de aprobacion en app.

Referencia visual:
- Estilo de tarjeta simple tipo Google Wallet / Steren Card.

Pantallas obligatorias:
1) MagicLinkEntry
2) SessionBootstrap
3) HomeCards (principal)
4) CardDetail (incluye movimientos y flip para QR)
5) Profile

Endpoints disponibles:
- POST /api/v1/auth/client/magic-links/consume
- GET /api/v1/client/me/profile
- GET /api/v1/client/me/cards
- GET /api/v1/client/me/ledger

Mapeo de datos a UI:
- cards[]: HomeCards + CardDetail
- qr_payload: reverso de card (QR)
- points_balance: saldo visible
- ledger data: lista de movimientos newest-first
- profile.client_identity: pantalla Profile

Requisitos UX:
- Mobile-first, una accion primaria por pantalla.
- Estados completos por pantalla: loading, empty, error, offline, session expired.
- Branding por tarjeta usando color_primary, color_secondary, color_accent y logo_url, con fallback.
- Accesibilidad AA y touch targets >= 44px.
- HomeCards sin saturacion: solo datos esenciales por card.

Errores a mapear en UI:
- MAGIC_LINK_INVALID_FORMAT
- MAGIC_LINK_ALREADY_CONSUMED
- MAGIC_LINK_EXPIRED
- CLIENT_UNAUTHENTICATED
- MEMBERSHIP_NOT_OWNED

Entregables esperados:
- Mapa de navegacion.
- Wireframe textual por pantalla (layout detallado arriba-abajo).
- Lista de componentes reutilizables.
- Matriz de estados UX por pantalla.
- Reglas visuales (tipografia, espaciado, color, iconografia).
- Criterios de aceptacion verificables por pantalla.

Restriccion:
- No propongas funcionalidades fuera de MVP.
- No cambies contratos de datos.
```

## 8) Criterios de aceptacion UI (checklist rapido)

- Existe flujo completo de magic-link a home sin pasos admin.
- HomeCards muestra solo informacion esencial (sin saturacion).
- Tap en card abre detalle con historial filtrado por membership.
- CardDetail permite voltear la tarjeta y ver QR en reverso.
- El cliente puede mostrar QR e ID manual en caja.
- Todos los errores definidos tienen mensaje UX y accion.
- El diseno funciona en mobile sin dependencias desktop.
