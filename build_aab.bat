@echo off
echo Setting up environment...
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
cd "C:\Users\Marija\Mobilna app"
echo Current directory: %CD%
echo Checking Flutter...
if exist "flutter\bin\flutter.bat" (
    echo Flutter found, building AAB...
    flutter\bin\flutter.bat build appbundle --release
) else (
    echo Flutter not found in flutter\bin\flutter.bat
    echo Checking if Flutter is in PATH...
    flutter --version
    if errorlevel 1 (
        echo Flutter not found in PATH either
    ) else (
        echo Building with Flutter from PATH...
        flutter build appbundle --release
    )
)
echo Build completed.
pause