Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-CommandExists([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Missing required command '$name'. Install Flutter and ensure 'flutter' is on PATH."
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $repoRoot "app"
$packageDir = Join-Path $repoRoot "packages\\phone_app"

Assert-CommandExists "flutter"

if (-not (Test-Path $packageDir)) {
  throw "Expected Flutter package not found: $packageDir"
}

if (-not (Test-Path (Join-Path $appDir "pubspec.yaml"))) {
  New-Item -ItemType Directory -Force -Path $appDir | Out-Null

  Push-Location $appDir
  try {
    # Generate host app (Android+iOS). You can add other platforms later.
    flutter create --platforms=android,ios .
  } finally {
    Pop-Location
  }
}

# Wire the host app to use the package as its UI.
$mainDart = @'
import 'package:flutter/material.dart';
import 'package:phone_app/phone_app.dart';

void main() {
  runApp(const PhoneAppRoot());
}
'@

$mainPath = Join-Path $appDir "lib\\main.dart"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $mainPath) | Out-Null
Set-Content -Path $mainPath -Value $mainDart -Encoding UTF8

# Add path dependency to packages/phone_app.
$appPubspecPath = Join-Path $appDir "pubspec.yaml"
$appPubspec = Get-Content -Raw -Path $appPubspecPath

if ($appPubspec -notmatch "(?m)^\s*phone_app\s*:") {
  if ($appPubspec -notmatch "(?m)^\s*dependencies\s*:") {
    throw "Unexpected pubspec.yaml format; missing dependencies section: $appPubspecPath"
  }

  $injected = $appPubspec -replace "(?m)^(dependencies\\s*:\\s*\\r?\\n)", "`$1  phone_app:`r`n    path: ../packages/phone_app`r`n"
  Set-Content -Path $appPubspecPath -Value $injected -Encoding UTF8
}

Write-Host "Bootstrap complete."
Write-Host "Next:"
Write-Host "  cd $appDir"
Write-Host "  flutter pub get"
Write-Host "  flutter run"

