import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shahovska_app/services/auth_service.dart';
import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockGoogleSignIn = MockGoogleSignIn();
      
      authService = AuthService(
        firebaseAuth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );
    });

    group('Email Authentication', () {
      test('should create user with email and password successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const displayName = 'Test User';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.updateDisplayName(displayName)).thenAnswer((_) async {});

        // Act
        final result = await authService.createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
        verify(mockUser.updateDisplayName(displayName)).called(1);
      });

      test('should sign in with email and password successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('should send password reset email', () async {
        // Arrange
        const email = 'test@example.com';

        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        // Act
        await authService.sendPasswordResetEmail(email);

        // Assert
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      });

      test('should send email verification', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});

        // Act
        await authService.sendEmailVerification();

        // Assert
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should check if email is verified', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        final result = authService.isEmailVerified;

        // Assert
        expect(result, isTrue);
      });

      test('should reload user', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.reload()).thenAnswer((_) async {});

        // Act
        await authService.reloadUser();

        // Assert
        verify(mockUser.reload()).called(1);
      });
    });

    group('Google Sign In', () {
      test('should sign in with Google successfully', () async {
        // Arrange
        final mockGoogleSignInAccount = MockGoogleSignInAccount();
        final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleSignInAccount);
        when(mockGoogleSignInAccount.authentication)
            .thenAnswer((_) async => mockGoogleSignInAuthentication);
        when(mockGoogleSignInAuthentication.accessToken).thenReturn('access_token');
        when(mockGoogleSignInAuthentication.idToken).thenReturn('id_token');

        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      });

      test('should return null when Google sign in is cancelled', () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act
        final result = await authService.signInWithGoogle();

        // Assert
        expect(result, isNull);
        verify(mockGoogleSignIn.signIn()).called(1);
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
      });
    });

    group('Sign Out', () {
      test('should sign out from Firebase and Google', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        // Act
        await authService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockGoogleSignIn.signOut()).called(1);
      });
    });

    group('Current User', () {
      test('should return current user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = authService.currentUser;

        // Assert
        expect(result, equals(mockUser));
      });

      test('should return auth state changes stream', () {
        // Arrange
        final stream = Stream<User?>.value(mockUser);
        when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => stream);

        // Act
        final result = authService.authStateChanges;

        // Assert
        expect(result, equals(stream));
      });
    });

    group('Error Handling', () {
      test('should throw exception when createUserWithEmailAndPassword fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const displayName = 'Test User';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        // Act & Assert
        expect(
          () => authService.createUserWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should throw exception when signInWithEmailAndPassword fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });
  });
}