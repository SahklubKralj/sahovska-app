import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService _notificationService = NotificationService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _authService = authService,
        _firestoreService = firestoreService {
    _initializeAuth();
    _setupFCMTokenRefresh();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  void _setupFCMTokenRefresh() {
    // Set up FCM token refresh callback
    _notificationService.setTokenRefreshCallback((newToken) async {
      if (_user != null) {
        try {
          await _firestoreService.updateUserFCMToken(_user!.uid, newToken);
          _user = _user!.copyWith(fcmToken: newToken);
          notifyListeners();
          AppLogger.auth('FCM token updated', _user!.uid);
        } catch (e) {
          AppLogger.error('Failed to update FCM token', 'AUTH', e);
        }
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserModel? userData = await _firestoreService.getUser(uid);
      
      if (userData != null) {
        _user = userData;
      } else {
        // User exists in Firebase Auth but not in Firestore
        // This can happen if Firestore creation failed during signup
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          await _createMissingUserDocument(firebaseUser);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create missing user document in Firestore
  Future<void> _createMissingUserDocument(User firebaseUser) async {
    try {
      String? fcmToken = await _notificationService.getFCMToken();
      
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Korisnik',
        isAdmin: false,
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      await _firestoreService.createUser(newUser);
      _user = newUser;
      
      AppLogger.auth('Created missing user document', firebaseUser.uid);
    } catch (e) {
      AppLogger.error('Failed to create missing user document', 'AUTH', e);
      throw e;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result?.user != null) {
        await _loadUserData(result!.user!.uid);
        await _updateFCMTokenAfterSignIn();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update FCM token after successful sign in
  Future<void> _updateFCMTokenAfterSignIn() async {
    if (_user == null) return;
    
    try {
      String? currentFCMToken = await _notificationService.getFCMToken();
      
      if (currentFCMToken != null && currentFCMToken != _user!.fcmToken) {
        // Update FCM token in Firestore
        await _firestoreService.updateUserFCMToken(_user!.uid, currentFCMToken);
        
        // Update local user model
        _user = _user!.copyWith(fcmToken: currentFCMToken);
        notifyListeners();
      }
    } catch (e) {
      // Don't fail sign in if FCM token update fails
      AppLogger.warning('Failed to update FCM token during sign in', 'AUTH');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create Firebase Auth user
      UserCredential result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Get FCM token
      String? fcmToken = await _notificationService.getFCMToken();
      
      // Create UserModel for Firestore
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        displayName: displayName,
        isAdmin: false, // Default to regular user
        createdAt: DateTime.now(),
        fcmToken: fcmToken,
      );

      // Save user to Firestore
      await _firestoreService.createUser(newUser);
      
      // Send email verification
      await _authService.sendEmailVerification();
      
      // Set local user state
      _user = newUser;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with Google
  Future<bool> signUpWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential? result = await _authService.signInWithGoogle();
      
      if (result?.user == null) {
        return false; // User canceled
      }

      final firebaseUser = result!.user!;
      
      // Check if user already exists in Firestore
      UserModel? existingUser = await _firestoreService.getUser(firebaseUser.uid);
      
      if (existingUser != null) {
        // User exists, just update FCM token and sign in
        String? fcmToken = await _notificationService.getFCMToken();
        if (fcmToken != null && fcmToken != existingUser.fcmToken) {
          existingUser = existingUser.copyWith(fcmToken: fcmToken);
          await _firestoreService.updateUser(existingUser);
        }
        _user = existingUser;
      } else {
        // New user, create Firestore document
        String? fcmToken = await _notificationService.getFCMToken();
        
        UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Google korisnik',
          isAdmin: false,
          createdAt: DateTime.now(),
          fcmToken: fcmToken,
        );

        await _firestoreService.createUser(newUser);
        _user = newUser;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _error = null;
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if current user's email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  /// Send email verification to current user
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reload user data from Firebase Auth and Firestore
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? email,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      UserModel updatedUser = _user!;

      // Update display name if provided
      if (displayName != null && displayName != _user!.displayName) {
        updatedUser = updatedUser.copyWith(displayName: displayName);
      }

      // Update email if provided
      if (email != null && email != _user!.email) {
        updatedUser = updatedUser.copyWith(email: email);
      }

      // Update in Firestore
      await _firestoreService.updateUser(updatedUser);
      
      // Update local state
      _user = updatedUser;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}