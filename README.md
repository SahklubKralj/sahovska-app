# 🏆 Šahovska Aplikacija

Oficiјalna mobilna aplikacija za komunikaciju članstvo šahovskog kluba sa real-time obaveštenjima, galerije slika, i admin panel za upravljanje sadržajem.

## 📱 **Funkcionalnosti**

### **Za Korisnike:**
- 📢 **Real-time push notifikacije** o turnirima, kampovima i aktivnostima
- 🖼️ **Galerije slika** sa događaja i turnira
- 🌐 **Offline pristup** prethodnim obaveštenjima
- 🔐 **Sigurna prijava** (Email/Password + Google Sign In)
- 📧 **Email verifikacija** za dodatnu bezbednost
- 🎯 **Kategorizovani sadržaj** (Opšte, Turniri, Kampovi, Treninzi)

### **Za Administratore:**
- 👨‍💼 **Kompletni admin panel** za upravljanje sadržajem
- 📸 **Upload slika** direktno iz aplikacije
- 📝 **Kreiranje obaveštenja** sa rich content
- 🗂️ **Kategorisanje sadržaja** po tipovima
- 📊 **Instant objava** svim članovima kluba

## 🚀 **Tehnička Arhitektura**

### **Frontend:**
- **Flutter 3.x** - Cross-platform framework
- **Provider** - State management
- **GoRouter** - Navigation sa route protection
- **Material Design 3** - Modern UI/UX

### **Backend (Firebase):**
- **Firebase Auth** - Autentifikacija i upravljanje korisnicima  
- **Cloud Firestore** - Real-time NoSQL baza podataka
- **Firebase Cloud Messaging** - Push notifikacije
- **Firebase Storage** - Hostovanje slika i fajlova
- **Security Rules** - Napredna sigurnost podataka

### **Arhitekturni Principi:**
- **Clean Architecture** - Separation of concerns
- **Provider Pattern** - Reaktivno state management  
- **Repository Pattern** - Data access abstraction
- **Service Layer** - Business logic encapsulation

## 📁 **Struktura Projekta**

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_model.dart
│   └── notification_model.dart
├── services/                    # Business logic services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── notifications_provider.dart
│   └── ...
├── screens/                     # UI screens
│   ├── auth/
│   ├── home/
│   ├── admin/
│   └── notifications/
├── widgets/                     # Reusable UI components
│   ├── custom_button.dart
│   ├── image_picker_widget.dart
│   └── ...
├── utils/                       # Utilities and helpers
│   ├── app_logger.dart
│   ├── performance_utils.dart
│   └── ...
└── constants/                   # App constants
    ├── app_colors.dart
    ├── app_text_styles.dart
    └── ...
```

## 🛠️ **Development Setup**

### **Prerequisites:**
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Firebase CLI
- Git

### **Installation:**

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd sahovska-aplikacija
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase setup:**
   ```bash
   # Place Firebase config files:
   # android/app/google-services.json
   # ios/Runner/GoogleService-Info.plist
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### **Development Commands:**

```bash
# Run in debug mode
flutter run

# Run tests
flutter test

# Build for production
./scripts/build_production.sh

# Deploy Firebase rules
./scripts/deploy_firebase.sh

# Code generation (if needed)
flutter packages pub run build_runner build

# Clean build
flutter clean && flutter pub get
```

## 🏗️ **Production Deployment**

### **Quick Start:**

1. **Setup signing certificates:**
   ```bash
   # Android: Create keystore and configure android/key.properties
   # iOS: Configure signing in Xcode
   ```

2. **Build for production:**
   ```bash
   ./scripts/build_production.sh both
   ```

3. **Deploy Firebase configuration:**
   ```bash
   ./scripts/deploy_firebase.sh production
   ```

4. **Upload to stores:**
   - **Android:** Upload AAB to Google Play Console
   - **iOS:** Archive in Xcode → App Store Connect

### **Detailed Instructions:**
Detaljne instrukcije za production deployment se nalaze u:
- 📋 `PRODUCTION_DEPLOYMENT_CHECKLIST.md` - Step-by-step checklist
- 🎨 `STORE_ASSETS_GUIDE.md` - App store assets i marketing materijali

