param(
  [string]$DeviceIpPort = "192.168.0.252:5555",
  [string]$ApiBaseUrl = ""
)

$adbPath = "C:\Android\platform-tools\adb.exe"
if (Test-Path $adbPath) {
  $adb = $adbPath
} else {
  $adb = "adb"
}

Write-Host "Connecting to device $DeviceIpPort..."
$env:ANDROID_SDK_ROOT = "C:\Android"
$env:ANDROID_HOME = "C:\Android"
$env:Path = "C:\Android\platform-tools;C:\src\flutter\bin;" + $env:Path
& $adb connect $DeviceIpPort

Write-Host "Available Flutter devices:"
flutter devices

Write-Host "Running Flutter app on $DeviceIpPort..."
if ([string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
  flutter run -d $DeviceIpPort
} else {
  Write-Host "Using API_BASE_URL=$ApiBaseUrl"
  flutter run -d $DeviceIpPort --dart-define=API_BASE_URL=$ApiBaseUrl
}
