# Ejecutar emulador Android y correr la app Flutter

Este documento explica cómo iniciar el emulador `Pixel_7_API_34` usando el SDK en `C:\Android`, y cómo ejecutar la app Flutter en ese emulador.


 C:\Android\emulator\emulator.exe -avd Pixel_7_API_34 -netdelay none -netspeed full

 
## Requisitos previos

- Flutter SDK instalado en `C:\src\flutter`.
- Android SDK en `C:\Android` con:
  - `platform-tools` (adb)
  - `emulator`
  - `system-images;android-34;google_apis;x86_64`
  - `platforms;android-34`
- Variables de entorno del usuario:
  - `ANDROID_SDK_ROOT=C:\Android`
  - `ANDROID_HOME=C:\Android`
- `PATH` incluye:
  - `C:\src\flutter\bin`
  - `C:\Android\platform-tools`

## 1) Iniciar el emulador

El emulador se debe iniciar en **otra terminal** para dejarlo abierto mientras compilas y ejecutas la app.

El emulador se inicia con `ANDROID_SDK_ROOT` apuntando al SDK:

```powershell
$env:ANDROID_SDK_ROOT="C:\Android"
C:\Android\emulator\emulator.exe -avd Pixel_7_API_34 -netdelay none -netspeed full
```

Si el emulador no arranca y marca error de `Broken AVD system path`, revisa el archivo:

```text
%USERPROFILE%\.android\avd\Pixel_7_API_34.avd\config.ini
```

Asegura que tenga esta línea (ruta relativa al SDK):

```text
image.sysdir.1=system-images\android-34\google_apis\x86_64\
```

## 2) Verificar que Flutter detecta el emulador

En una terminal distinta (por ejemplo `cybac_mobile`), configura el PATH y verifica Flutter:

```powershell
$env:Path = "C:\src\flutter\bin;C:\Android\platform-tools;" + $env:Path
flutter --version
flutter devices
```

Salida esperada (ejemplo):

```text
Found 5 connected devices:
  2311DRK48G (mobile)          • 192.168.0.252:5555 • android-arm64  • Android 15 (API 35)
  sdk gphone64 x86 64 (mobile) • emulator-5554      • android-x64    • Android 14 (API 34) (emulator)
  Windows (desktop)            • windows            • windows-x64    • Microsoft Windows [Version 10.0.26100.6899]
  Chrome (web)                 • chrome             • web-javascript • Google Chrome 145.0.7632.76
  Edge (web)                   • edge               • web-javascript • Microsoft Edge 145.0.3800.58
```

Debe aparecer un dispositivo Android con un nombre similar a `Pixel_7_API_34` (por ejemplo `emulator-5554`).

## 3) Instalar y ejecutar la app Flutter en el emulador

Desde la raíz del proyecto (en la misma terminal donde corriste `flutter devices`):

```powershell
cd C:\laragon\www\puntos_cybac_mobile
flutter pub get
flutter clean
flutter run -d emulator-5554
```

Salida esperada (ejemplo):

```text
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
Running Gradle task 'assembleDebug'...
```

> Nota: el ID del emulador puede variar (por ejemplo `emulator-5554`). Usa el ID exacto que te muestre `flutter devices`.

## 4) Ejecutar con API_BASE_URL (opcional)

Si tu backend corre en el PC, usa la IP LAN del PC (no `10.0.2.2` si es dispositivo físico). En emulador puedes usar `10.0.2.2`, pero aquí dejamos el ejemplo con IP LAN:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://TU_IP_LOCAL:8000/api/v1
```

## Problemas comunes

- **`flutter` no reconocido**: agrega `C:\src\flutter\bin` al `PATH` del usuario y abre una nueva consola.
- **`adb` no reconocido**: agrega `C:\Android\platform-tools` al `PATH` del usuario.
- **No aparece el emulador en `flutter devices`**: espera a que termine el boot del emulador o reinícialo.
