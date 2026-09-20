import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInReady = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInReady) return;
    await _googleSignIn.initialize();
    _googleSignInReady = true;
  }

  /// Stream status login dipakai AuthGate utk menentukan halaman awal.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isGuest => currentUser != null && currentUser!.isAnonymous;

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInReady();

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      final message = switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Login Google dibatalkan pengguna.',
        GoogleSignInExceptionCode.interrupted =>
          'Login Google terganggu (koneksi terputus). Coba lagi.',
        _ => 'Login Google belum bisa dipakai saat ini konfigurasi Firebase '
            '(SHA-1/OAuth client) untuk project ini kemungkinan belum lengkap.',
      };
      throw FirebaseAuthException(code: 'google-sign-in-failed', message: message);
    }

    // authentication sekarang synchronous (bukan Future lagi) di v7.
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInAsGuest() {
    return _firebaseAuth.signInAnonymously();
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}