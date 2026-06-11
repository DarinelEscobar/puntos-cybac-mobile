# puntos_cybac_mobile

App Flutter para la experiencia mobile de clientes de Puntos Cybac.

## Objetivo

Este repositorio contiene la app móvil cliente. No incluye backend, PHP ni base de datos. La integración con backend se consume vía HTTP y su contrato vive en `spec/`.

## Stack y versiones base

- Flutter app privada (`publish_to: none`)
- Dart SDK: `>=3.10.0 <4.0.0`
- Android:
  - Android Gradle Plugin `8.11.1`
  - Gradle `8.14`
  - Kotlin `2.2.20`
  - Java `17`
  - `applicationId`: `com.cybac.puntos`
- iOS:
  - `PRODUCT_BUNDLE_IDENTIFIER`: `com.cybac.puntos`
  - `IPHONEOS_DEPLOYMENT_TARGET`: `13.0`
  - `MARKETING_VERSION`: `1.0`
- Deep link configurado:
  - Android/iOS app scheme: `cybacpuntos://magic-link`

## Qué sí documenta este repo

- Estructura y arquitectura Flutter.
- Contrato API consumido por mobile.
- Variables de entorno requeridas por la app.
- Guías locales para correr Flutter desde Windows/WSL y emulador Android.
- Comandos base para build debug y release.

## Qué no documenta este repo

Este proyecto no define dentro del código:

- versión de PHP
- motor o versión de base de datos
- despliegue del backend
- infraestructura del API

Si necesitas eso, debe documentarse en el repositorio del backend. Aquí solo se define el contrato que la app espera consumir.

## Estructura principal del proyecto

```text
.
├── lib/            # código fuente Flutter
├── test/           # pruebas
├── docs/           # documentación operativa y arquitectura
├── spec/           # contrato API y ejemplos de payloads
├── android/        # configuración nativa Android
├── ios/            # configuración nativa iOS
├── web/            # runner web Flutter
├── windows/        # runner Windows
├── linux/          # runner Linux
├── macos/          # runner macOS
├── .env.example    # ejemplo de variables locales
├── pubspec.yaml    # dependencias y constraints
└── run_wireless.ps1 # helper de ejecución por PowerShell
```

## Estructura de `lib/`

La app sigue una organización feature-first:

```text
lib/
  app/            # bootstrap, app root y DI
  core/           # config, red, tema, utilidades compartidas
  features/       # features por dominio
  integrations/   # adaptadores a servicios externos
  main.dart       # entrypoint
```

Features detectadas actualmente:

- `auth/`
- `client_cards/`
- `home/`
- `profile/`
- `rewards/`

## Documentación incluida

### `docs/`

- `docs/architecture.md`
  - guía de arquitectura y reglas de modularidad
- `docs/local-wsl-flutter.md`
  - flujo recomendado para trabajar este repo entre WSL y Windows
- `docs/emulator-setup.md`
  - pasos para levantar emulador Android y correr la app

### `spec/`

Fuente de verdad del contrato API para mobile:

- `spec/openapi.yaml`
  - contrato OpenAPI canónico
- `spec/README.md`
  - resumen del alcance del contrato mobile
- `spec/auth.md`
  - flujo de autenticación por magic link
- `spec/errors.md`
  - manejo esperado de errores
- `spec/domain.md`
  - reglas de dominio e invariantes
- `spec/client-api.md`
  - guía rápida de consumo para Flutter
- `spec/examples/*.json`
  - ejemplos de request y response listos para pruebas

## Variables de entorno

1. Copia `.env.example` a `.env`.
2. Configura:
   - `API_BASE_URL`
   - `TERMS_URL`

Valores ejemplo actuales:

```env
API_BASE_URL=https://puntos-cybac.vercel.app/api/v1
TERMS_URL=https://puntos-cybac.vercel.app/terms
```

Reglas importantes:

- En `release`, `API_BASE_URL` debe usar `https://`.
- `TERMS_URL` puede sobreescribirse por `--dart-define`.
- Si no se define `TERMS_URL`, la app puede resolverla a partir del origen de `API_BASE_URL`.

## Dependencias principales de la app