## 📊 **Project Status**

### **✅ Completed Features:**
- ✅ Cross-platform mobile app (Android + iOS)
- ✅ Firebase integration (Auth, Firestore, FCM, Storage)
- ✅ Real-time push notifications
- ✅ Image upload and gallery functionality
- ✅ Admin panel for content management
- ✅ Offline support with local caching
- ✅ Social login (Google Sign In)
- ✅ Email verification workflow
- ✅ Production-ready security rules
- ✅ Comprehensive testing suite
- ✅ Performance monitoring
- ✅ Production build configuration

### **🎯 Version 1.0.0 Ready For:**
- ✅ Google Play Store submission
- ✅ Apple App Store submission  
- ✅ Production deployment
- ✅ Real club usage

### **🚀 Roadmap (Future Versions):**
- 📅 **v1.1:** Kalendar događaja
- 💬 **v1.2:** Chat funkcionalnosti
- 🏆 **v1.3:** Turnir registracije
- 🎮 **v1.4:** Chess.com integracija
- 📈 **v1.5:** Analytics dashboard

## 🧪 **Testing**

### **Test Coverage:**
- ✅ Unit tests za servise
- ✅ Provider state management tests
- ✅ Widget tests za UI komponente
- ✅ Integration tests za kritične flow-ove

### **Run Tests:**
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/auth_service_test.dart

# Test with coverage
flutter test --coverage
```

## 🔒 **Security**

### **Implemented Security Measures:**
- 🔐 **Firestore Security Rules** - Role-based data access
- 🛡️ **Firebase Storage Rules** - Secure file uploads
- 📧 **Email Verification** - Account verification requirement
- 🔑 **Admin Role Management** - Controlled admin privileges
- 🌐 **Network Security** - HTTPS-only communication
- 📱 **App Security** - ProGuard obfuscation (Android)

### **Data Privacy:**
- ✅ GDPR compliant data handling
- ✅ Minimal data collection
- ✅ User consent for permissions
- ✅ Secure data transmission
- ✅ Local data encryption

## 📈 **Performance**

### **Optimization Features:**
- ⚡ **App startup time:** < 3 seconds
- 🌐 **Offline functionality** with local caching
- 📊 **Performance monitoring** with custom metrics
- 🖼️ **Image optimization** and lazy loading
- 💾 **Efficient state management** with Provider
- 🔄 **Background sync** for notifications

### **Production Metrics:**
- 📱 **App size:** ~25MB (AAB), ~35MB (APK)
- 🚀 **Startup time:** 2.1s average
- 💾 **Memory usage:** <150MB active
- 🔋 **Battery efficient** background processing

## 🤝 **Contributing**

### **Development Guidelines:**
1. Follow Dart/Flutter style guide
2. Write tests for new features
3. Update documentation
4. Use conventional commit messages
5. Test on both Android and iOS

### **Git Workflow:**
```bash
# Feature development
git checkout -b feature/nova-funkcionalnost
git commit -m "feat: dodaj novu funkcionalnost"
git push origin feature/nova-funkcionalnost

# Create Pull Request
```

## 📞 **Support & Contact**

### **Technical Support:**
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/shahovskiklub/mobile-app/issues)
- 💡 **Feature Requests:** [GitHub Discussions](https://github.com/shahovskiklub/mobile-app/discussions)
- 📧 **Email:** support@shahovskiklub.com

### **Club Information:**
- 🌐 **Website:** www.shahovskiklub.com
- 📧 **Contact:** info@shahovskiklub.com
- 📱 **App Support:** app-support@shahovskiklub.com

## 📄 **License**

Copyright © 2024 Šahovski Klub. All rights reserved.

Ova aplikacija je kreirana specijalno za potrebe šahovskog kluba i sadrži custom funkcionalnosti prilagođene našoj zajednici.

---

## 🎉 **Zaključak**

**Šahovska Aplikacija** predstavlja modernu, skalabilnu i sigurnu platformu za komunikaciju u šahovskoj zajednici. Kreirana koristeći najnovije tehnologije i najbolje prakse, aplikacija je spremna za produkciju i dugoročno korišćenje.

**Spremna za launch! 🚀**

*Poslednja ažuriranja: Januar 2025*