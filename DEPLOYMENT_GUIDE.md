# 🚀 VODIČ ZA DEPLOY - Šahovska Aplikacija

## ✅ CURRENT STATUS
**Aplikacija je spremna za produkciju!** 🎉

Svi glavni komponenti su implementirani:
- ✅ Kompletna autentifikacija (email/password + Google Sign In)
- ✅ Push notifikacije (FCM)
- ✅ Admin panel funkcionalnost
- ✅ Offline podrška
- ✅ Real-time notifikacije
- ✅ Email verifikacija
- ✅ Provider arhitektura
- ✅ Navigation handling
- ✅ Performance monitoring

---

## 🔧 PREDUSLOVI ZA DEPLOY

### 1. **Firebase Projekat Setup**

#### **Kreiranje Firebase Projekta:**
```bash
# 1. Idite na https://console.firebase.google.com
# 2. Kliknite "Add project"
# 3. Unesite ime: "shahovska-aplikacija" (ili po izboru)
# 4. Omogućite Google Analytics (opciono)
```

#### **Dodavanje Flutter aplikacije:**
```bash
# Android App
# - Package name: com.example.shahovska_app (ili vaš package)
# - Downloadujte google-services.json
# - Stavite u: android/app/google-services.json

# iOS App  
# - Bundle ID: com.example.shahovskaApp (ili vaš bundle)
# - Downloadujte GoogleService-Info.plist
# - Stavite u: ios/Runner/GoogleService-Info.plist
```

### 2. **Firebase Services Konfiguracija**

#### **Authentication:**
```bash
# Firebase Console > Authentication > Sign-in method
# Omogućite:
# ✅ Email/Password
# ✅ Google (dodajte SHA-1 fingerprints)
```

#### **Firestore Database:**
```bash
# Firebase Console > Firestore Database
# 1. Kreirajte bazu u production mode
# 2. Kopirajte security rules iz firestore.rules
# 3. Publish rules
```

#### **Cloud Messaging:**
```bash
# Firebase Console > Cloud Messaging
# 1. Automatski aktiviran nakon dodavanja aplikacije
# 2. Testirajte sa test notifikacijom
```

#### **Storage (za buduće potrebe):**
```bash
# Firebase Console > Storage
# 1. Kreirajte bucket
# 2. Konfigurišite security rules
```

### 3. **Google Sign In Setup**

#### **Android konfiguracija:**
```gradle
// android/app/build.gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.4.1'
}
```

```bash
# Dobijanje SHA-1 fingerprints:
cd android
./gradlew signingReport

# Ili za debug:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### **iOS konfiguracija:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

---

## 🔑 FIREBASE KONFIGURACIJA

### **Zamenite placeholder vrednosti:**

#### **1. Android Google Services**
```json
// android/app/google-services.json
{
  "project_info": {
    "project_number": "VAŠA_PROJECT_NUMBER",
    "project_id": "VAŠA_PROJECT_ID"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "VAŠA_ANDROID_APP_ID",
        "android_client_info": {
          "package_name": "com.example.shahovska_app"
        }
      }
    }
  ]
}
```

#### **2. iOS Google Services**
```xml
<!-- ios/Runner/GoogleService-Info.plist -->
<key>PROJECT_ID</key>
<string>VAŠA_PROJECT_ID</string>
<key>GOOGLE_APP_ID</key>
<string>VAŠA_IOS_APP_ID</string>
<key>REVERSED_CLIENT_ID</key>
<string>VAŠ_REVERSED_CLIENT_ID</string>
```

---

## 👤 KREIRANJE PRVOG ADMIN KORISNIKA

### **Opcija 1: Firebase Console (Preporučeno)**
```bash
# 1. Idite na Firebase Console > Firestore Database
# 2. Kreirajte collection: "users" 
# 3. Dodajte dokument sa UID prvog admin korisnika:

Document ID: [USER_UID_FROM_AUTH]
Data:
{
  "email": "admin@shahovskiklub.com",
  "displayName": "Admin",
  "isAdmin": true,
  "createdAt": [current_timestamp],
  "fcmToken": null
}
```

### **Opcija 2: Programski**
```dart
// Dodajte u debugging kod ili admin setup screen
final adminUser = UserModel(
  uid: 'FIREBASE_AUTH_UID',
  email: 'admin@shahovskiklub.com', 
  displayName: 'Admin',
  isAdmin: true,
  createdAt: DateTime.now(),
  fcmToken: null,
);

await FirestoreService().createUser(adminUser);
```

---

## 📱 BUILD I DEPLOY

### **Android APK Build**
```bash
# Development build
flutter build apk --debug

