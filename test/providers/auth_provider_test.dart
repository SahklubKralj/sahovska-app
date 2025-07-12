import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shahovska_app/providers/auth_provider.dart';
import 'package:shahovska_app/services/auth_service.dart';
import 'package:shahovska_app/services/firestore_service.dart';
import 'package:shahovska_app/models/user_model.dart';
import 'auth_provider_test.mocks.dart';

@GenerateMocks([
  AuthService,
  FirestoreService,
  User,
  UserCredential,
])
void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;
    late MockFirestoreService mockFirestoreService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuthService = MockAuthService();
      mockFirestoreService = MockFirestoreService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Setup auth state stream
      when(mockAuthService.authStateChanges).thenAnswer(
        (_) => Stream<User?>.value(null),
      );

      authProvider = AuthProvider(
        authService: mockAuthService,
        firestoreService: mockFirestoreService,
      );
    });

    group('Sign Up', () {
      test('should sign up successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const displayName = 'Test User';
        const uid = 'test-uid';

        when(mockAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);

        when(mockAuthService.sendEmailVerification()).thenAnswer((_) async {});
        when(mockFirestoreService.createUser(any)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.signUp(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        verify(mockAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        )).called(1);
        verify(mockFirestoreService.createUser(any)).called(1);
        verify(mockAuthService.sendEmailVerification()).called(1);
      });

      test('should handle sign up failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const displayName = 'Test User';

        when(mockAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        // Act
        final result = await authProvider.signUp(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isFalse);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, contains('email-already-in-use'));
      });
    });

    group('Sign In', () {
      test('should sign in successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const uid = 'test-uid';

        final userModel = UserModel(
          uid: uid,
          email: email,
          displayName: 'Test User',
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        when(mockAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);

        when(mockFirestoreService.getUser(uid)).thenAnswer((_) async => userModel);

        // Act
        final result = await authProvider.signIn(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user!.email, equals(email));
        verify(mockAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
        verify(mockFirestoreService.getUser(uid)).called(1);
      });

      test('should handle sign in failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act
        final result = await authProvider.signIn(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isFalse);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, contains('wrong-password'));
      });
    });

    group('Google Sign In', () {
      test('should sign in with Google successfully for new user', () async {
        // Arrange
        const uid = 'google-uid';
        const email = 'google@example.com';
        const displayName = 'Google User';

        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);

        when(mockFirestoreService.getUser(uid)).thenAnswer((_) async => null);
        when(mockFirestoreService.createUser(any)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.signUpWithGoogle();

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        expect(authProvider.user, isNotNull);
        verify(mockAuthService.signInWithGoogle()).called(1);
        verify(mockFirestoreService.getUser(uid)).called(1);
        verify(mockFirestoreService.createUser(any)).called(1);
      });

      test('should sign in with Google successfully for existing user', () async {
        // Arrange
        const uid = 'google-uid';
        const email = 'google@example.com';

        final existingUser = UserModel(
          uid: uid,
          email: email,
          displayName: 'Existing Google User',
          isAdmin: false,
          createdAt: DateTime.now().subtract(Duration(days: 30)),
        );

        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);

        when(mockFirestoreService.getUser(uid)).thenAnswer((_) async => existingUser);
        when(mockFirestoreService.updateUser(any)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.signUpWithGoogle();

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user!.uid, equals(uid));
        verify(mockAuthService.signInWithGoogle()).called(1);
        verify(mockFirestoreService.getUser(uid)).called(1);
        verifyNever(mockFirestoreService.createUser(any));
      });

      test('should handle Google sign in cancellation', () async {
        // Arrange
        when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => null);

        // Act
        final result = await authProvider.signUpWithGoogle();

        // Assert
        expect(result, isFalse);
        verify(mockAuthService.signInWithGoogle()).called(1);
        verifyNever(mockFirestoreService.getUser(any));
      });
    });

    group('Sign Out', () {
      test('should sign out successfully', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async {});

        // Act
        await authProvider.signOut();

        // Assert
        expect(authProvider.user, isNull);
        verify(mockAuthService.signOut()).called(1);
      });
    });

    group('Password Reset', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockAuthService.sendPasswordResetEmail(email)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.sendPasswordResetEmail(email);

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
      });

      test('should handle password reset failure', () async {
        // Arrange
        const email = 'invalid@example.com';
        when(mockAuthService.sendPasswordResetEmail(email))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        // Act
        final result = await authProvider.sendPasswordResetEmail(email);

        // Assert
        expect(result, isFalse);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, contains('user-not-found'));
      });
    });

    group('Email Verification', () {
      test('should send email verification successfully', () async {
        // Arrange
        when(mockAuthService.sendEmailVerification()).thenAnswer((_) async {});

        // Act
        final result = await authProvider.sendEmailVerification();

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        verify(mockAuthService.sendEmailVerification()).called(1);
      });

      test('should reload user successfully', () async {
        // Arrange
        const uid = 'test-uid';
        final userModel = UserModel(
          uid: uid,
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        when(mockAuthService.reloadUser()).thenAnswer((_) async {});
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockFirestoreService.getUser(uid)).thenAnswer((_) async => userModel);

        // Act
        await authProvider.reloadUser();

        // Assert
        expect(authProvider.error, isNull);
        verify(mockAuthService.reloadUser()).called(1);
        verify(mockFirestoreService.getUser(uid)).called(1);
      });

      test('should get email verification status', () {
        // Arrange
        when(mockAuthService.isEmailVerified).thenReturn(true);

        // Act
        final result = authProvider.isEmailVerified;

        // Assert
        expect(result, isTrue);
        verify(mockAuthService.isEmailVerified).called(1);
      });
    });

    group('Profile Update', () {
      test('should update profile successfully', () async {
        // Arrange
        const uid = 'test-uid';
        const newDisplayName = 'Updated Name';
        const newEmail = 'updated@example.com';

        final currentUser = UserModel(
          uid: uid,
          email: 'old@example.com',
          displayName: 'Old Name',
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        authProvider.user = currentUser; // Set current user

        when(mockFirestoreService.updateUser(any)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.updateProfile(
          displayName: newDisplayName,
          email: newEmail,
        );

        // Assert
        expect(result, isTrue);
        expect(authProvider.error, isNull);
        expect(authProvider.user!.displayName, equals(newDisplayName));
        expect(authProvider.user!.email, equals(newEmail));
        verify(mockFirestoreService.updateUser(any)).called(1);
      });

      test('should handle profile update failure', () async {
        // Arrange
        const uid = 'test-uid';
        final currentUser = UserModel(
          uid: uid,
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: false,
          createdAt: DateTime.now(),
        );

        authProvider.user = currentUser;

        when(mockFirestoreService.updateUser(any))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await authProvider.updateProfile(displayName: 'New Name');

        // Assert
        expect(result, isFalse);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, contains('Update failed'));
      });
    });

    group('State Properties', () {
      test('should return correct authentication state', () {
        // Initially not authenticated
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isAdmin, isFalse);

        // After setting a user
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAdmin: true,
          createdAt: DateTime.now(),
        );
        authProvider.user = user;

        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isAdmin, isTrue);
      });

      test('should clear error', () {
        // Set an error
        authProvider.error = 'Test error';
        expect(authProvider.error, isNotNull);

        // Clear error
        authProvider.clearError();
        expect(authProvider.error, isNull);
      });
    });
  });
}