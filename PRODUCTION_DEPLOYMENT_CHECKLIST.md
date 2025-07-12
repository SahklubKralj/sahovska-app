# 🚀 PRODUKCIJSKI DEPLOY CHECKLIST - Šahovska Aplikacija

## ✅ PRE-DEPLOY CHECKLIST

### **Faza 1: Firebase Production Setup**

#### **🔥 Firebase Billing & Configuration**
- [ ] **Upgrade na Blaze plan** (Pay-as-you-go)
  ```bash
  # Firebase Console > Settings > Usage and billing > Modify plan
  # Blaze plan: $0.18 per 100k reads, $0.18 per 100k writes
  # Za malu aplikaciju: ~$1-5 mesečno
  ```

- [ ] **Production Firestore Security Rules**
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      // Users - samo svoj profil
      match /users/{userId} {
        allow read, update: if request.auth != null && request.auth.uid == userId;
        allow create: if request.auth != null;
        allow read: if request.auth != null && 
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
      }
      
      // Notifications - svi čitaju, samo admini pišu
      match /notifications/{notificationId} {
        allow read: if request.auth != null;
        allow create, update: if request.auth != null && 
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
        allow delete: if request.auth != null && 
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
      }
    }
  }
  ```

- [ ] **Firebase Storage Security Rules**
  ```javascript
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      // Notifications images - svi čitaju, samo admini pišu
      match /notifications/{imageId} {
        allow read: if true;
        allow write: if request.auth != null && 
          firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true;
      }
      
      // User avatars - vlasnik može čitati/pisati
      match /avatars/{userId}/{imageId} {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

- [ ] **Enable Firebase Analytics**
  ```bash
  # Firebase Console > Analytics > Dashboard
  # Automatic user tracking, events, demographics
  ```

- [ ] **Enable Crashlytics**
  ```bash
  # Firebase Console > Crashlytics > Enable
  # Real-time crash reporting
  ```

- [ ] **Firebase Performance Monitoring**
  ```bash
  # Automatically enabled with firebase_performance plugin
  # Tracks app startup, network requests, custom traces
  ```

#### **🔐 Security Validation**
- [ ] **Remove all debug prints from code**
  ```bash
  # Search for: print(, debugPrint(, console.log
  # Replace with proper logging or remove
  ```

- [ ] **Review API keys and secrets**
  ```bash
  # Ensure no hardcoded secrets in code
  # Firebase config files should be in .gitignore
  # Use environment variables for sensitive data
  ```

- [ ] **Validate FCM token handling**
  ```dart
  // Ensure FCM tokens are properly refreshed
  // Test notifications in all app states:
  // - Foreground, Background, Terminated
  ```

---

### **Faza 2: Flutter App Production Prep**

#### **📱 App Configuration**
- [ ] **Update pubspec.yaml version**
  ```yaml
  version: 1.0.0+1  # semantic_version+build_number
  ```

- [ ] **Clean build environment**
  ```bash
  flutter clean
  flutter pub get
  flutter pub deps
  ```

- [ ] **Remove development dependencies**
  ```yaml
  # Ensure no dev dependencies in main dependencies
  # Check for unused packages: flutter pub deps
  ```

#### **🎨 App Branding**
- [ ] **App Icons (all sizes)**
  ```bash
  # android/app/src/main/res/mipmap-*/ic_launcher.png
  # ios/Runner/Assets.xcassets/AppIcon.appiconset/
  ```

- [ ] **Splash Screen**
  ```bash
  # Configure launch screen for both platforms
  # Ensure chess theme branding
  ```

- [ ] **App Name & Bundle ID**
  ```bash
  # Android: android/app/src/main/AndroidManifest.xml
  # iOS: ios/Runner/Info.plist
  ```

#### **🔧 Platform-Specific Setup**

**Android:**
- [ ] **AndroidManifest.xml permissions**
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
  <uses-permission android:name="android.permission.VIBRATE" />
  <!-- For image picker -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  ```

- [ ] **Generate upload keystore**
  ```bash
  keytool -genkey -v -keystore ~/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

- [ ] **Configure app signing**
  ```gradle
  // android/app/build.gradle
  android {
    ...
    signingConfigs {
      release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
      }
    }
    buildTypes {
      release {
        signingConfig signingConfigs.release
        minifyEnabled true
        useProguard true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
      }
    }
  }
  ```

**iOS:**
- [ ] **Update Info.plist permissions**
  ```xml
  <!-- ios/Runner/Info.plist -->
  <key>NSCameraUsageDescription</key>
  <string>Ova aplikacija koristi kameru za fotografisanje slika za obaveštenja.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Ova aplikacija pristupa galeriji za izbor slika za obaveštenja.</string>
  <key>NSUserNotificationsUsageDescription</key>
  <string>Ova aplikacija šalje notifikacije o novim obaveštenjima šahovskog kluba.</string>
  ```

- [ ] **Xcode project configuration**
  ```bash
  # Open ios/Runner.xcworkspace in Xcode
  # Set Team, Bundle Identifier, Signing Certificate
  # Configure Capabilities: Push Notifications, Background Modes
  ```

---

### **Faza 3: Production Builds**

#### **🤖 Android Build**
- [ ] **Build Android App Bundle**
  ```bash
  flutter build appbundle --release --verbose
  
  # Output: build/app/outputs/bundle/release/app-release.aab
  # Size should be ~15-25MB for our app
  ```

- [ ] **Test AAB locally** (optional)
  ```bash
  # Install bundletool
  java -jar bundletool.jar build-apks \
    --bundle=app-release.aab \
    --output=app.apks
  ```

- [ ] **Verify signing**
  ```bash
  jarsigner -verify -verbose -certs app-release.aab
  ```

#### **🍎 iOS Build**
- [ ] **Archive in Xcode**
  ```bash
  # 1. Open ios/Runner.xcworkspace
  # 2. Select "Any iOS Device (arm64)"
  # 3. Product > Archive
  # 4. Organizer > Distribute App > App Store Connect
  ```

- [ ] **Upload to App Store Connect**
  ```bash
  # Follow Xcode upload flow
  # Build will appear in App Store Connect after processing
  ```

---

### **Faza 4: Store Preparation**

#### **📊 Google Play Console Setup**
- [ ] **Create app listing**
  ```bash
  # App name: "Šahovska Aplikacija" / "Chess Club App"
  # Category: Sports / Board Games
  # Content rating: Everyone
  ```

- [ ] **Prepare store assets**
  ```bash
  # Required screenshots:
  # - Phone: 2-8 screenshots (1080x1920 or 1080x2340)
  # - 7" Tablet: 1-8 screenshots (1200x1920)
  # - 10" Tablet: 1-8 screenshots (1600x2560)
  # - Feature Graphic: 1024x500
  # - App Icon: 512x512
  ```

- [ ] **App description (Serbian/English)**
  ```markdown
  # Short description (80 chars):
  "Oficijalna aplikacija šahovskog kluba za obaveštenja i komunikaciju"
  
  # Full description:
  Dobrodošli u oficijalna aplikaciju našeg šahovskog kluba!
  
  🏆 FUNKCIONALNOSTI:
  • Real-time obaveštenja o turnirima, kursevima i događajima
  • Galerija slika sa turnira i aktivnosti
  • Offline pristup prethodnim obaveštenjima
  • Push notifikacije za važne vesti
  • Admin panel za upravljanje sadržajem
  
  ♟️ OSTANITE POVEZANI:
  Ne propustite nijedan turnir ili trening! Aplikacija vam omogućava da:
  - Primate trenutna obaveštenja
  - Pregledajte slike sa događaja
  - Čitajte vesti čak i bez interneta
  
  Aplikacija je kreirana specijalno za naš šahovski klub da olakša komunikaciju između članova i organizatora.
  ```

- [ ] **Privacy Policy & Terms**
  ```markdown
  # Create and host privacy policy
  # Must cover: data collection, storage, Firebase usage, image uploads
  ```

#### **🍎 App Store Connect Setup**
- [ ] **Create app listing**
  ```bash
  # App name: "Šahovska Aplikacija"
  # Category: Sports
  # Age Rating: 4+ (Everyone)
  ```

- [ ] **Prepare store assets**
  ```bash
  # Required screenshots:
  # iPhone: 6.7", 6.5", 5.5" displays
  # iPad: 12.9", 11" displays  
  # App Icon: 1024x1024
  ```

- [ ] **App Review Information**
  ```bash
  # Demo account credentials for reviewers
  # Test admin account: admin@demo.com / TestPassword123
  # Include explanation of admin features
  ```

---

### **Faza 5: Testing Before Launch**

#### **🧪 Final Testing Checklist**
- [ ] **Authentication flow**
  ```bash
  ✅ Email/password registration
  ✅ Email verification
  ✅ Google Sign In (prod SHA-1)
  ✅ Password reset
  ✅ Auto-login on app restart
  ```

- [ ] **Push notifications**
  ```bash
  ✅ Foreground notifications
  ✅ Background notifications  
  ✅ App terminated notifications
  ✅ Notification tap navigation
  ✅ FCM token refresh
  ```

- [ ] **Admin functionality**
  ```bash
  ✅ Create notifications (text only)
  ✅ Create notifications with images
  ✅ Delete notifications
  ✅ Image upload to Firebase Storage
  ✅ Image viewing and zoom
  ```

- [ ] **Offline functionality**
  ```bash
  ✅ View cached notifications offline
  ✅ Offline banner display
  ✅ Auto-sync when back online
  ```

- [ ] **Performance**
  ```bash
  ✅ App startup time < 3 seconds
  ✅ Smooth scrolling in notifications list
  ✅ Image loading with proper placeholders
  ✅ No memory leaks in image gallery
  ```

#### **📱 Device Testing**
- [ ] **Test on multiple devices**
  ```bash
  # Android: Different screen sizes, OS versions
  # iOS: Different iPhone/iPad models
  # Test with real Firebase production data
  ```

- [ ] **Test different network conditions**
  ```bash
  # WiFi, 4G, slow connection, offline
  # Ensure graceful handling of network issues
  ```

---

### **Faza 6: Launch Strategy**

#### **🎯 Soft Launch**
- [ ] **Internal testing (1-2 weeks)**
  ```bash
  # Google Play: Internal testing track
  # iOS: TestFlight internal testing
  # 5-10 club members as beta testers
  ```

- [ ] **Create first admin user in production**
  ```bash
  # Firebase Console > Firestore > users collection
  # Add document with isAdmin: true
  ```

- [ ] **Test production notifications**
  ```bash
  # Send test notification from admin panel
  # Verify all registered devices receive it
  ```

#### **🚀 Public Launch**
- [ ] **Google Play Store**
  ```bash
  # Release to production track
  # Staged rollout: 20% → 50% → 100%
  # Monitor crash reports and reviews
  ```

- [ ] **Apple App Store**
  ```bash
  # Submit for review
  # Usually approved within 24-48 hours
  # Be ready to respond to review feedback
  ```

#### **📈 Post-Launch Monitoring**
- [ ] **Day 1 monitoring**
  ```bash
  # Check Crashlytics for any crashes
  # Monitor FCM delivery reports
  # Verify Analytics data is coming in
  # Check user reviews and ratings
  ```

- [ ] **Week 1 review**
  ```bash
  # Performance metrics analysis
  # User feedback evaluation
  # Plan for first update if needed
  ```

---

## 🎯 **SUCCESS METRICS**

### **Technical KPIs:**
- Crash-free rate: >99.5%
- App startup time: <3 seconds
- Notification delivery rate: >95%
- Image upload success rate: >98%

### **User KPIs:**
- Daily active users
- Notification engagement rate
- Time spent in app
- User retention (Day 1, 7, 30)

### **Business KPIs:**
- Club member app adoption rate
- Notification click-through rate
- Admin content creation frequency
- User feedback sentiment

---

## 🚨 **EMERGENCY PROCEDURES**

### **Critical Bug Response:**
1. **Assess impact** (crash rate, affected users)
2. **Emergency hotfix** if needed
3. **Expedited review process** (Google/Apple)
4. **User communication** via club channels

### **Server Issues:**
1. **Firebase status check** (status.firebase.google.com)
2. **Fallback communication** (email, social media)
3. **User notification** about temporary issues

---

## ✅ **FINAL PRE-LAUNCH VERIFICATION**

- [ ] All Firebase services configured for production
- [ ] Security rules tested and locked down
- [ ] App icons and branding finalized
- [ ] Store listings complete with screenshots
- [ ] Privacy policy published and linked
- [ ] Beta testing completed successfully
- [ ] Emergency procedures documented
- [ ] First admin user created in production
- [ ] Monitoring dashboards set up

**🎉 READY FOR LAUNCH! 🚀**

---

**Napomena:** Ovaj checklist je specifično prilagođen vašoj šahovskoj aplikaciji. Pratite ga korak po korak za siguran i uspešan deploy na produkciju.