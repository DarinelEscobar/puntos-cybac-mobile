# Errores API cliente (MVP)

## Envelope estándar

```json
{
  "error": {
    "code": "STRING_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

## Códigos relevantes para mobile cliente

| HTTP | code | Cuándo ocurre | Acción sugerida en app |
| --- | --- | --- | --- |
| 400 | `MAGIC_LINK_INVALID_FORMAT` | Token mal formado | Mostrar mensaje y permitir reintento |
| 409 | `MAGIC_LINK_ALREADY_CONSUMED` | Token ya usado | Solicitar nuevo magic-link |
| 410 | `MAGIC_LINK_EXPIRED` | Token vencido (24h) | Solicitar nuevo magic-link |
| 401 | `CLIENT_UNAUTHENTICATED` | Token bearer faltante/inválido/expirado | Limpiar sesión y volver a login |
| 403 | `MEMBERSHIP_NOT_OWNED` | `membership_id` no pertenece al cliente | Bloquear detalle y volver a tarjetas |
