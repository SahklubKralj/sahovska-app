# 🏆 FINALNI BUILD GUIDE - Sahovska App

## 📱 O Aplikaciji
- **Naziv**: Sahovska App
- **Verzija**: 1.0.0
- **Platform**: Android (Flutter)
- **Namena**: Oficijalna aplikacija šahovskog kluba za obaveštenja i komunikaciju

## 🚀 OPCIJE ZA BUILD

### Opcija 1: GitHub Actions (PREPORUČENO)
1. Push kod na GitHub
2. Automatski se pokreće build
3. Download AAB iz Releases

### Opcija 2: PowerShell Script
```powershell
# Otvori PowerShell kao Administrator
cd "C:\Users\Marija\Mobilna app"

# Pokušaj opcije redom:
.\FINAL_BUILD.ps1 -UseDocker      # Najstabilnije
.\FINAL_BUILD.ps1 -InstallFlutter # Instaliraj Flutter globalno  
.\FINAL_BUILD.ps1                 # Direktni Gradle
.\manual_build.bat                # Poslednja opcija
```

### Opcija 3: Online Build Servisi
- **Codemagic**: https://codemagic.io
- **GitHub Codespaces**: Besplatan za 60h mesečno
- **GitLab CI/CD**: Besplatan

## 📋 PRE-ZAHTEVI

### Potrebno:
- ✅ Java 17+ (Android Studio JBR)
- ✅ Android SDK 
- ✅ Keystore fajl (kreiran)
- ✅ Git

### Opciono:
- Docker Desktop (za Docker build)
- Flutter SDK (za lokalni build)

## 🔑 Keystore Info
- **Lokacija**: `android/upload-keystore.jks`
- **Password**: `mali2025genijalci`
- **Alias**: `upload`
- **Key Password**: `mali2025genijalci`

## 📁 Output Lokacija
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`

## 🛠️ Troubleshooting

### "Flutter SDK not found"
```bash
git clone https://github.com/flutter/flutter.git -b stable C:\flutter
set PATH=C:\flutter\bin;%PATH%
```

### "Gradle build failed"
```bash
cd android
.\gradlew clean
.\gradlew :app:bundleRelease
```

### "Java version incompatible"
```bash
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
```

## 📱 Google Play Store Upload

1. Idite na [Google Play Console](https://play.google.com/console)
2. Create New App
3. Upload `app-release.aab`
4. Popunite store listing
5. Submit za review

## 🆘 Podrška
Ako ništa ne radi, koristite GitHub Actions - to je najsigurniji način!

---
**Autor**: Claude Code Assistant  
**Datum**: 2025-07-12  
**Status**: Production Ready ✅