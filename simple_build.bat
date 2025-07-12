@echo off
echo === Building Android App Bundle ===
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%

cd "C:\Users\Marija\Mobilna app"
echo Working directory: %CD%

echo.
echo Cleaning previous builds...
flutter\bin\flutter.bat clean

echo.
echo Getting dependencies...
flutter\bin\flutter.bat pub get

echo.
echo Building AAB (this takes 5-10 minutes)...
flutter\bin\flutter.bat build appbundle --release --verbose

echo.
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo SUCCESS! AAB file created at:
    echo %CD%\build\app\outputs\bundle\release\app-release.aab
    dir "build\app\outputs\bundle\release\app-release.aab"
) else (
    echo BUILD FAILED - AAB file not found
)

pause