# Production build  
flutter build apk --release

# Split APKs po arhitekturi (manje veličine)
flutter build apk --release --split-per-abi
```

### **Android App Bundle (za Google Play)**
```bash
# Production bundle
flutter build appbundle --release

# Nalaze se u: build/app/outputs/bundle/release/
```

### **iOS Build**
```bash
# Development
flutter build ios --debug

# Production (potreban Xcode i Apple Developer Account)
flutter build ios --release

# Zatim u Xcode:
# 1. Otvorite ios/Runner.xcworkspace
# 2. Product > Archive
# 3. Upload to App Store Connect
```

---

## 🧪 TESTING PROCEDURE

### **1. Firebase Connection Test**
```bash
# Pokrenite aplikaciju u debug mode
flutter run --debug

# Proverite u konzoli:
# ✅ "Firebase initialized successfully"
# ✅ "FCM Token: [token]"
# ✅ "User authenticated: [uid]"
```

### **2. Authentication Test**
- ✅ Registracija novog korisnika
- ✅ Email verifikacija (proverite spam folder)
- ✅ Google Sign In (potreban SHA-1 setup)
- ✅ Logout/Login funkcionalnost

### **3. Push Notifications Test**
```bash
# Firebase Console > Cloud Messaging > Send test message
# Target: FCM registration token (iz debug konzole)
# Message: "Test notifikacija"

