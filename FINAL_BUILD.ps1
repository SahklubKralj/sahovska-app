# FINALNI BUILD SCRIPT - Ovo MORA da radi!
param(
    [switch]$UseDocker,
    [switch]$InstallFlutter,
    [switch]$SkipFlutter
)

Write-Host "=== FINALNI FLUTTER BUILD SCRIPT ===" -ForegroundColor Cyan
Write-Host "Aplikacija: Sahovska App v1.0.0" -ForegroundColor Green
Write-Host "Cilj: Kreiranje production AAB fajla za Google Play Store" -ForegroundColor Green
Write-Host ""

# Set strict error handling
$ErrorActionPreference = "Stop"

try {
    # Navigate to project directory
    $projectPath = "C:\Users\Marija\Mobilna app"
    Set-Location $projectPath
    Write-Host "✓ Navigated to: $projectPath" -ForegroundColor Green

    # Option 1: Use Docker (most reliable)
    if ($UseDocker) {
        Write-Host "`n=== DOCKER BUILD APPROACH ===" -ForegroundColor Yellow
        
        # Check if Docker is installed
        try {
            & docker --version
            Write-Host "✓ Docker found" -ForegroundColor Green
        } catch {
            Write-Host "✗ Docker not found. Installing Docker Desktop..." -ForegroundColor Red
            Start-Process "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
            Read-Host "Please install Docker Desktop and restart this script with -UseDocker flag"
            return
        }
        
        Write-Host "Building with Docker..." -ForegroundColor Yellow
        & docker build -f Dockerfile.build -t flutter-build .
        & docker run --rm -v "${pwd}\build:/app/build" flutter-build
        
        if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
            Write-Host "✓ SUCCESS! Docker build completed!" -ForegroundColor Green
            return
        }
    }

    # Option 2: Install Flutter globally
    if ($InstallFlutter) {
        Write-Host "`n=== INSTALLING FLUTTER GLOBALLY ===" -ForegroundColor Yellow
        
        $flutterPath = "C:\flutter"
        if (-not (Test-Path $flutterPath)) {
            Write-Host "Downloading Flutter SDK..." -ForegroundColor Yellow
            $flutterZip = "$env:TEMP\flutter.zip"
            Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile $flutterZip
            
            Write-Host "Extracting Flutter..." -ForegroundColor Yellow
            Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force
            Remove-Item $flutterZip
        }
        
        # Add to PATH
        $env:PATH = "$flutterPath\bin;$env:PATH"
        
        # Setup environment
        $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
        $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
        
        Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
        & flutter doctor
        
        Write-Host "Building AAB..." -ForegroundColor Yellow
        & flutter clean
        & flutter pub get
        & flutter build appbundle --release --verbose
        
        if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
            Write-Host "✓ SUCCESS! Global Flutter build completed!" -ForegroundColor Green
            return
        }
    }

    # Option 3: Direct Gradle build (most likely to work)
    if (-not $SkipFlutter) {
        Write-Host "`n=== DIRECT GRADLE BUILD ===" -ForegroundColor Yellow
        
        # Set Java environment
        $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
        $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
        
        # Navigate to android directory
        Set-Location "android"
        
        # Clean previous builds
        Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
        if (Test-Path "app\build") { Remove-Item "app\build" -Recurse -Force }
        if (Test-Path ".gradle") { Remove-Item ".gradle" -Recurse -Force }
        
        # Update Gradle wrapper properties
        $gradleProps = "gradle\wrapper\gradle-wrapper.properties"
        (Get-Content $gradleProps) -replace "gradle-7\.5-all\.zip", "gradle-8.4-all.zip" | Set-Content $gradleProps
        
        # Update local.properties with correct paths
        $localProps = @"
flutter.sdk=C:\\Users\\Marija\\Mobilna app\\flutter
sdk.dir=C:\\Users\\Marija\\AppData\\Local\\Android\\Sdk
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
"@
        Set-Content "local.properties" $localProps
        
        # Build with Gradle
        Write-Host "Building with Gradle..." -ForegroundColor Yellow
        & .\gradlew clean
        & .\gradlew :app:bundleRelease --stacktrace --info
        
        # Check for success
        $aabPath = "..\build\app\outputs\bundle\release\app-release.aab"
        if (Test-Path $aabPath) {
            Write-Host "✓ SUCCESS! Gradle build completed!" -ForegroundColor Green
            $aabInfo = Get-Item $aabPath
            Write-Host "AAB Location: $($aabInfo.FullName)" -ForegroundColor Cyan
            Write-Host "AAB Size: $([math]::Round($aabInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
            return
        }
    }

    # Option 4: Manual APK build
    Write-Host "`n=== FALLBACK: MANUAL APK BUILD ===" -ForegroundColor Yellow
    
    # Create a simple build script that uses existing tools
    $manualBuild = @"
@echo off
echo Building APK manually...
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

cd android
gradlew assembleRelease
if exist app\build\outputs\apk\release\app-release.apk (
    echo SUCCESS! APK created at app\build\outputs\apk\release\app-release.apk
) else (
    echo FAILED! APK not created
)
pause
"@
    
    Set-Content "manual_build.bat" $manualBuild
    Write-Host "Created manual_build.bat - run this if all else fails" -ForegroundColor Yellow

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location $projectPath
}

Write-Host "`n=== USAGE INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host "Try these options in order:" -ForegroundColor White
Write-Host "1. .\FINAL_BUILD.ps1 -UseDocker" -ForegroundColor Yellow
Write-Host "2. .\FINAL_BUILD.ps1 -InstallFlutter" -ForegroundColor Yellow  
Write-Host "3. .\FINAL_BUILD.ps1" -ForegroundColor Yellow
Write-Host "4. .\manual_build.bat" -ForegroundColor Yellow
Write-Host ""
Write-Host "For GitHub Actions: Push code to GitHub and build will run automatically" -ForegroundColor Green