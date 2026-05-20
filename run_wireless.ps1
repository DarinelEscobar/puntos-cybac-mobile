param(
  [string]$DeviceIpPort = "192.168.0.252:33375",
  [string]$ApiBaseUrl = "",
  [string]$TermsUrl = "",
  [string]$EnvFile = ".env"
)

function Get-EnvValue {
  param(
    [string]$Path,
    [string]$Key
  )

  if (-not (Test-Path $Path)) {
    return ""
  }

  $pattern = "^\s*${Key}\s*=\s*(.*)$"
  $line = Get-Content $Path | Where-Object { $_ -match $pattern } | Select-Object -Last 1
  if ([string]::IsNullOrWhiteSpace($line)) {
    return ""
  }

  $value = [regex]::Match($line, $pattern).Groups[1].Value.Trim()

  if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
      ($value.StartsWith("'") -and $value.EndsWith("'"))) {
    $value = $value.Substring(1, $value.Length - 2).Trim()
  }

  return $value
}

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
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedEnvFile = if ([System.IO.Path]::IsPathRooted($EnvFile)) {
  $EnvFile
} else {
  Join-Path $scriptDirectory $EnvFile
}

$resolvedApiBaseUrl = if ([string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
  Get-EnvValue -Path $resolvedEnvFile -Key "API_BASE_URL"
} else {
  $ApiBaseUrl
}
$resolvedTermsUrl = if ([string]::IsNullOrWhiteSpace($TermsUrl)) {
  Get-EnvValue -Path $resolvedEnvFile -Key "TERMS_URL"
} else {
  $TermsUrl
}

$dartDefines = @()
if (-not [string]::IsNullOrWhiteSpace($resolvedApiBaseUrl)) {
  Write-Host "Using API_BASE_URL=$resolvedApiBaseUrl"
  $dartDefines += "--dart-define=API_BASE_URL=$resolvedApiBaseUrl"
}
if (-not [string]::IsNullOrWhiteSpace($resolvedTermsUrl)) {
  Write-Host "Using TERMS_URL=$resolvedTermsUrl"
  $dartDefines += "--dart-define=TERMS_URL=$resolvedTermsUrl"
}

if ($dartDefines.Count -eq 0) {
  flutter run -d $DeviceIpPort
} else {
  flutter run -d $DeviceIpPort @dartDefines
}