# Testirajte:
# ✅ Notifikacija kada je app u foreground
# ✅ Notifikacija kada je app u background  
# ✅ Notifikacija kada je app zatvorena
# ✅ Navigation nakon klika na notifikaciju
```

### **4. Admin Functionality Test**
- ✅ Admin korisnik vidi admin dugme
- ✅ Kreiranje novih notifikacija
- ✅ Različite kategorije notifikacija
- ✅ Push notifikacije se šalju svim korisnicima

### **5. Offline Test**
- ✅ Isključite internet
- ✅ Aplikacija pokazuje offline banner
- ✅ Poslednje notifikacije se prikazuju
- ✅ Uključite internet - sinhronizacija radi

---

## 🔒 SECURITY CHECKLIST

### **Firestore Security Rules**
```javascript
// Proverite da su rules primenjene:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users mogu čitati/pisati samo svoje podatke
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Notifikacije mogu čitati svi autentifikovani korisnici
    match /notifications/{notificationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### **API Keys Protection**
- ✅ Google Services config fajlovi u .gitignore
- ✅ Nikad ne commitujte production keys u git
- ✅ Koristite environment varijable za CI/CD

---

## 📊 MONITORING I ANALYTICS

### **Firebase Analytics (Opciono)**
```bash
# Ako je omogućen Analytics:
# 1. Firebase Console > Analytics
# 2. Dashboard će pokazati:
#    - Daily Active Users
#    - Screen views  
#    - App crashes
#    - Performance data
```

### **Performance Monitoring**
```dart
// Ugrađen performance tracking kroz PerformanceUtils
// Logovi će se prikazivati u debug konzoli:
// "Performance: operation_name took 150ms"
// "⚠️ SLOW OPERATION: heavy_operation took 2500ms"
```

### **Crash Reporting**
```bash
# Dodajte Firebase Crashlytics (opciono):
# firebase_crashlytics: ^3.4.8

# Automatski će pratiti:
# - App crashes
# - ANRs (Android Not Responding)
# - Fatal errors
```

---

## 🚀 PRODUCTION DEPLOYMENT

### **Google Play Store (Android)**
```bash
# 1. Kreirajte Google Play Console nalog
# 2. Upload app bundle (.aab fajl)
# 3. Popunite store listing:
#    - App name: "Šahovska Aplikacija"
#    - Description: [vaš opis]
#    - Screenshots: [iPhone i Android]
#    - Privacy Policy: [potreban link]

# 4. Internal testing → Closed testing → Open testing → Production
```

### **App Store (iOS)**
```bash
# 1. Apple Developer Program membership ($99/god)
# 2. App Store Connect
# 3. Upload preko Xcode ili Transporter
# 4. App Review proces (1-7 dana)

# Potrebno:
# - App ikone (različite veličine)
# - Launch screens
# - Privacy Policy
# - App Store screenshots
```

### **Alternative Distribution**
```bash
# APK Direct Distribution:
# - Host .apk fajl na vašem sajtu
# - Omogućite "Unknown sources" na Android
# - QR kod za download

# Firebase App Distribution:
# - Closed beta testing
# - Automatski updates
# - User feedback
```

---

## 🔄 CONTINUOUS INTEGRATION (CI/CD)

### **GitHub Actions Setup**
```yaml
# .github/workflows/build.yml
name: Build and Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
```

### **Fastlane Setup (Advanced)**
```bash
# Automatski build i deploy
# - Automatski version bump
# - App store upload
# - Beta distribution
# - Slack notifications
```

---

## 🎯 NEXT STEPS & ROADMAP

### **Immediate (Launch Ready)**
- ✅ **Deploy na production Firebase**
- ✅ **Kreiraj prvog admin korisnika**
- ✅ **Test na real devices**
- ✅ **Submit za app store review**

### **Short Term (1-2 meseca)**
- 📸 **Galerija slika** (Firebase Storage integration)
- 📅 **Kalendar događaja** (dodajte date picking)
- 🏆 **Turnir registracije** (dodatni forms i tracking)
- 💬 **Push notification personalizacija**

### **Medium Term (3-6 meseci)**
- 👥 **Chat funkcionalnost** (user-to-user messaging)
- 📈 **Analytics dashboard** (Firebase Analytics)
- 🌍 **Multi-language support** (srpski/engleski)
- 💳 **Payment integration** (stripe/paypal za turnire)

### **Long Term (6+ meseci)**
- 🎮 **Chess game integration** (play chess in app)
- 📊 **Player ratings/ELO tracking**
- 🏅 **Achievement system**
- 🔄 **Sync sa chess.com/lichess**

---

## 🆘 TROUBLESHOOTING

### **Common Firebase Issues**
```bash
# Problem: "Default FirebaseApp is not initialized"
# Rešenje: Proverite da li je google-services.json na pravom mestu

# Problem: Google Sign In ne radi
# Rešenje: Dodajte SHA-1 fingerprint u Firebase Console

# Problem: Push notifikacije ne stižu
# Rešenje: Proverite FCM token i Firebase Console setup
```

### **Build Issues**
```bash
# Problem: Android build fails
# Rešenje: 
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter build apk

# Problem: iOS build fails  
# Rešenje: Otvorite ios/Runner.xcworkspace u Xcode i build tamo
```

### **Runtime Issues**
```bash
# Problem: App crashes on startup
# Rešenje: Proverite Firebase inicijalizaciju u main.dart

# Problem: Offline mode ne radi
# Rešenje: Proverite ConnectivityService setup
```

---

## 📞 SUPPORT & MAINTENANCE

### **Regular Maintenance Tasks**
- 🔄 **Firebase Analytics review** (mesečno)
- 📊 **Performance metrics check** (nedeljno)  
- 🐛 **Bug reports handling** (daily)
- 🔐 **Security updates** (po potrebi)

### **Monitoring Endpoints**
- 📊 **Firebase Console Dashboard**
- 🔥 **Firestore usage metrics**
- 📱 **FCM delivery reports**
- ⚡ **Performance traces**

---

## ✅ FINAL CHECKLIST

Przed deploy-om, proverite da je sve ✅:

### **Firebase Setup**
- [ ] Firebase projekt kreiran
- [ ] Android app dodana sa google-services.json
- [ ] iOS app dodana sa GoogleService-Info.plist
- [ ] Authentication enabled (Email + Google)
- [ ] Firestore database kreirana
- [ ] Security rules deploy-ovane
- [ ] Cloud Messaging enabled

### **App Configuration**  
- [ ] Package name/Bundle ID finalized
- [ ] App ikone dodane
- [ ] Launch screens konfigurisan
- [ ] Permissions properly set (Android/iOS)
- [ ] Prvi admin korisnik kreiran

### **Testing Completed**
- [ ] Registration/Login flow
- [ ] Google Sign In (sa real SHA-1)
- [ ] Push notifications (all states)
- [ ] Admin functionality
- [ ] Offline mode
- [ ] Production build test

### **Store Preparation**
- [ ] App store listing ready
- [ ] Screenshots captured
- [ ] Privacy Policy written
- [ ] Release notes prepared
- [ ] Pricing model decided

---

## 🎉 ZAKLJUČAK

**Čestitamo! Vaša šahovska aplikacija je spremna za produkciju!** 

Aplikacija sadrži sve moderne funkcionalnosti koje korisnici očekuju:
- 🔐 **Sigurna autentifikacija**
- 📱 **Real-time push notifikacije**  
- 👨‍💼 **Admin panel management**
- 🌐 **Offline support**
- ⚡ **Optimizovane performanse**

**Sledeći korak:** Deploy na Firebase production i submit za app store review!

Za dodatnu podršku ili pitanja, kontaktirajte development tim. 

**Srećan deploy! 🚀**