- `http`
- `app_links`
- `flutter_secure_storage`
- `intl`
- `qr_flutter`
- `url_launcher`

## Cómo instalar dependencias

```bash
flutter pub get
```

## Cómo correr la app

### Opción 1: ejecución manual

```bash
flutter run --dart-define=API_BASE_URL=https://tu-api/api/v1 --dart-define=TERMS_URL=https://tu-sitio/terms
```

### Opción 2: helper PowerShell

```powershell
.\run_wireless.ps1
```

Ese script:

- lee `.env`
- conecta un dispositivo Android por ADB
- pasa `API_BASE_URL` y `TERMS_URL` como `--dart-define`

## Requisitos básicos para desarrollo

### Generales

- Flutter SDK instalado
- Dart SDK compatible con `>=3.10.0 <4.0.0`
- `flutter doctor` sin errores bloqueantes

### Android

- Java `17`
- Android SDK instalado
- ADB disponible
- emulador o dispositivo físico

### iOS

- macOS
- Xcode
- CocoaPods
- cuenta/provisioning de Apple si vas a firmar para distribución

## Comandos útiles

```bash
flutter doctor
flutter devices
flutter analyze
flutter test
```

## Build Android

### APK release

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://tu-api/api/v1 --dart-define=TERMS_URL=https://tu-sitio/terms
```

### App Bundle para Google Play

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://tu-api/api/v1 --dart-define=TERMS_URL=https://tu-sitio/terms
```

### Qué se necesita para publicar Android

- keystore de release
- configuración de firma en `android/app/build.gradle.kts`
- nombre/versionado final de release
- revisión de `applicationId`

Estado actual importante:

- hoy el bloque `release` de Android firma con debug key para permitir `flutter run --release`
- así como está, no debe considerarse listo para Play Store sin configurar firma real

## Build iOS

### Build release iOS

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://tu-api/api/v1 --dart-define=TERMS_URL=https://tu-sitio/terms
```

### Build IPA

```bash
flutter build ipa --release --dart-define=API_BASE_URL=https://tu-api/api/v1 --dart-define=TERMS_URL=https://tu-sitio/terms
```

### Qué se necesita para publicar iOS

- ejecutar el build en macOS
- Xcode configurado
- certificado de firma
- provisioning profile
- App ID / Bundle Identifier válidos en Apple Developer
- revisar capacidades y firma en Xcode antes de App Store Connect

Estado actual importante:

- el bundle identifier actual es `com.cybac.puntos`
- el target mínimo configurado es iOS `13.0`
- la firma depende de la configuración local de Xcode/Apple Developer

## Contrato API implementado

Endpoints principales:

- `POST /auth/client/magic-links/consume`
- `GET /client/me/profile`
- `GET /client/me/cards`
- `GET /client/me/rewards`
- `GET /client/me/ledger/latest`
- `POST /client/me/account-deletion`

## Estado funcional actual

Pantallas principales documentadas/implementadas:

1. `MagicLinkEntry`
2. `SessionBootstrap`
3. `HomeCards`
4. `CardDetail`
5. `Profile`

Supuestos y gaps conocidos:

- el QR se genera localmente con `qr_flutter`
- `Add Card` sigue como placeholder
- el token se persiste con `flutter_secure_storage`

## Validación antes de merge o release

Ejecuta:

```bash
flutter analyze
flutter test
```

Si habrá release móvil, además valida:

- que `API_BASE_URL` apunte al ambiente correcto
- que use `https://` en release
- firma Android/iOS
- versionado visible para tienda
- deep links y navegación inicial

## Referencias rápidas

- Arquitectura: [docs/architecture.md](/home/cybac/projects/puntos-cybac-mobile/docs/architecture.md)
- WSL/Windows: [docs/local-wsl-flutter.md](/home/cybac/projects/puntos-cybac-mobile/docs/local-wsl-flutter.md)
- Emulador Android: [docs/emulator-setup.md](/home/cybac/projects/puntos-cybac-mobile/docs/emulator-setup.md)
- Spec mobile: [spec/README.md](/home/cybac/projects/puntos-cybac-mobile/spec/README.md)
- OpenAPI: [spec/openapi.yaml](/home/cybac/projects/puntos-cybac-mobile/spec/openapi.yaml)
