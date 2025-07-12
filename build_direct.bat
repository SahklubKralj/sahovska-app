@echo off
echo Setting up direct Gradle build...
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
set PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

cd "C:\Users\Marija\Mobilna app"
echo Current directory: %CD%

echo Building AAB directly with Gradle...
cd android
gradlew bundleRelease
cd ..

echo Build completed!
echo AAB file should be in: build\app\outputs\bundle\release\
pause