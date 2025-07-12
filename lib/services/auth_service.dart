import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if the current user is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth
      await result.user?.updateDisplayName(displayName);
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Greška pri Google prijavi: ${e.toString()}');
    }
  }

  /// Sign in with Apple (placeholder for future implementation)
  Future<UserCredential?> signInWithApple() async {
    // TODO: Implement Apple Sign In
    throw UnimplementedError('Apple Sign In nije još implementiran');
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Greška pri slanju verifikacionog email-a: ${e.toString()}');
    }
  }

  /// Reload current user to get updated info
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Greška pri ažuriranju korisnika: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google if user was signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      await _auth.signOut();
    } catch (e) {
      throw Exception('Greška pri odjavi: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Korisnik sa ovim email-om ne postoji.';
      case 'wrong-password':
        return 'Pogrešna lozinka.';
      case 'email-already-in-use':
        return 'Email je već u upotrebi.';
      case 'weak-password':
        return 'Lozinka je presslaba.';
      case 'invalid-email':
        return 'Nevažeći email format.';
      case 'too-many-requests':
        return 'Previše pokušaja. Pokušajte kasnije.';
      default:
        return 'Greška pri autentifikaciji: ${e.message}';
    }
  }
}