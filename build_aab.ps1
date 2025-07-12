# Flutter AAB Build Script
Write-Host "Setting up environment for Flutter build..." -ForegroundColor Green

# Set Java Home
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Navigate to project directory
Set-Location "C:\Users\Marija\Mobilna app"
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Check if Flutter exists locally
if (Test-Path "flutter\bin\flutter.bat") {
    Write-Host "Found local Flutter installation" -ForegroundColor Green
    $flutterCmd = ".\flutter\bin\flutter.bat"
} else {
    Write-Host "Checking for Flutter in PATH..." -ForegroundColor Yellow
    try {
        & flutter --version
        $flutterCmd = "flutter"
        Write-Host "Found Flutter in PATH" -ForegroundColor Green
    } catch {
        Write-Host "Flutter not found! Please install Flutter or check PATH" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host "Building Android App Bundle..." -ForegroundColor Green
Write-Host "This may take several minutes..." -ForegroundColor Yellow

try {
    & $flutterCmd build appbundle --release
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "AAB file location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
} catch {
    Write-Host "Build failed with error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")