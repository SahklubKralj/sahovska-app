# Detailed Flutter AAB Build Script
Write-Host "=== Flutter AAB Build Script ===" -ForegroundColor Cyan

# Set environment variables
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Change to project directory
Set-Location "C:\Users\Marija\Mobilna app"
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green

# Check Flutter
Write-Host "`nChecking Flutter..." -ForegroundColor Yellow
if (Test-Path "flutter\bin\flutter.bat") {
    Write-Host "✓ Local Flutter found" -ForegroundColor Green
    $flutterCmd = ".\flutter\bin\flutter.bat"
} else {
    Write-Host "✗ Local Flutter not found" -ForegroundColor Red
    exit 1
}

# Flutter doctor
Write-Host "`nRunning Flutter doctor..." -ForegroundColor Yellow
& $flutterCmd doctor

# Clean previous builds
Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
& $flutterCmd clean

# Get dependencies
Write-Host "`nGetting dependencies..." -ForegroundColor Yellow
& $flutterCmd pub get

# Build AAB
Write-Host "`nBuilding Android App Bundle..." -ForegroundColor Green
Write-Host "This will take several minutes..." -ForegroundColor Yellow

$buildOutput = & $flutterCmd build appbundle --release --verbose 2>&1
Write-Host $buildOutput

# Check if build succeeded
if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    Write-Host "`n✓ SUCCESS! AAB file created!" -ForegroundColor Green
    $fileInfo = Get-Item "build\app\outputs\bundle\release\app-release.aab"
    Write-Host "File: $($fileInfo.FullName)" -ForegroundColor Cyan
    Write-Host "Size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "`n✗ BUILD FAILED! AAB file not found!" -ForegroundColor Red
    Write-Host "Check the output above for errors." -ForegroundColor Yellow
}

Read-Host "`nPress Enter to exit"